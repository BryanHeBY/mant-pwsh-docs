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

## Context commands

<!-- mant:entries role=command case=insensitive -->
- `netsh.exe`: Run one fully qualified Windows Netsh context command.
- `interface`: Enter or address the interface-management context.
- `6to4`: Address legacy IPv6-over-IPv4 transition settings; do not enable it
  from generic connectivity advice.
- `fl48`: Display or dump build-specific virtual-interface state.
- `fl68`: Display or dump build-specific virtual-interface state.
- `httpstunnel`: Display or manage IP-HTTPS client/server interfaces and
  active versus persistent state.
- `ipv4`: Address IPv4 interfaces, addresses, routes, neighbors, DNS, and stack state.
- `ipv6`: Address IPv6 interfaces, addresses, routes, neighbors, DNS, and stack state.
- `isatap`: Address legacy ISATAP transition-tunnel state.
- `tcp`: Address interface-context TCP global, supplemental, heuristic, and
  connection settings supported by the target build.
- `udp`: Address interface-context UDP settings supported by the target build.
- `portproxy`: Display or manage selected TCP v4/v6 listener-to-destination proxies.
- `teredo`: Address Teredo transition-tunnel state.
- `show`: Display the selected interface/context state without changing it.
- `set`: Change one existing interface/context setting or policy-store value.
- `add`: Add a supported address, route, neighbor, DNS/WINS entry, or proxy rule.
- `delete`: Delete one exact supported interface-context object/rule.
- `reset`: Reset the selected context family; this is a broad mutation, not a
  generic troubleshooting query.
- `dump`: Emit a Netsh replay script for review; do not execute it blindly.
- `install`: Install the IPv4 protocol on builds that expose the command; this
  is a broad stack mutation, not a repair probe.
- `uninstall`: Uninstall the IPv4 protocol on builds that expose the command;
  this can remove connectivity and must never be generated for validation.
- `reload`: Reload persisted TCP configuration; installed and current official
  help mark it experimental and explicitly say not to use it.
- `rundown`: Force connection rundown on active TCP trace sessions; it changes
  diagnostic-session state rather than merely showing connections.

Parameters such as `name=`, `interface=`, `address=`, and `store=` are Netsh's
bare equals-bearing grammar rather than PowerShell named parameters.

## PowerShell boundaries

Use a fully qualified noninteractive invocation such as
`netsh.exe interface ipv4 show ...`; never rely on state left at a Netsh prompt.
Pass each `name=value` token as one native argument, capture `$LASTEXITCODE`,
and prefer typed NetTCPIP/DnsClient cmdlets where they expose the required
policy store. Re-query both active and persistent state after a mutation.

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

### Treating every context noun as a query

IPv4 `install`/`uninstall`, TCP `reload`/`rundown`, and tunnel-context
`set`/`reset` forms are operational commands. In particular, current help says
TCP `reload` is experimental and must not be used, while `rundown` acts on all
active TCP trace sessions. Discover context grammar with a trailing `?`, but
do not invoke a named operation merely to learn what it does.

### Guessing interface names

Names can be localized, renamed, or duplicated across hosts. Query names and
indexes first, quote names containing spaces, and use typed NetTCPIP/DnsClient
cmdlets for reliable automation where supported.

## Version and platform differences

This Windows-only context varies substantially by release, network stack, and
installed features. Some settings require elevation or are controlled by
policy; current PowerShell networking cmdlets are preferred when equivalent.
On exact System32 Netsh file version `10.0.26100.8457`, top-level `?` returned
1 with 38 nonempty lines, while `interface ?` and the IPv4, IPv6, TCP, UDP, and
PortProxy context-help forms all returned 0 with 22/14/16/14/10/12 lines. Help
exposed `6to4`, `fl48`, `fl68`, `httpstunnel`, `isatap`, `teredo`, IPv4
`install`/`uninstall`, and TCP `reload`/`rundown`. Only help ran; no interface,
address, route, neighbor, DNS, tunnel, proxy, TCP/UDP, trace, or policy state
was queried or changed.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 Netsh file version 10.0.26100.8457
top-level ? returned 1/38 nonempty lines, while interface and
IPv4/IPv6/TCP/UDP/PortProxy context help returned 0 with 22/14/16/14/10/12
lines. Help added 6to4, fl48, fl68, httpstunnel, isatap, teredo, IPv4
install/uninstall, and TCP reload/rundown; only help ran and no network or
trace state was queried or changed. Representative interface, policy-store,
tunnel, and proxy environments remain required.

## Related documents
- [netsh.exe](netsh.exe.md)
- [ipconfig.exe](ipconfig.exe.md)
- [route.exe](route.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netsh interface reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-interface).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
