<!-- mant:tldr:start -->
# ncpa.cpl

> Open Network Connections for interactive adapter inspection; preserve stable adapter identity, binding, IP/DNS/route/profile/VPN state, management path, and remote recovery before changing anything.
> More information: https://learn.microsoft.com/troubleshoot/windows-client/networking/disconnect-incoming-vpn-connection.

- Resolve the module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\ncpa.cpl')`

- Open Network Connections interactively:

`Start-Process ncpa.cpl`

- Query adapter and IP state as objects:

`Get-NetAdapter; Get-NetIPConfiguration`
<!-- mant:tldr:end -->

# ncpa.cpl

## Overview

`ncpa.cpl` opens the classic Network Connections folder for physical, virtual,
VPN, bridge, team, and other network connection objects exposed on the device.
The GUI can enable/disable, rename, diagnose, bridge, and edit properties when
the caller is authorized.

The visible connection name is mutable and not sufficient identity. Preserve
interface index/GUID, alias, description, hardware address, PnP instance,
compartment, virtual owner, and target computer.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `ncpa.cpl`: Open the classic Network Connections folder in the current interactive session.

This module has no supported parameter contract documented here. Use NetAdapter,
NetTCPIP, NetConnectionProfile, DnsClient, VpnClient, CIM, or vendor/virtualization
interfaces for typed inventory and controlled automation.

## Network state boundaries

Record link state/speed, addresses/prefixes, gateways, routes/metrics, DNS servers
and registration, DHCP, profiles/categories, bindings/components, VLAN/team/
bridge/virtual ownership, VPN configuration, firewall profile, proxy layers, and
remote-management path before a change.

Disabling or reconfiguring the active management adapter can immediately sever
the session. Require console or out-of-band recovery for remote changes.

## Common mistakes

- Selecting an adapter by friendly name alone after rename, localization,
  docking, reinstall, virtualization, or duplicate description.
- Disabling an adapter to “reset networking” without preserving address, route,
  DNS, binding, VPN, Hyper-V/container, cluster, and management dependencies.
- Confusing adapter state with Internet reachability, DNS, proxy, firewall,
  routing, authentication, captive portal, or application behavior.
- Editing IPv4 while traffic uses IPv6, or changing one compartment/profile while
  testing another.
- Bridging/sharing connections or removing protocol bindings without recovery and
  owner-specific documentation.
- Automating localized GUI labels instead of stable interface identifiers and
  typed cmdlets.

## PowerShell behavior

`Start-Process ncpa.cpl` opens a GUI and returns no adapter state. In PowerShell,
keep Net* objects and stable IDs through the pipeline; do not pass formatted table
text back into mutating cmdlets. Query routes, DNS, profiles, bindings, and IP
configuration separately because no single default view proves effective state.

## Version and platform differences

`ncpa.cpl` is Windows-only. Connection types, Settings migration, Net* cmdlets,
driver properties, virtual adapters, permissions, remote behavior, and available
actions vary by build, edition, role, hardware, installed software, and policy.

## Related documents

- [ipconfig.exe](ipconfig.exe.md)
- [netsh-interface](netsh-interface.md)
- [wf.msc](wf.msc.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Network Connections entry-point guidance](https://learn.microsoft.com/troubleshoot/windows-client/networking/disconnect-incoming-vpn-connection)
and [network adapter cmdlet reference](https://learn.microsoft.com/powershell/module/netadapter/).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
