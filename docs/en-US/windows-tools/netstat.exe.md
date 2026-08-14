<!-- mant:tldr:start -->
# netstat.exe

> Inspect Windows sockets, owning process IDs, protocol statistics, and routes.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/netstat.

- List numeric TCP connections and listeners with owning process IDs:

`netstat.exe -ano -p tcp`

- Select one exact local TCP port with typed PowerShell objects:

`Get-NetTCPConnection -LocalPort {{port}} | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess`

- Resolve a reviewed owning PID to current process identity:

`Get-Process -Id {{owning-process-id}} | Select-Object Id, ProcessName, Path, StartTime`

- List numeric UDP endpoints with owning process IDs:

`netstat.exe -ano -p udp`

- Display every connection and listening TCP/UDP endpoint:

`netstat.exe -a`

- Display interface byte and packet statistics:

`netstat.exe -e`

- Display the current IP routing table:

`netstat.exe -r`

- Display per-protocol network statistics:

`netstat.exe -s`
<!-- mant:tldr:end -->

# netstat.exe

## Overview

`netstat.exe` displays TCP connections, TCP and UDP listeners, owning PIDs,
protocol statistics, Ethernet statistics, and the route table. `-a` includes
listeners, `-n` prevents name and service lookups, `-o` adds a PID, and `-p`
limits a protocol. A trailing interval repeats output until Ctrl+C.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `netstat.exe`: Display Windows network endpoints, connections, statistics,
  routing information, and selected ownership details.

Single-letter switches can be combined, as in `-ano`. A final integer operand
repeats the selected display at that interval in seconds until interrupted.

<!-- mant:entries role=option case=insensitive -->
- `-a`: Include active TCP connections plus listening TCP and UDP ports.
- `-b`: Show the executable involved in creating each connection or listener;
  this can be slow and requires sufficient access.
- `-c`: Display processes ordered by the number of TCP or UDP ports currently
  consumed; this installed, build-dependent view is not CPU utilization.
- `-d`: Add the DSCP value associated with each connection; it does not prove
  that every network hop honors that marking.
- `-e`: Display Ethernet statistics such as bytes and packets sent/received;
  combine with `-s` for per-protocol statistics.
- `-f`: Show fully qualified domain names for foreign endpoints when name
  resolution succeeds.
- `-i`: Display how long a TCP connection has remained in its current state;
  this is state duration, not process age or end-to-end uptime.
- `-n`: Keep addresses and ports numeric instead of resolving host/service names.
- `-o`: Include the owning process ID for each connection or listener.
- `-p`: Limit a connection display or statistics report to the following
  protocol supported by that mode.
- `-q`: Include bound non-listening TCP ports in addition to listening and
  active endpoints.
- `-r`: Display the IP routing table.
- `-s`: Display per-protocol statistics; narrow them with `-p` when needed.
- `-t`: Display the current TCP connection offload state.
- `-x`: Display NetworkDirect connections, listeners, and shared endpoints.
- `-y`: Display the TCP connection template for all connections; it cannot be
  combined with the other documented switches.
- `-?`, `/?`: Display installed command help.

## PowerShell boundaries

`netstat.exe` emits snapshots as localized text. Prefer `Get-NetTCPConnection`,
`Get-NetUDPEndpoint`, and `Get-NetRoute` for typed selection, then revalidate
the owning PID because endpoints and process IDs are race-prone. Bound repeat
mode and check `$LASTEXITCODE` when collecting evidence in a script.

## Common mistakes

### Filtering a port with an unanchored text search

`findstr 8080` can match a local port, remote port, address fragment, or PID.
It can also match `18080`. Prefer `Get-NetTCPConnection -LocalPort` or parse
the local endpoint field and numeric port explicitly.

### Assuming TCP and UDP have the same state model

UDP has endpoints but no TCP-style `LISTENING` or connection state. Query the
protocol intended by the application and do not discard a UDP result because
it lacks a state label.

### Trusting a PID after the snapshot

Sockets close and PIDs are reused. Revalidate the socket and process path,
start time, service relationship, and purpose immediately before acting.

### Reaching for `-b` first

`-b` can be slow and requires sufficient permissions. Start with numeric
endpoints and `-o`; inspect only the relevant PID with process and service
tools. Elevation can expose more information but does not make a snapshot
race-free.

### Treating a listener as remote reachability

A local listener does not prove that a firewall, route, address binding, TLS,
or application protocol permits a remote client. Test from the relevant
network path using the actual service protocol.

## Version and platform differences

This page documents Windows `netstat.exe`. The NetTCPIP PowerShell cmdlets are
Windows-specific. Visible ownership and executable details depend on access.
On Windows NT `10.0.26200.0`, installed file version `10.0.26100.8521`
printed 42 normalized nonempty help lines and returned 1 for both `/?` and
`-?`; help used the native error stream. Installed help adds `-c`, `-d`, and
`-i` beyond the locked general page. Only help ran for this comparison; no
endpoint, PID, protocol, interval, or remote target was selected.

## Runtime evidence

The repeatable read-only Windows CLI fixture resolved exact System32
`netstat.exe`, captured its localized `/?` text from stderr with expected exit
code `1`, and ran one local numeric TCP/PID snapshot using `-ano -p tcp`.
The snapshot returned `0` and nonempty output under both PowerShell collectors;
endpoints and PIDs were counted but not emitted into logs. No interval, binary
ownership lookup, routing table, protocol statistics, or remote target was
used, and the snapshot remains race-prone.

## Related documents

- [tasklist.exe](tasklist.exe.md)
- [route.exe](route.exe.md)
- [ping.exe](ping.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netstat reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netstat).
The common PID-to-port investigation was cross-checked against a highly used
[practitioner Q&A](https://stackoverflow.com/questions/48198/how-do-i-find-out-which-process-is-listening-on-a-tcp-or-udp-port-on-windows),
then constrained by the official option semantics. Exact sources and licenses
are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
