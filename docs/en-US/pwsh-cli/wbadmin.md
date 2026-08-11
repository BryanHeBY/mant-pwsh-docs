<!-- mant:tldr:start -->
# wbadmin

> Discover Windows Backup versions, contents, online disks, and active-job state before starting, stopping, deleting, or restoring anything.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/wbadmin.

- Show the status of a currently running backup or recovery job:

`wbadmin.exe get status`

- List online disks using Windows Backup's identity fields:

`wbadmin.exe get disks`

- List known backup versions; entries can remain cataloged even when their media is unavailable:

`wbadmin.exe get versions`

- Discover versions at one exact target and, for a shared target, one source machine:

`wbadmin.exe get versions "-backupTarget:{{\\server\share}}" "-machine:{{server01}}"`

- Copy the exact version identifier returned above to inventory its recoverable items:

`wbadmin.exe get items "-version:{{MM/DD/YYYY-HH:MM}}" "-backupTarget:{{\\server\share}}" "-machine:{{server01}}"`
<!-- mant:tldr:end -->

# wbadmin

## Overview

`wbadmin.exe` is the native Windows Backup command family for scheduled and
one-time backup, catalog/version discovery, file/application/volume recovery,
system-state operations, and full-system recovery. Scheduling requires local
Administrators membership; other tasks require Backup Operators,
Administrators, or delegated rights, and Microsoft requires an elevated
command prompt.

The TLDR is intentionally discovery-only. Backup and recovery correctness
depends on exact source scope, target, machine identity, version identifier,
VSS mode, credentials/ACLs, installed features, and a tested restore—not only
the process exit code.

## Command-family map

| Family | Commands | Purpose and boundary |
| --- | --- | --- |
| Inventory | `get status`, `get disks`, `get versions`, `get items` | A catalog entry may point to unavailable media; inventory does not validate contents. |
| One-time backup | `start backup`, `start systemstatebackup` | Explicit target/include/critical/state/VSS policy is safer than inheriting an unknown schedule. |
| Schedule | `enable backup`, `disable backup` | Changes recurring protection; dedicated targets and retention need review. |
| Recovery | `start recovery`, `start systemstaterecovery` | File, app, volume, ACL, overwrite, and roll-forward semantics differ. |
| Full-system recovery | `start sysrecovery` | Runs only in Windows Recovery Environment and affects OS-state volumes. |
| Job control | `stop job` | Interrupts an active backup/recovery and can leave an unusable partial result. |
| Catalog | `restore catalog`, `delete catalog` | Catalog metadata is distinct from stored backup data; deletion impairs discovery. |
| Retention | `delete systemstatebackup` | Deletes eligible system-state versions, not arbitrary backup kinds. |

## Safe discovery sequence

1. Record host name, edition/build, installed Windows Backup feature, current
   time zone, privilege, job status, and intended recovery question.
2. Run `get versions` against the exact local volume or UNC target and source
   machine. Do not assume the local catalog proves media is attached.
3. Copy the returned version identifier verbatim into `get items`; do not
   reinterpret it from a display timestamp.
4. Confirm item type and identity, application registration, original and
   alternate destination, ACL/overwrite behavior, dependencies, free space,
   and backup integrity before authorizing recovery.
5. Prefer recovery to an isolated alternate path where supported, compare the
   result, and preserve a rollback route before replacing production data.

## Common mistakes

### Typing a friendly timestamp instead of the version identifier

`get items` and recovery commands require the identifier in the exact
`MM/DD/YYYY-HH:MM` form emitted by `get versions`. Locale, time zone, daylight
saving, and the backup host can make a separately reformatted time identify no
version or the wrong version. Copy the identifier and bind it to target and
machine in the change record.

### Omitting `-machine` for a shared target

Multiple computers can store backups at one location. Microsoft says
`-machine` should accompany `-backupTarget` when selecting another or shared
computer's backup. Match the catalog's machine name; a same-named rebuilt host
or renamed machine still needs explicit provenance checks.

### Assuming cataloged means available and restorable

Without parameters, `get versions` can list local-computer backups even when
they are unavailable. Confirm the target is online, the version appears when
querying that target, `get items` succeeds, dependent volumes/application
components exist, and a representative restore is readable.

