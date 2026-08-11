# Release manifests

Release manifests define the expected document set and verification platforms
for a named documentation release. They are repository metadata, not published
ManT documents.

`v1.json` is the authoritative inventory for the first English release. A
portable validator will compare the manifest with `docs/en-US/` and the
corresponding `upstream/` catalogs.

[v1-runtime.md](v1-runtime.md) is the required platform verification matrix.
[v1-runtime-evidence.md](v1-runtime-evidence.md) records collected evidence
and makes the remaining platform work explicit.

For this repository, `reviewed` means the document has passed editorial,
provenance, ManT-parse, and locked-upstream accessibility review. `verified`
is stronger: it additionally requires recorded runtime verification on every
platform declared by that document. This distinction keeps Windows-only and
tool-version-specific runtime work visible without blocking a reviewed source
release.
