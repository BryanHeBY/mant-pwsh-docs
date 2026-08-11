<!-- mant:tldr:start -->
# del

> Permanently delete files with cmd; preview the exact wildcard with `dir` first.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/del.

- Preview the exact files a wildcard can match:

`cmd.exe /d /c 'dir /b /a "{{C:\path\pattern}}"'`

- Prompt before deleting each exact reviewed file:

`cmd.exe /d /c 'del /p "{{C:\path\file}}"'`

- Prefer literal-path PowerShell deletion for one exact file:

`Remove-Item -LiteralPath '{{C:\path\file}}' -Confirm`
<!-- mant:tldr:end -->

# del

## Overview

`del` permanently deletes files; `erase` is the same cmd builtin. It does not
move items to the Recycle Bin. Bare `del` in PowerShell normally aliases
`Remove-Item`, which has different syntax and wildcard semantics.

## Syntax

```text
del [/p] [/f] [/s] [/q] [/a[:ATTRIBUTES]] NAMES
erase [/p] [/f] [/s] [/q] [/a[:ATTRIBUTES]] NAMES
```

`/p` prompts per file, `/f` includes read-only files, `/s` recurses, `/q`
suppresses confirmation, and `/a` filters attributes including `r`, `h`, `i`,
`s`, `a`, `l`, with `-` for negation.

## Common mistakes

### Combining `/s /q` with an unreviewed pattern

This is irreversible and broad. Resolve the absolute root, list the exact same
pattern with `dir /s /b /a`, check reparse points, and validate nonempty scope
before deletion.

### Assuming `*.*` means only names containing a dot

In cmd it is commonly used for all files. Wildcards can also match short 8.3
names unexpectedly. Never infer the selected set from Unix glob behavior.

### Passing a directory when intending to remove the directory

`del DIRECTORY` deletes files inside it, not the directory itself. Use `rd`
only after separately reviewing recursive directory-tree scope.

### Trusting a zero/quiet run as proof of the desired state

Locks, permissions, races, reparse points, and concurrent creation can affect
results. Re-enumerate the exact target and record failures.

### Running the PowerShell alias accidentally

Use `Get-Command del -All`; prefer the full `Remove-Item -LiteralPath` spelling
for reviewed PowerShell scripts.

## Version and platform differences

This page targets supported Windows cmd. WinRE differs. Filesystem semantics,
8.3 names, permissions, and reparse behavior depend on the target volume.

## Related documents

- [erase alias](erase.md)
- [dir](dir.md)
- [rd](rd.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's official
[del reference](https://learn.microsoft.com/windows-server/administration/windows-commands/del),
including its requirement to preview wildcard matches with `dir`. Exact locked
provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
