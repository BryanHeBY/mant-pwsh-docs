<!-- mant:tldr:start -->
# tracert

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

# tracert

## Overview

`tracert.exe` sends ICMP probes with increasing time-to-live values. Routers
that return ICMP Time Exceeded messages reveal hop addresses; the destination
ends the trace when it responds. `/d` skips reverse lookups, `/h` limits hops,
`/w` sets a per-probe timeout in milliseconds, and `/4` or `/6` fixes the
address family.

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

- [ping](ping.md)
- [pathping](pathping.md)
- [nslookup](nslookup.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tracert reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tracert).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
