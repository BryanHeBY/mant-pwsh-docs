<!-- mant:tldr:start -->
# vssadmin

> Inventory Volume Shadow Copy Service (VSS) writers, providers, storage associations, and shadow-copy identity before changing or deleting anything.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/vssadmin.

- List registered writers and preserve each state, last error, writer ID, and instance ID:

`vssadmin.exe list writers`

- List installed providers before attributing a snapshot to Microsoft or backup software:

`vssadmin.exe list providers`

- Show used, allocated, and maximum diff-area storage associations:

`vssadmin.exe list shadowstorage`

- List shadow copies for one exact source volume:

`vssadmin.exe list shadows /for={{C:}}`

- Re-query one shadow by the exact ID returned above; quote braces in PowerShell:

`vssadmin.exe list shadows "{{/shadow={shadow-copy-ID}}}"`
<!-- mant:tldr:end -->

# vssadmin

## Overview

`vssadmin.exe` is an administrative interface to Volume Shadow Copy Service
(VSS). It inventories writers, providers, shadow copies, and diff-area
associations; installed versions can also create or delete shadows and resize
shadow storage. Current Microsoft command pages prominently expose `delete
shadows`, `list shadows`, `list writers`, and `resize shadowstorage`, while
installed help and Microsoft's VSS overview may expose additional verbs such
as provider and storage inventory. Treat local help as the executable contract.

VSS coordinates a requester, application writers, a provider, source volumes,
and shadow-copy storage. A successful query of one component is not proof that
a later application-consistent backup will complete or be restorable.

## Command-family map

| Family | Purpose | Boundary |
| --- | --- | --- |
| `list writers` | Writer IDs, instances, state, and last error | A point-in-time observation; correlate with the failed operation and VSS/application events. |
| `list providers` | Registered system, software, or hardware providers | Registration is not proof that a provider serviced a particular shadow. |
| `list shadows` | Shadow sets, IDs, source volume, device object, provider, type, and attributes | Use the exact shadow ID or `/for=` volume; do not infer ownership from age alone. |
| `list shadowstorage` | Source (`For`) to diff-area (`On`) association and used/allocated/maximum space | Distinguish three capacity values and two volume roles. |
| `resize shadowstorage` | Change the association maximum | Microsoft warns that resizing can make shadows disappear. |
| `delete shadows` | Remove one, oldest, or all eligible shadows | Removes recovery/backup dependencies; it is not generic disk cleanup. |
| `create shadow` | Create a system-provider shadow where the installed version supports it | A snapshot is not automatically application-consistent, retained, exported, or backed up. |

The following families are resolvable as complete ManT command entries; local
verb help remains authoritative because installed Windows versions differ.

<!-- mant:entries role=command case=insensitive -->
- `vssadmin.exe`: Inspect or administer VSS state exposed by the installed build.
- `list writers`: List registered VSS writers, current state, and last error.
- `list providers`: List registered VSS providers.
- `list shadows`: List shadow copies, optionally filtered by source volume or ID.
- `list shadowstorage`: List source/diff-area associations and capacity values.
- `create shadow`: Create a system-provider shadow where this verb is available.
- `delete shadows`: Delete one, oldest, or all eligible system-provider shadows.
- `add shadowstorage`: Add a source-to-diff-area association where available.
- `resize shadowstorage`: Change an association's maximum diff-area size.
- `delete shadowstorage`: Remove an association where the installed build supports it.

Parameters below are valid only with the verbs that document them. Values use
an equals sign in native syntax, such as `/for=C:` and `/maxsize=10GB`.

<!-- mant:entries role=option case=insensitive -->
- `/for`: Select the protected source volume.
- `/on`: Select the volume holding shadow-copy diff-area storage.
- `/shadow`: Select one exact shadow-copy ID.
- `/oldest`: Select only the oldest eligible shadow copy.
- `/all`: Select every eligible shadow copy for a destructive verb.
- `/maxsize`: Set a byte, KB, MB, GB, TB, PB, EB, or percentage capacity limit.
- `/quiet`: Suppress a destructive command's confirmation prompt.
- `/?`: Display top-level or verb-specific help supported by the installed build.

