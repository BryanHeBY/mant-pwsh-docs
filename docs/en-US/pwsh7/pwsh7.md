<!-- mant:tldr:start -->
# pwsh7

> Browse the PowerShell 7 documentation source with ManT.
> PowerShell 7 is the current cross-platform edition and is started with
> `pwsh`.

- Open this source index:

`mant pwsh7 --source pwsh7`

- Inspect the sections in a document:

`mant {{document-name}} --source pwsh7 --outline=sections`

- Explain a parameter or option:

`mant {{document-name}} --source pwsh7 --explain={{parameter}}`

- Search within one document:

`mant {{document-name}} --source pwsh7 --search={{pattern}}`
<!-- mant:tldr:end -->

# PowerShell 7

## Overview

This source documents modern PowerShell for Windows, macOS, and Linux. It is
organized around the supported PowerShell 7 long-term support channel, with
version notes for behavior that differs in newer stable releases.

Examples favor portable object-pipeline patterns. A document identifies
operating-system dependencies rather than presenting platform-specific
behavior as universal.

## Planned coverage

The first release will cover:

- the `pwsh` command-line interface;
- core cmdlets and their built-in aliases, including short forms such as
  `irm` and `iwr`;
- compatibility and commonly encountered custom short names, including
  `irx`, with their origin and availability stated explicitly;
- language and shell concepts represented by `about_*` topics;
- discovery, help, pipelines, formatting, remoting, jobs, modules, and
  package management;
- native-command interoperability, argument passing, output streams, and
  exit status handling;
- high-impact differences from Windows PowerShell 5.1.

Coverage is intentionally practical rather than a mirror of every upstream
reference page.

## Platform and version policy

Portable behavior is documented first. Windows-, macOS-, and Linux-specific
sections are added where installation, security, path handling, available
modules, or native command behavior differs. Each document records the
PowerShell version used for runtime verification.

The exact documentation and runtime revisions used for the current baseline
are recorded in `upstream/pwsh7.json`.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, select this source explicitly when a Windows PowerShell
5.1 page has the same name:

```text
mant Get-Command --source pwsh7
mant Get-Command --source pwsh7 --outline
mant Get-Command --source pwsh7 --explain=-Module
mant about_Native_Commands --source pwsh7 --search=LASTEXITCODE
```

## Sources and license

This source contains original ManT-oriented documentation informed by the
official Microsoft PowerShell documentation and the PowerShell source code.
Exact upstream revisions and page-level provenance are recorded in the
repository's `upstream/pwsh7.json` catalog.

The documentation in this source is licensed under CC BY 4.0. Microsoft
product names are trademarks of the Microsoft group of companies; this
project is not affiliated with or endorsed by Microsoft.
