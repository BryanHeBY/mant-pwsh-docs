<!-- mant:tldr:start -->
# services

> Open the Services MMC console for interactive inspection; resolve service name, display name, runtime PID/state, start configuration, triggers, dependencies, account, privileges, security descriptor and owner before any control or configuration action.
> More information: https://learn.microsoft.com/windows/win32/services/about-services.

- Open the Services MMC snap-in:

`services.msc`

- Launch Services explicitly through Microsoft Management Console:

`mmc.exe services.msc`
<!-- mant:tldr:end -->

# services

## Overview

Services is an MMC interface over the Service Control Manager database and runtime.
It displays service state and selected configuration/control actions. Display name,
service name, process, host group, driver service and executable are distinct, and
running state does not prove readiness or workload health.

## Common mistakes

- Selecting by localized display name rather than immutable service name and owner.
- Restarting a service without dependencies, shared-process impact, active work,
  cluster/orchestrator ownership, stop timeout, recovery and health verification.
- Confusing Automatic, Automatic (Delayed Start), trigger-start and runtime state;
  policy/product servicing can restore or override local configuration.
- Changing logon account/password without service logon right, SPN/delegation,
  profile, filesystem/registry/network access and dependent secret coordination.
- Assuming GUI permissions equal service DACL rights, or that elevation grants
  every control/config/security operation on protected services.
- Automating localized UI instead of `sc.exe`, service cmdlets or SCM APIs.

## PowerShell behavior

Use `Start-Process services.msc` for interactive launch. For automation, use
`Get-Service`/`Get-CimInstance` plus `sc.exe` where its extended config/security
families are required; preserve native status and verify runtime workload health.

## Version and platform differences

`services.msc` is Windows-only. Service types, triggers, protected services,
security, accounts, controls and UI vary by build, roles/products and policy.

## Related documents

- [sc.exe](sc.md)
- [net.exe](net.md)
- [tasklist](tasklist.md)
- [wevtutil](wevtutil.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Services and Service Control Manager overview](https://learn.microsoft.com/windows/win32/services/about-services).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
