<!-- mant:tldr:start -->
# dir

> List files and directories through `cmd.exe`; use `Get-ChildItem` for PowerShell objects.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/dir.

- Produce a bare recursive list of files only:

`cmd.exe /d /c 'dir /s /b /a:-d "{{C:\path\pattern}}"'`

- Include hidden and system entries for inspection:

`cmd.exe /d /c 'dir /a "{{C:\path}}"'`

- Show reparse points without traversing them:

`cmd.exe /d /c 'dir /a:l "{{C:\path}}"'`
<!-- mant:tldr:end -->

# dir

## Overview

`dir` is a `cmd.exe` builtin that formats directory listings as localized text.
In PowerShell, bare `dir` normally aliases `Get-ChildItem`, which returns
objects and has different parameters.

## Syntax and options

```text
dir [DRIVE:][PATH][NAME] [/p] [/q] [/w] [/d] [/a[:ATTRS]]
    [/o[:ORDER]] [/t[:FIELD]] [/s] [/b] [/l] [/n] [/x] [/c] [/4] [/r]
```

<!-- mant:entries role=command case=insensitive -->
- `dir`: Format a directory listing through the `cmd.exe` builtin; it is not a
  standalone `dir.exe`.

The path operand uses Cmd wildcard and short-name matching. The following
switches control presentation and traversal, not PowerShell object properties.

<!-- mant:entries role=option case=insensitive -->
- `/p`: Pause after each screenful of output for attended viewing.
- `/q`: Display each entry's owner where available and permitted.
- `/w`: Use a wide name-only display.
- `/d`: Use a wide display sorted down columns rather than across them.
- `/a`: Include all entries or, after a colon, filter by attribute letters
  such as `d`, `h`, `s`, `l`, `r`, `a`, and `i`; `-` negates a letter.
- `/o`: Order by a field such as name, extension, size, date, or directory
  grouping; `-` reverses the selected order.
- `/t`: Select creation (`c`), last-access (`a`), or last-write (`w`) time for
  display and date ordering.
- `/s`: Recurse into matching subdirectories.
- `/b`: Use bare format without headings or summaries; with `/s`, emit paths.
- `/l`: Display names in lowercase without renaming filesystem entries.
- `/n`: Use the long-list format with filenames at the right.
- `/x`: Display generated 8.3 short names where they exist.
- `/c`: Show the locale's thousands separator in file sizes; this is default.
- `/-c`: Omit the thousands separator from displayed sizes.
- `/4`: Display four-digit years.
- `/r`: Display alternate data streams associated with each entry.
- `/?`: Display installed builtin help through `cmd.exe`.

## PowerShell boundaries

Bare `dir` normally resolves to `Get-ChildItem`. Use that cmdlet for typed
items, `-LiteralPath`, and provider-aware filtering. Invoke the builtin through
`cmd.exe /d /c` only for its exact textual contract; check the child exit code
and do not treat `/b` text as race-free filesystem inventory.

## Common mistakes

### Assuming bare `dir` means cmd in PowerShell

Use `Get-Command dir -All`. Invoke `cmd.exe /d /c` only when cmd's textual
format or switches are required.

### Parsing the normal display

Headers, dates, separators, owners, and ordering are localized and
configuration-dependent. For cmd text pipelines use `/s /b /a:-d`; for robust
automation use PowerShell objects or a filesystem API.

### Trusting wildcard results before deletion

Cmd wildcard matching can involve short 8.3 names, so a pattern may match more
than its visible long-name spelling suggests. Use the exact same `dir` pattern,
review `/x`, then prefer literal-path deletion where possible.

### Recursing across reparse points blindly

Junctions and symbolic links can change scope or create cycles. Identify
`/a:l` entries and define traversal policy before recursive work.

## Version and platform differences

This page targets supported Windows cmd. WinRE has a different form. Output
language, date format, 8.3-name creation, filesystems, and permissions vary.

## Related documents

- [cmd.exe](cmd.exe.md)
- [for](for.md)
- [del](del.md)
- [Windows tools index](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's official
[dir reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dir).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
