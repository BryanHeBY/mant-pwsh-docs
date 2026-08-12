<!-- mant:tldr:start -->
# refsutil.exe

> Identify the exact ReFS volume and query installed compression, I/O-metric, leak-analysis, and salvage capabilities before any repair or recovery operation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/refsutil.

- Inventory ReFS volumes with structured identity, health, size, and allocation data:

`Get-Volume | Where-Object FileSystemType -eq 'ReFS' | Format-Table DriveLetter, FileSystemLabel, Path, HealthStatus, OperationalStatus, Size, SizeRemaining`

- Display the command families installed on this exact Windows build:

`refsutil.exe`

- Query compression parameters on one confirmed ReFS volume:

`refsutil.exe compression {{F:}} /q`

- Query current ReFS I/O activity-tracking settings without enabling tracking:

`refsutil.exe iometrics {{F:}} /q`

- Estimate scratch space required for leak analysis before starting the scan:

`refsutil.exe leak {{F:}} /q`

- Diagnose a damaged source using a protected working directory on a different healthy volume:

`refsutil.exe salvage -D {{E:}} "{{F:\refs-work}}"`
<!-- mant:tldr:end -->

# refsutil.exe

## Overview

`refsutil.exe` is an advanced Windows family for Resilient File System (ReFS)
compression, cluster deduplication, boot-sector repair, I/O metrics,
allocated-space leak diagnosis/repair, damaged-volume salvage, stream snapshots, and
metadata triage. Its supported families and switches change with Windows build,
edition, ReFS on-disk version, feature set, and filesystem state.

RefsUtil is not a generic `fsck`, CHKDSK replacement, or data-recovery
guarantee. Before using it on unique data, preserve storage/controller events,
ReFS events, disk/virtual-disk topology, volume signature/version, sector and
cluster geometry, exact installed help, backup/replica status, and a block-level
recovery strategy. If the data is irreplaceable, stop writes and involve the
storage vendor or a qualified recovery service.

## Command-family map

<!-- mant:entries role=command case=insensitive -->
- `refsutil.exe`: Inspect, repair, or recover supported ReFS structures and data.
- `compression`: Query or configure ReFS volume compression.
- `dedup`: Scan for or consolidate equivalent ReFS clusters.
- `fixboot`: Repair or update ReFS boot-sector metadata.
- `iometrics`: Query or configure ReFS I/O activity tracking.
- `leak`: Estimate, diagnose, or repair allocated-space leaks/corruption.
- `salvage`: Diagnose/scan a damaged ReFS volume and copy recoverable files out.
- `streamsnapshot`: Create, list, query, or delete data-stream snapshots.
- `triage`: Scrub a directory or global ReFS tables.

The following common switches are case-sensitive across family-specific syntax;
always confirm installed help for the exact Windows build.

<!-- mant:entries role=option case=sensitive -->
- `/q`: Query state or estimate required scratch space without applying a repair.
- `/c`: Configure a supported family setting.
- `/s`: Scan or set tracking according to the selected family.
- `/d`: Diagnose leaks or perform deduplication according to family context.
- `/a`: Attempt repair in the leak family.
- `/x`: Force exclusive access/dismount and invalidate open handles.
- `/g`: Select global-table triage instead of directory triage.
- `-D`: Diagnose a Salvage source and initialize its work directory.
- `-QS`: Perform a quick Salvage scan.
- `-FS`: Perform a full Salvage scan.
- `-C`: Copy files found by a completed Salvage scan.
- `-SL`: Copy only files named by a reviewed selected-files list.
- `-IC`: Interactively select found files to copy.
- `-sv`: Assume the highest supported ReFS on-disk version; high risk.
- `-m`: Include deleted files in Salvage results.

