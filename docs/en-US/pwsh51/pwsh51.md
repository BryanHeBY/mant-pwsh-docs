<!-- mant:tldr:start -->
# pwsh51

> Browse the Windows PowerShell 5.1 documentation source with ManT.
> Windows PowerShell 5.1 is included with supported Windows releases and is
> started with `powershell.exe`.

- Open this source index:

`mant pwsh51 --source pwsh51`

- Inspect the sections in a document:

`mant {{document-name}} --source pwsh51 --outline=sections`

- Explain a parameter or option:

`mant {{document-name}} --source pwsh51 --explain={{parameter}}`

- Search within one document:

`mant {{document-name}} --source pwsh51 --search={{pattern}}`
<!-- mant:tldr:end -->

# Windows PowerShell 5.1

## Overview

This source documents Windows PowerShell 5.1 as shipped with Windows. It is
for users maintaining Windows-only systems and scripts that cannot yet move
to PowerShell 7. Examples use `powershell.exe` when the distinction between
the two editions matters.

Windows PowerShell and PowerShell 7 have overlapping command sets but are not
interchangeable. This source records 5.1 behavior independently, including
edition-specific aliases, modules, syntax limitations, and Windows-only
features.

## Planned coverage

The first release will cover:

- the `powershell.exe` command-line interface;
- built-in cmdlets and their commonly used aliases;
- language and shell concepts represented by `about_*` topics;
- command discovery, help, pipelines, providers, remoting, jobs, and modules;
- differences that commonly affect migration to PowerShell 7.

Coverage is intentionally practical rather than a mirror of every upstream
reference page.

## Platform and version policy

This source targets Windows PowerShell 5.1 on Windows. Documents should state
when behavior depends on a Windows release, an optional Windows feature, a
module version, elevated privileges, or Windows PowerShell compatibility
components.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, select this source explicitly when the same command is
also available in PowerShell 7:

```text
mant Get-Command --source pwsh51
mant Get-Command --source pwsh51 --outline
mant Get-Command --source pwsh51 --explain=-Module
mant about_Pipelines --source pwsh51 --search=enumeration
```

## Sources and license

This source contains original ManT-oriented documentation informed by the
official Microsoft documentation for Windows PowerShell 5.1. Exact upstream
revisions and page-level provenance are recorded in the repository's
`upstream/pwsh51.json` catalog.

The documentation in this source is licensed under CC BY 4.0. Microsoft
product names are trademarks of the Microsoft group of companies; this
project is not affiliated with or endorsed by Microsoft.
