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

## Commands and options

<!-- mant:entries role=command case=insensitive -->
- `del`, `erase`: Permanently delete matching files through equivalent
  `cmd.exe` builtin names; neither name identifies a standalone executable.

The `NAMES` operand uses Cmd path and wildcard rules. Preview the exact same
path, pattern, attribute filter, and recursion root before mutation.

<!-- mant:entries role=option case=insensitive -->
- `/p`: Prompt before deleting each selected file.
- `/f`: Force deletion of read-only files; it does not bypass ACLs, locks, or
  other filesystem protections.
- `/s`: Delete matching files in the named directory and all subdirectories.
- `/q`: Suppress confirmation when a global wildcard is used; it does not make
  the operation a dry run or suppress every diagnostic.
- `/a`: Select files by attributes after an optional colon; prefix an attribute
  letter with `-` to require that attribute to be absent.
- `/?`: Display installed builtin help through `cmd.exe`.

## PowerShell boundaries

Bare `del` and `erase` normally resolve to `Remove-Item` aliases, not Cmd.
Prefer `Remove-Item -LiteralPath` for exact PowerShell targets. If the builtin
is required, invoke it through `cmd.exe /d /c`, keep the pattern quoted for
the child shell, check its exit code, and re-enumerate the intended scope.

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
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[del reference](https://learn.microsoft.com/windows-server/administration/windows-commands/del),
including its requirement to preview wildcard matches with `dir`. Exact locked
provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