| Family | Primary purpose | Boundary |
| --- | --- | --- |
| `compression` | Query or configure ReFS volume compression format, engine, and chunk size | `/q` queries; `/c` changes future/volume behavior and compatibility/performance. |
| `dedup` | Scan for equivalent clusters or deduplicate them | `/s` is a resource-intensive scan; `/d` changes allocation and is distinct from merely estimating savings. |
| `fixboot` | Repair/update ReFS boot-sector metadata | Writes filesystem boot metadata; version and cluster-size overrides must never be guessed. |
| `iometrics` | Query or configure volume activity tracking | `/q` queries; `/s` changes tracking and can impose workload/retention cost. |
| `leak` | Estimate, diagnose, and repair allocated-space leaks/corruption | `/q` estimates scratch; `/d` diagnoses leaks; `/a` may repair corruption; `/x` takes an exclusive lock. |
| `salvage` | Diagnose/scan a severely damaged ReFS source and copy recoverable files elsewhere | Work and target must not be on source; recovery is copy-out, not proof of in-place repair. |
| `streamsnapshot` | Create/list/query/delete snapshots of a file data stream | Stream chain, file identity, storage cost, application support, and build availability matter. |
| `triage` | Scrub a directory by file ID or global ReFS tables | A scrub is active filesystem work; `/s` and `/g` are mutually exclusive. |

## Salvage phases

Microsoft describes manual diagnose (`-D`), quick/full scans (`-QS`, `-FS`),
copy (`-C`), selected-list copy (`-SL`), and interactive copy (`-IC`), plus
quick/full automatic modes. Scan state and `foundfiles.<volume-signature>.txt`
are stored in the working directory so some scans can resume. The copy target
and working directory must be on storage other than the source volume.

Use `-D` first to assess filesystem/version/mountability. If the volume is
readable but read-only, Microsoft says copy accessible data without Salvage.
For a RAW/unmountable source, establish a forensic/recovery plan and adequate
healthy destination capacity before scanning. Review the generated file list
before copy; recovery can include stale/deleted versions and cannot establish
application consistency by itself.

## Common mistakes

### Running RefsUtil against NTFS, RAW identity guesses, or the wrong extent

A RAW presentation does not preserve a convenient drive-letter identity, and
Storage Spaces, RAID, virtual disks, snapshots, and mount points add layers.
Map physical disks/controller state to pool/virtual disk, partition, volume
signature, expected ReFS version, and historical mount point. Do not format,
initialize, or recreate a filesystem merely to give the damaged source a
letter.

### Using automatic Salvage before preserving the source

Automatic modes combine scan and copy with less review. The current upstream
page's automatic examples and two-phase parameter narrative are not fully
self-explanatory, so local help is mandatory. On unique data, preserve a
read-only image/snapshot when technically valid, stabilize underlying storage,
and prefer phased diagnosis, scan review, and copy to a separate healthy
target.

### Placing work or recovered files on the damaged source

Microsoft prohibits both the working directory and target directory from being
on the source volume. Doing so consumes source space, adds writes, risks losing
logs/checkpoints with the source, and can overwrite recoverable extents. Use
separate healthy storage with validated free space, ACLs, integrity, and backup.

### Treating a read-only volume as requiring Salvage

Microsoft says Salvage is normally for a volume appearing RAW; if files remain
accessible read-only, retrieve them directly. Copy the most valuable data first
to independent storage and verify hashes/application readability before adding
the I/O and complexity of a full scan.

### Skipping the volume-version check with `-sv`

`-sv` assumes the highest on-disk version the tool can handle, and Microsoft
warns of unexpected results. Mounting or repairing with a different Windows
build can also introduce version/feature questions reported in real incidents.
Match the originating/supported Windows version and seek Microsoft/vendor
guidance instead of forcing compatibility.

### Using `-m` as “recover more safely”

`-m` includes deleted files, increases time, and can produce unexpected/stale
versions, duplicate names, sensitive deleted content, and much larger capacity
requirements. Recover current namespace first where appropriate, protect the
output, and have application owners decide which versions are valid.

### Adding `-x` because the command is busy

`-x` forces a dismount and invalidates every open handle. Coordinate workloads,
clusters, backup software, antivirus, virtual disks, and mount points; confirm
that the selected source is not serving live data. Exclusive access does not
repair failing hardware or make a guessed command correct.

### Confusing leak diagnosis with repair

