<!-- mant:tldr:start -->
# chkdsk

> Scan one local filesystem first, then choose online, spot, or offline repair from evidence and a current backup.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chkdsk.

- Display a read-only status report for one exact local volume:

`chkdsk.exe "{{C:}}"`

- Run an online NTFS scan and immediately preserve its documented result code:

`chkdsk.exe "{{C:}}" /scan; $chkdskExitCode = $LASTEXITCODE`

- Run the online scan faster only during an approved maintenance window:

`chkdsk.exe "{{D:}}" /scan /perf`

- Repair logical errors on an exact offline or lockable volume after backup:

`chkdsk.exe "{{D:}}" /f`

<!-- mant:tldr:end -->

# chkdsk

## Overview

`chkdsk.exe` checks filesystem structures and metadata on a local volume.
Without a repair option it reports status; `/scan` performs an online NTFS
scan. `/f` fixes logical errors and needs an exclusive lock, `/spotfix` repairs
previously identified NTFS defects with short offline time, and
`/offlinescanandfix` combines offline scanning and repair. `/r` additionally
reads sectors to locate bad areas and recover readable data; it includes `/f`.

Filesystem repair is not hardware repair, backup, malware cleanup, or Windows
component repair. A failing device can deteriorate under heavy reads. Preserve
important data and storage-health evidence before a repair or surface scan.

## Operation and filesystem matrix

| Option | Scope | Main consequence |
| --- | --- | --- |
| no repair option | Read-only status report | An active unlocked volume can produce transient/spurious findings. |
| `/scan` | Online NTFS scan | Finds issues while mounted; may repair online unless `/forceofflinefix` queues them. |
| `/scan /forceofflinefix` | Online NTFS detection | Defects are queued for later offline repair. |
| `/spotfix` | NTFS spot repair | Requires offline access and repairs recorded defects rather than a full rescan. |
| `/f` | Logical filesystem repair | Locks or schedules the volume and changes metadata. |
| `/r` | `/f` plus allocated/free sector reads | Can take hours or longer and heavily reads the device. |
| `/b` | NTFS `/r` plus reset of bad-cluster list | Intended after imaging to new media, not as routine maintenance. |
| `/i`, `/c` | Reduced NTFS checks | Faster because checks are skipped; not equivalent to a full clean bill of health. |
| FAT-family recovery options | FAT/FAT32/exFAT only | Orphan handling can discard or recover chains; decide from backup/recovery needs. |

Use the installed `chkdsk /?` because filesystem and recovery-environment
support can differ. A drive letter redirected to a network share is not a
supported local target.

## Exit codes

CHKDSK uses result codes, not a simple zero/nonzero success contract:

- `0`: no errors found;
- `1`: errors found and fixed;
- `2`: cleanup occurred, or cleanup was not performed because `/f` was absent;
- `3`: the volume could not be checked, or errors were not/could not be fixed.

Capture `$LASTEXITCODE` immediately and interpret it together with the exact
mode and saved report. Code `1` can be a completed repair, while code `0` from
an online scan does not prove the storage hardware is healthy.

## Common mistakes

### Using `/r` whenever `/f` is mentioned

`/r` includes `/f` but also reads allocated and free sectors. That greatly
expands runtime and I/O and can stress a failing device. Use it when media/read
errors or an approved post-image validation require a surface scan; use the
smallest mode supported by the evidence for logical corruption.

### Running repair before protecting data

Repair deliberately changes metadata and can recover or discard orphaned
content. If the device is failing, image/recover valuable data with an
appropriate storage-recovery process first. Confirm backups can be restored;
do not present CHKDSK as a substitute for them.

### Forcing `/x` on a busy application volume

`/x` dismounts the volume, invalidates open handles, and includes `/f`.
Applications can lose writes or fail. Stop and verify workloads through their
supported maintenance procedure, or schedule appropriate offline repair.

### Assuming a read-only scan of an active volume is definitive

Microsoft notes that an unlocked active partition can report spurious errors.
Correlate `/scan`, dirty state, storage events, application I/O errors, and a
controlled offline check when necessary. Do not schedule repair automatically
from one parsed sentence.

### Treating a boot-time prompt as a completed schedule

Interactive `chkdsk C: /f` may ask whether to schedule after it cannot lock the
volume. Automation must not rely on locale-specific prompt injection. Use an
approved scheduling mechanism, verify with `chkntfs C:`, plan downtime, and
collect the later Wininit/Chkdsk event.

### Combining fast-scan switches and claiming full verification

NTFS `/i` and `/c` skip or reduce checks. `/perf` does not skip checks but uses
more resources with `/scan` and can harm workload latency. Record every option
and never summarize a reduced check as a complete scan.

### Using CHKDSK to diagnose all storage or Windows errors

CHKDSK addresses filesystem consistency. SMART/NVMe/device health, controller
and cable errors, storage spaces/RAID state, VSS, Windows protected files, and
application databases need their own tools. `sfc` and DISM do not replace
filesystem or hardware diagnosis either.

### Ignoring time and interruption risk

Large `/f`, `/r`, or `/b` operations can run for a long time. Ensure stable
power, cooling, maintenance time, backups, and a recovery route. Avoid
interrupting CHKDSK; if interruption occurs, collect state and rerun the
appropriate check rather than assuming completion.

## Logs and verification

Boot-time repairs normally write Application-log events from `Wininit`; online
runs can use `Chkdsk`. Query by provider and time through `Get-WinEvent` rather
than searching translated message text alone. Preserve the command, volume
identity, filesystem, exit code, timestamps, event record, dirty state, and
storage-health evidence.

## PowerShell behavior

CHKDSK is a native text command. Specify the volume explicitly, capture output
and `$LASTEXITCODE`, and do not treat nonzero as generic process failure.
PowerShell's preference-based native error integration can obscure these
documented result codes, so handle the process result deliberately.

## Version and platform differences

This Windows-only command applies to supported Windows client and server
releases. Options vary by NTFS versus FAT/FAT32/exFAT and by the running or
recovery environment. Local disk, cluster/storage virtualization, snapshots,
encryption, device health, and workload ownership constrain safe use.

## Related documents

- [chkntfs](chkntfs.md)
- [defrag](defrag.md)
- [sfc](sfc.md)

## Sources and license

This original guide was adapted from Microsoft's official
[CHKDSK reference](https://learn.microsoft.com/windows-server/administration/windows-commands/chkdsk).
The recurring `/f` versus `/r` question was cross-checked against
[practitioner discussion](https://superuser.com/questions/315878/what-is-the-difference-between-chkdsk-f-and-chkdsk-r),
while syntax, scope, and exit-code conclusions follow Microsoft's current
reference. Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Super User contributions are licensed under CC BY-SA 4.0.
