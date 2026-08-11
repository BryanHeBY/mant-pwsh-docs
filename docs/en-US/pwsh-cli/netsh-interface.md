<!-- mant:tldr:start -->
# netsh interface

> Inspect Windows interface, IP, TCP/UDP, tunnel, and port-proxy contexts.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-interface.

- List interfaces and administrative/connection state:

`netsh.exe interface show interface`

- Show detailed IPv4 interface configuration:

`netsh.exe interface ipv4 show config`

- Show detailed IPv6 interfaces without changing them:

`netsh.exe interface ipv6 show interfaces level=verbose`

- Inventory configured TCP port proxies before any change:

`netsh.exe interface portproxy show all`
<!-- mant:tldr:end -->

# netsh interface

## Overview

`netsh interface` is a large family for interface state, IPv4 and IPv6
addresses, routes, DNS/WINS, neighbors, TCP/UDP settings, transition tunnels,
HTTPS tunnels, and TCP port proxies. The full context path makes a command
scriptable and prevents hidden interactive context state.

## Common mistakes

### Disabling the interface carrying the session

`set interface admin=disabled`, address/DNS changes, tunnel changes, and route
changes can terminate local connectivity or remote administration. Record the
interface index/name, current config, expected path, persistence store, and a
console recovery plan first.

### Confusing active and persistent stores

Many subcommands accept `store=active` or `store=persistent`. State it
explicitly and query after the change and after restart when persistence is
part of the requirement.

### Treating a port proxy as a firewall or full proxy

`portproxy` forwards selected TCP endpoints; it does not create the required
firewall policy, validate application protocols, or provide general UDP
forwarding. Inspect listener/address family, destination, route, firewall,
and service separately.

### Copying obsolete transition-technology recipes

6to4, ISATAP, and Teredo settings are environment- and policy-sensitive.
Do not enable a tunnel because a generic diagnostic mentions it; verify the
current supported design and organizational policy.

### Guessing interface names

Names can be localized, renamed, or duplicated across hosts. Query names and
indexes first, quote names containing spaces, and use typed NetTCPIP/DnsClient
cmdlets for reliable automation where supported.

## Version and platform differences

This Windows-only context varies substantially by release, network stack, and
installed features. Some settings require elevation or are controlled by
policy; current PowerShell networking cmdlets are preferred when equivalent.

## Related documents

- [netsh](netsh.md)
- [ipconfig](ipconfig.md)
- [route](route.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netsh interface reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-interface).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
