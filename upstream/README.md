# Upstream provenance

This directory records authoritative source URLs, revisions, product
versions, licenses, and verification status. It does not contain vendored
upstream prose or cached MCP responses.

## Catalogs

- `pwsh51.json` covers `docs/en-US/pwsh51/`.
- `pwsh7.json` covers `docs/en-US/pwsh7/`.
- `cli.json` covers `docs/en-US/pwsh-cli/`.
- `windows-command-index.json` records every top-level entry in the locked
  Microsoft Windows Commands A-Z index and its current coverage classification.
- `schema.json` defines the common catalog format.

Each catalog has three layers:

1. `source` identifies the published ManT source and its version policy.
2. `baselines` lock upstream Git repositories to exact revisions and record
   their licenses.
3. `documents` map each published Markdown filename to the material used to
   write or verify it.

Git branches are recorded for maintainers, but a 40-character revision is the
reproducible reference. Update a revision only after reviewing the relevant
upstream changes. A page can cite a locked Git path, an authoritative web
page, or both.

## Verification states

- `planned`: the filename is reserved but the document is not published.
- `draft`: the document is useful but has not completed source and runtime
  review.
- `reviewed`: its claims and attribution have been reviewed against the
  recorded sources.
- `verified`: relevant examples have also been exercised on every declared
  version and platform, or the catalog notes an explicit exception.

## MCP discovery

An MCP server is a discovery channel, not an upstream source by itself. A
catalog may record an optional MCP service under `discovery`, together with
its purpose and official documentation. When an MCP tool returns useful
material, record the final Microsoft Learn or vendor page under the affected
document's `sources`; do not store the response or attribute every result to
the MCP server's repository license.

The catalogs and schema are hand-maintained source files. Portable validation
must use dependency-free Node.js ESM and must not require a network request.

## Windows command coverage index

`windows-command-index.json` is the audit ledger for broad Windows in-box
command coverage. Its baseline revision must match `cli.json`. Entries begin as
`unclassified` and are changed only after review:

- `documented`: an independent ManT page covers the command.
- `family`: a named command-family page or section covers the entry.
- `alias`: a canonical command page covers the equivalent spelling.
- `legacy`: the project records its deprecated, removed, or compatibility-only
  status and any authoritative replacement.
- `excluded`: evidence shows the indexed entry is not a Windows in-box command
  applicable to the declared scope; the reason must be recorded separately.

The Windows CLI coverage goal is not complete while any entry remains
`unclassified`. The index records upstream names and paths, not copied upstream
prose.
