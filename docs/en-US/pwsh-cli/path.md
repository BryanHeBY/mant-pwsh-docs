<!-- mant:tldr:start -->
# path

> Inspect or replace the executable search path of the current `cmd.exe` process.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/path.

- Display the current cmd search path:

`cmd.exe /d /c path`

- Prepend one directory for a single child command:

`cmd.exe /d /c 'set "PATH={{C:\tools}};%PATH%" & {{tool.exe}}'`

- Inspect PowerShell's inherited PATH entries:

`$env:PATH -split [IO.Path]::PathSeparator`
<!-- mant:tldr:end -->

# path

## Overview

`path` is a cmd builtin that displays or replaces the current process's `PATH`
environment variable. A child cmd cannot persist a change in its parent
PowerShell process.

## Syntax

```text
path [[DRIVE:]PATH[;...][;%PATH%]]
path ;
```

`path ;` clears PATH for that process, leaving cmd's documented current-
directory search behavior. Prefer `set "PATH=NEW;%PATH%"` for visibly scoped
batch edits.

## Common mistakes

### Replacing PATH when intending to append

`path C:\tools` discards the inherited entries. Include `%PATH%` exactly once,
or save/restore the environment with `setlocal`.

### Expecting a child-shell change to persist

`cmd.exe /c path ...` ends with the child. Set `$env:PATH` in the current
PowerShell session, or use supported user/machine environment management when
persistence is explicitly intended.

### Trusting the first bare command name

Cmd searches the current directory before PATH, then PATH entries in order;
extensions and `PATHEXT` also affect resolution. Use an absolute executable
path for privileged automation and inspect with `where.exe`/`Get-Command`.

### Adding empty or writable entries

Empty components, the current directory, and broadly writable directories can
enable executable shadowing. Normalize, deduplicate, and apply least privilege.

### Editing persistent PATH as one unbounded string

User and machine values, process inheritance, expansion, length, and concurrent
changes make blind replacement unsafe. Read current state, modify one intended
entry, and verify in a new process.

## Version and platform differences

This page describes Windows cmd search behavior. PowerShell and native process
launchers have their own command-resolution layers before Windows searches PATH.

## Related documents

- [where](where.md)
- [set](set.md)
- [setlocal](setlocal.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's official
[path reference](https://learn.microsoft.com/windows-server/administration/windows-commands/path).
Exact locked provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
