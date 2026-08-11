<!-- mant:tldr:start -->
# netstat

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
<!-- mant:tldr:end -->

# netstat

## Overview

`netstat.exe` displays TCP connections, TCP and UDP listeners, owning PIDs,
protocol statistics, Ethernet statistics, and the route table. `-a` includes
listeners, `-n` prevents name and service lookups, `-o` adds a PID, and `-p`
limits a protocol. A trailing interval repeats output until Ctrl+C.

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

## Related documents

- [tasklist](tasklist.md)
- [route](route.md)
- [ping](ping.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netstat reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netstat).
The common PID-to-port investigation was cross-checked against a highly used
[practitioner Q&A](https://stackoverflow.com/questions/48198/how-do-i-find-out-which-process-is-listening-on-a-tcp-or-udp-port-on-windows),
then constrained by the official option semantics. Exact sources and licenses
are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
