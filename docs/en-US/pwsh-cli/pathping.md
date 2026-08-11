<!-- mant:tldr:start -->
# pathping

> Sample ICMP latency and loss along a Windows network path.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pathping.

- Measure the path without reverse-DNS delays, allowing time for sampling:

`pathping.exe /n {{host-or-address}}`

- Run a shorter exploratory sample before a longer measurement:

`pathping.exe /n /q {{20}} /p {{250}} {{host-or-address}}`

- Fix the address family when the name has both IPv4 and IPv6 records:

`pathping.exe /n /4 {{host-or-address}}`

- Get a quick hop list when statistical sampling is unnecessary:

`tracert.exe /d {{host-or-address}}`
<!-- mant:tldr:end -->

# pathping

## Overview

`pathping.exe` first discovers an ICMP-visible route and then sends repeated
probes to estimate latency and loss for hops and links. `/n` skips reverse
lookups, `/q` controls queries per hop, `/p` controls milliseconds between
probes, and `/4` or `/6` fixes the address family. Its sampling phase is
intentionally slower than `tracert`.

## Common mistakes

### Closing the command before statistics arrive

Path discovery is only the first phase. The default 100 queries per hop take
time; wait for the computed result or state the reduced `/q` sample size when
sharing evidence.

### Calling every intermediate loss value packet loss

Routers may rate-limit or deprioritize replies addressed to themselves while
forwarding transit packets normally. Loss that appears at one hop but not at
subsequent hops is not, by itself, proof that the link drops forwarded traffic.

### Comparing samples with different parameters

Query count, interval, timeout, source path, address family, and time of day
all affect results. Preserve the full command and timestamp before comparing
runs.

### Using it as an application monitor

The command samples ICMP behavior, not a service transaction. Confirm any
suspected endpoint problem with the actual port and application protocol.

## Version and platform differences

This executable is Windows-only. Firewalls, routing policy, and ICMP response
policy determine which hops and measurements are visible.

## Related documents

- [tracert](tracert.md)
- [ping](ping.md)
- [nslookup](nslookup.md)

## Sources and license

This original guide was adapted from Microsoft's official
[pathping reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pathping).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
