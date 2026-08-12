<!-- mant:tldr:start -->
# jetpack.exe

> Compact a legacy WINS or DHCP database only in its role-specific offline maintenance and restore procedure.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/jetpack.

- Confirm the tool and role service without touching the database:

`Get-Command jetpack.exe -ErrorAction SilentlyContinue; Get-Service -Name WINS,DHCPServer -ErrorAction SilentlyContinue`

- Inventory exact candidate files, sizes, timestamps, and hashes before maintenance:

`Get-Item -LiteralPath "{{C:\Windows\System32\dhcp\dhcp.mdb}}" | Select-Object FullName, Length, LastWriteTime; Get-FileHash -LiteralPath "{{C:\Windows\System32\dhcp\dhcp.mdb}}"`

- Confirm a unique temporary path does not already exist:

`if (Test-Path -LiteralPath "{{C:\Windows\System32\dhcp\jet-new.tmp}}") { throw 'Temporary path already exists' }`

- Read installed syntax; do not run it while the owning service is active:

`jetpack.exe /?`
<!-- mant:tldr:end -->

# jetpack.exe

## Overview

`jetpack.exe <database> <temporary-database>` compacts a legacy WINS or DHCP
Jet database by copying into a temporary database, deleting the original, and
renaming the temporary result. Microsoft examples stop the owning service first
and restart it afterward. This is an offline, destructive replacement workflow.

## Invocation boundary

<!-- mant:entries role=command case=insensitive -->
- `jetpack.exe`: Compact an offline WINS or DHCP Jet database through a temporary database.

Both database paths are positional and the owning service must be stopped;
compaction is neither backup nor general repair.

## Common mistakes

### Running against a live database

Stop and quiesce the correct role through its supported maintenance procedure,
including failover/partner implications and clients. Open handles or concurrent
writes can corrupt state or invalidate the result.

### Calling compaction a backup or repair

The original is deleted during successful processing. Take and validate a
role-supported backup, record database/log paths and service state, and prepare
restore before compaction. Diagnose storage or database errors separately.

### Reusing an existing temporary filename

Microsoft requires a unique non-existing temporary file. Confirm it explicitly,
keep it on appropriate protected storage with adequate free space, and never
point it at a valuable artifact.

### Copying the WINS example to DHCP unchanged

Database name, directory, logs, service name, backup/restore process, failover,
and verification differ. Use the procedure for the installed role and version.

## PowerShell boundaries

JetPack is native and mutates files. Resolve literal paths, preserve hashes and
service evidence, capture `$LASTEXITCODE`, and verify database/service/client
health after restart. PowerShell success starting the process is not proof of a
consistent database.

## Version and platform differences

This is Windows role-specific legacy tooling. WINS/DHCP versions, failover,
database engine, service accounts, storage paths, backup APIs, and supported
repair procedures differ. Do not use it for unrelated ESE databases.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`jetpack.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains help/service/file/hash/free-path inventory
only; no database, temporary file, service, role, failover, backup or restore
mutation is permitted merely for evidence.

## Related documents
- [sc.exe](sc.exe.md)
- [freedisk.exe](freedisk.exe.md)

## Sources and license

Adapted as an original guide from Microsoft's [JetPack reference](https://learn.microsoft.com/windows-server/administration/windows-commands/jetpack).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
