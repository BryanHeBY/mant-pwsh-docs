<!-- mant:tldr:start -->
# tracert.exe

> Trace the ICMP-visible Windows path to a destination.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tracert.

- Trace an IPv4 path without waiting for reverse-DNS names:

`tracert.exe /d /4 {{host-or-address}}`

- Bound both the hop count and wait per probe for a quick diagnostic:

`tracert.exe /d /h {{15}} /w {{1000}} {{host-or-address}}`

- Trace IPv6 explicitly:

`tracert.exe /d /6 {{host-or-address}}`

- Collect loss and latency samples across the path after a basic trace:

`pathping.exe /n {{host-or-address}}`
<!-- mant:tldr:end -->

# tracert.exe

## Overview

`tracert.exe` sends ICMP probes with increasing time-to-live values. Routers
that return ICMP Time Exceeded messages reveal hop addresses; the destination
ends the trace when it responds. `/d` skips reverse lookups, `/h` limits hops,
`/w` sets a per-probe timeout in milliseconds, and `/4` or `/6` fixes the
address family.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `tracert.exe`: Trace the ICMP-visible Windows hop path to one destination.

Uppercase `/R` and `/S` are IPv6-specific and are not interchangeable with
lowercase options used by other Windows networking tools.

<!-- mant:entries role=option case=sensitive -->
- `/d`: Keep hop addresses numeric and skip reverse-DNS name resolution.
- `/h`: Set the maximum hop count searched for the destination.
- `/j`: Use the following loose IPv4 source-route host list.
- `/w`: Set the wait in milliseconds for each probe reply.
- `/R`: Trace the IPv6 round-trip path where routing headers and the target
  support that diagnostic behavior.
- `/S`: Use the following IPv6 source address.
- `/4`: Force IPv4.
- `/6`: Force IPv6.
- `/?`: Display installed command help.

## PowerShell boundaries

`tracert.exe` emits localized incremental text rather than hop objects. Set
explicit `/h` and `/w` bounds for automation, preserve a timestamp and source
context, and check `$LASTEXITCODE` after completion. An asterisk is missing
diagnostic response data, not a typed assertion that forwarding failed.

## Common mistakes

### Treating an asterisk as a broken forwarding path

A router can forward traffic while declining or delaying the diagnostic ICMP
reply. Later hops or the destination may still answer. Correlate consecutive
hops, destination behavior, and application tests before locating a failure.

### Reading the output as a complete physical topology

The trace reports responding near-side router interfaces for this flow.
Load balancing, tunnels, policy, asymmetric return paths, and invisible
routers can hide or vary the path.

### Blaming network delay on reverse DNS

Name lookups can add visible delay before rows appear. Start with `/d` for
address and timing evidence; resolve selected addresses separately when names
are useful.

### Assuming one trace is stable evidence

Routes and load-balanced paths can change between probes. Preserve the target,
source context, address family, timestamp, and repeated results.

## Version and platform differences

This page documents Windows `tracert.exe`, not Unix `traceroute`. Network
policy can filter the ICMP messages on which its view depends.

## Related documents

- [ping.exe](ping.exe.md)
- [pathping.exe](pathping.exe.md)
- [nslookup.exe](nslookup.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tracert reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tracert).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
