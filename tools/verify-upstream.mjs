#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("../", import.meta.url));
const allCatalogPaths = [
  "upstream/pwsh7.json",
  "upstream/pwsh51.json",
  "upstream/windows-tools.json",
  "upstream/cross-platform-tools.json"
];
const catalogAliases = new Map(allCatalogPaths.map((catalogPath) => [
  path.basename(catalogPath, ".json"),
  catalogPath
]));
const requestedCatalogs = [];
let showProgress = false;
let countOnly = false;
for (let index = 2; index < process.argv.length; index += 1) {
  const argument = process.argv[index];
  if (argument === "--help" || argument === "-h") {
    console.log("Usage: verify-upstream.mjs [--catalog NAME]... [--progress] [--count-only]");
    console.log(`Catalog names: ${[...catalogAliases.keys()].join(", ")}`);
    process.exit(0);
  }
  if (argument === "--progress") {
    showProgress = true;
    continue;
  }
  if (argument === "--count-only") {
    countOnly = true;
    continue;
  }
  if (argument === "--catalog") {
    const value = process.argv[index + 1];
    if (value === undefined || value.startsWith("-")) {
      console.error("error: --catalog requires a catalog name.");
      process.exit(2);
    }
    requestedCatalogs.push(value);
    index += 1;
    continue;
  }
  if (argument.startsWith("--catalog=")) {
    requestedCatalogs.push(argument.slice("--catalog=".length));
    continue;
  }
  console.error(`error: unknown argument ${argument}.`);
  process.exit(2);
}
const catalogPaths = requestedCatalogs.length === 0
  ? allCatalogPaths
  : [...new Set(requestedCatalogs.map((name) => {
      const catalogPath = catalogAliases.get(name);
      if (catalogPath === undefined) {
        console.error(`error: unknown catalog ${name}.`);
        process.exit(2);
      }
      return catalogPath;
    }))];
const concurrency = 8;
const timeoutSeconds = 20;
const maxCapturedBodyBytes = 8 * 1024 * 1024;
const errors = [];
const targets = new Map();

function fail(message) {
  errors.push(message);
}

function loadCatalog(relativePath) {
  try {
    return JSON.parse(fs.readFileSync(path.join(repositoryRoot, relativePath), "utf8"));
  } catch (cause) {
    fail(`${relativePath}: invalid JSON (${cause.message}).`);
    return undefined;
  }
}

function rawGitHubUrl(baseline, sourcePath) {
  const match = /^https:\/\/github\.com\/([^/]+)\/([^/]+?)(?:\.git)?$/u.exec(baseline.repository);
  if (match === null) {
    return undefined;
  }
  const encodedPath = sourcePath.split("/").map(encodeURIComponent).join("/");
  return `https://raw.githubusercontent.com/${match[1]}/${match[2]}/${baseline.revision}/${encodedPath}`;
}

function gitHubContentsUrl(baseline, sourcePath) {
  const match = /^https:\/\/github\.com\/([^/]+)\/([^/]+?)(?:\.git)?$/u.exec(baseline.repository);
  if (match === null) {
    return undefined;
  }
  const encodedPath = sourcePath === "." ? "" : `/${sourcePath.split("/").map(encodeURIComponent).join("/")}`;
  return `https://api.github.com/repos/${match[1]}/${match[2]}/contents${encodedPath}?ref=${baseline.revision}`;
}

function addTarget(label, url) {
  const labels = targets.get(url);
  if (labels === undefined) {
    targets.set(url, [label]);
  } else {
    labels.push(label);
  }
}

function webAuditUrl(url) {
  let parsed;
  try {
    parsed = new URL(url);
  } catch {
    return url;
  }
  if (parsed.hostname !== "stackoverflow.com" && parsed.hostname !== "www.stackoverflow.com") {
    return url;
  }
  const question = /^\/questions\/(\d+)(?:\/|$)/u.exec(parsed.pathname)?.[1];
  if (question === undefined) {
    return url;
  }
  const query = new URLSearchParams({
    question,
    service: "stackoverflow",
    language: "en",
    hideAnswers: "false",
    showAll: "true",
    width: "640"
  });
  return `https://stackprinter.appspot.com/export?${query}`;
}

for (const catalogPath of catalogPaths) {
  const catalog = loadCatalog(catalogPath);
  if (catalog === undefined) {
    continue;
  }
  for (const [filename, document] of Object.entries(catalog.documents ?? {})) {
    for (const source of document.sources ?? []) {
      const label = `${catalogPath}: ${filename}`;
      if (source.type === "web") {
        // Stack Overflow blocks unattended curl requests with HTTP 403. Its
        // read-only Stack Printer endpoint provides a stable, auditable view
        // while reader-facing pages continue to link the canonical question.
        addTarget(label, webAuditUrl(source.url));
      } else if (source.type === "git") {
        const baseline = catalog.baselines?.[source.baseline];
        if (baseline === undefined) {
          fail(`${label}: unknown baseline ${String(source.baseline)}.`);
          continue;
        }
        const directorySource = source.path === "." || path.posix.extname(source.path) === "";
        const url = directorySource
          ? gitHubContentsUrl(baseline, source.path)
          : rawGitHubUrl(baseline, source.path);
        if (url === undefined) {
          fail(`${label}: cannot derive a raw GitHub URL from ${baseline.repository}.`);
        } else {
          addTarget(label, url);
        }
      } else {
        fail(`${label}: unsupported source type ${String(source.type)}.`);
      }
    }
  }
}

