<!-- mant:tldr:start -->
# fsutil.exe

> Query advanced Windows filesystem, volume, link, sparse-file, journal, and global behavior state before using mutating subcommands.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/fsutil.

- List filesystem drive roots visible to the current host:

`fsutil.exe fsinfo drives`

- Show filesystem and volume identity for one exact volume:

`fsutil.exe fsinfo volumeinfo "{{C:}}"`

- Query the dirty bit without scheduling or repairing anything:

`fsutil.exe dirty query "{{C:}}"`

- Query delete-notification policy for NTFS and ReFS; zero means notifications are enabled:

`fsutil.exe behavior query DisableDeleteNotify`

- List every hard-link name for one exact file:

`fsutil.exe hardlink list "{{file}}"`

- Inspect reparse-point metadata without following or deleting it:

`fsutil.exe reparsepoint query "{{path}}"`

- Query BypassIO support and the first vetoing filter/storage driver on a
  supported Windows 11 path:

`fsutil.exe bypassIo state /v "{{path}}"`
<!-- mant:tldr:end -->

# fsutil.exe

## Overview

`fsutil.exe` is an advanced administrative family for Windows filesystem and
volume internals. It queries and changes global/filesystem behavior, short
names, dirty state, file IDs/extents/valid-data length, hard links, reparse
points, sparse allocation, quotas, self-healing, USN journals, transactional
resources, storage tiers/reserves, DAX alignment, BypassIO support, NTFS trace
sessions, WIM-backed files, Dev Drives, and volume state.

Microsoft limits FSUtil to administrators and advanced users with a thorough
understanding of Windows. Many subcommands bypass ordinary file abstractions or
change machine-wide policy. Start with query/help forms installed on the exact
Windows build; do not generalize one subcommand's syntax or units to another.

## Subcommand map

| Family | Primary purpose | Mutating risk to contain |
| --- | --- | --- |
| `fsinfo` | Drive, volume, filesystem, NTFS and statistics inventory | Mostly query; output/fields vary by filesystem/version. |
| `dirty` | Query or set the volume dirty bit | Setting schedules Autochk behavior; repair clears state through supported checks. |
| `behavior` | Query/set filesystem and global behaviors | Negative option names, global scope, reboot requirements, compatibility impact. |
| `8dot3name` | Query/change short-name creation and strip names | Removing existing names can break registry/application paths. |
| `file` | File IDs, extents, allocation, EOF, VDL, zeroing, creation | `seteof`, `setvaliddata`, and `setzerodata` can expose, truncate, or destroy data. |
| `hardlink` | List/create names for the same file record | Links share content and must remain on one volume. |
| `reparsepoint` | Query/delete reparse metadata | Reparse types belong to filesystems/filter drivers; deletion can break products/paths. |
| `sparse` | Query/set sparse flag and ranges | Range deallocation changes file allocation/content semantics. |
| `objectid` | Manage file object identifiers | Tracking/replication consumers can depend on IDs. |
| `quota` | Query/configure per-volume NTFS quotas | Enforcement, tracking, SID identity, and remote storage behavior matter. |
| `repair` | Query/change self-healing and initiate verification | Can trigger I/O/repairs and changes corruption handling. |
| `usn` | Query/manage NTFS change journal | Deleting a journal disrupts backup, index, replication, and monitoring consumers. |
| `volume` | Free-space/cluster queries and dismount | Dismount invalidates workload handles. |
| `tiering` | Storage-tier flags and inventory | Requires supported tiered storage and workload policy. |
| `resource`, `transaction` | Transactional resource managers/transactions | TxF/resource-manager recovery is specialized and compatibility-sensitive. |
| `clfs` | CLFS log authentication/correction | Specialized log repair can affect dependent services. |
| `devdrv` | Dev Drive and minifilter management | Security/performance policy and build availability matter. |
| `wim` | Discover/manage WIM-backed files | Servicing/backing-image dependencies constrain changes. |
| `bypassIo` | Query BypassIO support/veto diagnostics for a path | Windows 11/build/storage/filter dependent; verbose output names drivers. |
| `dax` | Query DAX file-alignment ranges | DAX/architecture dependent; offsets, range count, and byte lengths matter. |
| `storageReserve` | Query/find or repair storage-reserve areas | `repair` mutates reserve state; IDs and volume identity must be exact. |
| `trace` | Query, start, stop, or decode an NTFS trace | Start/stop change tracing; decode can create or replace report artifacts. |

