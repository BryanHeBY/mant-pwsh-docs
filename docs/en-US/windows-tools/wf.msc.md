<!-- mant:tldr:start -->
# wf.msc

> Open Windows Defender Firewall with Advanced Security for interactive inspection; query effective profiles, rules, filters, stores, and policy authority with typed tools before changing firewall state.
> More information: https://learn.microsoft.com/windows/security/operating-system-security/network-security/windows-firewall/tools.

- Resolve the console file without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\wf.msc')`

- Open the advanced firewall console:

`Start-Process wf.msc`

- Inspect effective firewall profiles as objects:

`Get-NetFirewallProfile -PolicyStore ActiveStore`
<!-- mant:tldr:end -->

# wf.msc

## Overview

`wf.msc` opens Windows Defender Firewall with Advanced Security. The MMC snap-in
shows inbound/outbound rules, connection-security rules, monitoring information,
profiles, logging, IPsec, and local or policy-managed settings when available.

It is an interactive view, not a stable automation interface. A rule's display
name is not unique identity: direction, action, enabled state, profiles, program,
service, protocol, ports, addresses, interface, edge traversal, security,
policy store, owner, and target all affect behavior.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `wf.msc`: Open the advanced Windows Firewall MMC console for an explicitly identified local or remote policy target.

The console file has no supported option contract documented here. Use the
NetSecurity module, `netsh advfirewall` where compatibility requires it, policy
management, CSP, or firewall APIs for reproducible automation.

## Policy and effective state

Local persistent rules can be combined with or overridden by domain Group
Policy, MDM/CSP, security products, service hardening, and other policy stores.
Record both the source store and `ActiveStore` result before concluding that a
visible local rule is effective.

Test the exact traffic direction, profile, executable/service identity, protocol,
local/remote endpoint, interface, IPsec state, and network path. Opening the
console or enabling a rule does not prove packets can reach the application.

## Common mistakes

- Disabling an entire firewall/profile to diagnose one flow instead of gathering
  logs and creating a narrow, time-bounded, reversible rule.
- Matching only a localized display name and changing the wrong duplicate rule
  or policy store.
- Confusing inbound with outbound traffic, local with remote ports/addresses, or
  executable path with service-restricted rules.
- Editing Local Policy while a domain or MDM authority supplies effective state,
  then assuming a temporary UI appearance will persist.
- Forgetting the current network profile or testing on one profile while the
  target uses another.
- Removing/blocking management access without an out-of-band recovery path.
- Scraping localized MMC rows instead of querying typed rules and associated
  port, address, application, service, interface, and security filters.

## PowerShell behavior

`Start-Process wf.msc` only launches a GUI. For automation use `Get-NetFirewall*`
cmdlets with explicit policy stores and join rule objects to their filter objects;
do not assume the default formatted rule view contains the complete match.

For changes, first export or inventory the narrow policy, use exact names/IDs and
stores, preserve remote recovery, and verify effective state plus real traffic.

## Version and platform differences

`wf.msc` and the NetSecurity module are Windows-only. Rule properties, policy
stores, IPsec, remote management, firewall tooling, defaults, and UI vary by
Windows client/server version, edition, role, management authority, and product.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\WF.msc`. It exposed no nonzero four-part fixed
file version through `FileVersionInfo`; the audit retains that as absent rather
than inventing `0.0.0.0`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [netsh.exe](netsh.exe.md)
- [gpedit.msc](gpedit.msc.md)
- [secpol.msc](secpol.msc.md)
- [mmc.exe](mmc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows Firewall tools](https://learn.microsoft.com/windows/security/operating-system-security/network-security/windows-firewall/tools),
[configuration best practices](https://learn.microsoft.com/windows/security/operating-system-security/network-security/windows-firewall/best-practices-configuring),
and [Server Core remote MMC guidance](https://learn.microsoft.com/windows-server/administration/server-core/server-core-manage).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
