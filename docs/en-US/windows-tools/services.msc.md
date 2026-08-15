<!-- mant:tldr:start -->
# services.msc

> Open the Services MMC console for interactive inspection; resolve service name, display name, runtime PID/state, start configuration, triggers, dependencies, account, privileges, security descriptor and owner before any control or configuration action.
> More information: https://learn.microsoft.com/windows/win32/services/about-services.

- Open the Services MMC snap-in:

`services.msc`

- Launch Services explicitly through Microsoft Management Console:

`mmc.exe services.msc`
<!-- mant:tldr:end -->

# services.msc

## Overview

Services is an MMC interface over the Service Control Manager database and runtime.
It displays service state and selected configuration/control actions. Display name,
service name, process, host group, driver service and executable are distinct, and
running state does not prove readiness or workload health.

## Entry points

<!-- mant:entries role=command case=insensitive -->
- `services.msc`: Open the Services MMC snap-in for interactive inspection and selected controls.
- `mmc.exe`: Host `services.msc` explicitly; the GUI does not expose a stable automation result.

Resolve the service key name and owner before action. Use service cmdlets,
`sc.exe`, CIM, or SCM APIs for state that must be queried and verified.

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

## OpenSSH Server inspection

The localized display name for Microsoft OpenSSH Server can vary, but its
service key name is `sshd`. Use the GUI to inspect it interactively and use
structured commands when results must drive automation:

```powershell
Get-Service sshd | Select-Object Name, DisplayName, Status, StartType
Get-CimInstance Win32_Service -Filter "Name='sshd'" |
    Select-Object Name, State, StartMode, ProcessId, PathName
```

Running state does not prove that the intended address and port are listening
or admitted by Windows Defender Firewall. Continue with [sshd.exe](sshd.exe.md)
and [OpenSSH Server on Windows](openssh-server.md).

## Version and platform differences

`services.msc` is Windows-only. Service types, triggers, protected services,
security, accounts, controls and UI vary by build, roles/products and policy.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\services.msc`. It exposed no nonzero four-part
fixed file version through `FileVersionInfo`; the audit retains that as absent
rather than inventing `0.0.0.0`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [sc.exe](sc.exe.md)
- [net.exe](net.exe.md)
- [tasklist.exe](tasklist.exe.md)
- [wevtutil.exe](wevtutil.exe.md)
- [sshd.exe](sshd.exe.md)
- [OpenSSH Server on Windows](openssh-server.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Services and Service Control Manager overview](https://learn.microsoft.com/windows/win32/services/about-services).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
