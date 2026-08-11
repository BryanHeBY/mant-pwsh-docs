<!-- mant:tldr:start -->
# label

> Inspect durable volume identity before changing its human-readable label; labels are mutable and non-unique.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/label.

- Inventory labels together with unique volume paths and sizes before selecting a target:

`Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem, Size, UniqueId, Path`

- Display the label and serial number for one exact drive without changing it:

`cmd.exe /d /c 'vol {{X:}}'`

- After revalidating unique identity and dependencies, assign one explicit nonempty label:

`label.exe "{{X:}}" "{{DATA-2026}}"`

- Verify the target by both durable identity and resulting label:

`Get-Volume -DriveLetter {{X}} | Select-Object DriveLetter, FileSystemLabel, UniqueId, Path`

<!-- mant:tldr:end -->

# label

## Overview

`label.exe` creates, changes, or deletes a filesystem volume label. The target
can be a drive letter, mount point, or volume name; `/MP` explicitly treats the
operand as a mount point or volume name. NTFS labels can contain spaces and are
up to 32 characters according to Microsoft's reference.

A label is display metadata, not a volume GUID, hardware serial, access-control
boundary, mount guarantee, or globally unique key. Scripts and operators should
use durable identity plus label, size, filesystem, and ownership evidence.

## Common mistakes

### Running `label` with no explicit target or label

With omitted parameters the command operates interactively on the current
volume and can delete its existing label. Always name the verified target and
intended nonempty label; use `vol` or `Get-Volume` for read-only inspection.

### Selecting a volume by label alone

Labels can be duplicated, changed, truncated by a target filesystem, or absent.
Correlate volume GUID/path, disk/partition identity, size, filesystem, drive
letter/mount point, and workload owner immediately before changing it.

### Confusing volume label with volume serial or device serial

`vol` displays a filesystem volume serial, while storage devices expose other
serial/unique IDs. None is interchangeable. Record the correct identity layer
for backup, deployment, licensing, or incident evidence.

### Removing a label unintentionally

An empty label can mean delete in an interactive flow. Do not use an empty
variable or whitespace-only input in automation. Validate length/characters and
reject missing values before invoking the native command.

### Renaming a production volume without checking consumers

Applications, backup policies, monitoring, scripts, operators, mount logic, and
runbooks can display or match labels even though drive access still works.
Search dependencies, schedule the change, update inventories, and verify after.

## PowerShell behavior

Invoke `label.exe` explicitly and pass target and label as separate quoted
arguments. Prefer `Get-Volume` for typed inventory and `Set-Volume` when its
version/platform contract fits, but apply the same unique-identity and rollback
gates. Capture `$LASTEXITCODE` and requery rather than parsing prompt prose.

## Version and platform differences

This Windows-only command is documented on supported Windows client and server
releases. Label length, allowed characters, case display, filesystem behavior,
permissions, mount-point syntax, and clustered/virtual storage constraints vary.

## Related documents

- [vol](vol.md)
- [mountvol](mountvol.md)
- [format](format.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Label reference](https://learn.microsoft.com/windows-server/administration/windows-commands/label).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