These families are resolvable semantic command entries. Each has its own
verbs, units, filesystem requirements, privileges, and target-local help.

<!-- mant:entries role=command case=insensitive -->
- `fsutil.exe`: Display installed FSUtil families or run one advanced filesystem task.
- `8dot3name`: Query/change short-name policy, scan dependencies, or strip names.
- `behavior`: Query or change global and filesystem behavior settings.
- `bypassio`: Query whether BypassIO is supported for a path and report veto
  diagnostics on builds that expose the family.
- `clfs`: Create or correct authentication codes for CLFS log files.
- `dax`: Query file-alignment ranges on a supported DAX volume.
- `devdrv`: Manage Dev Drive state and allowed minifilters where supported.
- `dirty`: Query or set a volume dirty bit.
- `file`: Query or change file IDs, ranges, EOF, valid data, allocation, or names.
- `fsinfo`: List drives or query volume/filesystem information and statistics.
- `hardlink`: List or create hard-link names for a file.
- `objectid`: Query, create, delete, or set file object identifiers.
- `quota`: Query or configure NTFS quota tracking, enforcement, and thresholds.
- `repair`: Query/change self-healing or start and monitor supported verification.
- `reparsepoint`: Query or delete reparse-point metadata.
- `resource`: Inspect or administer a Transactional NTFS resource manager.
- `sparse`: Query/set sparse state or change allocated ranges.
- `storagereserve`: Query or find storage-reserve data, or repair reserve areas
  on builds that expose the family.
- `tiering`: Inspect or administer supported storage-tier functions.
- `trace`: Query, start, stop, or decode the installed NTFS trace session.
- `transaction`: List, inspect, commit, or roll back filesystem transactions.
- `usn`: Inspect, create, configure, or delete an NTFS USN change journal.
- `volume`: Query free/cluster state, locate cluster users, or dismount a volume.
- `wim`: Discover or administer WIM-backed file state.

## Common mistakes

### Reading `DisableDeleteNotify = 0` as “TRIM disabled”

The option is negatively named: zero means delete notifications are enabled;
one means disabled. The query reports filesystem policy (often separate NTFS
and ReFS values), not each physical SSD. It does not prove the complete stack
or device honored a notification; use appropriate storage evidence and retrim
tools for that question.

### Changing `behavior` from a one-line tuning recipe

Options can be global or filesystem/volume-specific, take effect only after a
restart, and affect compression, encryption, last-access timestamps, short
names, corruption handling, TxF, tiering, paging-file encryption, symlink
evaluation, MFT zone, memory, quotas, and TRIM. Record scope/default/dependency
and test workload compatibility before any `set`.

### Setting the dirty bit as a repair

`dirty set` marks a volume so Autochk checks it at restart; it does not repair
corruption. Do not use it to fabricate health evidence or create unplanned
downtime. Query first, plan CHKDSK mode and restart, and collect the resulting
event and post-check state.

### Treating a hard link as a copy or shortcut

All hard-link names reference the same file record and content; modification
through one name is visible through all. The file is removed only after all
links are deleted. Hard links cannot cross volumes. Inventory link names and
backup/retention behavior before creating or deleting them.

### Confusing hard links, symbolic links, junctions, and reparse points

Hard links are multiple names for one file record. Symbolic links and
junctions are reparse-point-based indirections, and other reparse tags belong
to cloud, HSM, WIM, deduplication, or filter-driver features. Never delete
unknown reparse metadata merely because a path looks like a link.

### Using `setzerodata` or sparse ranges as harmless space reclamation

Zeroing/deallocating a range changes the file's logical content/allocation and
can corrupt databases, VHDs, archives, or application formats. Validate byte
offset/length units, file ownership, locks, backups, and format-specific sparse
support; test on a disposable copy.

### Using `setvaliddata` to create a large file casually

VDL differs from end-of-file and this operation requires volume-maintenance
privilege for specialized I/O scenarios. Incorrect values can make stale disk
content logically valid or violate application assumptions. Use normal file
APIs unless a reviewed storage design explicitly requires VDL manipulation.

### Deleting the USN journal to fix its size

Backup, replication, indexing, antivirus, and change-monitoring tools use the
journal. Deletion/recreation can trigger full rescans or data-protection gaps.
Identify every consumer, current journal ID/range, supported sizing policy,
maintenance impact, and post-change resynchronization.

