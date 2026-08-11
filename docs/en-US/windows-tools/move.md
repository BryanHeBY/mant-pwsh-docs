<!-- mant:tldr:start -->
# move

> Move files with cmd.exe; bare `move` in PowerShell normally means `Move-Item`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/move.

- Preview a PowerShell-native move without changing anything:

`Move-Item -LiteralPath '{{C:\source\file}}' -Destination '{{D:\target\file}}' -WhatIf`

- Move one file with cmd and require overwrite confirmation:

`cmd.exe /d /c 'move /-y "{{C:\source\file}}" "{{D:\target\file}}"'`

- Move matching files into an existing directory with cmd:

`cmd.exe /d /c 'move /-y "{{C:\source\*.log}}" "{{D:\archive\}}"'`
<!-- mant:tldr:end -->

# move

## Overview

Cmd's `move` builtin moves files and can move or rename a directory. In
PowerShell, `move` normally aliases the provider-aware `Move-Item` cmdlet; the
two commands accept different syntax and have different overwrite behavior.

## Syntax

```text
move [/y | /-y] SOURCE TARGET
```

<!-- mant:entries role=command case=insensitive -->
- `move`: Move files, or move/rename a directory, through the `cmd.exe`
  builtin; it is not a standalone `move.exe`.

`SOURCE` is one file, a file pattern, or a directory path. `TARGET` is an
existing destination directory or the new target path/name.

<!-- mant:entries role=option case=insensitive -->
- `/y`: Suppress the normal prompt before overwriting an existing destination.
- `/-y`: Require an overwrite prompt and override a `COPYCMD=/y` environment
  default.
- `/?`: Display installed builtin help through `cmd.exe`.

`COPYCMD` can preset `/y`; an explicit `/-y` overrides it. Batch execution can
also differ from interactive prompting, so unattended automation must specify
and verify its collision policy.

## Common mistakes

### Running PowerShell's alias with cmd switches

`move /y ...` in PowerShell normally calls `Move-Item` and fails parameter
binding. Resolve with `Get-Command move -All`. Use `Move-Item` with named
parameters or run the builtin explicitly through `cmd.exe /d /c`.

### Treating a missing destination directory as a directory

A destination-looking path is not automatically created as a directory.
Validate its item type first; create it explicitly when required. This also
prevents a single moved file from taking the intended directory name.

### Suppressing overwrite prompts without checking collisions

`/y` and batch defaults can replace destination files. Enumerate source and
destination paths, choose an explicit policy, and verify the post-move item.
Read-only attributes and permissions can still prevent a clean unattended
operation.

### Moving encrypted files to a volume without EFS

Cmd reports an error rather than silently decrypting an EFS file. Decrypt it
deliberately or select an EFS-capable target and verify protection afterward.

### Assuming the operation is transactional

Multi-file moves can partially succeed. Check cmd's exit status and the final
source/destination inventories; do not interpret one summary line as an
all-or-nothing guarantee.

## PowerShell boundaries

Bare `move` normally resolves to `Move-Item`. Prefer the full cmdlet name with
literal paths and `-WhatIf`/`-Confirm`. Invoke the builtin through
`cmd.exe /d /c` only for its contract, explicitly quote child-shell paths,
check the child exit code, and compare final source/destination inventories.

## PowerShell-native alternative

`Move-Item` supports `-LiteralPath`, `-WhatIf`, `-Confirm`, providers, and
pipeline input. It does not create a missing destination hierarchy, and
moving directories between filesystem drives has additional limits. Prefer
full cmdlet names in scripts so their contract is visible.

## Version and platform differences

The cmd builtin is Windows-only. EFS availability depends on the filesystem,
Windows edition, policy, and target volume. `Move-Item` is available on all
PowerShell platforms but its provider and filesystem behavior varies.

## Related documents

- [copy](copy.md)
- [dir](dir.md)
- [ren](ren.md)
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[move reference](https://learn.microsoft.com/windows-server/administration/windows-commands/move)
and [Move-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/move-item).
The recurring alias mismatch is evidenced by
[How do you move more than a single item with PowerShell at once?](https://stackoverflow.com/questions/71871305/how-do-you-move-more-than-a-single-item-with-powershell-at-once).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
