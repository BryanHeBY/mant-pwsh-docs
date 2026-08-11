# Release manifests

Release manifests define the expected document set and verification platforms
for a named documentation release. They are repository metadata, not published
ManT documents.

`v1.json` is the authoritative inventory for the first English release. A
portable validator will compare the manifest with `docs/en-US/` and the
corresponding `upstream/` catalogs.
