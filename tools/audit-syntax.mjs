#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("../", import.meta.url));
const sourceNames = ["pwsh7", "pwsh51", "windows-tools", "cross-platform-tools"];
const interfaceHeading = /^(?:syntax|synopsis|syntax and status|(?:query|add and delete|common|important) parameters|(?:important )?options)$/iu;
const options = parseArguments(process.argv.slice(2));

function parseArguments(argumentsList) {
  const parsed = { json: false, mantBin: process.env.MANT_BIN || "mant" };
  for (let index = 0; index < argumentsList.length; index += 1) {
    const argument = argumentsList[index];
    if (argument === "--json") {
      parsed.json = true;
    } else if (argument === "--mant") {
      const value = argumentsList[index + 1];
      if (value === undefined || value.startsWith("--")) {
        fail("--mant requires a value.");
      }
      parsed.mantBin = value;
      index += 1;
    } else if (argument === "--help" || argument === "-h") {
      console.log(`Usage: node tools/audit-syntax.mjs [options]

Compare option-shaped tokens in concise syntax fences with ManT option entries.
Only the first fence in a recognized interface section is inspected, so examples
that invoke other commands do not become false interface requirements.

Options:
  --mant PATH   Use PATH instead of the mant command or MANT_BIN value.
  --json        Emit a machine-readable report.
  -h, --help    Show this help text.`);
      process.exit(0);
    } else {
      fail(`Unknown argument: ${argument}`);
    }
  }
  return parsed;
}

function fail(message) {
  console.error(`error: ${message}`);
  process.exit(2);
}

function childDiagnostic(result, fallback) {
  const stderr = typeof result.stderr === "string" ? result.stderr.trim() : "";
  if (stderr) return stderr;
  if (result.error?.message) return result.error.message;
  if (result.signal) return `ManT terminated by signal ${result.signal}`;
  return fallback;
}

function collectEntries(nodes, output = []) {
  for (const node of nodes) {
    if (node.kind === "document-entry") output.push(node);
    if (Array.isArray(node.children)) collectEntries(node.children, output);
  }
  return output;
}

function normalize(token) {
  let value = token.replace(/[),;\]}]+$/u, "");
  value = value.replace(
    /[:=](?:PATH|FILE|NAME|VALUE|TEXT|NUMBER|SECONDS|COUNT|TYPE|URI|URL|HOST|TARGET|DIRECTORY|DIR|COMMAND|SPECIFICATION)$/iu,
    ""
  );
  return value.toLocaleLowerCase("en-US");
}

function syntaxTokens(markdown) {
  const tokens = new Set();
  let heading = "";
  let fenced = false;
  let relevant = false;
  let consumed = false;
  for (const line of markdown.split(/\r?\n/u)) {
    const headingMatch = line.match(/^##+\s+(.+)$/u);
    if (headingMatch) {
      heading = headingMatch[1];
      consumed = false;
    }
    if (/^```/u.test(line)) {
      if (!fenced) {
        relevant = !consumed && interfaceHeading.test(heading);
        if (relevant) consumed = true;
        fenced = true;
      } else {
        fenced = false;
        relevant = false;
      }
      continue;
    }
    if (!fenced || !relevant) continue;
    const expression = /(?<![\w.])(?:--?[A-Za-z][A-Za-z0-9-]*|\/{1,2}(?:-?[A-Za-z][A-Za-z0-9.+-]*|\?)(?::(?:32|64))?)/gu;
    for (const tokenMatch of line.matchAll(expression)) {
      tokens.add(normalize(tokenMatch[0]));
    }
  }
  return tokens;
}

function mantOptionNames(relativePath) {
  const result = spawnSync(
    options.mantBin,
    ["--input", relativePath, "--outline=entries", "--format", "json", "--compact"],
    {
      cwd: repositoryRoot,
      encoding: "utf8",
      maxBuffer: 16 * 1024 * 1024,
      timeout: 20_000
    }
  );
  if (result.status !== 0) {
    fail(`${relativePath}: ${childDiagnostic(result, `ManT exited with status ${String(result.status)}`)}`);
  }
  let outline;
  try {
    outline = JSON.parse(result.stdout);
  } catch (cause) {
    fail(`${relativePath}: ManT returned invalid JSON (${cause.message}).`);
  }
  if (outline?.schema !== "mant.outline/v7" || !Array.isArray(outline.nodes)) {
    fail(`${relativePath}: expected mant.outline/v7; received ${outline?.schema || "no schema"}.`);
  }
  return new Set(
    collectEntries(outline.nodes)
      .filter((entry) => entry.role === "option")
      .flatMap((entry) => entry.names || [])
      .map(normalize)
  );
}

const gaps = [];
let syntaxDocumentCount = 0;
for (const sourceName of sourceNames) {
  const catalog = JSON.parse(
    fs.readFileSync(path.join(repositoryRoot, "upstream", `${sourceName}.json`), "utf8")
  );
  for (const filename of Object.keys(catalog.documents)) {
    const relativePath = `docs/en-US/${sourceName}/${filename}`;
    const markdown = fs.readFileSync(path.join(repositoryRoot, relativePath), "utf8");
    const tokens = syntaxTokens(markdown);
    if (tokens.size === 0) continue;
    syntaxDocumentCount += 1;
    const names = mantOptionNames(relativePath);
    const missing = [...tokens].filter((token) =>
      !names.has(token) && ![...names].some((name) => name.startsWith(`${token}:`))
    ).sort();
    if (missing.length > 0) {
      gaps.push({ declaredOptions: names.size, missing, path: relativePath });
    }
  }
}

gaps.sort((left, right) =>
  right.missing.length - left.missing.length || left.path.localeCompare(right.path, "en")
);
const report = {
  schema: "mant-pwsh-docs.syntax-audit/v1",
  summary: { gapCount: gaps.length, syntaxDocumentCount },
  gaps
};

if (options.json) {
  console.log(JSON.stringify(report, null, 2));
} else {
  console.log(`Audited concise syntax fences in ${syntaxDocumentCount} documents; found ${gaps.length} option-entry gap(s).`);
  for (const gap of gaps) {
    console.log(`  ${gap.path}: ${gap.missing.join(", ")}`);
  }
}
if (gaps.length > 0) process.exitCode = 1;
