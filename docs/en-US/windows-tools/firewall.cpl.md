<!-- mant:tldr:start -->
# firewall.cpl

> Open the basic Windows Defender Firewall applet for interactive status and simple allowances; use `wf.msc` or NetSecurity for complete rule/filter/store identity and effective-policy verification.
> More information: https://learn.microsoft.com/windows/security/operating-system-security/network-security/windows-firewall/tools.

- Resolve the module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\firewall.cpl')`

- Open the basic firewall Control Panel applet:

`Start-Process firewall.cpl`

- Query effective firewall profiles as objects:

`Get-NetFirewallProfile -PolicyStore ActiveStore`
<!-- mant:tldr:end -->

# firewall.cpl

## Overview

`firewall.cpl` opens the basic Windows Defender Firewall Control Panel applet.
It provides simpler status, notification, allow-app, default/reset, and on/off
workflows than Windows Defender Firewall with Advanced Security (`wf.msc`).

The simplified UI is not a complete rule, filter, IPsec, policy-store, or
effective-policy view. Security products and domain/MDM policy can manage or
replace parts of the experience.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `firewall.cpl`: Open the basic Windows Defender Firewall Control Panel applet.
- `control.exe /name Microsoft.WindowsFirewall`: Open the canonical Windows Firewall item where supported.

Use `wf.msc`, NetSecurity, policy/CSP, `netsh advfirewall` compatibility, or the
firewall APIs for detailed/reproducible administration.

## Simplified versus effective state

Record profile, local/remote policy store, rule and associated filters, direction,
action, enabled state, application/service, protocol, local/remote ports and
addresses, interface, edge traversal, IPsec, logging, owner, and target.

An allowed-app checkbox or profile status does not prove one flow succeeds.
Verify the real process/service identity and network path on the active profile.

## Common mistakes

- Disabling the firewall/profile to diagnose one connection rather than gathering
  logs and making a narrow, time-bounded, reversible exception.
- Assuming the basic applet shows every effective rule, filter, store, or policy.
- Matching an application display name while its executable path, service,
  package, direction, profile, address, or port differs.
- Editing local state that domain/MDM/security-product policy overrides.
- Resetting defaults without exporting/inventorying deliberate enterprise,
  management, service, and application rules.
- Blocking remote administration without console/out-of-band recovery.

## PowerShell behavior

`Start-Process firewall.cpl` opens a GUI. Use NetSecurity cmdlets with explicit
policy stores for typed automation and join rule objects to their filter objects;
the default rule formatting omits important match conditions.

## Version and platform differences

`firewall.cpl` is Windows-only. Naming, UI, policy ownership, security-product
integration, profiles, rule properties, and applet availability vary by build,
edition, server role, management authority, and installed products.

## Related documents

- [wf.msc](wf.msc.md)
- [netsh.exe](netsh.exe.md)
- [secpol.msc](secpol.msc.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows Firewall tools](https://learn.microsoft.com/windows/security/operating-system-security/network-security/windows-firewall/tools)
and [Control Panel canonical names](https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
