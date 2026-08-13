# Release manifests

Release manifests define the expected document set and verification platforms
for a named documentation release. They are repository metadata, not published
ManT documents.

`v0.7.0.json` is the authoritative inventory for the initial English 0.7.0
release. A portable validator will compare the manifest with `docs/en-US/`
and the corresponding `upstream/` catalogs.

The manifest keeps `$schema: release-manifest/v1` because that value versions
the manifest format, while the filename and `release` field version the
documentation bundle.

[v0.7.0-runtime.md](v0.7.0-runtime.md) is the required platform verification
matrix. [v0.7.0-runtime-evidence.md](v0.7.0-runtime-evidence.md) records
collected evidence and makes the remaining platform work explicit.

For this repository, `reviewed` means the document has passed editorial,
provenance, ManT-parse, and locked-upstream accessibility review. `verified`
is stronger: it additionally requires recorded runtime verification on every
platform declared by that document. This distinction keeps Windows-only and
tool-version-specific runtime work visible without blocking a reviewed source
release.
