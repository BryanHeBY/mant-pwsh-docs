<!-- mant:tldr:start -->
# sysdm.cpl

> Open System Properties only for an explicitly identified interactive setting; its tabs span unrelated identity, domain, protection, remote, performance, profile, environment, startup, and recovery authorities.
> More information: https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names.

- Resolve the Control Panel module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\sysdm.cpl')`

- Open classic System Properties:

`Start-Process sysdm.cpl`

- Query computer and operating-system identity as objects:

`Get-CimInstance Win32_ComputerSystem, Win32_OperatingSystem`
<!-- mant:tldr:end -->

# sysdm.cpl

## Overview

`sysdm.cpl` opens classic System Properties. Depending on Windows version and
policy, its pages link to or configure computer description/name/domain or
workgroup, system protection, remote settings, performance, user profiles,
environment variables, startup and recovery, hardware, and related settings.

These pages do not form one automation contract. Each setting has its own
authority, privilege, restart/sign-in requirements, dependencies, and supported
management surface.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `sysdm.cpl`: Open classic System Properties in the current interactive session.

This page does not document remembered numeric tab selectors as a stable API.
Use canonical Control Panel/Settings links or the specific documented cmdlet,
native tool, CIM/API, policy, and deployment interface for the intended setting.

## Identify the setting owner

Before a change, identify the exact page/setting, current/effective value,
computer and user, local versus domain/MDM authority, privilege, dependent
services/apps, new-token/restart requirements, remote access, recovery path,
and independently queryable success condition.

Computer rename/domain join, restore protection, profile deletion, environment,
performance, dump, boot, and remote-access changes have materially different
risk and rollback. Never treat them as equivalent “System Properties” writes.

## Common mistakes

- Using a remembered tab number across Windows versions/locales and assuming the
  intended page opened.
- Renaming or joining/leaving a domain without credentials, DNS/time/connectivity,
  restart, trust, local-admin, BitLocker, profile, and rollback planning.
- Deleting a user profile because an account looks unused without preserving
  data, keys, ownership, services/tasks, and sign-in evidence.
- Changing machine environment variables and expecting existing processes or
  services to inherit the new value immediately.
- Enabling Remote Desktop without firewall, NLA, group/policy, identity, network,
  licensing, and recovery validation.
- Treating a GUI value as effective when policy or a specialized subsystem owns
  runtime behavior.

## PowerShell behavior

`Start-Process sysdm.cpl` only launches the GUI. Use typed CIM/cmdlets and exact
native tools for the selected subsystem. Preserve values before formatting,
distinguish process/user/machine environment scopes, and verify after required
token, service, sign-in, or restart transitions.

## Version and platform differences

`sysdm.cpl` is Windows-only. Pages and redirections to Settings vary by build,
edition, domain/server role, hardware, management policy, privilege, and
installed components.

## Related documents

- [systempropertiesadvanced.exe](systempropertiesadvanced.exe.md)
- [ms-settings](ms-settings.md)
- [setx.exe](setx.exe.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Control Panel canonical names](https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names)
and [Control Panel execution guidance](https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
