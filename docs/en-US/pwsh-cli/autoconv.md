<!-- mant:tldr:start -->
# autoconv

> Recognize the startup-only FAT/FAT32-to-NTFS conversion worker; use `convert.exe` to request a conversion.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/autoconv.

- Inspect a volume's filesystem and identity before considering conversion:

`Get-Volume -DriveLetter {{D}} | Format-List DriveLetter, FileSystem, FileSystemLabel, HealthStatus, Size, SizeRemaining`

- Read the supported front-end syntax; do not run `autoconv.exe` directly:

`convert.exe /?`

- Check the target volume before a separately approved conversion window:

`chkdsk.exe {{D:}}`
<!-- mant:tldr:end -->

# autoconv

## Overview

`autoconv.exe` is an internal startup worker used after `convert.exe` schedules
a FAT or FAT32 volume conversion to NTFS. It preserves existing files and
directories, but the filesystem conversion cannot be reversed to FAT/FAT32.
Microsoft explicitly says AutoConv cannot be run from the command line.

## Common mistakes

### Calling the worker directly

Use `convert.exe` as the supported front end. A copied command line for
`autoconv.exe` is not a supported shortcut and omits the scheduling and
validation performed by the front end.

### Describing conversion as reversible or risk-free

NTFS cannot be converted back in place by AutoConv. Confirm application,
firmware, removable-media, dual-boot, and recovery compatibility; verify a
restorable backup and stable storage before requesting conversion.

### Confusing filesystem conversion with formatting

Conversion retains the existing tree; formatting creates a filesystem and can
destroy the previous one. Record the exact volume ID, not only a drive letter,
and stop if the selected target is ambiguous.

## PowerShell behavior

Use typed `Get-Volume` inventory where available, but invoke the native
`convert.exe` only during an approved change. Capture its output and
`$LASTEXITCODE` immediately. A future-startup schedule is not completed work;
verify the filesystem and events after restart.

## Version and platform differences

This Windows-only internal component applies to the FAT/FAT32-to-NTFS startup
path. Filesystem, boot-volume, encryption, recovery, and removable-media
constraints require target-system verification.

## Related documents

- [DiskPart conversion and volume operations](diskpart.md)
- [autochk](autochk.md)
- [format](format.md)

## Sources and license

This original guide was adapted from Microsoft's official
[AutoConv reference](https://learn.microsoft.com/windows-server/administration/windows-commands/autoconv)
and its linked Convert workflow. Exact provenance is recorded in
`upstream/cli.json`. Microsoft documentation and this adaptation are licensed
under CC BY 4.0.
