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

## Syntax and useful switches

```text
dir [DRIVE:][PATH][NAME] [/p] [/q] [/w] [/d] [/a[:ATTRS]]
    [/o[:ORDER]] [/t[:FIELD]] [/s] [/b] [/l] [/n] [/x] [/c] [/4] [/r]
```

- `/a`: include all attributes; filters include `d`, `h`, `s`, `l`, `r`, `a`,
  `i`, with `-` for negation.
- `/s`: recurse; `/b`: emit one bare path per line.
- `/o`: order by name, extension, directory grouping, size, or date.
- `/t:c|a|w`: choose creation, access, or write time.
- `/x`: show generated short names; `/r`: show alternate data streams.

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

- [cmd](cmd.md)
- [for](for.md)
- [del](del.md)
- [PowerShell-facing CLI index](pwsh-cli.md)

## Sources and license

This original guide was adapted from Microsoft's official
[dir reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dir).
Exact locked provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