### Stripping 8.3 names without scanning dependencies

Legacy applications, installers, scripts, and registry values may contain
short paths. Use the scan capability and application/vendor testing first.
Removing short names is not equivalent to merely disabling future generation
and may be difficult to reverse accurately.

### Dismounting a volume during diagnosis

`fsutil volume dismount` changes availability and invalidates handles. Use
query forms for inventory and follow filesystem, application, cluster, VSS,
encryption, and storage-owner maintenance procedures before dismount.

### Omitting Trace operands to discover syntax

`fsutil trace start` and `fsutil trace stop` are actions, not usage requests.
On Windows build `10.0.26200`, a bounded probe found no existing Data Collector
Set, `start` failed, yet bare `stop` still printed “Successfully stopped” with
exit 0. Use top-level `fsutil trace` inventory or an explicitly verified help
form; never omit operands from an unfamiliar verb and assume it cannot act.

### Treating Trace decode or StorageReserve repair as queries

Trace `decode` converts an ETL and can write reports, including an explicit
overwrite mode. `storageReserve repair` changes reserve state; it is not a
synonym for `query` or `findByID` and not a general filesystem repair. Preflight
every input/output path, protect trace contents, and use exact volume/ID scope
only under an approved maintenance procedure.

### Reading a BypassIO veto as general storage failure

The Windows 11 query is diagnostic: it can report full, partial, or blocked
support and identify the first filter/storage driver plus reason. BitLocker,
minifilters, storage type, filesystem, client/server release, and the selected
path all affect the answer. A veto means the optimized path is unavailable for
that context; it does not by itself prove ordinary I/O or the device failed.

### Assuming redirected text is a stable data API

FSUtil output is native and can vary by build, locale, filesystem, and
subcommand. Prefer supported PowerShell/storage APIs for structured automation,
while retaining exact FSUtil output as diagnostic evidence when necessary.

## PowerShell boundaries

Quote paths and volume GUIDs, pass scalar properties rather than formatted
objects, and capture `$LASTEXITCODE` immediately. Braces in volume/object IDs
must be quoted. Never interpolate untrusted offsets, lengths, SIDs, file IDs,
or behavior names into a privileged FSUtil mutation. Some family verbs use
status unusually: on the recorded build `trace query` printed “Data Collector
Set was not found” but returned 0, while `trace stop` also returned 0. Preserve
the full verb, output, state-before/state-after evidence, and exit code.

## Version and platform differences

This Windows-only administrative family evolves across Windows builds.
Subcommands and flags depend on NTFS, ReFS, FAT, Dev Drive, WIM backing,
storage tiers, filter drivers, local privileges, and installed components.
Current installed help additionally exposes `bypassIo`, `dax`,
`storageReserve`, and `trace`, which Microsoft's current FSUtil family index
omits. BypassIO starts with Windows 11 and has client/filesystem/storage/filter
limits. Use top-level family inventory and only help forms already verified for
the exact verb; do not rely on missing operands as discovery.

## Runtime evidence

Installed top-level `fsutil.exe` inventory returned status `0` and exposed 24
families, including build-local `bypassIo`, `dax`, `storageReserve`, and
`trace`. Read-only family help/query mappings were recorded. An accidental
missing-operand trace action was bounded by before/after checks: no session or
artifact existed before or after, but the attempted stop remains an action and
is retained as a procedural warning. No filesystem mutation ran;
feature-specific disposable-volume verification remains pending.

## Related documents

- [chkdsk.exe](chkdsk.exe.md)
- [defrag.exe](defrag.exe.md)
- [mklink](mklink.md)

## Sources and license

This original guide was adapted from Microsoft's official
[FSUtil family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fsutil),
[behavior reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fsutil-behavior),
the [file reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fsutil-file),
and Microsoft's [BypassIO architecture and query guidance](https://learn.microsoft.com/windows-hardware/drivers/ifs/bypassio).
The recurring negative `DisableDeleteNotify` interpretation was cross-checked
against
[practitioner discussion](https://superuser.com/questions/1741273/a-few-questions-on-command-fsutil-behavior-query-disabledeletenotify),
then resolved using Microsoft's documented scope and values. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Super User contributions are licensed under CC BY-SA 4.0.
