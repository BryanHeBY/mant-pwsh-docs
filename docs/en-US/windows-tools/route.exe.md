<!-- mant:tldr:start -->
# route.exe

> Inspect the Windows IPv4 routing table without changing connectivity.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/route_ws2008.

- Print interfaces, active IPv4 routes, and persistent IPv4 routes:

`route.exe print`

- Print routes matching one reviewed destination prefix:

`route.exe print {{10.*}}`

- Inspect typed routes ordered by prefix length and metric:

`Get-NetRoute -AddressFamily IPv4 | Sort-Object DestinationPrefix, RouteMetric | Select-Object DestinationPrefix, NextHop, InterfaceIndex, RouteMetric, PolicyStore`

- Find the route Windows would use for one remote IPv4 address:

`Find-NetRoute -RemoteIPAddress {{destination-IPv4-address}}`
<!-- mant:tldr:end -->

# route.exe

## Overview

`route.exe` displays and modifies the local IPv4 routing table. `print` is
read-only; `add`, `change`, and `delete` alter routes. `/p add` persists a
route in the registry. Route selection first favors the most specific matching
prefix and then considers route and interface metrics.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `route.exe`: Display or modify the classic Windows IPv4 routing table.
- `print`: Display interfaces plus active and persistent routes, optionally
  restricted by an IPv4 destination pattern.
- `add`: Add one route using an explicit destination and gateway.
- `change`: Change an existing route's gateway, metric, or interface selection.
- `delete`: Delete routes matching the supplied destination and optional mask.

Mutation syntax can also include the bare keywords `mask`, `metric`, and `if`
followed by their values. They are operands in `route.exe` grammar, not
PowerShell named parameters.

<!-- mant:entries role=option case=insensitive -->
- `/f`: Flush all gateway routes before running any accompanying command; this
  is a broad destructive network change, not a force/confirmation switch.
- `/p`: With `add`, make the route persistent across TCP/IP restarts; with
  `print`, show only persistent routes. It is ignored by other verbs.
- `/?`: Display installed command help.

## PowerShell boundaries

Call `route.exe` explicitly and pass each destination, mask, gateway, metric,
and interface token separately. Its tables are localized text; prefer
`Get-NetRoute`, `Find-NetRoute`, and the corresponding NetTCPIP mutation
cmdlets for typed policy-store control. Preserve a recovery path, check
`$LASTEXITCODE`, and verify the winning route after every change.

## Common mistakes

### Reading `/f` as “force”

`/f` flushes nearly the entire routing table before any accompanying command.
It can immediately disconnect the host or a remote administration session.
It is never a harmless confirmation bypass and does not belong in a generic
repair recipe.

### Omitting the mask unintentionally

The default netmask is `255.255.255.255`, which creates or targets a host
route. State the destination, mask, next hop, interface, persistence, and
expected winning route before making a change.

### Ignoring persistence and policy store

An ordinary added route and `/p add` have different lifetimes. Inventory both
active and persistent routes, and verify the resulting policy store after a
change rather than assuming a successful message means the intended lifetime.

### Deleting with a wildcard

Wildcards are accepted by `print` and `delete`; a pattern can select many more
routes than its visual shorthand suggests. Expand and review an identical
`print` selection first, but still prefer an exact destination and mask for
changes.

### Comparing metrics without prefix length or interface cost

A more specific prefix wins before a less-specific route's lower metric, and
automatic interface metrics contribute to path selection. Use `Find-NetRoute`
for the actual destination and test connectivity from a recoverable console.

## Version and platform differences

This executable and the NetTCPIP alternatives are Windows-only. The classic
reference primarily describes IPv4 route syntax; use typed Windows networking
cmdlets for explicit IPv6 route management.

## Related documents

- [netstat.exe](netstat.exe.md)
- [ipconfig.exe](ipconfig.exe.md)
- [tracert.exe](tracert.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[route reference](https://learn.microsoft.com/windows-server/administration/windows-commands/route_ws2008).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
