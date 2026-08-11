<!-- mant:tldr:start -->
# arp.exe

> Inspect the per-interface Windows IPv4 neighbor cache.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/arp.

- Display current ARP entries for all interfaces:

`arp.exe -a`

- Display the entry for one IPv4 address if it is currently cached:

`arp.exe -a {{neighbor-IPv4-address}}`

- Limit display to the interface owning one exact local IPv4 address:

`arp.exe -a -N {{local-interface-IPv4-address}}`

- Inspect typed IPv4 neighbor state and interface identity:

`Get-NetNeighbor -AddressFamily IPv4 | Select-Object InterfaceIndex, IPAddress, LinkLayerAddress, State, PolicyStore`
<!-- mant:tldr:end -->

# arp.exe

## Overview

`arp.exe` displays or changes the Address Resolution Protocol cache that maps
on-link IPv4 addresses to link-layer addresses. Windows maintains a table per
applicable interface. `-a` and `-g` display; `-d` deletes; `-s` adds a static
entry that remains until the TCP/IP stack restarts.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `arp.exe`: Display or change the Windows IPv4 ARP cache.

The display and mutation modes use switches rather than subcommands. Address
operands are IPv4 addresses; an interface operand is one local IPv4 address,
not an adapter alias or index.

<!-- mant:entries role=option case=insensitive -->
- `-a`: Display current ARP entries; optionally limit the result to one cached
  IPv4 address. With multiple interfaces, show a separate table for each one.
- `-g`: Display entries using the legacy option name equivalent to `-a`.
- `-v`: Include invalid entries and entries on the loopback interface in a
  verbose display; combine it with a display operation.
- `-N`: Limit a display to the interface owning the following local IPv4
  address. This switch is uppercase in Microsoft's documented syntax.
- `-d`: Delete the following IPv4 entry; `*` selects every entry, so avoid it
  unless that complete mutation was explicitly intended and reviewed.
- `-s`: Add a static IPv4-to-link-layer mapping, optionally on the interface
  identified by a following local IPv4 address.

## PowerShell boundaries

Call `arp.exe` explicitly because other operating systems expose a different
`arp` syntax. Its output is localized text, not neighbor objects; use
`Get-NetNeighbor` for typed selection. Check `$LASTEXITCODE` after a mutation
and query the exact interface/address again to verify the resulting state.

## Common mistakes

### Treating the cache as a network inventory

The cache contains recently resolved or configured on-link neighbors, not
every live device. An absent entry does not prove a device is down, and a
present entry does not prove it is currently reachable.

### Applying ARP to IPv6 or routed destinations

ARP maps IPv4 neighbors on a local link. IPv6 uses Neighbor Discovery, and a
remote destination normally produces an entry for the next-hop router rather
than the remote host. Use `Get-NetNeighbor` with the correct address family.

### Looking at the wrong interface table

VPN, Wi-Fi, Ethernet, and virtual adapters can have separate entries for
similar address ranges. Correlate local interface address/index and route;
`-N` takes a local interface IPv4 address, not an interface name.

### Deleting all entries as a first diagnostic step

`arp -d *` changes every selected cache table and erases evidence. Capture the
tables, interface state, and route first. If an exact entry must be refreshed,
scope it to one IPv4 address and interface and verify the result.

### Using a MAC address as permanent device identity

Virtual adapters, replacement hardware, spoofing, and address randomization
break that assumption. Treat the observed pair as time- and interface-scoped
network evidence.

## Version and platform differences

This page documents Windows `arp.exe`; syntax differs across operating
systems. `Get-NetNeighbor` is a Windows NetTCPIP cmdlet.

## Related documents

- [getmac.exe](getmac.exe.md)
- [route.exe](route.exe.md)
- [ipconfig.exe](ipconfig.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[arp reference](https://learn.microsoft.com/windows-server/administration/windows-commands/arp).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
