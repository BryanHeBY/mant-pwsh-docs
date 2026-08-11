<!-- mant:tldr:start -->
# ipxroute

> Inventory a legacy NWLink IPX configuration before migrating the workload to a supported TCP/IP design.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ipxroute.

- Confirm that the executable and any IPX-era bindings exist:

`Get-Command ipxroute.exe -ErrorAction SilentlyContinue; Get-NetAdapterBinding -AllBindings | Where-Object DisplayName -Match 'IPX|NWLink'`

- Display IPX bindings, network/node addresses, and frame types:

`ipxroute.exe config`

- Display the Service Advertising Protocol table for all server types:

`ipxroute.exe servers`

- Resolve a captured adapter name to its legacy GUID form without changing routing:

`ipxroute.exe resolve guid "{{Legacy Adapter}}"`
<!-- mant:tldr:end -->

# ipxroute

## Overview

`ipxroute.exe` displays and modifies routing information for the obsolete NWLink
IPX protocol stack. `config` shows configured bindings; `servers [/type=x]`
shows Service Advertising Protocol entries; `resolve guid|name` translates an
adapter identifier; `ripout <network>` and `board=<n>` address routing/source-
routing behavior.

Use it to gather evidence for an isolated legacy system, then migrate the
application or encapsulated environment. Microsoft's Win32 RPC documentation
calls the IPX protocol family obsolete and says not to use it in new software.

## Common mistakes

### Using mutation options during discovery

`board=<n> def/gbr/mbr` changes broadcast routing behavior, and
`remove=<12-hex-node>` removes a source-routing entry. Start with `config`,
`servers`, and `resolve`; require an exact adapter/node, packet evidence,
rollback, and isolated maintenance window for any change.

### Confusing IPX network, node, and TCP/IP addresses

An IPX network is eight hexadecimal digits and a node is typically a 12-digit
MAC-derived value. SAP server types and frame types are not TCP ports or DNS
records. Preserve the complete binding and application context when migrating.

### Believing a command page means the stack is installed

Current Windows usually lacks NWLink/IPX. Verify binary, protocol binding,
driver, application, frame type, and network segment. Do not download a random
legacy stack or enable an obsolete protocol on a trusted production network.

## PowerShell behavior

Output is localized legacy text. Capture raw output and `$LASTEXITCODE`; use
typed adapter cmdlets only to inventory modern bindings, not to claim they can
interpret IPX state. Explicitly invoke `ipxroute.exe` to avoid name collisions.

## Version and platform differences

IPX/NWLink is obsolete and may exist only in historical Windows images or
specialized compatibility environments. The Microsoft Learn applicability
banner is not binary/driver support evidence. Prefer TCP/IP, SMB, or a vendor-
supported application migration on current systems.

## Related documents

- [route](route.md)
- [netsh](netsh.md)
- [getmac](getmac.md)

## Sources and license

Adapted as an original migration guide from Microsoft's
[ipxroute reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ipxroute)
and [obsolete IPX RPC transport note](https://learn.microsoft.com/windows/win32/midl/ncadg-ipx).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
