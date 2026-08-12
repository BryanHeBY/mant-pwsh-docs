<!-- mant:tldr:start -->
# ntfrsutl.exe

> Use NTFRSUtil only after proving the exact DC still participates in an FRS
> replica set; modern SYSVOL estates use DFSR, and poll controls can change FRS
> activity.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ntfrsutl.

- Confirm the exact executable and display its local help:

`$cmd = Get-Command ntfrsutl.exe -ErrorAction Stop; $cmd | Select-Object Source, Version; & $cmd.Source '/?'`

- Query the FRS API/service version on one exact server:

`ntfrsutl.exe version "{{dc01.example.com}}"`

- List active FRS replica sets known by one exact server:

`ntfrsutl.exe sets "{{dc01.example.com}}"`

- Display the configured FRS polling interval on one exact server without forcing a poll:

`ntfrsutl.exe poll "{{dc01.example.com}}"`

<!-- mant:tldr:end -->

# ntfrsutl.exe

## Overview

`ntfrsutl.exe` dumps internal File Replication Service (NTFRS/FRS) tables,
logs, replica sets, directory-service view, memory/threads/staging, versions,
and polling configuration. FRS is legacy; use this tool only for an exact older
replica set or a not-yet-completed SYSVOL migration. It is not a DFSR diagnostic.

First establish the domain's Dfsrmig global/local states and the target DC's
actual replica-set membership. FRS objects and binaries can persist during or
after transition; their existence alone is not proof that FRS is authoritative.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `ntfrsutl.exe`: Inspect or alter legacy File Replication Service internals.
- `idtable`: Dump FRS identity-table state for the selected server/set context.
- `configtable`: Dump FRS configuration-table state.
- `inlog`: Dump the inbound FRS change log.
- `outlog`: Dump the outbound FRS change log.
- `memory`: Display internal FRS memory state.
- `threads`: Display internal FRS thread state.
- `stage`: Display FRS staging state.
- `ds`: Display FRS's directory-service configuration view.
- `sets`: List active FRS replica sets known to one server.
- `version`: Display FRS API and service versions.
- `poll`: Display or change FRS directory polling behavior.

Polling modifiers change when FRS reads directory configuration and therefore
must not be mixed into an evidence-only session.

<!-- mant:entries role=option case=insensitive -->
- `/quickly`: Select the documented fast polling interval.
- `/slowly`: Select the documented slow polling interval.
- `/now`: Trigger an immediate FRS configuration poll.
- `/?`: Display installed legacy syntax.

## Command map

- `idtable`, `configtable`, `inlog`, and `outlog` expose internal replication
  identity/configuration and inbound/outbound change-log state.
- `memory`, `threads`, and `stage` expose runtime/staging information.
- `ds` reports FRS's view of directory configuration; `sets` lists active
  replica sets; `version` shows API/service versions.
- `poll` displays polling intervals. `/quickly`, `/slowly`, their numeric forms,
  and `/now` alter or trigger polling behavior and are not read-only inventory.

## Common mistakes

### Using NTFRSUtil in an Eliminated DFSR domain

If SYSVOL migration reached state 3, FRS is no longer the SYSVOL mechanism and
cannot be restored through Dfsrmig rollback. Diagnose DFSR instead. Do not start
NTFRS, create legacy objects, or apply FRS registry recovery recipes to a DFSR
incident.

### Interpreting stale server references as live partners

FRS reads directory objects that can retain an incompletely decommissioned DC.
Correlate server/computer/NTDS/FRS member objects, `serverReference`, DNS,
Sites and Services, Repadmin, system-state history, and every current replica.
Do not delete an object directly from ADSIEdit based on one dump.

### Forcing `/now` or fast polling during evidence collection

A poll changes when FRS rereads configuration and can advance/change observed
state. Preserve tables, logs, service/events, AD state, USN journal context and
timestamps before an approved poll. Persistent fast polling can add load and
hide the original timing.

### Treating inbound/outbound logs as file content truth

FRS internal logs show queued/history state, not a cryptographic comparison or
application-valid SYSVOL. Correlate exact file paths, versions/hashes where
appropriate, staging, conflicts, permissions, shares, GPO AD/SYSVOL version
pairs and client RSoP.

### Applying D2/D4 or journal-wrap registry recipes casually

Non-authoritative/authoritative FRS recovery selects which content wins and can
cause broad overwrite/data loss. System-state backup includes SYSVOL files but
FRS database recovery has distinct semantics. Use a current Microsoft incident
procedure with an explicitly authoritative DC, full topology, backups and
rollback—not an old registry snippet.

### Dumping unrestricted internal data

Tables and logs can reveal topology, paths, filenames, accounts, partners,
change history and operational failures. Bound the target and collection,
protect evidence, and avoid parsing localized/unversioned structures as an API.

## PowerShell boundaries

Invoke `ntfrsutl.exe` explicitly, pass the server as a separate argument, and
capture `$LASTEXITCODE` plus raw output. Do not use string evaluation. There is
no supported typed PowerShell equivalent for every internal FRS table; for
DFSR use the DFSR module and event/diagnostic interfaces instead.

## Version and platform differences

NTFRSUtil is Windows legacy feature/support tooling. Binary availability,
remote access, table layout, service version, FRS role, and support depend on
Server/DC generation and installed components. A current Learn applicability
banner does not mean FRS should be enabled for modern SYSVOL.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`ntfrsutl.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains exact approved legacy-FRS server
help/version/sets/poll display only after mechanism/membership proof; no
forced/fast/slow poll, service, registry, AD/replica-set object, D2/D4,
journal-wrap, staging/log or recovery mutation is permitted merely for
evidence.

## Related documents
- [dfsrmig.exe](dfsrmig.exe.md)
- [dcdiag.exe](dcdiag.exe.md)
- [repadmin.exe](repadmin.exe.md)
- [dfsdiag.exe](dfsdiag.exe.md)
- [wevtutil.exe](wevtutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[NTFRSUtil reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ntfrsutl)
and current Dfsrmig guidance. Stale membership and dangerous FRS recovery
shortcuts were cross-checked against practitioner discussions of
[references to removed servers](https://serverfault.com/questions/616329/) and
[FRS restore semantics](https://serverfault.com/questions/769771/).
Community repair instructions are not treated as a runbook. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
