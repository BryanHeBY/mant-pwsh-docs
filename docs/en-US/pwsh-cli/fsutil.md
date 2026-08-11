<!-- mant:tldr:start -->
# fsutil

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
<!-- mant:tldr:end -->

# fsutil

## Overview

`fsutil.exe` is an advanced administrative family for Windows filesystem and
volume internals. It queries and changes global/filesystem behavior, short
names, dirty state, file IDs/extents/valid-data length, hard links, reparse
points, sparse allocation, quotas, self-healing, USN journals, transactional
resources, storage tiers, WIM-backed files, Dev Drives, and volume state.

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

### Assuming redirected text is a stable data API

FSUtil output is native and can vary by build, locale, filesystem, and
subcommand. Prefer supported PowerShell/storage APIs for structured automation,
while retaining exact FSUtil output as diagnostic evidence when necessary.

## PowerShell behavior

Quote paths and volume GUIDs, pass scalar properties rather than formatted
objects, and capture `$LASTEXITCODE` immediately. Braces in volume/object IDs
must be quoted. Never interpolate untrusted offsets, lengths, SIDs, file IDs,
or behavior names into a privileged FSUtil mutation.

## Version and platform differences

This Windows-only administrative family evolves across Windows builds.
Subcommands and flags depend on NTFS, ReFS, FAT, Dev Drive, WIM backing,
storage tiers, filter drivers, local privileges, and installed components.
Use `fsutil.exe` and `fsutil.exe {{subcommand}} /?` on the target system.

## Related documents

- [chkdsk](chkdsk.md)
- [defrag](defrag.md)
- [mklink](mklink.md)

## Sources and license

This original guide was adapted from Microsoft's official
[FSUtil family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fsutil),
[behavior reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fsutil-behavior),
and [file reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fsutil-file).
The recurring negative `DisableDeleteNotify` interpretation was cross-checked
against
[practitioner discussion](https://superuser.com/questions/1741273/a-few-questions-on-command-fsutil-behavior-query-disabledeletenotify),
then resolved using Microsoft's documented scope and values. Exact sources and
licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Super User contributions are licensed under CC BY-SA 4.0.
