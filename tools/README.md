# Repository tools

Maintenance and validation tools are cross-platform and dependency-free at the
repository level. `tools/validate.mjs` runs on Node.js 20 or newer and checks:

- flat, portable source filenames and local links;
- optional embedded tldr structure when present;
- one document H1 and a reader-facing `Sources and license` section;
- provenance catalogs, baseline revisions, licenses, and source references;
- ManT v5 JSON diagnostics for every currently published document.

Role-aware interface lists use the explicit `mant:entries` declarations in
`AUTHORING.md`. The validator checks their ManT diagnostics; repository-wide
semantic coverage and content-quality audits are developed as separate,
portable Node.js checks so missing entry lists cannot be hidden by otherwise
valid Markdown.

Run the normal check with:

```text
npm run validate
```

Use `npm run validate:structure` only when ManT is intentionally unavailable;
release work must run the normal command. The GitHub Actions workflow is
manual-only until ManT 0.6.0 is publicly installable in CI. Use
`npm run validate:release` before creating v1 to enforce the full release
manifest in `release/v1.json`.

`npm run validate:upstream` is a separate networked editorial audit. It checks
that every locked Git source path and every web source URL in the provenance
catalogs is reachable. Because Stack Overflow blocks unattended requests to
canonical question pages, the audit checks the corresponding read-only Stack
Printer representation while documents retain the canonical reader link. The
normal validators intentionally remain offline so they work in restricted or
air-gapped environments; upstream verification is not a document-reading
dependency.

Set `MANT_BIN` or pass `--mant PATH` when the ManT executable is not named
`mant`. Platform-specific runtime checks remain separate from this structural
validator.

Run the complete editorial gap inventory with:

```text
npm run audit:content -- --mant PATH
```

The audit reports every document, its ManT semantic entries, and structural
signals such as missing interface summaries, version/availability guidance,
PowerShell boundaries, related documents, or substantial TLDR examples. Use
`--json` for the complete machine-readable matrix and `--strict` only after
all reviewed exceptions and content gaps have been resolved.