VssAdmin administers shadows created by the system software provider. Use the
requesting backup product or reviewed provider workflow for product-owned or
hardware-provider snapshots.

## Common mistakes

### Treating `Stable` before a job as proof that backup will succeed

Writer state is sampled when the command runs. High-quality support cases show
writers stable before a backup and failed only during or immediately after its
snapshot phase. Capture `list writers` before and promptly after the failed
job, plus the job ID/timestamp and relevant Application/System/VSS/provider
events. `Stable` is evidence, not a restore test or application-consistency
certificate.

### Restarting every writer service or re-registering VSS blindly

A writer normally belongs to a workload service, and a provider may belong to
backup/storage software. Generic restart, DLL-registration, registry-deletion,
or reboot recipes can interrupt production and erase the failure state without
fixing the requester/provider cause. Identify the failing writer/provider and
follow current workload/vendor guidance after preserving evidence.

### Treating every shadow copy as a backup

A snapshot can remain on the same host, storage, credentials, and failure
domain as its source. It may be crash-consistent, temporary, incomplete, or
retained by System Restore or backup software. Verify the requester, context,
writer result, independent destination, retention, catalog, and an actual
restore before calling it a backup.

### Deleting shadows as routine free-space cleanup

`delete shadows /all /quiet` is irreversible from VssAdmin and is also a
well-known destructive pattern. It can remove restore points and backup
dependencies without proving that VSS caused a capacity problem. Inventory
exact IDs, providers, types, attributes, storage associations, application
owners, and recovery requirements; use the owning product's retention
workflow.

### Resizing the wrong side of a storage association

`/for=` identifies the protected source volume; `/on=` identifies the volume
holding its diff area. They can differ. Record the exact association and its
used, allocated, and maximum values before changing it. A percentage applies
to the relevant storage volume, a value without a unit is bytes, and omitting
`/maxsize` means unbounded. Microsoft explicitly warns that resizing may purge
shadows.

### Assuming a full diff area is the only VSS failure cause

Capacity is only one dimension. Writers, providers, timeouts, I/O, filesystem
state, security software, requester sequencing, application health, and
provider conflicts also matter. Correlate the operation's error code and
timestamp rather than changing storage until a backup happens to pass.

### Parsing localized text as a durable automation API

VssAdmin emits human-oriented native text whose fields, ordering, and language
can vary. Capture raw output for diagnosis, but use supported VSS, CIM, backup,
or product APIs when automation needs structured identity and state. Capture
`$LASTEXITCODE` immediately; a nonzero code and the actual backup result both
matter.

## PowerShell boundaries

Use `vssadmin.exe` explicitly. Quote GUIDs because PowerShell uses braces as
syntax, pass scalar volume strings, and avoid interpolating untrusted IDs into
privileged delete/resize operations. Redirect diagnostic output only to a
protected path because it reveals volume device names, host names, providers,
and application writers.

## Version and platform differences

VssAdmin is Windows-only and current Microsoft documentation applies it to
supported Windows client and server releases. Available verbs and the shadows
they can manage vary by Windows build, provider, VSS context, installed backup
features, and privilege. Run `vssadmin.exe /?` and verb-specific help on the
target host before using a mutation.

## Related documents

- [diskshadow](diskshadow.md)
- [wbadmin](wbadmin.md)
- [fsutil](fsutil.md)

## Sources and license

This original guide was adapted from Microsoft's official
[VssAdmin family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/vssadmin),
[shadow-list syntax](https://learn.microsoft.com/windows-server/administration/windows-commands/vssadmin-list-shadows),
[shadow-storage warning](https://learn.microsoft.com/windows-server/administration/windows-commands/vssadmin-resize-shadowstorage),
and [VSS overview](https://learn.microsoft.com/windows-server/storage/file-server/volume-shadow-copy-service).
The timing-sensitive writer-state mistake was cross-checked against
[a case where writers fail only during a backup](https://serverfault.com/questions/755787/veeam-backup-failing-cannot-create-a-shadow-copy-of-the-volumes-containing-writ),
then resolved with the official VSS component model. Exact sources and licenses
are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
