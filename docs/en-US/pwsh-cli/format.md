<!-- mant:tldr:start -->
# format

> Create a new filesystem only after proving the target volume identity and restore path; this destroys the volume's existing filesystem and data.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/format.

- Display the syntax supported by this Windows build without touching a volume:

`format.exe /?`

- Correlate drive letters, labels, filesystem types, sizes, and unique volume paths before selecting a target:

`Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem, Size, SizeRemaining, UniqueId, Path`

- Correlate the proposed volume with its partition and physical disk instead of trusting a drive letter alone:

`Get-Partition -DriveLetter {{X}} | Get-Disk | Select-Object Number, FriendlyName, SerialNumber, UniqueId, BusType, Size`

- After verified backup/restore, maintenance, and target-identity gates, format exactly the reviewed placeholder volume:

`format.exe "{{X:}}" /FS:{{NTFS}} /V:"{{LABEL}}"`

<!-- mant:tldr:end -->

# format

## Overview

`format.exe` creates a new filesystem on a volume, mount point, or drive
letter. It destroys the existing filesystem namespace and data on that target.
The filesystem, allocation unit, label, compression, integrity, short-name,
trim, Dev Drive, DAX, and overwrite options can also change compatibility,
performance, or recovery behavior.

Formatting is not partition creation, a dry run, backup, hardware repair, or a
universal media-sanitization method. Establish the exact disk, partition,
volume GUID, drive letter, workload owner, encryption state, and verified
restore path before invoking it. Prefer an isolated maintenance console so a
mistake does not also destroy remote access.

## Quick, full, and overwrite modes

- `/Q` deletes filesystem tables and skips the sector-by-sector bad-area scan.
  Microsoft restricts it to previously formatted volumes known to be healthy.
- A full format takes much longer because it examines the volume; on supported
  modern Windows releases it also writes across the volume.
- `/P:count` zeroes every sector and then performs `count` additional random
  overwrites. `/Q` overrides and disables `/P`.
- Neither mode necessarily sanitizes remapped, reserved, cached, snapshot,
  replica, thin-provisioned, SSD flash, or backup copies. Use the device and
  organization's approved cryptographic erase or sanitize process when data
  disposal is the objective.

## Filesystem and feature choices

Use the installed `format /?` and the target workload's support matrix. Valid
filesystems and options vary by Windows release, media, sector size, and role.
The default allocation unit is normally the safest general-purpose choice.
In particular, NTFS compression is unavailable above a 4096-byte allocation
unit, ReFS integrity and Dev Drive options have different goals, DAX requires
capable hardware, and `/NoTrim` changes storage-notification behavior.

Explicitly decide the label. Without a suitable `/V` value, format can prompt
afterward; `/Y` suppresses the force-dismount prompt and assumes an empty label,
so it is not a general unattended-safety switch.

## Common mistakes

### Formatting the right letter on the wrong device

Drive letters are mutable access paths, not durable device identities. Match
the volume GUID, partition offsets and size, disk number, serial/unique ID,
bus type, and application ownership. Remove or offline unrelated removable
media where practical, then revalidate immediately before the command.

### Treating `/Q` as preview, safe deletion, or secure erase

Quick format is destructive and intentionally skips a media scan. Recoverable
content can remain. It is neither a dry run nor a sanitization guarantee, and
combining it with `/P` silently defeats the requested overwrite behavior.

### Forcing a dismount while applications are active

`/X` invalidates open handles. Stop databases, virtual machines, services,
backup jobs, replicas, and mounts through supported procedures first. Confirm
there is no paging, dump, boot, recovery, cluster, Storage Spaces, or other
system dependency on the volume.

### Assuming a successful format proves healthy storage

A format result describes that operation, not end-to-end health. Correlate
device/controller events, SMART or NVMe health, enclosure paths, redundancy,
firmware, and workload I/O. Preserve evidence before stressing a failing
device; image valuable data first.

### Choosing advanced options from a generic recipe

Large allocation units, ReFS integrity, compression, short names, TxF, DAX,
Dev Drive, checksum, trim, and repair-log choices have workload- and version-
specific effects. Validate support, backup/restore, servicing, security tools,
and measured performance on disposable media before production use.

### Ignoring BitLocker, EFS, snapshots, and replicas

Formatting an unlocked BitLocker volume does not manage every key or copy.
EFS recovery depends on certificates, while VSS, backup, replication, cloud,
and application copies can retain data. Inventory each layer independently.

## Exit status and PowerShell behavior

Microsoft documents `0` for success, `1` for invalid parameters, `4` for a
fatal error, and `5` when the operator declines the confirmation. Capture
`$LASTEXITCODE` immediately, preserve the transcript, and verify the resulting
volume by unique identity and expected filesystem. Never translate every
nonzero value into the same failure message.

PowerShell can resolve functions or aliases before an application. Invoke
`format.exe` explicitly, quote mount-point paths, and never construct a target
from unvalidated text or a first-match pipeline.

## Version and platform differences

This administrative command is Windows-only. Filesystems, flags, Recovery
Environment syntax, maximum sizes, feature support, and defaults differ by
Windows build and storage stack; local help and current Microsoft guidance are
part of the change review.

## Related documents

- [diskpart](diskpart.md)
- [mountvol](mountvol.md)
- [manage-bde](manage-bde.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Format reference](https://learn.microsoft.com/windows-server/administration/windows-commands/format).
Microsoft's archived but still maintained
[format-behavior article](https://learn.microsoft.com/previous-versions/troubleshoot/windows-server/format-command-not-write-zeros-to-disk)
establishes the Vista-and-later full-format zero-write behavior and its
thin/on-demand-allocation consequence.
Recurring confusion about full versus quick formatting and bad-sector scans
was cross-checked against a high-quality
[practitioner question and answers](https://superuser.com/questions/1596556/does-a-full-format-on-a-modern-windows-system-really-check-for-bad-sectors).
Syntax and supported behavior follow Microsoft's current reference. Exact
sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
