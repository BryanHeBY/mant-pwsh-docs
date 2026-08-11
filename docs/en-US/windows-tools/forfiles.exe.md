<!-- mant:tldr:start -->
# forfiles.exe

> Select Windows filesystem entries by path, mask, recursion, and modification date.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/forfiles.

- Safely list files modified at least 30 days ago, excluding directories:

`forfiles.exe /p "{{C:\path}}" /s /m "*" /d -30 /c "cmd.exe /d /c if @isdir==FALSE echo @path"`

- List selected full paths and modification timestamps before any action:

`forfiles.exe /p "{{C:\path}}" /m "{{*.log}}" /c "cmd.exe /d /c echo @path @fdate @ftime"`

- Use PowerShell objects for richer preview and filtering:

`Get-ChildItem -LiteralPath '{{C:\path}}' -File -Recurse | Where-Object LastWriteTime -LE (Get-Date).AddDays(-30)`
<!-- mant:tldr:end -->

# forfiles.exe

## Overview

`forfiles.exe` selects filesystem entries and runs a command once per match.
`/p` sets the root, `/m` the mask, `/s` recursion, `/d` a modification-date
threshold, and `/c` the nested command.

`@path`, `@file`, `@fname`, `@ext`, `@isdir`, `@fsize`, `@fdate`, and `@ftime`
expand inside `/c`. Absolute dates use the machine's regional date format.
`/d -30` means modified on or before today minus 30 days; it does not mean
“within the last 30 days.”

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `forfiles.exe`: Select filesystem entries by root, mask, recursion, and
  modification date, then execute one nested command per match.

The `/c` value crosses both the `forfiles` parser and a nested command parser.
Preview the identical selection before placing a mutation there.

<!-- mant:entries role=option case=insensitive -->
- `/p`: Set the search root to the following path; default is the current directory.
- `/m`: Select the following filename mask; default is `*`.
- `/s`: Recurse into subdirectories beneath the selected root.
- `/c`: Run the following quoted command for each match; default is a simple
  `cmd /c echo @file` display.
- `/d`: Select entries by last-modified date: an absolute regional date, a
  negative age (on/before cutoff), or a positive offset (on/after cutoff).
- `/?`: Display installed command help.

## PowerShell boundaries

Pass `/c` as one argument and account for the second Cmd parsing layer;
`@path` is already the quoted full path substitution. Capture
`$LASTEXITCODE`, but prefer `Get-ChildItem` plus typed `LastWriteTime` filtering
for PowerShell automation, where file/directory identity and timezone/cutoff
logic can be inspected before action.

## Common mistakes

### Deleting before previewing the identical selection

Keep the first run read-only: echo `@path`, `@isdir`, and timestamps. Record
the root, mask, recursion, boundary inclusion, timezone, and current date.

### Forgetting that directories are selected

Use `if @isdir==FALSE` for file-only work. Passing a matched directory to
`del` can affect its contents far beyond the intended age-filtered files.

### Using `*.*` and missing extensionless names

Use `*` when all names are intended. Community testing shows `forfiles` mask
semantics do not always match cmd builtins' historical `*.*` behavior.

### Reversing the sign on `/d`

Negative relative days select entries older than or equal to the cutoff;
positive days select entries newer than or equal to a future cutoff. Test the
boundary with controlled timestamps.

### Losing quoting across `/c "cmd /c ..."`

There are two parsers. Use plain ASCII quotes, prefer `@path` for the quoted
full path, and test names containing spaces and metacharacters.

## Version and platform differences

This executable is Windows-only. Absolute date input and displayed timestamps
are locale-dependent; filesystem timestamp precision and semantics vary.

## Related documents

- [for](for.md)
- [dir](dir.md)
- [del](del.md)

## Sources and license

This original guide was adapted from Microsoft's official
[forfiles reference](https://learn.microsoft.com/windows-server/administration/windows-commands/forfiles).
The directory-selection deletion hazard is evidenced by
[Use forfiles to delete a folder and its contents](https://stackoverflow.com/questions/39377372/use-forfiles-to-delete-a-folder-and-its-contents),
and the `/d` sign misunderstanding by
[Why does FORFILES /D -10 not find files modified within the last 10 days?](https://stackoverflow.com/questions/71270665/why-does-windows-forfiles-with-option-d-10-not-find-files-last-modified-within).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
