<!-- mant:tldr:start -->
# help

> Discover help in the interpreter that owns a command; Cmd, DiskPart,
> PowerShell, native executables, and ManT have different help systems.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/help.

- List commands described by a clean child Cmd session:

`cmd.exe /d /c help`

- Show Cmd help for one command name:

`cmd.exe /d /c "help {{command}}"`

- In PowerShell, resolve a name first, then read its full PowerShell help:

`Get-Command {{command}} -All; Get-Help {{command}} -Full`

- After confirming that an exact native tool documents `/?` as help, query it explicitly:

`& "{{tool.exe}}" /?`

- Read the reviewed ManT page without depending on live online help:

`mant {{command}} --source windows-tools --outline`

<!-- mant:tldr:end -->

# help

## Overview

`help` is context-sensitive. In `cmd.exe`, the builtin lists commands or asks
the relevant command-help provider for one topic. Inside interpreters such as
DiskPart, `help` instead describes that interpreter's commands. In PowerShell,
`help` normally resolves to a function that wraps `Get-Help` and adds paging;
it is not the Cmd builtin.

Use help only after resolving both the shell and command. An external program
may use `/?`, `-?`, `--help`, a subcommand, or no conventional switch at all.
Never execute a guessed help switch against a tool whose syntax could treat it
as a target or change request.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `help`: List Cmd builtin help topics or request one resolved Cmd topic; inside
  another interpreter it instead addresses that interpreter's help context.

## Common mistakes

### Running bare `help` in PowerShell and assuming it is Cmd help

Run `Get-Command help -All` to see what PowerShell will invoke. Use
`cmd.exe /d /c help` for Cmd, `Get-Help` for PowerShell, and enter a tool's
interpreter deliberately before using its contextual help.

### Treating the list as every executable installed on Windows

Cmd's list is not an authoritative software, PATH, feature, or capability
inventory. Use `Get-Command <name> -All`, `where.exe <name>`, package inventory,
and feature-specific discovery for the actual question.

### Assuming `help <name>` proves which executable will run

Aliases, functions, Cmd builtins, application paths, file associations, current
directory, PATHEXT, App Execution Aliases, and architecture can change
resolution. Resolve the exact command in the same shell, identity, environment,
and bitness that will execute it.

### Parsing localized or paged help as an API

Help is reader-facing text and can be localized, wrapped, paged, missing, or
older than the executable. Prefer typed discovery or a documented structured
format for automation. Record executable path/version and installed help when
version-specific syntax matters.

### Updating PowerShell help without reviewing provenance

`Update-Help` downloads module content and can require network access and
policy approval. It does not update native executable help. Treat downloaded
help as versioned input, not permission to run examples or make changes.

## PowerShell boundaries

PowerShell's `help` function produces display-oriented, paged text around
`Get-Help`; `Get-Help` returns help objects that are more suitable for further
inspection. `Get-Command` answers what a name resolves to, not how to use it.
Use both when command precedence or multiple matching topics matter.

Cmd builtins cannot be invoked directly as PowerShell commands. Use an explicit
clean child shell such as `cmd.exe /d /c "help ver"`; `/d` suppresses Cmd
AutoRun commands for more deterministic discovery.

## Version and platform differences

This page covers the Windows Cmd builtin on supported Windows client and server
releases. Available topics depend on installed components and interpreter
context. PowerShell help content depends on edition, module version, locale,
installed help, and network/update state.

## Related documents

- [cmd.exe](cmd.exe.md)
- [where.exe](where.exe.md)
- [microsoft-learn-mcp](microsoft-learn-mcp.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Help reference](https://learn.microsoft.com/windows-server/administration/windows-commands/help).
The PowerShell function-versus-cmdlet distinction was cross-checked against a
[practitioner explanation](https://stackoverflow.com/questions/64507081/in-powershell-5-what-is-the-difference-between-help-and-get-help);
Microsoft's installed and online references govern supported behavior. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
