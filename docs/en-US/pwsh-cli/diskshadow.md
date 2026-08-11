<!-- mant:tldr:start -->
# diskshadow

> Inspect Windows VSS state through DiskShadow's own interpreter without creating, exposing, deleting, or reverting a shadow copy.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/diskshadow.

- Confirm that DiskShadow exists on this exact host before relying on conflicting platform matrices:

`Get-Command diskshadow.exe -ErrorAction Stop`

- Start the elevated DiskShadow interpreter:

`diskshadow.exe`

- At the `DISKSHADOW>` prompt, list writers and their current state:

`list writers`

- List registered providers before attributing a shadow to one provider:

`list providers`

- List every visible shadow and preserve its set, ID, provider, and attributes:

`list shadows all`

- Display the current creation settings without changing them:

`set`

- Leave the interpreter without creating or changing a shadow:

`exit`
<!-- mant:tldr:end -->

# diskshadow

## Overview

`diskshadow.exe` is an elevated interactive and scriptable VSS requester. It
can select volumes and writers, create shadow sets, run backup/restore writer
events, persist metadata, transport or expose hardware snapshots, and perform
destructive deletion, break, mask, or revert operations. Its commands run at
the `DISKSHADOW>` prompt or from `diskshadow.exe /s "script.dsh"`; they are not
PowerShell commands.

This is a specialist backup/storage tool. A minimal `add` plus `create` is not
a complete backup workflow: Microsoft notes that it accepts default context,
creates a copy backup, and has no backup execution script. A reviewed workflow
must define consistency, provider, metadata, copying, retention, cleanup, and
recovery verification.

## Command-family map

| Family | Commands | Purpose and boundary |
| --- | --- | --- |
| Inventory/state | `list`, parameterless `set`, parameterless `add`, `reset`, `exit` | `reset` is not read-only: it discards interpreter state and nonpersistent shadows. |
| Creation policy | `set context`, `set option`, `set metadata`, `set verbose` | Context controls persistence, writer participation, client access, transport, and recovery behavior. |
| Selection | `add volume`, `add alias`, `writer verify`, `writer exclude`, `writer include` | Confirm canonical volume, provider, writer/component IDs, and aliases. |
| Snapshot transaction | `begin backup`, `create`, `exec`, `end backup` | Coordinate writer events and the external data-copy step; `exec` runs a local program with elevated impact. |
| Restore transaction | `load metadata`, `begin restore`, `end restore` | Writer metadata and pre/post-restore events are part of application recovery. |
| Access | `expose`, `unexpose` | Exposure adds/removes an access path; it does not copy or independently protect data. |
| Hardware transport | `import`, `mask`, `break` | Requires compatible provider/array and metadata; writable break changes snapshot semantics. |
| Destructive lifecycle | `delete shadows`, `revert` | Delete removes snapshots; revert rolls an entire source volume back to one eligible shadow. |

## Context and metadata

`set context clientaccessible` creates a persistent, client-accessible context.
`persistent` survives DiskShadow exit/reset/restart; `volatile` is deleted on
exit or reset. Adding `nowriters` excludes all writers, so it cannot establish
application consistency. Options such as `transportable`, `differential`,
`plex`, `rollbackrecover`, and `noautorecover` have provider and writer
semantics; never combine words copied from an unrelated storage workflow.

The metadata CAB contains the Backup Components Document and aliases required
for transport/import and writer-aware restore. Treat it as integrity- and
confidentiality-sensitive recovery material: use an explicit protected path,
retain it with the matching snapshot/backup, and never load an untrusted CAB.

## Common mistakes

### Running DiskShadow subcommands directly in PowerShell

`list writers`, `set context`, and `create` belong to the DiskShadow
interpreter. Put them in a reviewed `.dsh` file and call `diskshadow.exe /s`,
or enter them only after the prompt appears. PowerShell aliases and parsing do
not apply inside that interpreter.

### Assuming Microsoft currently gives one unambiguous client matrix

The current DiskShadow command page labels supported Windows client and server
releases, while Microsoft's current VSS overview says DiskShadow is available
only on Windows Server. Resolve that documentation conflict on the target:
check `Get-Command diskshadow.exe`, local help, edition/build, and the supported
workflow. Do not deploy a script merely because one web-page banner includes
the operating system.

### Using `nowriters` as a performance shortcut

`nowriters` excludes all writers. The shadow may be useful for a narrowly
designed crash-consistent workflow, but it does not perform the application
quiescing and metadata coordination needed for writer-aware recovery. Define
the consistency requirement with each workload owner and test restore.

### Omitting `end backup` after copying data

`begin backup`, snapshot creation, the actual copy, and `end backup` are a
transaction. `end backup` sends the BackupComplete event with the appropriate
writer state. Creating and exposing a snapshot without completing and checking
the data copy is not a successful backup.

### Treating exposure as a durable copy

`expose` makes a persistent shadow reachable by drive letter, share, or mount
point. It remains tied to its provider, shadow set, source/diff storage, and
retention. Unexposing only removes that access path; deleting, purging, or
breaking the shadow is a different operation.

### Using `reset` as harmless screen cleanup

`reset` loses state established by `add`, `set`, `load`, and `writer`, releases
the backup-component interfaces, and loses nonpersistent shadows. Use it only
when that lifecycle transition is intended and cleanup has been verified.

### Reverting a volume to recover one file

`revert <shadowcopyID>` rolls the volume back and is supported only for
client-accessible, persistent shadows made by the system provider. It is not a
file restore and changes everything on the volume since the snapshot. Stop
owners, validate snapshot/source identity and dependencies, preserve newer
data independently, follow workload/boot/cluster guidance, and require an
approved rollback and recovery plan.

### Breaking or importing a hardware shadow without array coordination

Transportable metadata, compatible hardware providers, LUN presentation,
masking, reservations, multipathing, host signatures, and array ownership all
matter. `break ... writable` disassociates the shadow from VSS and permits
writes; it is not a reversible browse toggle. Use the provider/vendor runbook.

### Trusting the generic linked `list` or `create` page blindly

At the locked upstream revision, links from the DiskShadow family page can
resolve to pages whose prose describes DiskPart disks, partitions, volumes, or
VHDs. Use the family description and installed `DISKSHADOW>` help for
DiskShadow syntax, and do not transfer DiskPart grammar into a VSS script.

## PowerShell and script behavior

Keep scripts as reviewable files with explicit absolute paths and no embedded
secrets. DiskShadow scripts can invoke local executables through `exec`; treat
them as privileged code. Capture complete stdout/stderr and `$LASTEXITCODE`,
but independently verify writer status, shadow/provider identity, copied data,
catalog/metadata, retention, and restore. Do not pipe untrusted text into the
interactive prompt.

## Version and platform differences

DiskShadow behavior depends on Windows edition/build, installed executable,
VSS provider, writer/workload, storage hardware, context, and privileges. The
Microsoft platform conflict described above is unresolved by the source pages;
target-host discovery is mandatory. Transport, import, mask, break, and some
context options require capable hardware providers and are not generic client
features.

## Related documents

- [vssadmin](vssadmin.md)
- [wbadmin](wbadmin.md)
- [mountvol](mountvol.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DiskShadow family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/diskshadow),
its linked context, metadata, transaction, exposure, transport, reset, delete,
and revert command pages, and Microsoft's
[VSS overview](https://learn.microsoft.com/windows-server/storage/file-server/volume-shadow-copy-service).
The source conflict and linked-page collisions are recorded rather than
silently resolved. Exact source paths, revision, and license are recorded in
`upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0.
