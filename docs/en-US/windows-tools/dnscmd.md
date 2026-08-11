<!-- mant:tldr:start -->
# dnscmd

> Query one explicit Windows DNS server, zone, and node first; omitted server
> names select the local host, while many families immediately change or delete
> server, zone, record, partition, cache, or DNSSEC state.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/dnscmd.

- List zones hosted by one exact DNS server:

`dnscmd.exe "{{dns01.example.com}}" /enumzones`

- Show type, storage, update, aging, transfer, and DNSSEC settings for one exact zone:

`dnscmd.exe "{{dns01.example.com}}" /zoneinfo "{{example.com}}"`

- Enumerate every detail for one exact node in one exact zone:

`dnscmd.exe "{{dns01.example.com}}" /enumrecords "{{example.com}}" "{{www}}" /detail`

- List AD-integrated DNS application-directory partitions visible to one exact server:

`dnscmd.exe "{{dns01.example.com}}" /enumdirectorypartitions`

<!-- mant:tldr:end -->

# dnscmd

## Overview

`dnscmd.exe` is the broad native administration interface for Microsoft DNS
Server. It can inventory and also configure servers/zones, add/delete records,
create/move/delete AD application partitions, sign zones, manage keys/trust
anchors, clear caches, pause/reload zones, and import/export data. Always name
the server; an omitted server silently means the local host.

Prefer the DnsServer PowerShell module for new automation because it returns
typed objects and exposes parameter binding, confirmation, and help. Dnscmd
remains important for compatibility and families not present on every module
version.

## Command-family map

- Read-only inventory: `/info`, `/enumzones`, `/zoneinfo`, `/enumrecords`,
  `/enumdirectorypartitions`, `/directorypartitioninfo`, cache/file/key and
  selected signing-status queries.
- Records/nodes: `/recordadd`, `/recorddelete`, `/nodedelete`, aging and reset-
  listen operations can affect one record, RRset, node tree, or availability.
- Zones: add/delete/reset type/masters/forwarders, pause/resume/reload/refresh,
  transfer, partition moves, scopes/policies, DNSSEC signing and key rollover.
- Server: `/config`, cache clear, forwarders, recursion, logging, scavenging,
  plug-ins, root hints, boot source and RPC settings.
- Directory partitions: create/delete/enlist/unenlist can change AD replica
  topology and DNS availability after replication.

## Common mistakes

### Omitting the server argument

The syntax permits it, but “local” may be a management workstation, a DC that
is not the intended DNS owner, or a different replica than the failing client
uses. Record server FQDN, address, site, role, zone replica, elevation, and
calling identity for every invocation.

### Confusing `/zoneprint`, `/zoneexport`, and backup

`/zoneprint` emits a textual record representation. `/zoneexport` writes a file
on the DNS server under its DNS directory by default, not on the calling client,
and is described as troubleshooting output for an AD-integrated zone. Neither
alone preserves AD replication metadata, ACLs, server configuration, policies,
DNSSEC private keys, or system-state recovery. Use supported DNS/system-state
backup and test restoration.

### Deleting more records than intended

`/recorddelete` without exact RR data can delete all records of a type at that
node; `/nodedelete /tree` expands to descendants; `/f` suppresses the last
confirmation. Inventory the exact zone, node, type, data, timestamp/owner and
dependent service, then requery immediately before an authorized deletion.

### Treating `/config` as a query

`/config` changes server or zone registry-backed settings. Use `/info` for
server state and `/zoneinfo` for zone state. Missing values and hexadecimal/
decimal units can radically change recursion, forwarding, scavenging, update,
logging, transfers, plug-ins, or cache behavior.

### Applying scavenging or aging as cleanup

`/ageallrecords` adds irreversible Windows timestamps and can make records
eligible for scavenging; `/startscavenging` and interval changes affect broad
data lifecycles. Establish record ownership, static/dynamic origin, refresh/no-
refresh math, DHCP credentials, replication, backups, and business exceptions.

### Assuming record presence proves client resolution

Validate authoritative zone/delegation, view/scope/policy, DNSSEC, conditional
forwarding, replica convergence, client resolver/cache/suffix, UDP/TCP paths,
and the exact query type from the failing client. A row from `/enumrecords` is
only server-local inventory.

### Building command strings with `Invoke-Expression`

Pass an argument array directly to `dnscmd.exe`; zone, node, server, filename,
and record data can otherwise become injected shell syntax. Use DnsServer
cmdlets for typed bulk work and independently validate each exact object.

## PowerShell behavior

Invoke `dnscmd.exe`, preserve localized raw output, and capture
`$LASTEXITCODE`. Do not parse columns as a stable schema. For typed automation,
use `Get-DnsServerZone`, `Get-DnsServerResourceRecord`, and family-specific
DnsServer cmdlets against an explicit `-ComputerName`; review `-WhatIf`/
confirmation support for every mutating cmdlet.

## Version and platform differences

Dnscmd is Windows DNS Server/RSAT tooling. Families, DNSSEC/policy/scope
features, record types, partition behavior, output, permissions, and module
equivalents vary by Windows Server/RSAT version. Some reference text preserves
legacy terminology or obsolete switches; target-local help and current feature-
specific Microsoft documentation govern behavior.

## Related documents

- [nslookup](nslookup.md)
- [dcdiag](dcdiag.md)
- [repadmin](repadmin.md)
- [ipconfig](ipconfig.md)
- [netsh](netsh.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Dnscmd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dnscmd).
The distinction between zone configuration, printed records, and server-local
exports was cross-checked against practitioner questions about
[displaying zone configuration](https://serverfault.com/questions/732528/) and
[export location/meaning](https://serverfault.com/questions/535438/).
Microsoft documentation and target-local help govern supported behavior. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