async function checkTarget(url, labels) {
  const parsed = new URL(url);
  const fragment = decodeURIComponent(parsed.hash.slice(1));
  parsed.hash = "";
  const fetchUrl = parsed.toString();
  const runCurl = (headOnly, captureBody = false) => new Promise((resolve) => {
    const args = [
      "--silent",
      "--show-error",
      "--location",
      "--fail",
      "--max-time",
      String(timeoutSeconds),
      "--user-agent",
      "mant-pwsh-docs-upstream-audit/1.0"
    ];
    if (headOnly) {
      args.push("--head");
    } else if (!captureBody) {
      args.push("--range", "0-0");
    } else {
      // Fragment validation needs the page body, but an upstream server must
      // not be able to make this editorial audit retain an unbounded response.
      args.push("--max-filesize", String(maxCapturedBodyBytes));
    }
    args.push(fetchUrl);
    const child = spawn(process.env.CURL_BIN || "curl", args, {
      stdio: ["ignore", captureBody ? "pipe" : "ignore", "pipe"]
    });
    let stderr = "";
    const stdoutChunks = [];
    let stdoutBytes = 0;
    let bodyTooLarge = false;
    if (captureBody) {
      child.stdout.on("data", (chunk) => {
        stdoutBytes += chunk.length;
        if (stdoutBytes > maxCapturedBodyBytes) {
          bodyTooLarge = true;
          child.kill();
          return;
        }
        stdoutChunks.push(chunk);
      });
    }
    child.stderr.setEncoding("utf8");
    child.stderr.on("data", (chunk) => { stderr += chunk; });
    child.on("error", (cause) => resolve({
      cause,
      stderr,
      stdout: Buffer.concat(stdoutChunks).toString("utf8"),
      bodyTooLarge
    }));
    child.on("close", (status) => resolve({
      status,
      stderr,
      stdout: Buffer.concat(stdoutChunks).toString("utf8"),
      bodyTooLarge
    }));
  });
  let result = await runCurl(fragment.length === 0, fragment.length > 0);
  if (result.cause === undefined && result.status !== 0) {
    // Some valid documentation servers reject or mishandle HEAD. A one-byte
    // range request provides a bounded GET fallback; servers that ignore the
    // range still stream to a discarded stdout rather than repository files.
    result = await runCurl(false, fragment.length > 0);
  }
  if (result.bodyTooLarge || result.status === 63) {
    fail(`${labels.join(", ")}: ${url} exceeded the ${maxCapturedBodyBytes}-byte fragment-validation limit.`);
  } else if (result.cause !== undefined) {
    fail(`${labels.join(", ")}: ${url} could not start curl (${result.cause.message}).`);
  } else if (result.status !== 0) {
    fail(`${labels.join(", ")}: ${url} could not be fetched (${result.stderr.trim() || `curl exited ${result.status}`}).`);
  } else if (fragment.length > 0) {
    const escaped = fragment.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
    const anchor = new RegExp(`\\b(?:id|name)=["']${escaped}["']`, "u");
    if (!anchor.test(result.stdout)) {
      fail(`${labels.join(", ")}: ${url} returned a page without the requested fragment target.`);
    }
  }
}

const entries = [...targets.entries()];
if (countOnly) {
  for (const error of errors) {
    console.error(`error: ${error}`);
  }
  console.log(`Found ${entries.length} unique upstream source URL(s).`);
  process.exit(errors.length > 0 ? 1 : 0);
}
let cursor = 0;
let completed = 0;
let nextProgress = 25;
const reportProgress = () => {
  if (!showProgress) {
    return;
  }
  completed += 1;
  if (completed >= nextProgress || completed === entries.length) {
    console.error(`progress: checked ${completed}/${entries.length} upstream source URL(s).`);
    nextProgress += 25;
  }
};
async function worker() {
  while (cursor < entries.length) {
    const [url, labels] = entries[cursor];
    cursor += 1;
    await checkTarget(url, labels);
    reportProgress();
  }
}

await Promise.all(Array.from({ length: Math.min(concurrency, entries.length) }, worker));

if (errors.length > 0) {
  for (const error of errors) {
    console.error(`error: ${error}`);
  }
  console.error(`Upstream verification failed with ${errors.length} error(s).`);
  process.exitCode = 1;
} else {
  console.log(`Verified ${entries.length} unique upstream source URL(s).`);
}
