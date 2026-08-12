<!-- mant:tldr:start -->
# wbadmin.exe

> Discover Windows Backup versions, contents, online disks, and active-job state before starting, stopping, deleting, or restoring anything.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/wbadmin.

- Show the exact installed syntax for a family; WBAdmin uses `-?`, not `/?`:

`wbadmin.exe delete backup -?`

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

# wbadmin.exe

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
| Retention | `delete backup`, `delete systemstatebackup` | Installed builds can expose a general backup deletion family separately from system-state-only retention; selectors and eligible backup types differ. |

These complete families are semantic command entries. Run
`wbadmin.exe family -?` on the target because installed features and editions
change support. Do not copy the more common `/?` convention to WBAdmin.

<!-- mant:entries role=command case=insensitive -->
- `wbadmin.exe`: Inspect or administer Windows Backup on supported installations.
- `get status`: Display the currently running backup or recovery job.
- `get disks`: List online disks using Windows Backup identity fields.
- `get versions`: List cataloged backup version identifiers for a target and machine.
- `get items`: List recoverable items contained in one exact backup version.
- `start backup`: Start a one-time backup with explicit source, target, and VSS policy.
- `enable backup`: Create or replace a scheduled backup policy.
- `disable backup`: Disable the scheduled backup policy.
- `start recovery`: Recover selected files, applications, or volumes.
- `start systemstatebackup`: Start a system-state backup where supported.
- `start systemstaterecovery`: Recover system state where supported.
- `start sysrecovery`: Start full-system recovery from Windows Recovery Environment.
- `stop job`: Interrupt the currently running backup or recovery operation.
- `restore catalog`: Restore the local backup catalog from available backup media.
- `delete catalog`: Delete a corrupted local catalog only under the documented conditions.
- `delete backup`: Delete selected eligible backup versions on builds that expose this installed command; exactly one retention/version selector is required.
- `delete systemstatebackup`: Delete eligible system-state backup versions.

The same option name can have narrower semantics under different command
families; inspect that family's help before constructing an invocation.

<!-- mant:entries role=option case=insensitive -->
- `-?`: Request WBAdmin or exact-family help; do not substitute the common Windows `/?` spelling.
- `-backupTarget`: Select the exact backup source or destination volume/UNC path.
- `-machine`: Select the source computer represented at a shared or alternate target.
- `-version`: Select the exact `MM/DD/YYYY-HH:MM` identifier returned by inventory.
- `-include`: Select volumes, folders, or files for a backup family.
- `-nonRecurseInclude`: Include selected paths without recursively including descendants.
- `-exclude`: Exclude selected children from an included backup scope.
- `-nonRecurseExclude`: Exclude selected paths without recursively matching descendants.
- `-allCritical`: Include every volume required for bare-metal recovery.
- `-systemState`: Include system state where the selected backup family supports it.
- `-hyperv`: Select registered Hyper-V components for a supported backup.
- `-vssFull`: Perform a VSS full backup and update applicable backup history/log state.
- `-vssCopy`: Perform a VSS copy backup without updating applicable backup history.
- `-user`: Supply an account for an explicit remote backup target.
- `-password`: Supply its password on the command line, exposing a secret.
- `-noInheritAcl`: Restrict a UNC backup folder to supplied credentials and
  backup-administrator identities instead of inheriting the share folder ACL.
- `-quiet`: Suppress confirmation prompts without adding validation.
- `-items`: Select recoverable files, volumes, or applications from one version.
- `-itemType`: Declare the item category expected by a recovery family.
- `-recoveryTarget`: Select an alternate recovery destination.
- `-recursive`: Include descendants in file recovery.
- `-notRestoreAcl`: Inherit destination ACLs instead of restoring saved ACLs.
- `-overwrite`: Choose `Skip`, `CreateCopy`, or `Overwrite` conflict behavior.
- `-skipBadClusterCheck`: Skip restoring saved bad-cluster information during
  volume/full-system recovery, requiring a separate filesystem-health plan.
