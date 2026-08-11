<!-- mant:tldr:start -->
# Get-Command

> Discover aliases, functions, cmdlets, scripts, and native applications available to Windows PowerShell 5.1.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-command?view=powershell-5.1.

- Find the command that a name resolves to:

`Get-Command {{name}}`

- Show every matching definition, including shadowed commands:

`Get-Command {{name}} -All`

- List commands exported by a module:

`Get-Command -Module {{module-name}}`
<!-- mant:tldr:end -->

# Get-Command

## Synopsis

```powershell
Get-Command [[-Name] <string[]>] [-All] [-CommandType <CommandTypes>]
    [-Module <string[]>] [-Syntax] [<CommonParameters>]
```

`Get-Command` returns metadata for aliases, functions, filters, cmdlets,
scripts, and external applications. Use it before assuming an unqualified name
starts the command you expect on a Windows PowerShell 5.1 machine.

## Command resolution

One name can have multiple definitions. An alias or function can hide a cmdlet
or `.exe` application. `Get-Command NAME` shows the normal precedence winner;
`Get-Command NAME -All` exposes every match.

```powershell
Get-Command curl -All
Get-Command where -All
```

Use a full path, an explicit executable extension such as `where.exe`, or a
module-qualified cmdlet name when the result matters. Windows PowerShell has
Windows-specific aliases and inbox modules, so do not infer results from a
PowerShell 7 or Unix-like host.

## Common options

<!-- mant:entries role=option case=insensitive -->
- `-Name NAME`: Find commands by name, including wildcard patterns.
- `-All`: Return every definition instead of only the precedence winner.
- `-CommandType TYPE`: Limit results to aliases, functions, cmdlets, scripts, or applications.
- `-Module MODULE`: Return commands exported by one or more modules.
- `-Syntax`: Display parameter syntax rather than normal metadata.
- `-ListImported`: Restrict results to modules loaded in the current session.
- `-TotalCount COUNT`: Limit the number of matching results.

Quote a wildcard pattern if an invoking shell might expand it before Windows
PowerShell receives it.

## Modules and prerequisites

`Get-Command -Module NAME` can discover commands exported by an installed
module even when it is not imported. `-ListImported` checks the current session
only. Use `Get-Module -ListAvailable` to inspect available modules, then
`Import-Module` only when an explicit import is appropriate.

Module availability depends on Windows version, installed roles/features,
products, bitness, PowerShell edition, and session configuration. Finding a
command on one Windows computer is not proof it exists on another.

```powershell
Get-Command -Module Microsoft.PowerShell.Management
Get-Command -ListImported -CommandType Cmdlet
```

## Syntax and automation checks

Use `-Syntax` for a compact parameter-set view and `Get-Help -Full` for
descriptions, examples, input types, and output types.

```powershell
Get-Command Get-ChildItem -Syntax
Get-Help Get-ChildItem -Full
```

Fail early when an automation prerequisite is missing:

```powershell
if ($null -eq (Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    throw 'git.exe is required but was not found on PATH.'
}
```

## Version and availability

This page targets Windows PowerShell 5.1. Results depend on Windows version,
installed features, process bitness, modules, profiles, and `PATH`.

## Common mistakes

### Omitting `-All` while diagnosing a collision

The default result can hide lower-precedence aliases, functions, scripts, or
applications. Use `-All` and inspect `CommandType`, `Source`, and `Definition`.

### Treating module discovery as proof that a command can run

An exported name can still depend on a missing Windows feature, incompatible
bitness, or unavailable service. Import and exercise the required operation on
the target Windows baseline.

## Related documents

- [Get-Help](Get-Help.md)
- [Get-Member](Get-Member.md)
- [native-commands](native-commands.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-Command reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-command?view=powershell-5.1).
It emphasizes command precedence, Windows module availability, and automation
diagnostics. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
