#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("../", import.meta.url));
const docsRoot = path.join(repositoryRoot, "docs", "en-US");
const catalogs = new Map([
  ["pwsh7", "upstream/pwsh7.json"],
  ["pwsh51", "upstream/pwsh51.json"],
  ["pwsh-cli", "upstream/cli.json"]
]);
const statuses = new Map([
  ["planned", 0],
  ["draft", 1],
  ["reviewed", 2],
  ["verified", 3]
]);
const platforms = new Set(["windows", "linux", "macos"]);
const errors = [];
const warnings = [];
let checkedDocuments = 0;
const options = parseArguments(process.argv.slice(2));

function parseArguments(argumentsList) {
  const parsed = {
    mantBin: process.env.MANT_BIN || "mant",
    release: undefined,
    skipMant: false
  };
  for (let index = 0; index < argumentsList.length; index += 1) {
    const argument = argumentsList[index];
    if (argument === "--skip-mant") {
      parsed.skipMant = true;
    } else if (argument === "--release" || argument === "--mant") {
      const value = argumentsList[index + 1];
      if (value === undefined || value.startsWith("--")) {
        errors.push(`${argument} requires a value.`);
      } else if (argument === "--release") {
        parsed.release = value;
        index += 1;
      } else {
        parsed.mantBin = value;
        index += 1;
      }
    } else if (argument === "--help" || argument === "-h") {
      printUsage();
      process.exit(0);
    } else {
      errors.push(`Unknown argument: ${argument}`);
    }
  }
  return parsed;
}

function printUsage() {
  console.log(`Usage: node tools/validate.mjs [options]

Options:
  --release NAME  Enforce release/NAME.json in addition to published documents.
  --skip-mant     Skip invoking the installed ManT executable.
  --mant PATH     Use PATH instead of the mant command or MANT_BIN value.
  -h, --help      Show this help text.`);
}

function relative(file) {
  return path.relative(repositoryRoot, file).split(path.sep).join("/");
}

function reportError(message) {
  errors.push(message);
}

function readJson(relativePath) {
  const file = path.join(repositoryRoot, relativePath);
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (cause) {
    reportError(`${relativePath}: invalid JSON (${cause.message}).`);
    return undefined;
  }
}

function sorted(items) {
  return [...items].sort((left, right) => left.localeCompare(right, "en"));
}

function sameMembers(left, right) {
  return JSON.stringify(sorted(left)) === JSON.stringify(sorted(right));
}

