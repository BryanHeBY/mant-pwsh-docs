<!-- mant:tldr:start -->
# ipconfig

> Inspect Windows TCP/IP, DHCP, and DNS client state.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ipconfig.

- Show the complete configuration for every physical and virtual adapter:

`ipconfig.exe /all`

- Inspect the local DNS client resolver cache without changing it:

`ipconfig.exe /displaydns`

- Inspect typed IP configuration when a script must select an adapter reliably:

`Get-NetIPConfiguration | Select-Object InterfaceAlias, InterfaceIndex, IPv4Address, IPv6Address, IPv4DefaultGateway, DNSServer`

- Renew DHCP configuration for one reviewed adapter only:

`ipconfig.exe /renew "{{adapter name from ipconfig output}}"`
<!-- mant:tldr:end -->

# ipconfig

## Overview

`ipconfig.exe` displays TCP/IP configuration and can request DHCP or DNS
client changes. With no option it shows addresses, subnet masks, and default
gateways; `/all` adds adapter, DHCP, DNS, and lease details. `/displaydns` is
read-only. `/flushdns`, `/registerdns`, `/release`, `/renew`, and class-ID
options change client state or initiate network operations.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `ipconfig.exe`: Display Windows IP configuration or request specific DHCP
  and DNS client operations.

An optional adapter selector is a connection name from `ipconfig` output and
can contain `*` or `?`. Quote names containing spaces and avoid a wildcard for
state-changing operations unless every match was reviewed.

<!-- mant:entries role=option case=insensitive -->
- `/all`: Display complete configuration for every adapter, including DHCP,
  DNS, lease, and physical-address fields where applicable.
- `/allcompartments`: Display information for every network compartment; add
  `/all` when complete adapter details are also required.
- `/release`: Release IPv4 DHCP configuration for all matching adapters.
- `/release6`: Release IPv6 DHCP configuration for all matching adapters.
- `/renew`: Renew IPv4 DHCP configuration for all matching adapters.
- `/renew6`: Renew IPv6 DHCP configuration for all matching adapters.
- `/flushdns`: Purge dynamic entries from the DNS client resolver cache.
- `/displaydns`: Display entries currently present in the DNS client resolver
  cache without changing them.
- `/registerdns`: Initiate manual dynamic DNS registration for configured
  names and addresses.
- `/showclassid`: Display allowed IPv4 DHCP class IDs for a matching adapter.
- `/setclassid`: Set or remove the IPv4 DHCP class ID for a matching adapter;
  omitting the class ID removes the current value.
- `/showclassid6`: Display allowed IPv6 DHCP class IDs for a matching adapter.
- `/setclassid6`: Set or remove the IPv6 DHCP class ID for a matching adapter.
- `/?`: Display the syntax installed with this Windows release.

## PowerShell boundaries

`ipconfig.exe` writes localized display text. Prefer NetTCPIP, DnsClient, and
DhcpClient cmdlets for typed automation. When invoking a native operation,
pass a quoted adapter name as one argument, capture the before-state, check
`$LASTEXITCODE`, and re-query the exact adapter rather than trusting output
text alone.

## Common mistakes

### Flushing DNS before collecting evidence

`/flushdns` removes positive and negative dynamic cache entries. Capture
`/displaydns`, configured DNS servers, the queried name, and timestamps first;
otherwise a transient resolver problem can become harder to diagnose.

### Releasing every DHCP adapter accidentally

`/release` without an adapter targets every DHCP-configured adapter and
discards its configuration. This can disconnect a local or remote session.
Copy one adapter name from current output, quote names containing spaces, and
avoid a wildcard unless every match was reviewed.

### Parsing localized display text

Labels and layout are presentation, not a stable data contract. For
automation, prefer `Get-NetIPConfiguration`, `Get-DnsClientCache`, and related
typed networking cmdlets where available.

### Treating all listed adapters as usable paths

VPNs, tunnels, virtual switches, disconnected adapters, and multiple address
families are normal. Correlate interface index, status, route, DNS server, and
the actual destination rather than selecting the first address.

## Version and platform differences

This executable is Windows-only. The NetTCPIP and DnsClient PowerShell
modules used by the typed alternatives are also Windows-specific and may be
restricted in minimal environments.

## Related documents

- [ping](ping.md)
- [nslookup](nslookup.md)
- [hostname](hostname.md)

## Sources and license

This original guide was adapted from Microsoft's official
[ipconfig reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ipconfig).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
