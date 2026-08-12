<!-- mant:tldr:start -->
# dfsrmig.exe

> Read the global state on the PDC Emulator and wait for every DC's local state
> to converge before any SYSVOL migration transition; state 3 (Eliminated) is
> irreversible.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/dfsrmig.

- Identify the PDC Emulator for one exact domain:

`$pdc = (Get-ADDomain -Identity "{{example.com}}").PDCEmulator; $pdc`

- Read the authoritative global migration state by running the query on that PDC Emulator:

`Invoke-Command -ComputerName $pdc -ScriptBlock { dfsrmig.exe /getglobalstate }`

- Compare every DC's local migration state with the current global state:

`Invoke-Command -ComputerName $pdc -ScriptBlock { dfsrmig.exe /getmigrationstate }`

- Correlate the PDC's current SYSVOL/NETLOGON shares and FRS/DFSR service state:

`Invoke-Command -ComputerName $pdc -ScriptBlock { Get-SmbShare -Name SYSVOL, NETLOGON -ErrorAction SilentlyContinue; Get-Service NTFRS, DFSR -ErrorAction SilentlyContinue }`

<!-- mant:tldr:end -->

# dfsrmig.exe

## Overview

`dfsrmig.exe` controls and reports the domain-wide migration of SYSVOL from the
legacy File Replication Service (FRS) to DFS Replication (DFSR). It writes AD DS
objects for migration and is not a general DFSR data-replication tool. Run global
state operations on the PDC Emulator; AD latency makes another DC's local copy
non-authoritative for that decision.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `dfsrmig.exe`: Query or change the domain-wide SYSVOL migration state.

Global-state operations belong on the PDC Emulator. Object repair operations
are narrow recovery tools, not generic cleanup.

<!-- mant:entries role=option case=insensitive -->
- `/getglobalstate`: Display the global SYSVOL migration goal known on this DC.
- `/setglobalstate`: Set goal 0 through 3 and initiate the corresponding phase.
- `/getmigrationstate`: Compare every DC's local state with the global goal.
- `/createglobalobjects`: Create missing migration objects under documented recovery conditions.
- `/deleterontfrsmember`: Delete legacy FRS membership for one or all RODCs.
- `/deleterodfsrmember`: Delete DFSR membership for one or all RODCs.
- `/?`: Display installed migration syntax.

## State model

- `0` Start: SYSVOL uses FRS.
- `1` Prepared: DFSR builds a synchronized copy while FRS remains authoritative;
  rollback to Start remains possible through the supported sequence.
- `2` Redirected: SYSVOL uses DFSR; rollback to Prepared/Start is still a
  migration procedure, not an instant toggle.
- `3` Eliminated: FRS SYSVOL configuration is removed. This is irreversible.

`/setglobalstate` changes the domain's goal and initiates work. It is never a
status query. `/getmigrationstate` lists DCs that have not reached the global
state and can report transitional/stale state because AD/DFSR convergence takes
time.

## Common mistakes

### Advancing because the global state changed

The PDC accepting a new global value is only the start of a phase. Wait until
`/getmigrationstate` reports every writable/RODC member consistently at the
goal, then verify AD replication, DFSR events, SYSVOL/NETLOGON shares, content,
GPO application, backups, and all sites before the next approved state.

### Treating service presence or AD objects as the active mechanism

During migration, FRS and DFSR services/objects can coexist. Installed features,
running services, folders, or one subscription object do not independently
identify the authoritative SYSVOL mechanism. Use the state machine plus per-DC
local state and postchecks.

### Jumping directly to state 3

Eliminated cannot roll back. It removes the FRS path only after prior states
have converged and been validated. Require system-state/GPO backups, restore
test, every-DC inventory, owner sign-off, maintenance window, monitoring, and a
documented recovery plan before committing.

### Creating or deleting global objects as generic repair

`/createglobalobjects`, `/deleterontfrsmember`, and `/deleterodfsrmember` mutate
AD and are documented for narrow stalled-RODC/missing-object conditions. An
omitted RODC name can target all RODCs. Preserve exact objects/replication state
and use current Microsoft escalation guidance before them.

### Forcing polls or replication to make a phase finish

First diagnose DNS, time, AD replication, topology, permissions/user rights,
DFSR health, offline/stale DC metadata, disk space, sharing violations, and
initial-sync partners. Forced AD/DFSR polls can change evidence without fixing
the cause and may add WAN/load pressure.

### Ignoring an offline or decommissioned DC

Every recorded domain controller can block consistency. Determine whether it is
temporarily unavailable or permanently removed, and complete supported DC
recovery/demotion/metadata cleanup before continuing. Never delete a member
object solely because its name appears in migration output.

## PowerShell boundaries

Dfsrmig has no remote-target switch; use an approved interactive/logged session
on the PDC or explicit PowerShell remoting as shown. Capture remote host,
`$LASTEXITCODE`, all text, UTC time, PDC identity and AD replication state.
Localized text is not a stable parser contract; do not automate phase changes
from a substring match.

## Version and platform differences

Dfsrmig is Windows/AD DS tooling installed with DFS Replication and requires a
supported domain functional level. Availability, migration eligibility, RODC
behavior, remoting, and output vary by DC version and estate history. Current
Microsoft documentation and target-local help take precedence over claims that
presence/absence on one host proves the domain state.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`dfsrmig.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains PDC identity and approved global/local
state plus share/service inventory only; no state transition,
global-object/member deletion/creation, AD/DFSR/FRS polling, service, registry,
authoritative/non-authoritative restore or metadata cleanup is permitted merely
for evidence.

## Related documents
- [ntfrsutl.exe](ntfrsutl.exe.md)
- [dcdiag.exe](dcdiag.exe.md)
- [repadmin.exe](repadmin.exe.md)
- [dfsdiag.exe](dfsdiag.exe.md)
- [gpresult.exe](gpresult.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Dfsrmig reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dfsrmig)
and its linked SYSVOL migration series. The frequent mistakes of inferring the
mechanism from coexisting objects/services and advancing while a DC remains in
transition were cross-checked against practitioner questions about
[detecting FRS versus DFSR](https://serverfault.com/questions/876823/) and a
[migration stuck in Redirected](https://serverfault.com/questions/925917/).
Community repair sequences are not treated as runbooks. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
