# Repository tools

Maintenance and validation tools are cross-platform and dependency-free at the
repository level. `tools/validate.mjs` runs on Node.js 20 or newer and checks:

- flat, portable source filenames and local links;
- optional embedded tldr structure when present;
- one document H1 and a reader-facing `Sources and license` section;
- provenance catalogs, baseline revisions, licenses, and source references;
- ManT JSON diagnostics for every currently published document.

Run the normal check with:

```text
npm run validate
```

Use `npm run validate:structure` only when ManT is intentionally unavailable;
release work must run the normal command. The GitHub Actions workflow is
manual-only until ManT 0.6.0 is publicly installable in CI. Use
`npm run validate:release` before creating v1 to enforce the full release
manifest in `release/v1.json`.

Set `MANT_BIN` or pass `--mant PATH` when the ManT executable is not named
`mant`. Platform-specific runtime checks remain separate from this structural
validator.
