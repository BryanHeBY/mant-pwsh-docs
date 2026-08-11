<!-- mant:tldr:start -->
# rpcinfo

> Query ONC RPC programs registered with an approved NFS-style portmapper; this is not the Microsoft RPC Endpoint Mapper.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rpcinfo.

- Display local syntax and confirm the optional tool:

`rpcinfo.exe /?`

- List ONC RPC program, version, transport, and port registrations on one exact host:

`rpcinfo.exe /p "{{nfs01.example.com}}"`

- Check the well-known ONC RPC portmapper TCP endpoint separately:

`Test-NetConnection "{{nfs01.example.com}}" -Port 111 -InformationLevel Detailed`

- Check the well-known NFS TCP endpoint separately:

`Test-NetConnection "{{nfs01.example.com}}" -Port 2049 -InformationLevel Detailed`
<!-- mant:tldr:end -->

# rpcinfo

## Overview

Windows `rpcinfo.exe` speaks ONC/Sun RPC and queries an RPC portmapper, commonly
for NFS services. `/p` lists registrations; `/t` and `/u` call an exact program
over TCP/UDP; `/b` broadcasts for a program/version. This is a different
protocol and registry from Microsoft MSRPC/RPCSS tested by `rpcping.exe`.

## Common mistakes

### Using `rpcinfo` to diagnose Windows MSRPC/DCOM

ONC portmapper normally uses port 111 and numeric program/version registrations.
Windows RPC Endpoint Mapper normally uses TCP 135, interface UUIDs and dynamic
endpoints. Choose the tool from the target protocol, not the shared word “RPC.”

### Treating port 111 and 2049 as the complete NFS firewall contract

NFS version and implementation determine whether mountd, lock/status and other
dynamically or statically assigned services participate. Use `/p` plus the
approved server design; do not open arbitrary ranges based on an old example.

### Broadcasting with `/b`

Broadcast discovery expands scope, may not cross routers, and can disclose or
load many hosts. Query one authorized FQDN/IP and exact program/version instead.

### Calling every version by omitting it

For `/t` or `/u`, omission can call all registered versions and muddy evidence.
Inventory with `/p`, then bind the exact program, version and transport expected
by the application.

### Equating registration with application health

A portmapper row or successful null call does not prove export authorization,
identity mapping, filesystem access, locking, or workload semantics.

## PowerShell behavior

Call `rpcinfo.exe` explicitly. `/` switches differ from Unix `-` spellings.
Check `$LASTEXITCODE`, retain raw text and record target resolution/address.
Never let a placeholder omission fall back to the local host unnoticed.

## Version and platform differences

The Windows binary is associated with optional Services for NFS components.
Remote ONC RPC versions/transports vary. Do not substitute syntax from a Unix
implementation without checking Windows local help.

## Related documents

- [rpcping](rpcping.md)
- [showmount](showmount.md)
- [nfsstat](nfsstat.md)
- [nfsshare](nfsshare.md)

## Sources and license

This original guide was adapted from Microsoft's official
[rpcinfo reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rpcinfo).
NFS dynamic-service/firewall demand was cross-checked against a
[high-volume practitioner discussion](https://serverfault.com/questions/377170/which-ports-do-i-need-to-open-in-the-firewall-to-use-nfs).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
