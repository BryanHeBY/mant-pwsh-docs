<!-- mant:tldr:start -->
# powershell-7-docs

> Browse the PowerShell 7 documentation source with ManT.
> Use `pwsh7` for the shell and language reference.

- Open the shell and language reference:

`mant pwsh7 --source pwsh7`

- Open this documentation index:

`mant powershell-7-docs --source pwsh7`

- Inspect the sections in a document:

`mant {{document-name}} --source pwsh7 --outline=sections`

- Search within one document:

`mant {{document-name}} --source pwsh7 --search={{pattern}}`
<!-- mant:tldr:end -->

# PowerShell 7 documentation

## Overview

This is the navigation page for the PowerShell 7 ManT source. Use
[`pwsh7`](pwsh7.md) for a self-contained shell and language reference similar
in purpose to a traditional shell manual. Other documents focus on one
cmdlet, alias, launcher, concept, or compatibility issue.

The source covers modern PowerShell on Windows, macOS, and Linux. It follows
the supported PowerShell 7 long-term support channel and records material
differences in newer stable releases.

## Start here

- [pwsh7](pwsh7.md): shell invocation, language, object pipelines, streams,
  errors, native commands, modules, profiles, and platform behavior.
- [pwsh](pwsh.md): launcher options for interactive sessions, scripts, and
  automation.
- [about_Parsing](about_Parsing.md): expression mode, argument mode, literal
  input, and native-command boundaries.
- [about_Quoting_Rules](about_Quoting_Rules.md): literal, expandable, and
  multi-line strings.
- [about_Pipelines](about_Pipelines.md): object flow, parameter binding, and
  native-command boundaries.
- [about_Redirection](about_Redirection.md): success, diagnostic, and
  information stream routing.
- [about_Automatic_Variables](about_Automatic_Variables.md): pipeline state,
  invocation paths, runtime information, errors, and native exit status.
- [about_Profiles](about_Profiles.md): startup customization without
  making automation depend on startup state.
- [about_Functions](about_Functions.md): reusable commands with parameters,
  pipeline input, scope, and module-oriented design.
- [native-commands](native-commands.md): executable resolution, argument
  conversion, streams, exit codes, and safety.

## Command discovery

- [Get-Command](Get-Command.md): resolve aliases, functions, cmdlets, scripts,
  modules, and executables.
- [Get-Help](Get-Help.md): read installed, detailed, and online help.
- [Get-Member](Get-Member.md): inspect the members and type information of
  objects before selecting properties or calling methods.

## Object pipeline

- [Where-Object](Where-Object.md): filter objects with property comparisons or
  explicit predicates.
- [ForEach-Object](ForEach-Object.md): transform or act on one pipeline object
  at a time.
- [Select-Object](Select-Object.md): select, calculate, expand, or bound
  object output before display or export.
- [Get-ChildItem](Get-ChildItem.md): enumerate filesystem and provider items
  with safe literal paths and bounded recursion.
- [Sort-Object](Sort-Object.md): order objects by properties or calculated
  values before selecting or exporting them.

## Modules

- [Import-Module](Import-Module.md): explicitly load trusted module commands
  while managing conflicts and compatibility.

## Items and processes

- [Invoke-Item](Invoke-Item.md): perform a provider item's default action,
  including opening folders and associated documents on Windows.
- [ii](ii.md): built-in shorthand for `Invoke-Item`, with trust and
  portability boundaries.
- [Start-Process](Start-Process.md): launch a process when window, verb,
  environment, redirection, or lifecycle controls are required.
- [start](start.md): Windows-only PowerShell alias for `Start-Process`, not the
  `cmd.exe` builtin of the same name.

## Aliases and web commands

- [irm](irm.md): alias for `Invoke-RestMethod`, with safe API and remote-content guidance.
- [iwr](iwr.md): alias for `Invoke-WebRequest`, with explicit download verification.
- [iex](iex.md): alias for `Invoke-Expression`; use safer direct invocation instead.
- [irx](irx.md): a non-built-in custom shorthand; resolve it in the current session before use.
- [curl](curl.md): distinguish PowerShell 7's ambient native command from the
  Windows PowerShell 5.1 alias and any custom definitions.

## Migration

- [PowerShell 7 and Windows PowerShell 5.1 compatibility](powershell-5.1-compatibility.md): test edition, module, language, native-command, profile, and remoting boundaries explicitly.

## Planned command reference

The first release will cover:

- core cmdlets and their built-in aliases, including short forms such as
  `irm` and `iwr`;
- compatibility and commonly encountered custom short names, with their
  origin and availability stated explicitly;
- discovery, help, pipelines, formatting, remoting, jobs, modules, and
  package management;
- native-command interoperability, argument passing, output streams, and
  exit status handling.

## Planned concepts and guides

Language and shell concepts use their official `about_*` topic names. The
first group will cover parsing, quoting rules, pipelines, redirection,
automatic variables, profiles, functions, operators, scopes, error handling,
and native-command interoperability.

Coverage is practical rather than a mirror of every upstream reference page.
Each document should be useful independently and link back to the complete
`pwsh7` reference where broader context is needed.

## Platform and version policy

Portable behavior is documented first. Windows-, macOS-, and Linux-specific
sections identify differences in installation, security, paths, modules, and
native command behavior. Durable runtime evidence records the exact version
and platform actually tested; a document is not implicitly verified on every
platform it describes.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, use this index for navigation and `pwsh7` for shell
questions:

```text
mant powershell-7-docs --source pwsh7
mant pwsh7 --source pwsh7 --outline
mant pwsh7 --source pwsh7 --node native-commands
mant pwsh7 --source pwsh7 --search=LASTEXITCODE
```

## Verification boundary

This page is a navigation and retrieval index, not a runtime-behavior claim.
Repository validation checks its structure, links, semantic declarations, and
ManT parsing. Runtime evidence and any remaining platform boundary belong to
the linked command and shell pages.

## Related documents

- [PowerShell 7 shell and language](pwsh7.md)
- [pwsh launcher](pwsh.md)
- [Windows PowerShell 5.1 compatibility](powershell-5.1-compatibility.md)

## Sources and license

This source contains original ManT-oriented documentation informed by the
[official Microsoft PowerShell documentation](https://learn.microsoft.com/powershell/)
and the PowerShell source code. Exact upstream revisions and document-level
provenance are recorded in the repository's `upstream/pwsh7.json` catalog.

The documentation in this source is licensed under CC BY 4.0. Microsoft
product names are trademarks of the Microsoft group of companies; this
project is not affiliated with or endorsed by Microsoft.
