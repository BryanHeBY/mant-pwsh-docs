<!-- mant:tldr:start -->
# cd

> Display or change cmd.exe's current directory; `/d` also changes the current drive.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cd.

- Change drive and directory in an existing cmd session:

`cd /d "{{D:\work\project}}"`

- Run one cmd command from a directory without trying to change the parent PowerShell session:

`cmd.exe /d /c 'cd /d "{{D:\work\project}}" && {{command}}'`

- Change the current PowerShell location explicitly:

`Set-Location -LiteralPath '{{D:\work\project}}'`
<!-- mant:tldr:end -->

# cd

## Overview

`cd` displays or changes the current directory maintained by `cmd.exe`;
`chdir` is the same builtin. Cmd retains a separate current directory for each
drive. This historical model is why an ordinary `cd D:\work` can update D:'s
remembered directory while the prompt remains on C:.

PowerShell's bare `cd` resolves to `Set-Location`, not this cmd builtin.

## Syntax

```text
cd [/d] [DRIVE:][PATH]
cd ..
chdir [/d] [DRIVE:][PATH]
chdir ..
```

<!-- mant:entries role=command case=insensitive -->
- `cd`, `chdir`: Display or change the current directory maintained by the
  current `cmd.exe`; the two builtin names are equivalent.

The path and `..` parent-directory forms are operands. The only named switch
also changes Cmd's active drive.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Change both the active drive and that drive's current directory.
- `/?`: Display installed builtin help through `cmd.exe`.

With no argument, `cd` prints the active drive and directory. With only a
drive such as `cd D:`, it displays that drive's remembered current directory.

## PowerShell boundaries

Bare `cd` normally resolves to `Set-Location`; `/d` is not a PowerShell
parameter. Use `Set-Location -LiteralPath` to change the current PowerShell
location. A child Cmd location cannot affect its parent, so combine `cd /d`
and the dependent builtin operation inside the same reviewed `cmd.exe /d /c`
invocation and capture that child's exit code.

## Common mistakes

### Expecting `cd D:\path` to switch from C: to D:

Use `cd /d "D:\path"`. Alternatively, enter `D:` and then `cd`, but `/d` is
clearer and atomic for automation. This is one of the most frequently reported
cmd navigation surprises.

### Expecting a child process to change PowerShell's location

`cmd.exe /c "cd ..."` changes only the child cmd process, which then exits.
Either use `Set-Location` in PowerShell or combine the directory change and
the intended cmd operation in the same `/c` command.

### Copying cmd syntax into PowerShell without resolving the name

PowerShell `cd` is an alias for `Set-Location`; `/d` is not a PowerShell
parameter. Use `Get-Command cd -All` when the shell context is uncertain.

### Relying on unquoted paths

Enabled command extensions permit some paths containing spaces without
quotes, but disabled extensions do not. Quote paths consistently and use
`/d` on nested `cmd.exe` calls to suppress AutoRun commands.

## Version and platform differences

The cmd builtin is Windows-only. PowerShell's `Set-Location` is provider-aware
and can navigate non-filesystem drives; cmd's drive-directory model is not.

## Runtime evidence

Exact cmd.exe 10.0.26100.1 `help CD` printed 21 nonempty stdout lines, no
PowerShell error records, and returned 1 without changing location. Protected
per-drive and /d location fixtures remain required.

## Related documents
- [chdir](chdir.md)
- [pushd](pushd.md)
- [popd](popd.md)
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[cd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cd)
and [Set-Location reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/set-location).
The high-frequency cross-drive failure is evidenced by
[How to change directory using Windows command line](https://stackoverflow.com/questions/17753986/how-to-change-directory-using-windows-command-line).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
