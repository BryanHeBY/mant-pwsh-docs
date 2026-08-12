# Repository tools

Maintenance and validation tools are cross-platform and dependency-free at the
repository level. `tools/validate.mjs` runs on Node.js 20 or newer and checks:

- flat, portable source filenames and local links;
- canonical Windows entry-point suffixes used by ManT `PATHEXT` lookup;
- optional embedded tldr structure when present;
- explicit fixed-versus-collector-string labels for PE file/product version evidence;
- one document H1 outside fenced code and a reader-facing `Sources and license`
  section;
- provenance catalogs, baseline revisions, licenses, and source references;
- exactly one reader-visible evidence disposition per published page: either
  `Runtime evidence` or `Verification boundary`;
- consistency between a page's `Runtime evidence` section and generic
  runtime-pending provenance notes;
- command-like `New-Item -LiteralPath` lines in published documents and
  runtime fixtures, because neither supported PowerShell edition exposes that
  parameter and syntax parsing alone cannot detect the binding error;
- ManT v6 JSON diagnostics for every currently published document.

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
release work must run the normal command. GitHub Actions runs the normal ManT
0.6.4-backed validation on pushes, pull requests, and manual dispatch across
Ubuntu, macOS, and Windows. The Windows job also runs the protected Cmd builtin
behavior fixture through both Windows PowerShell and pwsh. Use
`npm run validate:release` before creating
`v0.6.0` to enforce the full release manifest in `release/v0.6.0.json`.

`npm run validate:upstream` is a separate networked editorial audit. It checks
that every locked Git source path and every web source URL in the provenance
catalogs is reachable. For a web source containing `#fragment`, it also fetches
that page and requires a matching HTML `id` or legacy `name`; an HTTP 200 alone
does not prove a deep link works. Because Stack Overflow blocks unattended requests to
canonical question pages, the audit checks the corresponding read-only Stack
Printer representation while documents retain the canonical reader link. The
normal validators intentionally remain offline so they work in restricted or
air-gapped environments; upstream verification is not a document-reading
dependency.

During a source-specific review, pass one or more catalog names to verify only
that locked subset without weakening the default full audit:

```powershell
node tools/verify-upstream.mjs --catalog pwsh7
node tools/verify-upstream.mjs --catalog pwsh7 --catalog pwsh51
node tools/verify-upstream.mjs --progress
node tools/verify-upstream.mjs --count-only
```

Accepted names are `pwsh7`, `pwsh51`, `windows-tools`, and
`cross-platform-tools`. Omitting `--catalog` continues to verify every catalog.
`--progress` writes one low-volume status line after every 25 checked unique
URLs (and at completion), so a slow full network audit remains observable
without changing its result or default quiet output.
`--count-only` performs the same catalog validation, URL derivation,
Stack Overflow-to-Stack Printer mapping, and deduplication, then reports the
target count without starting curl or making a network request.

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