function flatMarkdownFiles(sourceRoot) {
  if (!fs.existsSync(sourceRoot)) {
    return [];
  }
  return fs.readdirSync(sourceRoot, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
    .map((entry) => entry.name)
    .sort((left, right) => left.localeCompare(right, "en"));
}

function validateSourceDirectory(sourceRoot) {
  if (!fs.existsSync(sourceRoot)) {
    reportError(`${relative(sourceRoot)}: source directory does not exist.`);
    return [];
  }
  const lowerNames = new Map();
  for (const entry of fs.readdirSync(sourceRoot, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      reportError(`${relative(sourceRoot)}: nested directory ${entry.name} is not allowed; ManT sources are flat.`);
      continue;
    }
    if (!entry.isFile() || !entry.name.endsWith(".md")) {
      continue;
    }
    if (/[<>:"/\\|?*]/u.test(entry.name) || /[. ]$/u.test(entry.name)) {
      reportError(`${relative(sourceRoot)}/${entry.name}: filename is not portable across supported platforms.`);
    }
    const lowered = entry.name.toLocaleLowerCase("en-US");
    const earlier = lowerNames.get(lowered);
    if (earlier !== undefined) {
      reportError(`${relative(sourceRoot)}: ${earlier} and ${entry.name} collide on case-insensitive filesystems.`);
    } else {
      lowerNames.set(lowered, entry.name);
    }
  }
  return flatMarkdownFiles(sourceRoot);
}

function validateTldr(file, lines) {
  const startMarker = "<!-- mant:tldr:start -->";
  const endMarker = "<!-- mant:tldr:end -->";
  const startLines = lines.flatMap((line, index) => line.trim() === startMarker ? [index] : []);
  const endLines = lines.flatMap((line, index) => line.trim() === endMarker ? [index] : []);
  if (startLines.length === 0 && endLines.length === 0) {
    return lines;
  }
  if (startLines.length !== 1 || endLines.length !== 1) {
    reportError(`${relative(file)}: tldr markers must occur exactly once each.`);
    return lines;
  }
  const [startLine] = startLines;
  const [endLine] = endLines;
  if (lines.findIndex((line) => line.trim() !== "") !== startLine) {
    reportError(`${relative(file)}: tldr start marker must be the first non-empty line.`);
  }
  if (endLine <= startLine + 1) {
    reportError(`${relative(file)}: tldr preface cannot be empty.`);
  }
  if (endLine < startLine) {
    reportError(`${relative(file)}: tldr end marker occurs before its start marker.`);
    return lines;
  }
  const tldrHeadings = lines.slice(startLine + 1, endLine).filter((line) => /^# (?!#)/u.test(line));
  if (tldrHeadings.length !== 1) {
    reportError(`${relative(file)}: tldr preface must contain exactly one level-one title.`);
  }
  return lines.slice(endLine + 1);
}

function validateLocalLinks(file, sourceRoot, body) {
  for (const match of body.matchAll(/\[[^\]]+\]\(([^)]+)\)/gu)) {
    const target = match[1].trim();
    if (/^[a-z][a-z0-9+.-]*:/iu.test(target) || target.startsWith("#")) {
      continue;
    }
    const pathPart = target.split("#", 1)[0];
    if (!pathPart.endsWith(".md")) {
      continue;
    }
    if (pathPart.includes("/") || pathPart.includes("\\") || pathPart.includes("..")) {
      reportError(`${relative(file)}: local link ${target} must use a flat filename only.`);
    } else if (!fs.existsSync(path.join(sourceRoot, pathPart))) {
      reportError(`${relative(file)}: local link ${target} does not exist in this source.`);
    }
  }
}

function validateMarkdown(file, sourceRoot) {
  const lines = fs.readFileSync(file, "utf8").replace(/^\uFEFF/u, "").split(/\r?\n/u);
  const bodyLines = validateTldr(file, lines);
  const body = bodyLines.join("\n");
  if (bodyLines.filter((line) => /^# (?!#)/u.test(line)).length !== 1) {
    reportError(`${relative(file)}: document body must contain exactly one level-one title.`);
  }
  const sourcesIndex = bodyLines.findIndex((line) => line.trim() === "## Sources and license");
  if (sourcesIndex === -1) {
    reportError(`${relative(file)}: missing '## Sources and license' section.`);
  } else if (!/https:\/\//u.test(bodyLines.slice(sourcesIndex + 1).join("\n"))) {
    reportError(`${relative(file)}: sources section must include an HTTPS authoritative link.`);
  }
  validateLocalLinks(file, sourceRoot, body);
  checkedDocuments += 1;
}

function validateLicense(license, context) {
  if (license === null || typeof license !== "object") {
    reportError(`${context}: missing license object.`);
    return;
  }
  if (typeof license.spdx !== "string" || license.spdx.length === 0) {
    reportError(`${context}: license SPDX identifier is required.`);
  }
  if (typeof license.url !== "string" || !license.url.startsWith("https://")) {
    reportError(`${context}: license URL must use HTTPS.`);
  }
}

function validateCatalog(sourceName, catalogPath, actualDocuments) {
  const catalog = readJson(catalogPath);
  if (catalog === undefined) {
    return undefined;
  }
  const expectedRoot = `docs/en-US/${sourceName}`;
  if (catalog.schemaVersion !== 1) {
    reportError(`${catalogPath}: schemaVersion must be 1.`);
  }
  if (catalog.source?.id !== sourceName || catalog.source?.root !== expectedRoot) {
    reportError(`${catalogPath}: source id and root must identify ${expectedRoot}.`);
  }
  if (catalog.baselines === null || typeof catalog.baselines !== "object") {
    reportError(`${catalogPath}: baselines must be an object.`);
  } else {
    for (const [name, baseline] of Object.entries(catalog.baselines)) {
      const context = `${catalogPath}: baseline ${name}`;
      if (baseline?.type !== "git") {
        reportError(`${context} must be a git baseline.`);
      }
      if (typeof baseline?.repository !== "string" || !baseline.repository.startsWith("https://")) {
        reportError(`${context} repository must use HTTPS.`);
      }
      if (typeof baseline?.branch !== "string" || baseline.branch.length === 0) {
        reportError(`${context} branch is required.`);
      }
      if (typeof baseline?.revision !== "string" || !/^[0-9a-f]{40}$/u.test(baseline.revision)) {
        reportError(`${context} revision must be a 40-character lowercase Git commit.`);
      }
      if (typeof baseline?.retrievedAt !== "string" || !/^\d{4}-\d{2}-\d{2}$/u.test(baseline.retrievedAt)) {
        reportError(`${context} retrievedAt must be an ISO date.`);
      }
      validateLicense(baseline?.license, context);
    }
  }
  if (catalog.documents === null || typeof catalog.documents !== "object") {
    reportError(`${catalogPath}: documents must be an object.`);
    return catalog;
  }
  if (!sameMembers(actualDocuments, Object.keys(catalog.documents))) {
    reportError(`${catalogPath}: catalog documents must exactly match ${expectedRoot}.`);
  }
  for (const [filename, document] of Object.entries(catalog.documents)) {
    const context = `${catalogPath}: ${filename}`;
    if (!filename.endsWith(".md")) {
      reportError(`${context}: document key must end with .md.`);
    }
    if (typeof document?.kind !== "string" || document.kind.length === 0) {
      reportError(`${context}: kind is required.`);
    }
    if (!statuses.has(document?.status)) {
      reportError(`${context}: invalid status ${String(document?.status)}.`);
    }
    if (!Array.isArray(document?.versions) || document.versions.length === 0) {
      reportError(`${context}: versions must be a non-empty array.`);
    }
    if (!Array.isArray(document?.platforms) || document.platforms.length === 0) {
      reportError(`${context}: platforms must be a non-empty array.`);
    } else {
      for (const platform of document.platforms) {
        if (!platforms.has(platform)) {
          reportError(`${context}: unsupported platform ${platform}.`);
        }
      }
    }
    if (!Array.isArray(document?.sources) || document.sources.length === 0) {
      reportError(`${context}: sources must be a non-empty array.`);
      continue;
    }
    for (const source of document.sources) {
      if (source?.type === "git") {
        if (typeof source.baseline !== "string" || catalog.baselines?.[source.baseline] === undefined) {
          reportError(`${context}: git source references an unknown baseline.`);
        }
        if (typeof source.path !== "string" || source.path.length === 0) {
          reportError(`${context}: git source path is required.`);
        }
      } else if (source?.type === "web") {
        if (typeof source.url !== "string" || !source.url.startsWith("https://")) {
          reportError(`${context}: web source URL must use HTTPS.`);
        }
        validateLicense(source.license, context);
      } else {
        reportError(`${context}: source type must be git or web.`);
      }
    }
  }
  return catalog;
}

function validateRelease(name, sourceData) {
  const manifestPath = `release/${name}.json`;
  const manifest = readJson(manifestPath);
  if (manifest === undefined) {
    return;
  }
  if (manifest.release !== name || manifest.locale !== "en-US") {
    reportError(`${manifestPath}: release name and locale must match the requested English release.`);
  }
  if (manifest.sources === null || typeof manifest.sources !== "object") {
    reportError(`${manifestPath}: sources must be an object.`);
    return;
  }
  const minimumStatus = statuses.get(manifest.releaseRequirements?.minimumDocumentStatus);
  if (minimumStatus === undefined) {
    reportError(`${manifestPath}: releaseRequirements.minimumDocumentStatus is invalid.`);
  }
  let count = 0;
  for (const [sourceName, requirement] of Object.entries(manifest.sources)) {
    const current = sourceData.get(sourceName);
    if (current === undefined) {
      reportError(`${manifestPath}: unknown source ${sourceName}.`);
      continue;
    }
    if (!Array.isArray(requirement?.runtimePlatforms) || requirement.runtimePlatforms.length === 0) {
      reportError(`${manifestPath}: ${sourceName} runtimePlatforms must be non-empty.`);
    } else {
      for (const platform of requirement.runtimePlatforms) {
        if (!platforms.has(platform)) {
          reportError(`${manifestPath}: ${sourceName} has unsupported runtime platform ${platform}.`);
        }
      }
    }
    if (!Array.isArray(requirement?.documents)) {
      reportError(`${manifestPath}: ${sourceName} documents must be an array.`);
      continue;
    }
    if (new Set(requirement.documents).size !== requirement.documents.length) {
      reportError(`${manifestPath}: ${sourceName} contains duplicate document names.`);
    }
    count += requirement.documents.length;
    for (const filename of requirement.documents) {
      if (!/^[^/\\]+\.md$/u.test(filename)) {
        reportError(`${manifestPath}: ${sourceName}/${filename} is not a flat Markdown filename.`);
        continue;
      }
      const document = current.catalog?.documents?.[filename];
      if (!current.actualDocuments.includes(filename)) {
        reportError(`${manifestPath}: required document ${sourceName}/${filename} does not exist.`);
      }
      if (document === undefined) {
        reportError(`${manifestPath}: required document ${sourceName}/${filename} has no provenance record.`);
      } else if (minimumStatus !== undefined && statuses.get(document.status) < minimumStatus) {
        reportError(`${manifestPath}: ${sourceName}/${filename} must be at least ${manifest.releaseRequirements.minimumDocumentStatus}.`);
      }
    }
  }
  if (count !== manifest.requiredDocumentCount) {
    reportError(`${manifestPath}: requiredDocumentCount does not match the source lists.`);
  }
}

function validateMant(documents) {
  if (options.skipMant) {
    warnings.push("ManT invocation skipped by --skip-mant.");
    return;
  }
  const version = spawnSync(options.mantBin, ["--version"], {
    cwd: repositoryRoot,
    encoding: "utf8",
    timeout: 20_000
  });
  if (version.status !== 0) {
    reportError(`Unable to run ${options.mantBin} --version. Install ManT or use --skip-mant for structural checks.`);
    return;
  }
  for (const file of documents) {
    const result = spawnSync(options.mantBin, [relative(file), "--format", "json", "--compact"], {
      cwd: repositoryRoot,
      encoding: "utf8",
      timeout: 20_000
    });
    if (result.status !== 0) {
      reportError(`${relative(file)}: ManT could not parse this document (${result.stderr.trim() || "no diagnostic"}).`);
      continue;
    }
    try {
      const output = JSON.parse(result.stdout);
      if (output?.schema !== "mant.query/v4" || output.document === undefined) {
        reportError(`${relative(file)}: ManT JSON output was not a document query result.`);
      } else if (output.diagnostics !== undefined && (!Array.isArray(output.diagnostics) || output.diagnostics.length !== 0)) {
        reportError(`${relative(file)}: ManT reported ${output.diagnostics.length} diagnostic(s).`);
      }
    } catch (cause) {
      reportError(`${relative(file)}: ManT returned invalid JSON (${cause.message}).`);
    }
  }
}

const sourceData = new Map();
const allDocuments = [];
for (const [sourceName, catalogPath] of catalogs) {
  const sourceRoot = path.join(docsRoot, sourceName);
  const actualDocuments = validateSourceDirectory(sourceRoot);
  for (const filename of actualDocuments) {
    const file = path.join(sourceRoot, filename);
    validateMarkdown(file, sourceRoot);
    allDocuments.push(file);
  }
  sourceData.set(sourceName, {
    actualDocuments,
    catalog: validateCatalog(sourceName, catalogPath, actualDocuments)
  });
}
if (options.release !== undefined) {
  validateRelease(options.release, sourceData);
}
validateMant(allDocuments);

for (const message of warnings) {
  console.warn(`warning: ${message}`);
}
if (errors.length > 0) {
  for (const message of errors) {
    console.error(`error: ${message}`);
  }
  console.error(`Validation failed with ${errors.length} error(s).`);
  process.exitCode = 1;
} else {
  console.log(`Validated ${checkedDocuments} published document(s) across ${catalogs.size} source(s).`);
  if (options.release !== undefined) {
    console.log(`Release manifest ${options.release} passed.`);
  }
}