- `-noRollForward`: Prevent application recovery from rolling the latest backup forward.
- `-noVerify`: Skip error verification for a backup written to removable media.
- `-restoreAllVolumes`: Restore data volumes as well as critical volumes in WinRE.
- `-recreateDisks`: Recreate backed-up disk layout during WinRE recovery and
  potentially erase operating-system and data volumes.
- `-excludeDisks`: Exclude listed WBAdmin disk identifiers from `-recreateDisks`.
- `-showsummary`: Display the previous system-state recovery summary by itself.
- `-authsysvol`: Perform an authoritative SYSVOL restore during system-state recovery.
- `-autoReboot`: Restart automatically after original-location system-state recovery.
- `-addtarget`: Add a disk, volume, or UNC target to scheduled backup policy.
- `-removetarget`: Remove a disk target from scheduled backup policy.
- `-schedule`: Set one or more daily scheduled backup times in `HH:MM` form.
- `-allowDeleteOldBackups`: Permit removal of backups made before an OS upgrade.
- `-deleteOldest`: Delete the oldest eligible backup for the selected deletion family.
- `-keepVersions`: Retain the newest requested number of eligible versions; installed `delete backup` help states that zero deletes all eligible backups.

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

### Treating `delete backup` as a harmless alias

The recorded Windows client exposes `delete backup` separately from
`delete systemstatebackup` and catalog deletion. Its installed syntax requires
exactly one of `-keepVersions`, `-version`, or `-deleteOldest`; notably,
`-keepVersions:0` means delete all eligible backups, not keep none while
previewing. Inventory version, type, target, and machine first, retain a tested
independent recovery point, and never add `-quiet` until selectors and
post-deletion verification have been reviewed.

### Stopping a job because progress looks idle

VSS quiescing, verification, large files, slow media, and recovery can spend
time without a smooth percentage change. Correlate `get status`, storage I/O,
events, and target health. `stop job` deliberately interrupts work and a
partial output must not become the newest assumed-good recovery point.

## PowerShell boundaries

Call `wbadmin.exe` explicitly and quote each native `-name:value` argument
when its value contains spaces, braces, or UNC syntax. Avoid PowerShell's
formatted-object output as input. Capture raw native output, streams, and
`$LASTEXITCODE` immediately, then verify catalog, media, event-log, and restore
state separately. Output is localized human text, not a stable data API.
Help syntax and status are also easy to misread. On the recorded build,
top-level `-?` and `delete backup -?` returned 0 with help, whereas top-level
`/?`, `help delete backup`, and `delete backup /?` returned `-1`. The last form
prefixed valid syntax with a parser-error message. Use WBAdmin's `-?` form and
retain output plus status; neither `-1` nor the word `ERROR` alone proves that
the command family is absent.

## Version and platform differences

WBAdmin is Windows-only. Current Microsoft pages list supported Windows client
and server releases, but commands, Windows Server Backup features/cmdlets,
system-state support, applications, schedule behavior, and permissions vary by
edition, role/feature installation, recovery environment, target type, and
build. `start sysrecovery` is limited to WinRE. On the recorded Windows NT
`10.0.26200.0` client, the installed top-level help listed only eight families
and included `delete backup`, which Microsoft's current WBAdmin family index
does not list. Conversely, several server/system-state/WinRE families in the
official index were absent from that top-level client list. Installed
`wbadmin.exe` file version was `10.0.26100.8737`. Confirm top-level and exact
subcommand help on the target, and treat the online family index as a contract
source rather than an exhaustive installed-build inventory.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8737 top-level
help listed eight families including the online-index-omitted DELETE BACKUP.
DELETE BACKUP -? returned 0 with help; the commonly copied /? form returned -1
as a syntax error but still exposed the same selectors and keepVersions:0 risk.
No backup, deletion, catalog, schedule, job, or recovery operation ran.

## Related documents
- [vssadmin.exe](vssadmin.exe.md)
- [diskshadow.exe](diskshadow.exe.md)
- [manage-bde.exe](manage-bde.exe.md)

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
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