### Reusing one remote-share folder as versioned retention

Microsoft warns that a later backup from the same computer to the same remote
shared folder overwrites the earlier backup. If the new operation fails, the
old result may already be gone while the new result is unusable. Use a reviewed
target/retention design with separate protected destinations or supported
backup tooling; do not invent subfolders without also accounting for the
documented doubled parent-space requirement.

### Putting a password in command history or logs

`-password:` exposes a secret through shell history, transcripts, process
inspection, logging, and automation configuration. Prefer a managed identity,
service account, pre-authorized secure target, or supported backup platform.
If legacy use is unavoidable, contain and rotate the credential and protect
every log and script artifact.

### Treating `-quiet` as safe unattended mode

`-quiet` only suppresses prompts. It does not validate source/target identity,
capacity, overwrite, VSS consistency, recovery scope, or retention. Build
preflight and post-verification around the command before removing human
confirmation.

### Choosing `-vssFull` without coordinating other backup products

A VSS full backup updates file backup history and can truncate application
logs. Microsoft cautions against it when another product also protects
applications on the included volumes. A VSS copy backup avoids updating that
history. The application owner and every backup product must agree on the
mode and log-chain consequences.

### Believing `-allCritical` or system state means every data volume

Critical-volume, system-state, file/folder, application, and full-system
coverage are different. Inventory what the selected flags actually include on
that host with backup results and `get items`; document excluded data,
applications, encryption keys, and external dependencies.

### Restoring files with the wrong overwrite or ACL policy

File recovery distinguishes `Skip`, `CreateCopy`, and `Overwrite`; by default
it restores backed-up ACLs, while `-notRestoreAcl` inherits from the recovery
location. Prefer an alternate protected path and compare content, owner, ACL,
timestamps, links, and application semantics before production replacement.

### Deleting the catalog to delete backup data—or vice versa

The local catalog describes backups; it is not the backup payload. Microsoft
restricts `delete catalog` to a corrupted local catalog when no stored catalog
can be restored. Deleting it can make valid media hard to discover without
securely erasing that media. Preserve evidence and try the documented catalog
restore path first.

### Stopping a job because progress looks idle

VSS quiescing, verification, large files, slow media, and recovery can spend
time without a smooth percentage change. Correlate `get status`, storage I/O,
events, and target health. `stop job` deliberately interrupts work and a
partial output must not become the newest assumed-good recovery point.

## PowerShell behavior

Call `wbadmin.exe` explicitly and quote each native `-name:value` argument
when its value contains spaces, braces, or UNC syntax. Avoid PowerShell's
formatted-object output as input. Capture raw native output, streams, and
`$LASTEXITCODE` immediately, then verify catalog, media, event-log, and restore
state separately. Output is localized human text, not a stable data API.

## Version and platform differences

WBAdmin is Windows-only. Current Microsoft pages list supported Windows client
and server releases, but commands, Windows Server Backup features/cmdlets,
system-state support, applications, schedule behavior, and permissions vary by
edition, role/feature installation, recovery environment, target type, and
build. `start sysrecovery` is limited to WinRE. Confirm `wbadmin.exe /?` and
subcommand help on the target.

## Related documents

- [vssadmin](vssadmin.md)
- [diskshadow](diskshadow.md)
- [manage-bde](manage-bde.md)

## Sources and license

This original guide was adapted from Microsoft's official
[WBAdmin family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/wbadmin),
[version discovery](https://learn.microsoft.com/windows-server/administration/windows-commands/wbadmin-get-versions),
[item discovery](https://learn.microsoft.com/windows-server/administration/windows-commands/wbadmin-get-items),
[one-time backup](https://learn.microsoft.com/windows-server/administration/windows-commands/wbadmin-start-backup),
and [recovery reference](https://learn.microsoft.com/windows-server/administration/windows-commands/wbadmin-start-recovery).
The time-sensitive writer failure seen in an actual WBAdmin job was cross-
checked against
[a practitioner incident](https://serverfault.com/questions/634574/vss-dhcp-jet-writer-experiences-errors-during-backup-with-wbadmin),
then resolved using Microsoft's VSS and WBAdmin contracts. Exact sources and
licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
