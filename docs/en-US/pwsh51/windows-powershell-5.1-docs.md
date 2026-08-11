<!-- mant:tldr:start -->
# windows-powershell-5.1-docs

> Browse the Windows PowerShell 5.1 documentation source with ManT.
> Use `pwsh51` for the shell and language reference.

- Open the shell and language reference:

`mant pwsh51 --source pwsh51`

- Open this documentation index:

`mant windows-powershell-5.1-docs --source pwsh51`

- Inspect the sections in a document:

`mant {{document-name}} --source pwsh51 --outline=sections`

- Search within one document:

`mant {{document-name}} --source pwsh51 --search={{pattern}}`
<!-- mant:tldr:end -->

# Windows PowerShell 5.1 documentation

## Overview

This is the navigation page for the Windows PowerShell 5.1 ManT source. Use
[`pwsh51`](pwsh51.md) for a self-contained shell and language reference
similar in purpose to a traditional shell manual. Other documents focus on
one cmdlet, alias, launcher, concept, or compatibility issue.

The source is for users maintaining Windows-only systems and scripts that
cannot yet move to PowerShell 7. It treats Windows PowerShell 5.1 behavior
independently rather than assuming that current PowerShell documentation also
applies to the older edition.

## Start here

- [pwsh51](pwsh51.md): shell invocation, language, object pipelines, streams,
  errors, native commands, modules, profiles, and Windows-specific behavior.
- [powershell](powershell.md): `powershell.exe` launcher options for
  interactive sessions, scripts, and automation.
- [about_Parsing](about_Parsing.md): expression mode, argument mode, literal
  input, and Windows native-command boundaries.
- [about_Quoting_Rules](about_Quoting_Rules.md): literal, expandable, and
  multi-line strings.
- [about_Pipelines](about_Pipelines.md): object flow, parameter binding, and
  Windows native-command boundaries.
- [about_Redirection](about_Redirection.md): success, diagnostic, and
  information stream routing, including Windows PowerShell 5.1 text encoding.
- [about_Automatic_Variables](about_Automatic_Variables.md): pipeline state,
  invocation paths, runtime information, errors, and native exit status.
- [about_Profiles](about_Profiles.md): Windows host customization without
  making automation depend on startup state.
- [about_Functions](about_Functions.md): reusable commands with parameters,
  pipeline input, scope, and module-oriented design.
- [native-commands](native-commands.md): executable resolution, argument
  conversion, text streams, exit codes, and safety.

## Command discovery

- [Get-Command](Get-Command.md): resolve aliases, functions, cmdlets, scripts,
  modules, and executable applications.
- [Get-Help](Get-Help.md): read installed, detailed, and online help.
- [Get-Member](Get-Member.md): inspect object types and members before selecting
  properties or calling methods.

## Object pipeline

- [Where-Object](Where-Object.md): filter objects with property comparisons or
  explicit predicates.
- [ForEach-Object](ForEach-Object.md): transform or act on one pipeline object
  at a time.
- [Select-Object](Select-Object.md): select, calculate, expand, or bound object
  output before display or export.
- [Get-ChildItem](Get-ChildItem.md): enumerate filesystem and provider items
  with safe literal paths and bounded recursion.
- [Sort-Object](Sort-Object.md): order objects by properties or calculated
  values before selecting or exporting them.

## Modules

- [Import-Module](Import-Module.md): explicitly load trusted module commands
  while managing conflicts and compatibility.

## Items and processes

- [Invoke-Item](Invoke-Item.md): perform a provider item's default action,
  including opening folders and associated documents.
- [ii](ii.md): built-in shorthand for `Invoke-Item`, with trust boundaries.
- [Start-Process](Start-Process.md): launch a process when window, verb,
  credentials, redirection, or lifecycle controls are required.
- [start](start.md): PowerShell alias for `Start-Process`, not the `cmd.exe`
  builtin of the same name.

## Aliases and web commands

- [irm](irm.md): alias for `Invoke-RestMethod`, with safe API and remote-content guidance.
- [iwr](iwr.md): alias for `Invoke-WebRequest`, including legacy 5.1 parser guidance.
- [iex](iex.md): alias for `Invoke-Expression`; use direct invocation instead.
- [irx](irx.md): a non-built-in custom shorthand; resolve it in the current session before use.
- [curl](curl.md): distinguish the `Invoke-WebRequest` alias from `curl.exe`.

## Migration

- [Windows PowerShell 5.1 and PowerShell 7 compatibility](powershell-7-compatibility.md): test edition, language, module, native-command, profile, and remoting boundaries explicitly.

## Planned command reference

The first release will cover:

- built-in cmdlets and their commonly used aliases;
- the inbox modules normally available with Windows PowerShell 5.1;
- command discovery, help, pipelines, providers, remoting, jobs, and modules;
- differences that commonly affect migration to PowerShell 7.

## Planned concepts and guides

Language and shell concepts use their official `about_*` topic names. The
first group will cover parsing, quoting rules, pipelines, redirection,
automatic variables, profiles, functions, operators, scopes, error handling,
and native commands.

Coverage is practical rather than a mirror of every upstream reference page.
Each document should be useful independently and link back to the complete
`pwsh51` reference where broader context is needed.

## Platform and version policy

This source targets Windows PowerShell 5.1 on Windows. Documents state when
behavior depends on a Windows release, optional Windows feature, module
version, elevated privileges, or compatibility component. Runtime verification
for this source requires Windows PowerShell 5.1 on Windows.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, use this index for navigation and `pwsh51` for shell
questions:

```text
mant windows-powershell-5.1-docs --source pwsh51
mant pwsh51 --source pwsh51 --outline
mant pwsh51 --source pwsh51 --node native-commands
mant pwsh51 --source pwsh51 --search=LASTEXITCODE
```

## Related documents

- [Windows PowerShell 5.1 shell and language](pwsh51.md)
- [powershell.exe launcher](powershell.md)
- [PowerShell 7 compatibility](powershell-7-compatibility.md)

## Sources and license

This source contains original ManT-oriented documentation informed by the
[official Windows PowerShell documentation](https://learn.microsoft.com/powershell/scripting/what-is-windows-powershell?view=powershell-5.1).
Exact upstream revisions and document-level provenance are recorded in the
repository's `upstream/pwsh51.json` catalog.

The documentation in this source is licensed under CC BY 4.0. Microsoft
product names are trademarks of the Microsoft group of companies; this
project is not affiliated with or endorsed by Microsoft.
