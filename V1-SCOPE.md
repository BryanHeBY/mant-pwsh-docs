# Version 1 scope

Version 1 is the first publishable English reference release. It provides a
useful shell and automation baseline rather than attempting to mirror every
upstream Microsoft or vendor page. The normative, machine-readable inventory
is [`release/v1.json`](release/v1.json).

## Included sources

| Source | Required pages | Purpose |
| --- | ---: | --- |
| `pwsh7` | 30 | PowerShell 7 shell, language, common commands, aliases, process/item actions, custom-shorthand guidance, and compatibility guidance. |
| `pwsh51` | 30 | Windows PowerShell 5.1 equivalents, process/item actions, custom-shorthand guidance, and edition-specific behavior. |
| `windows-tools` | 309 | Windows-native and optional executables, Cmd builtins and interactive families, shell/GUI/URI entry points, package and system management, diagnostics, server roles, compatibility and recovery utilities, and optional Microsoft Learn MCP discovery. |
| `cross-platform-tools` | 6 | A dedicated index plus Git, OpenSSH, curl, tar, and .NET CLI guidance for Windows, macOS, and Linux. |
| **Total** | **375** | Current first-release document inventory. |

The two shell manuals, `pwsh7` and `pwsh51`, remain the broad equivalent of a
traditional `sh` manual. The `*-docs` pages are deliberately separate
navigation indexes. Focused pages must link to their relevant shell manual or
index where broader context helps.

## Content boundaries

### PowerShell 7 and Windows PowerShell 5.1

Both sources include a launcher page, a practical set of `about_*` concepts,
command discovery and object-pipeline cmdlets, and frequently encountered
aliases. The names may match across sources, but the documents are authored,
provenanced, and verified separately. A PowerShell 7 test is never evidence
for Windows PowerShell 5.1 behavior.

Each source also includes a compatibility guide. It records the differences
that affect script migration: executable and edition, language syntax,
modules, providers, native command argument and encoding behavior, remoting,
and platform availability.

### Tool sources

The `windows-tools` source contains Windows-specific command-line tools,
builtins, interactive families, GUI and URI entry points, and optional or
legacy utilities. The `cross-platform-tools` source contains separately
installed tools intended for use across Windows, macOS, and Linux. Native-tool
pages must explain exit status, PowerShell quoting and stream handling, and
platform constraints. The `curl` page must distinguish the executable from
the Windows PowerShell alias when both are available.

The Microsoft Learn MCP page is a guide to optional discovery. It must not
make the MCP server a prerequisite for reading, validating, or using any
document.

## Page acceptance requirements

Every required page must:

1. Exist in the source directory and be listed in the corresponding upstream
   catalog.
2. Parse without ManT diagnostics and have valid local links.
3. Include a clear H1, useful examples, version/platform constraints, and a
   `Sources and license` section. An embedded tldr preface remains strongly
   recommended, not mandatory.
4. Cite reader-facing authoritative sources in the Markdown page and record
   precise source paths, revision, and license in the catalog.
5. Reach `reviewed` status before release. Runtime-sensitive pages also need
   the platform evidence specified by the manifest before they can be marked
   `verified`.

## Release gates

The v1 tag may be created only when:

- all 375 manifest documents exist and pass portable validation;
- every document is at least `reviewed` in its provenance catalog;
- PowerShell 7 runtime checks pass on Windows, Linux, and macOS;
- Windows PowerShell 5.1 runtime checks pass on Windows;
- Windows-only tool checks pass on Windows and cross-platform tool checks pass
  on their declared operating systems;
- the optional MCP guide has no runtime dependency on an MCP server;
- README, changelog, licenses, notices, and the source installation example
  describe the released state.

## Deferred from version 1

Version 1 does not duplicate upstream pages one-for-one. The Windows tool
catalog aims for comprehensive supported inbox-command coverage, delivered in
reviewable batches; related subcommands can share a family page. PowerShell
cmdlets, `about_*` topics, and third-party CLI ecosystems remain selective.
