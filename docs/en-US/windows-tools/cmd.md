<!-- mant:tldr:start -->
# cmd

> Run a `cmd.exe` builtin, batch command, or command string from PowerShell.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cmd.

- Run one cmd builtin and exit without loading AutoRun commands:

`cmd.exe /d /c {{ver}}`

- Run a batch file and preserve its exit code:

`cmd.exe /d /c '"{{C:\path\script.cmd}}" {{argument}}'; $LASTEXITCODE`

- Keep a new command shell open after an initial command:

`cmd.exe /d /k {{set}}`
<!-- mant:tldr:end -->

# cmd

## Overview

`cmd.exe` is the Windows command interpreter. PowerShell can run native
executables directly, but cmd builtins such as `assoc`, `call`, `for`, `if`,
`set`, and `start` require a cmd process. Use `cmd.exe` explicitly when that
shell is required; do not send ordinary PowerShell code through it.

## Syntax

```text
cmd.exe [/c | /k] [/s] [/q] [/d] [/a | /u] [/t:BF]
        [/e:on | /e:off] [/f:on | /f:off] [/v:on | /v:off] [STRING]
```

## Important options

<!-- mant:entries role=option case=insensitive -->
- `/c STRING`: Run the command string, then exit.
- `/k STRING`: Run the command string, then keep the cmd process open.
- `/d`: Disable Command Processor AutoRun registry commands for this process.
- `/s`: With `/c` or `/k`, use cmd's special handling for the first and last
  double quotes. This does not make arbitrary nested quoting safe.
- `/q`: Turn command echo off.
- `/a`: Format command output as ANSI text.
- `/u`: Format command output as Unicode text.
- `/e:on`, `/e:off`: Enable or disable command extensions.
- `/f:on`, `/f:off`: Enable or disable cmd file and directory completion.
- `/v:on`, `/v:off`: Enable or disable delayed expansion with `!NAME!`.
- `/t:BF`: Set background and foreground colors with hexadecimal digits.

Use `/d` for deterministic automation unless the task intentionally depends
on Command Processor AutoRun configuration.

## PowerShell boundaries

PowerShell parses the outer command first. Cmd then parses the string supplied
to `/c` or `/k`. Keep the cmd portion as one PowerShell string and minimize
shell nesting:

```powershell
$cmdLine = 'echo current cmd directory: & cd'
cmd.exe /d /c $cmdLine
if ($LASTEXITCODE -ne 0) {
    throw "cmd.exe failed with exit code $LASTEXITCODE"
}
```

Inside cmd, `%NAME%` expands an environment variable when the command is
parsed. With `/v:on`, `!NAME!` performs delayed expansion. PowerShell instead
uses `$env:NAME`. An expression such as `$env:TEMP` is not valid cmd syntax,
and `%TEMP%` is not PowerShell variable syntax.

Cmd metacharacters include `&`, `&&`, `||`, `|`, `<`, `>`, `(`, `)`, and `^`.
Their meaning belongs to the cmd string; avoid adding another `cmd /c` layer
merely to copy a one-liner from a different shell.

## Common mistakes

### Sending PowerShell syntax to cmd

`cmd.exe /c 'Get-ChildItem | Where-Object Length -gt 0'` fails because cmd does
not provide PowerShell cmdlets or PowerShell expression syntax. Run that code
directly in PowerShell.

### Assuming `start` is the same command in both shells

`start` is a cmd builtin, but in PowerShell it normally resolves to the
`Start-Process` alias. Use `cmd.exe /d /c 'start ...'` for cmd semantics and
`Start-Process` for PowerShell semantics. See [start](start.md).

### Omitting `/d` in controlled automation

Without `/d`, cmd can execute per-machine or per-user AutoRun registry values
before the requested string. This can change output, working state, aliases,
and failure behavior.

### Losing an exit code across another native command

Read `$LASTEXITCODE` immediately after `cmd.exe` exits. Another native command
can overwrite it. Also remember that a command string containing several cmd
commands normally leaves the last command's status as the shell exit code.

## Version and platform differences

`cmd.exe` and these builtins are Windows-only. Some options and builtins depend
on command extensions and the installed Windows release. This page targets the
supported Windows 10, Windows 11, and Windows Server command interpreter
documented by Microsoft; legacy batch behavior can differ on older systems.

## Related documents

- [start](start.md)
- [where](where.md)
- [sc](sc.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original PowerShell-facing guide was adapted from Microsoft's official
[cmd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cmd)
and the official PowerShell guidance for
[running commands](https://learn.microsoft.com/powershell/scripting/learn/shell/running-commands).
Exact locked upstream revision and paths are recorded in `upstream/windows-tools.json`.

The cited Microsoft documentation is licensed under CC BY 4.0. This adaptation
is licensed under CC BY 4.0.
