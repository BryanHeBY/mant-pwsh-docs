<!-- mant:tldr:start -->
# diskmgmt.msc

> Open Disk Management only after resolving disk number, unique ID, bus/location, partition/volume/filesystem roles, boot/recovery/encryption state, health and backup; GUI selection by position or drive letter is not enough.
> More information: https://learn.microsoft.com/windows-server/storage/disk-management/overview-of-disk-management.

- Open the Disk Management MMC snap-in:

`diskmgmt.msc`

- Launch Disk Management explicitly through Microsoft Management Console:

`mmc.exe diskmgmt.msc`
<!-- mant:tldr:end -->

# diskmgmt.msc

## Overview

Disk Management is the Windows GUI for viewing and changing disks, partitions,
volumes, drive letters and selected storage configuration. Initialize, format,
delete, shrink, extend, convert, offline/online and letter actions can destroy data,
break boot/recovery, expose volumes, or affect encryption and applications.

## Entry points

<!-- mant:entries role=command case=insensitive -->
- `diskmgmt.msc`: Open Disk Management for interactive storage inspection and administration.
- `mmc.exe`: Host `diskmgmt.msc` explicitly; the GUI is not a transactional storage API.

Corroborate the selected disk/volume through stable identifiers and preserve a
recoverable backup before any layout, filesystem, or access change.

## Common mistakes

- Choosing “Disk 1” or a drive letter from memory/screenshot without unique ID,
  serial/path/bus, size, partition GUIDs, volume IDs and current rescan evidence.
- Initializing a disk reported unknown/not initialized before distinguishing a new
  blank device from damaged metadata, cabling/controller issues or wrong target.
- Formatting/deleting a volume to solve access/space problems without image-level
  backup, file recovery, application consistency and exact filesystem identity.
- Assuming Extend works with any free space or disk layout; adjacency, filesystem,
  partition style, dynamic/basic/storage technologies and boot roles constrain it.
- Modifying EFI System or Recovery partitions because the GUI reports free space;
  Microsoft explicitly recommends not modifying these critical partitions.
- Converting basic/dynamic, changing letters, or taking disks offline without
  cluster, mount-point, service, paging, dump, BitLocker and recovery review.

## PowerShell behavior

Use `Start-Process diskmgmt.msc` for interactive launch. For automation, prefer
Storage cmdlets or reviewed DiskPart scripts with unique identity assertions,
pre/post inventory, backups, explicit confirmation, native status and rollback.

## Version and platform differences

`diskmgmt.msc` is Windows-only. Supported operations and remote behavior vary by
build, edition, VDS/Storage stack, disk/partition type, filesystem and hardware.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\diskmgmt.msc`. It exposed no nonzero four-part
fixed file version through `FileVersionInfo`; the audit retains that as absent
rather than inventing `0.0.0.0`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [diskpart.exe](diskpart.exe.md)
- [fsutil.exe](fsutil.exe.md)
- [mountvol.exe](mountvol.exe.md)
- [manage-bde.exe](manage-bde.exe.md)
- [reagentc.exe](reagentc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Disk Management overview](https://learn.microsoft.com/windows-server/storage/disk-management/overview-of-disk-management)
and [Disk Management troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/backup-and-storage/troubleshoot-disk-management).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
