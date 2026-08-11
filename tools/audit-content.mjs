#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("../", import.meta.url));
const docsRoot = path.join(repositoryRoot, "docs", "en-US");
const sourceNames = ["pwsh7", "pwsh51", "windows-tools", "cross-platform-tools"];
const nonCommandKinds = new Set(["about-topic", "guide", "source-index"]);
const options = parseArguments(process.argv.slice(2));

function parseArguments(argumentsList) {
  const parsed = {
    json: false,
    mantBin: process.env.MANT_BIN || "mant",
    skipMant: false,
    strict: false
  };
  for (let index = 0; index < argumentsList.length; index += 1) {
    const argument = argumentsList[index];
    if (argument === "--json") {
      parsed.json = true;
    } else if (argument === "--skip-mant") {
      parsed.skipMant = true;
    } else if (argument === "--strict") {
      parsed.strict = true;
    } else if (argument === "--mant") {
      const value = argumentsList[index + 1];
      if (value === undefined || value.startsWith("--")) {
        fail("--mant requires a value.");
      }
      parsed.mantBin = value;
      index += 1;
    } else if (argument === "--help" || argument === "-h") {
      console.log(`Usage: node tools/audit-content.mjs [options]

Options:
  --mant PATH   Use PATH instead of the mant command or MANT_BIN value.
  --skip-mant   Report static Markdown signals without querying ManT.
  --json        Emit the complete machine-readable audit.
  --strict      Exit unsuccessfully when any reported content gap remains.
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

function relative(file) {
  return path.relative(repositoryRoot, file).split(path.sep).join("/");
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function markdownBody(source) {
  const start = source.indexOf("<!-- mant:tldr:start -->");
  const endMarker = "<!-- mant:tldr:end -->";
  const end = source.indexOf(endMarker);
  if (start === -1 || end === -1 || end < start) {
    return source;
  }
  return `${source.slice(0, start)}${source.slice(end + endMarker.length)}`;
}

function countMatches(value, expression) {
  return [...value.matchAll(expression)].length;
}

function headings(body) {
  return [...body.matchAll(/^## (.+)$/gmu)].map((match) => match[1].trim());
}

function hasHeading(items, expression) {
  return items.some((heading) => expression.test(heading));
}

function commandOriented(kind) {
  return !nonCommandKinds.has(kind);
}

function expectsSemanticEntries(metadata) {
  const informationalAlias = metadata.kind === "alias"
    && metadata.notes?.some((note) => note.includes("not a claim about a universal alias mapping"));
  return commandOriented(metadata.kind) && !informationalAlias;
}

function needsPowerShellBoundary(sourceName, kind) {
  return commandOriented(kind)
    && (sourceName === "windows-tools" || sourceName === "cross-platform-tools");
}

function collectEntries(nodes, entries = []) {
  for (const node of nodes) {
    if (node.kind === "document-entry") {
      entries.push({
        case: node.case,
        id: node.id,
        names: node.names,
        path: node.path,
        role: node.role
      });
    }
    if (Array.isArray(node.children)) {
      collectEntries(node.children, entries);
    }
  }
  return entries;
}

function mantEntries(file) {
  if (options.skipMant) {
    return { entries: [], skipped: true };
  }
  const result = spawnSync(
    options.mantBin,
    [relative(file), "--outline=entries", "--format", "json", "--compact"],
    {
      cwd: repositoryRoot,
      encoding: "utf8",
      maxBuffer: 16 * 1024 * 1024,
      timeout: 20_000
    }
  );
  if (result.status !== 0) {
    return {
      entries: [],
      error: result.stderr.trim() || `ManT exited with status ${String(result.status)}`
    };
  }
  try {
    const outline = JSON.parse(result.stdout);
    if (outline?.schema !== "mant.outline/v5" || !Array.isArray(outline.nodes)) {
      return { entries: [], error: "ManT did not return a mant.outline/v5 document." };
    }
    return { entries: collectEntries(outline.nodes) };
  } catch (cause) {
    return { entries: [], error: `ManT returned invalid JSON: ${cause.message}` };
  }
}

function auditDocument(sourceName, filename, metadata) {
  const file = path.join(docsRoot, sourceName, filename);
  const source = fs.readFileSync(file, "utf8").replace(/^\uFEFF/u, "");
  const body = markdownBody(source);
  const sectionHeadings = headings(body);
  const semantic = mantEntries(file);
  const directives = countMatches(body, /^<!-- mant:entries role=(option|command|environment-variable) case=(sensitive|insensitive) -->$/gmu);
  const tldrExamples = countMatches(source, /^- .+:$/gmu);
  const lineCount = source.split(/\r?\n/u).length;
  const flags = [];
  const interfaceHeading = hasHeading(
    sectionHeadings,
    /^(?:common )?(?:parameters|options|commands|subcommands|environment(?: variables)?)$/iu
  );

  if (semantic.error !== undefined) {
    flags.push("mant-outline-error");
  }
  if (!options.skipMant && expectsSemanticEntries(metadata) && semantic.entries.length === 0) {
    flags.push("missing-semantic-entries");
  }
  if (commandOriented(metadata.kind) && interfaceHeading && directives === 0) {
    flags.push("undeclared-interface-summary");
  }
  if (commandOriented(metadata.kind)
      && !hasHeading(sectionHeadings, /(?:synopsis|syntax|invocation|meaning|overview)/iu)) {
    flags.push("missing-interface-overview");
  }
  if (!hasHeading(sectionHeadings, /(?:availability|version|platform|compatibility|edition boundar|windows-specific behavior)/iu)) {
    flags.push("missing-version-or-availability");
  }
  if (needsPowerShellBoundary(sourceName, metadata.kind)
      && !hasHeading(sectionHeadings, /^PowerShell(?: behavior| boundaries| considerations| usage)?$/iu)) {
    flags.push("missing-powershell-boundary");
  }
  if (commandOriented(metadata.kind)
      && !hasHeading(sectionHeadings, /^Common mistakes$/iu)) {
    flags.push("missing-common-mistakes");
  }
  if (!hasHeading(sectionHeadings, /^Related documents$/iu)) {
    flags.push("missing-related-documents");
  }
  if (tldrExamples < 2 && commandOriented(metadata.kind)) {
    flags.push("thin-tldr");
  }
  if (lineCount < 70 && commandOriented(metadata.kind)) {
    flags.push("short-command-page");
  }

  return {
    directives,
    entries: semantic.entries,
    flags,
    headings: sectionHeadings,
    kind: metadata.kind,
    lineCount,
    mantError: semantic.error,
    path: relative(file),
    source: sourceName,
    status: metadata.status,
    tldrExamples
  };
}

function summarize(documents) {
  const flags = {};
  const roles = {};
  const sources = {};
  let entryCount = 0;
  let directiveCount = 0;
  for (const document of documents) {
    directiveCount += document.directives;
    entryCount += document.entries.length;
    for (const entry of document.entries) {
      roles[entry.role] = (roles[entry.role] || 0) + 1;
    }
    for (const flag of document.flags) {
      flags[flag] = (flags[flag] || 0) + 1;
    }
    const source = sources[document.source] || {
      documents: 0,
      entries: 0,
      flaggedDocuments: 0
    };
    source.documents += 1;
    source.entries += document.entries.length;
    if (document.flags.length > 0) {
      source.flaggedDocuments += 1;
    }
    sources[document.source] = source;
  }
  return {
    directiveCount,
    documentCount: documents.length,
    entryCount,
    flaggedDocumentCount: documents.filter((document) => document.flags.length > 0).length,
    flags,
    roles,
    sources
  };
}

function printHuman(report) {
  const { summary } = report;
  console.log(`Audited ${summary.documentCount} documents; found ${summary.entryCount} semantic entries from ${summary.directiveCount} explicit declarations.`);
  for (const [source, values] of Object.entries(summary.sources)) {
    console.log(`${source}: ${values.documents} documents, ${values.entries} entries, ${values.flaggedDocuments} flagged.`);
  }
  console.log("\nGap counts:");
  for (const [flag, count] of Object.entries(summary.flags).sort((left, right) => right[1] - left[1])) {
    console.log(`  ${String(count).padStart(3, " ")}  ${flag}`);
  }
  console.log("\nDocuments with the most signals:");
  const ranked = [...report.documents]
    .filter((document) => document.flags.length > 0)
    .sort((left, right) => right.flags.length - left.flags.length || left.path.localeCompare(right.path, "en"));
  for (const document of ranked.slice(0, 80)) {
    console.log(`  ${document.path}: ${document.flags.join(", ")}`);
  }
  if (ranked.length > 80) {
    console.log(`  ... ${ranked.length - 80} more flagged documents; use --json for the complete list.`);
  }
}

const documents = [];
for (const sourceName of sourceNames) {
  const catalog = readJson(path.join(repositoryRoot, "upstream", `${sourceName}.json`));
  for (const filename of Object.keys(catalog.documents).sort((left, right) => left.localeCompare(right, "en"))) {
    documents.push(auditDocument(sourceName, filename, catalog.documents[filename]));
  }
}

const report = {
  schema: "mant-pwsh-docs.content-audit/v1",
  summary: summarize(documents),
  documents
};

if (options.json) {
  console.log(JSON.stringify(report, null, 2));
} else {
  printHuman(report);
}

if (options.strict && report.summary.flaggedDocumentCount > 0) {
  process.exitCode = 1;
}
