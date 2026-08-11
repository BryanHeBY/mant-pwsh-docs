<!-- mant:tldr:start -->
# wmimgmt.msc

> Open WMI Control for a reviewed namespace-security or repository investigation; scripts should always name their target computer and namespace explicitly.
> More information: https://learn.microsoft.com/windows/win32/wmisdk/setting-namespace-security-with-the-wmi-control.

- Resolve the console file without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\wmimgmt.msc')`

- Open WMI Control in the current interactive session:

`Start-Process wmimgmt.msc`

- Test a named namespace with typed CIM output before changing security:

`Get-CimInstance -Namespace root\cimv2 -ClassName Win32_OperatingSystem | Select-Object CSName, Version`
<!-- mant:tldr:end -->

# wmimgmt.msc

## Overview

`wmimgmt.msc` opens the WMI Control MMC snap-in. It displays WMI status and
properties and can change namespace security, backup/restore settings, and the
default namespace used by legacy scripts that omit one.

Namespace ACL changes can grant remote access to sensitive management data and
methods or break monitoring, inventory, setup, and administration. Repository
repair is a separate escalation and should not be used as a generic response to
one provider, query, authentication, firewall, or namespace error.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `wmimgmt.msc`: Open WMI Control for an explicitly identified computer, namespace, provider, and security task.

The console file exposes no supported parameter interface documented here. Use
CIM cmdlets or documented WMI APIs for repeatable queries and configuration.

## What to preserve

Record the computer, namespace path, class/provider, query or method, caller SID
and token, local/remote transport, authentication and impersonation context,
namespace security descriptor, inheritance, WMI/service/provider events, error
code, architecture, repository status, management authority, and rollback.

Always specify a namespace in automation. Microsoft notes that the default
namespace is easy to change, so a script that relies on it can silently query a
different namespace later.

## Common mistakes

- Granting broad `Remote Enable`, `Execute Methods`, or provider-write rights at
  `root` when a narrower namespace and group are sufficient.
- Confusing DCOM computer access/launch rights with WMI namespace rights;
  firewall, RPC/DCOM, identity, UAC filtering, and namespace ACLs are separate.
- Resetting or rebuilding the WMI repository before proving corruption and
  preserving product/provider registration and recovery guidance.
- Changing the default scripting namespace to fix one script instead of making
  that script identify its namespace explicitly.
- Assuming a successful `root\cimv2` query proves every namespace/provider or a
  remote query will work under another identity.
- Using deprecated `wmic.exe` text as the only automation path when CIM cmdlets
  can return typed objects and expose target/namespace explicitly.

## PowerShell behavior

`Start-Process wmimgmt.msc` returns no WMI objects. Prefer `Get-CimInstance`,
`Invoke-CimMethod`, and explicit `-Namespace`, `-ComputerName`/`CimSession`, and
authentication choices. Preserve `CimException` details and the exact target;
never silently retry against localhost after a remote failure.

## Version and platform differences

`wmimgmt.msc` is Windows-only. WMI providers, namespaces, ACL defaults, remote
transport, repository behavior, and console availability vary by Windows build,
edition, role, architecture, installed software, and policy.

## Related documents

- [wmic.exe](wmic.exe.md)
- [comexp.msc](comexp.msc.md)
- [compmgmt.msc](compmgmt.msc.md)
- [winrm.exe](winrm.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[WMI Control namespace-security guidance](https://learn.microsoft.com/windows/win32/wmisdk/setting-namespace-security-with-the-wmi-control)
and [remote WMI security guidance](https://learn.microsoft.com/windows/win32/wmisdk/securing-a-remote-wmi-connection).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
