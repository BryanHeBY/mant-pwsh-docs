<!-- mant:tldr:start -->
# rd

> Remove an empty directory or, with `/s`, an entire directory tree permanently.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rd.

- Inspect all entries, including hidden/system and reparse points:

`cmd.exe /d /c 'dir /s /b /a "{{C:\path\directory}}"'`

- Remove one empty directory:

`cmd.exe /d /c 'rd "{{C:\path\empty-directory}}"'`

- Request confirmation before deleting a reviewed tree:

`cmd.exe /d /c 'rd /s "{{C:\path\directory}}"'`
<!-- mant:tldr:end -->

# rd

## Overview

`rd` removes directories; `rmdir` is identical cmd syntax. `/s` permanently
deletes the entire tree including files. PowerShell's `rmdir` normally aliases
`Remove-Item` and does not accept cmd's switches.

## Syntax

```text
rd [DRIVE:]PATH [/s [/q]]
rmdir [DRIVE:]PATH [/s [/q]]
```

Without `/s`, the directory must be empty, including hidden/system entries.
`/q` is valid with `/s` and removes confirmation.

## Commands and options

<!-- mant:entries role=command case=insensitive -->
- `rd`, `rmdir`: Remove an empty directory, or an entire selected tree when
  `/s` is explicitly present, through equivalent Cmd builtin names.

Recursive removal is permanent and has no preview mode. Enumerate the exact
absolute tree and reparse points before selecting it.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Remove the named directory tree including all files and subdirectories.
- `/q`: Suppress the `/s` confirmation prompt; it is valid only with `/s` and
  does not make deletion a dry run or guarantee success.
- `/?`: Display installed builtin help through `cmd.exe`.

## PowerShell boundaries

Bare `rmdir` normally aliases `Remove-Item`, whose parameters differ. Prefer
`Remove-Item -LiteralPath -Confirm` for a reviewed PowerShell target. If Cmd's
tree deletion is required, invoke it explicitly, change outside the target
tree first, check the child exit code, and re-enumerate the path afterward.

## Common mistakes

### Adding `/s /q` to silence “directory not empty”

That changes an empty-directory operation into irreversible tree deletion.
Inspect hidden/system entries, reparse points, locks, and the resolved absolute
target instead of escalating destructiveness blindly.

### Deleting the current directory or one of its parents

Cmd cannot remove its current directory. Change to a verified location outside
the target tree before deletion.

### Following reparse points without a scope policy

Junctions and links can make a visually contained tree refer elsewhere. List
reparse points and test on representative filesystems before recursive removal.

### Assuming retries fix every “not empty” result

Concurrent writers, antivirus/indexing, permissions, corruption, or open
handles can recreate/block entries. Diagnose the remaining path; do not loop
unbounded destructive commands.

### Confusing cmd and PowerShell `rmdir`

Use `Get-Command rmdir -All`. Prefer `Remove-Item -LiteralPath` in PowerShell
and `cmd.exe /d /c rd ...` only when cmd behavior is intended.

## Version and platform differences

This page targets supported Windows cmd; WinRE differs. Behavior depends on
filesystem, permissions, reparse points, sharing, and active processes.

## Related documents

- [rmdir alias](rmdir.md)
- [del](del.md)
- [dir](dir.md)
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[rd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rd).
The recurring nonempty-tree diagnostic is reflected in
[How to solve “The directory is not empty” with rmdir?](https://stackoverflow.com/questions/22948189/how-to-solve-the-directory-is-not-empty-error-when-running-rmdir-command-in-a).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
