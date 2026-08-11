<!-- mant:tldr:start -->
# nfsstat.exe

> Read cumulative Windows NFS/RPC client, server, and mount statistics without resetting the counters.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/nfsstat.

- Display all available NFS and ONC RPC statistics without resetting them:

`nfsstat.exe`

- Display client-side NFS and RPC statistics:

`nfsstat.exe -c`

- Display server-side NFS and RPC statistics:

`nfsstat.exe -s`

- Display current NFS mount flags and mount information:

`nfsstat.exe -m`
<!-- mant:tldr:end -->

# nfsstat.exe

## Overview

`nfsstat.exe` displays cumulative statistics for Windows NFS and its ONC RPC
calls. `-c`/`-s` select client/server, `-n`/`-r` select NFS/RPC, and `-m`
shows mounts. `-z` displays and resets selected counters and is excluded from
the TLDR because it destroys the baseline.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `nfsstat.exe`: Display or reset Microsoft NFS and ONC RPC call statistics.

Display filters can be combined; `-z` remains a mutation even when combined
with a narrower display selector.

<!-- mant:entries role=option case=insensitive -->
- `-c`: Limit call statistics to the NFS client side.
- `-s`: Limit call statistics to the Server for NFS side.
- `-m`: Display current mount flags and mount information.
- `-n`: Display NFS operation statistics.
- `-r`: Display ONC RPC operation statistics.
- `-z`: Display and then reset the selected cumulative call statistics.

## Common mistakes

### Reading cumulative counts as a current failure rate

Capture timestamps, uptime/service restart, workload interval and two samples;
compare deltas and denominators. A large lifetime total can represent old load,
while a small rejection count may be severe over a short quiet interval.

### Using `-z` before preserving evidence

Resetting counters changes shared diagnostic state for other operators and
monitoring. Export the full baseline first and reset only in an approved test
window with ownership of downstream alerts.

### Mixing NFS calls with Microsoft RPC

The RPC figures here belong to ONC/Sun RPC used by NFS, not the Windows MSRPC
Endpoint Mapper tested by `rpcping`. Protocol names alone are insufficient;
record program/version/transport and service role.

### Treating a rejected call as a network verdict

Authentication/mapping, export/ACL, version negotiation, stale handles, locks,
timeouts and application behavior can all contribute. Correlate client/server
counters, mounts, events, packet evidence and the exact operation.

## PowerShell boundaries

Call `nfsstat.exe` explicitly and check `$LASTEXITCODE`. Combined legacy flags
such as `-cn` are native-tool syntax; separate flags are clearer in generated
commands. Preserve raw localized text with timestamp and host identity.

## Version and platform differences

Windows-only and NFS-feature dependent. Available client/server/mount data and
counter names depend on installed roles, NFS version and build. Microsoft's
page uses Unix-like “root user” wording for `-z`; verify actual Windows
elevation behavior locally without resetting production counters.

## Related documents

- [nfsadmin.exe](nfsadmin.exe.md)
- [nfsshare.exe](nfsshare.exe.md)
- [showmount.exe](showmount.exe.md)
- [rpcinfo.exe](rpcinfo.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[nfsstat reference](https://learn.microsoft.com/windows-server/administration/windows-commands/nfsstat).
Dynamic NFS/RPC service and firewall demand was cross-checked against a
[widely used practitioner discussion](https://serverfault.com/questions/377170/which-ports-do-i-need-to-open-in-the-firewall-to-use-nfs).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
