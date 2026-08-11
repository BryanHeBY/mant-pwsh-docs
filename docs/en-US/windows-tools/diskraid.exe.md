<!-- mant:tldr:start -->
# diskraid.exe

> Inventory a VDS-capable hardware RAID subsystem without creating, resizing, exposing, or deleting storage.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/diskraid.

- Confirm the specialist tool exists before assuming a broad Microsoft Learn banner means it is usable:

`Get-Command diskraid.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Start the DiskRaid interpreter, then enumerate VDS providers:

`diskraid.exe`

- At `DISKRAID>`, enumerate storage subsystems before selecting anything:

`list subsystems`

- Select one verified subsystem and inventory its controllers, drives, and LUNs:

`select subsystem {{0}}`

`list controllers`

`list drives`

`list luns`

- Inspect the selected LUN, including its plexes:

`select lun {{0}}`

`detail lun verbose`

- Leave the interpreter without changing storage:

`exit`
<!-- mant:tldr:end -->

# diskraid.exe

## Overview

`diskraid.exe` is an interactive and scriptable administrator for hardware RAID
subsystems exposed through Virtual Disk Service (VDS). It models providers,
subsystems, controllers/ports, drives, LUNs and plexes, HBA paths, and iSCSI
initiators, targets, portals, and portal groups. It works only with a compatible
VDS hardware provider; it is not a generic replacement for the array vendor's
supported management stack.

Commands run at `DISKRAID>`, or from `diskraid.exe /s <script.txt>`. Focus is
stateful: most operations act on an object selected by `select`. That makes a
transcript easy to read but makes stale or misunderstood focus dangerous.

## Command-family map

| Family | Commands | Boundary |
| --- | --- | --- |
| Discovery | `help`, `initiator`, `list`, `detail`, parameterless `select`, `exit` | Query only when no setting keyword is supplied. |
| Focus/refresh | `select`, `refresh`, `reenumerate` | Focus changes later command targets; refresh/reenumeration can trigger provider/bus work. |
| LUN lifecycle | `create`, `delete`, `add plex`, `break`, `extend`, `shrink`, `recover`, `replace`, `setflag` | Can erase data, change capacity/redundancy, rebuild, or repurpose drives. |
| Access paths | `associate`, `dissociate`, `mask`, `unmask`, `online`, `offline`, `standby`, `lbpolicy` | Can remove host access, expose a LUN broadly, or change multipath/failover behavior. |
| iSCSI | `create target`, `create tpgroup`, `add/remove tpgroup`, `login`, `logout`, `chap` | Changes sessions, persistence, authentication, target topology, or secrets. |
| Provider/controller | `automagic`, `name`, `importtarget`, `flushcache`, `invalidatecache`, `maintenance`, `reset` | Can change provisioning hints, VSS target, cache integrity, hardware state, or availability. |
| Scripting | `rem`, `/s`, `noerr` | `noerr` deliberately continues after supported runtime failures. |

## Indexed interpreter commands

<!-- mant:entries role=command case=insensitive -->
- `diskraid.exe`: Start the VDS hardware-RAID interpreter or run one reviewed
  script with `/s`.
- `help`: Display installed interpreter syntax for a command family.
- `initiator`: Display or change iSCSI initiator state in the selected context.
- `list`: Enumerate providers, subsystems, controllers, drives, LUNs, targets,
  paths, and other supported object families.
- `detail`: Display detailed identity/state for the currently selected object.
- `select`: Display or change stateful focus to one enumerated object.
- `refresh`: Refresh provider/object state and potentially trigger provider work.
- `reenumerate`: Request storage-bus/provider re-enumeration.
- `create`: Create a supported LUN, target, portal group, or related object.
- `delete`: Delete the selected supported object and potentially its data.
- `add`: Add a plex, portal-group member, or other family-specific relationship;
  some forms erase the added storage.
- `break`: Break a LUN/plex relationship with destructive consistency effects.
- `extend`: Increase a selected LUN's capacity; it does not grow host partitions
  or filesystems.
- `shrink`: Reduce supported selected LUN capacity after workload/data planning.
- `recover`: Request provider recovery for a selected degraded LUN.
- `replace`: Replace a selected failed/missing member using provider semantics.
- `setflag`: Change provider-specific flags on selected storage.
- `associate`: Associate a selected LUN and host/access object.
- `dissociate`: Remove a selected LUN/access association.
- `mask`: Remove host visibility/access to selected LUNs.
- `unmask`: Expose selected LUNs, potentially replacing an access list unless
  the documented add behavior is used.
- `online`: Bring a selected supported storage/path object online.
- `offline`: Take a selected supported storage/path object offline.
- `standby`: Place a selected path/controller object into standby where supported.
- `lbpolicy`: Display or change multipath load-balancing policy.
- `login`: Establish an iSCSI target session.
- `logout`: Remove an iSCSI target session.
- `chap`: Configure iSCSI CHAP authentication material; never record secrets.
- `automagic`: Display or change provider automatic-provisioning hints.
- `name`: Set a selected object's friendly/provider name.
- `importtarget`: Set or change provider VSS import-target behavior.
- `flushcache`: Flush provider/controller cache under an approved storage runbook.
- `invalidatecache`: Invalidate cache state with potential I/O/availability impact.
- `maintenance`: Enter or leave provider-specific maintenance state.
- `reset`: Reset selected controller/port/provider state; it is not screen cleanup.
- `rem`: Add a script comment.
- `noerr`: Continue a supported script after runtime errors; syntax errors still
  stop parsing and later mutations can run after a failed prerequisite.
- `exit`: Leave the interpreter.

The launcher has one script-file switch; every other indexed word above belongs
inside the DiskRaid interpreter or its script language.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Run the following reviewed DiskRaid script file instead of using the
  interactive prompt.

## Safe discovery sequence

Start with `list providers` and `list subsystems`. Record provider/vendor,
subsystem identity, serial/model, controller health, and ownership. Select an
exact subsystem only after matching stable hardware identity, then use `list`
and `detail` for controllers, drives, LUNs, targets, and paths. Re-run the
parameterless `select <type>` form immediately before any approved change and
capture a complete transcript.

DiskRaid indexes are discovery-session positions, not globally stable storage
identities. A reboot, provider refresh, path change, failover, or array
reconfiguration can change enumeration. Never carry a copied `select lun 5`
into another host or maintenance window without re-resolving it.

## Common mistakes

### Running interpreter commands in PowerShell

`list luns`, `select subsystem`, and `detail lun` are DiskRaid language, not
PowerShell cmdlets. Enter them only after the `DISKRAID>` prompt or place them
in a reviewed script passed with `/s`. Do not pipe untrusted text into the
interpreter.

### Confusing DiskRaid, DiskPart, and vendor RAID tools

DiskRaid manages VDS hardware-provider objects and LUNs. DiskPart manages the
host's disks, partitions, volumes, and VHDs. Extending a LUN does not extend an
on-disk partition, volume, or filesystem; Microsoft directs a separate
DiskPart/filesystem step. Array firmware, snapshots, replication, clusters,
SAN zoning, and reservations may require vendor/orchestrator workflows too.

### Trusting the selected number instead of the selected identity

Focus is inherited by later commands. Selecting a subsystem can implicitly
select its provider and deselect other object types; selecting an invalid index
can clear focus. Before a mutation, display focus and `detail` again, then match
serials/WWNs/IQNs, capacity, paths, owners, workload, and change ticket.

### Treating `noerr` as resilience

Without `noerr`, a script stops and returns an error on a runtime failure.
With `noerr`, supported commands continue, potentially applying later changes
after an earlier selection, delete, or protection step failed. It still does
not suppress syntax errors. Avoid it for mutation workflows unless every
postcondition and compensation path is explicitly designed and tested.

### Assuming “add” is nondestructive

`add plex lun=<n>` deletes all data on the LUN being added as a plex. `break`
deletes the removed plex and does not guarantee consistency of the remaining
LUN. A name that sounds like topology maintenance does not describe data loss.

### Using mask/unmask as a browse toggle

Masking changes host visibility and can uninstall the local disk; unmasking can
replace the access list unless `add` is supplied. `unmask lun all` exposes the
LUN broadly and has iSCSI session constraints. Coordinate application quiesce,
cluster ownership, multipath, filesystem identity, reservations, zoning, and
every consuming host.

### Changing cache, controller, or path state while diagnosing

`flushcache`, `invalidatecache`, controller/port `reset`, `offline`, `standby`,
load-balancing policy, login/logout, and maintenance operations can affect I/O
or availability. They are not harmless refresh actions. Use the provider and
vendor runbook, redundancy validation, monitoring, rollback, and an approved
maintenance window.

### Putting CHAP secrets in scripts or transcripts

`chap` manages shared secrets. Do not embed secrets in a committed script,
command history, issue, screenshot, or captured transcript. Use the supported
secret channel and redact diagnostic evidence without losing target identity.

### Calling command success a storage success

DiskRaid exit code 0 means the script reported no failure; it does not prove
RAID rebuild completion, path redundancy, filesystem growth, application
consistency, cluster health, backup validity, or recovery. Verify every layer
with independent telemetry and a tested recovery plan.

## PowerShell boundaries

Use an absolute reviewed script path and capture stdout, stderr, start/end time,
host, executable hash/version, provider/array identity, and `$LASTEXITCODE`.
Documented codes are 0 success, 1 fatal exception, 2 bad command-line arguments,
3 script/output open failure, 4 dependent-service failure, and 5 syntax or
invalid-selection failure. Treat any nonzero code as failure, but also validate
postconditions when it is zero.

Never generate a mutation script directly from untrusted inventory output. A
safe automation design separates discovery, human-reviewed identity binding,
approved change, verification, and rollback/recovery evidence.

## Version and platform differences

Microsoft limits scripting to supported Windows Server systems with an
associated VDS hardware provider. The current page's generated applicability
banner is broader, so verify the installed executable and provider on the exact
server. VDS/provider versions, firmware, HBA/iSCSI stack, multipath software,
cluster ownership, and vendor support determine actual behavior. Prefer a
current vendor-supported API or management tool for new deployments.

## Related documents

- [diskpart.exe](diskpart.exe.md)
- [diskshadow.exe](diskshadow.exe.md)
- [netsh.exe](netsh.exe.md)
- [mountvol.exe](mountvol.exe.md)

## Sources and license

Adapted as an original safety and operations guide from Microsoft's
[DiskRaid family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/diskraid).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