`leak /q` estimates scratch requirements. `/d` reports leaks without fixing
them; `/a` attempts to fix discovered corruption and can restart detection.
Microsoft notes that combining `/d` and `/a` triages directory/file corruption
but still does not fix leaks. Keep the exact mode, scratch file, thread count,
snapshot/exclusive behavior, and before/after allocation evidence together.

### Confusing a dedup scan with deduplication

`dedup /s` estimates savings; `/d` consolidates clusters. Both can be heavy I/O
and are not interchangeable with Windows Server Data Deduplication policy or a
backup product's ReFS block-cloning integration. Validate support, exclusions,
recovery/backup behavior, CPU/I/O budget, and resulting allocation before a
mutation.

### Guessing `fixboot` version or cluster size

This writes boot-sector metadata and can make recovery harder if geometry or
on-disk version is wrong. Capture multiple independent geometry/version sources
and use a Microsoft-supported recovery instruction for that specific volume;
never use it as a general first response to RAW state.

### Trusting every current Learn example literally

At the locked upstream revision, the `dedup` page calls its command
“compression,” and several family pages have banners broader than feature-
specific support notes. Treat these as documentation defects to resolve with
the target's `refsutil.exe` help, OS build/edition, ReFS version, and current
Microsoft support—not as license to combine switches from different builds.

## PowerShell boundaries

Pass scalar drive/mount-point paths and quote working, target, scratch, and file-
list paths. Keep source, work, and target canonical identities in the recovery
record. Capture raw native output and `$LASTEXITCODE` immediately, but use
structured Storage cmdlets and event logs for corroboration. Logs and recovered
files can contain sensitive names, deleted data, topology, and corruption
details; protect them accordingly.

## Version and platform differences

RefsUtil is Windows-only and evolves rapidly. Microsoft's Salvage page limits
that function to Windows 10 Pro for Workstations or later and Windows Server
2019 or later even though general page banners list broader client/server
releases. Other subcommands can require newer builds, ReFS versions, editions,
or features. Confirm executable help and Microsoft support for the exact host
and volume before every operation.

On the recorded Windows NT `10.0.26200.0` Chinese-localized client, exact
System32 file version `10.0.26100.3912` returned 0 for a bare invocation and
listed all eight families above. Top-level `/?` printed the same nine nonempty
lines but returned 22. Do not generalize `/?` to family help: without any
volume operand, `fixboot`, `leak`, `triage`, `streamsnapshot`, `compression`,
and `dedup` followed by `/?` printed syntax-like output and returned 87;
`salvage /?` first required elevation and returned 1314; and `iometrics /?`
entered a volume-hot-parameter error path and returned `-2147024891`. Start
discovery with the bare top-level command, treat localized text and native
status separately, and use family help only when its exact build-specific form
has been reviewed. No volume, work directory, target, or scratch path was
supplied, and no operation succeeded or changed filesystem state.

## Runtime evidence

On the recorded Windows NT 10.0.26200.0 Chinese-localized client, exact
System32 file version 10.0.26100.3912 bare invocation returned 0 and listed
eight families; top-level /? returned 22 with the same nine nonempty lines.
Family /? behavior was nonuniform: six syntax-like paths returned 87, salvage
required elevation and returned 1314, and iometrics entered a
volume-hot-parameter error path and returned -2147024891. No volume or path was
supplied and no operation succeeded; representative supported builds and
disposable ReFS volumes remain required.

## Related documents
- [fsutil.exe](fsutil.exe.md)
- [chkdsk.exe](chkdsk.exe.md)
- [diskpart.exe](diskpart.exe.md)
- [wbadmin.exe](wbadmin.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[RefsUtil family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/refsutil)
and its compression, dedup, fixboot, iometrics, leak, salvage, streamsnapshot,
and triage subcommand pages. The recurring RAW-volume, version, and missing-
backup concerns were cross-checked against
[a production ReFS incident](https://serverfault.com/questions/968966/refs-cant-be-mounted-any-more),
then resolved using the official phase, volume, and support boundaries. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
