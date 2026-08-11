<!-- mant:tldr:start -->
# tapicfg.exe

> Query TAPI application-directory partitions before any forest-wide partition, SCP, or default change.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tapicfg.

- Read family and installed subcommand help without changing Active Directory:

`tapicfg.exe /?; tapicfg.exe show /?`

- Display TAPI application-directory partitions and locations in the domain:

`tapicfg.exe show`

- Capture the current forest/domain identity before planning a change:

`Get-CimInstance Win32_ComputerSystem | Select-Object Domain, PartOfDomain`

- Inventory TAPI service connection points independently when AD tooling is available:

`Get-ADObject -LDAPFilter '(objectClass=serviceConnectionPoint)' -Properties serviceBindingInformation | Where-Object Name -Match 'TAPI'`
<!-- mant:tldr:end -->

# tapicfg.exe

## Overview

`tapicfg.exe` manages TAPI 3.1 application-directory partitions and their Active
Directory service connection points. `show` is the read-only discovery family;
`install`, `remove`, `publishscp`, `removescp`, and `makedefault` mutate
forest/domain discovery state. Install/remove requires Enterprise Admins.

## Command families

<!-- mant:entries role=command case=insensitive -->
- `tapicfg.exe`: Inspect or administer legacy TAPI application-directory partitions.
- `show`: Display partition, default, or service-connection-point state.
- `install`: Create a TAPI application-directory partition.
- `remove`: Remove one exact partition.
- `publishscp`: Publish a partition service connection point in AD DS.
- `removescp`: Remove one published service connection point.
- `makedefault`: Select the default TAPI application-directory partition.

Use family-specific installed help before any mutation.

## Common mistakes

### Creating a partition before proving a client dependency

Inventory TAPI clients, servers, lines/providers, directory lookup, domains,
trusts, existing partitions/SCPs, and application ownership. An obsolete client
requirement may be better migrated than expanded forest-wide.

### Treating an SCP as the partition itself

The SCP publishes discovery information; the application directory partition
stores directory data. Removing/recreating one is not equivalent to deleting or
creating the other. Back up and verify both layers.

### Forgetting rename and replication effects

Microsoft notes that a renamed partition/domain can leave an SCP with an old DNS
name. Plan AD replication convergence, DNS, site/DC reachability, client caches,
rollback, and stale-object cleanup.

### Running high privilege for ordinary inspection

Use delegated read-only discovery for `show` and AD inventory. Do not normalize
Enterprise Admin credentials in scripts or interactive troubleshooting.

## PowerShell boundaries

TapiCfg emits native text; AD cmdlets return objects only when the ActiveDirectory
module and permissions are available. Capture exact forest/domain/DC context and
`$LASTEXITCODE`; do not parse localized display as a stable directory schema.

## Version and platform differences

This is Windows/domain-only legacy telephony tooling. AD schema/functional level,
replication, TAPI components, language support, trusts, and client compatibility
vary. Current catalog applicability does not imply a new design should use it.

## Related documents

- [tsecimp.exe](tsecimp.exe.md)
- [tcmsetup.exe](tcmsetup.exe.md)

## Sources and license

Adapted as an original guide from Microsoft's [TapiCfg family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tapicfg).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
