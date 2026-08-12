<!-- mant:tldr:start -->
# autofmt.exe

> Recognize the internal recovery formatting worker; do not launch it from a normal command line.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/autofmt.

- Inventory volumes and unique identities before entering a recovery workflow:

`Get-Volume | Sort-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, HealthStatus, Size`

- Open Windows Recovery options through the supported Settings URI:

`Start-Process 'ms-settings:recovery'`

- Read the documented interactive formatter syntax instead of invoking AutoFmt:

`format.com /?`
<!-- mant:tldr:end -->

# autofmt.exe

## Overview

`autofmt.exe` is the Auto File System Format Utility called from a Windows
recovery workflow. Microsoft states that it cannot be run directly from the
command line. It is not a general replacement for `format.com`, DiskPart,
Disk Management, or supported Windows Recovery Environment procedures.

## Invocation boundary

<!-- mant:entries role=command case=insensitive -->
- `autofmt.exe`: Internal Windows recovery formatting worker; never invoke directly.

Microsoft exposes no supported public parameters. Use the exact supported
recovery or formatting workflow after independently verifying the target.

## Common mistakes

### Treating an internal executable as a public CLI

Do not reverse-engineer or copy an AutoFmt command line from process listings.
Use the supported recovery or formatting front end and its current help.

### Selecting a recovery volume by its normal drive letter

Drive letters can change in WinRE. Identify the target using size, label,
filesystem, disk/partition identity, and contents before any destructive step.

### Treating a format as repair or secure erasure

Formatting is destructive filesystem creation. It is not a backup, a general
hardware repair, or a guaranteed media sanitization method. Match the action to
the incident and preserve recoverable data first.

## PowerShell boundaries

The TLDR inventory is for normal Windows preparation only. PowerShell may not
be present in the recovery environment, and objects gathered online must be
re-correlated with recovery-environment disk identities before a change.

## Version and platform differences

This Windows-only internal component belongs to recovery processing. WinRE
availability, BitLocker state, storage drivers, and drive-letter assignment
vary by device and environment.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`autofmt.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains online inventory/settings launch/help
only; no recovery boot, AutoFmt invocation, format, filesystem, volume,
partition, encryption or boot mutation is permitted merely for evidence.

## Related documents
- [format.com](format.com.md)
- [diskpart.exe](diskpart.exe.md)
- [reagentc.exe](reagentc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[AutoFmt reference](https://learn.microsoft.com/windows-server/administration/windows-commands/autofmt)
and linked Windows Recovery Environment guidance. Exact provenance is recorded
in `upstream/windows-tools.json`. Microsoft documentation and this adaptation are
licensed under CC BY 4.0.
