<!-- mant:tldr:start -->
# msconfig.exe

> Open System Configuration to isolate a startup problem; record the current state first, change one bounded variable at a time, restart deliberately, and restore Normal startup after the test.
> More information: https://learn.microsoft.com/troubleshoot/windows-client/performance/windows-boot-issues-troubleshooting.

- Open System Configuration interactively:

`msconfig.exe`

- Inventory registered startup commands without changing them:

`Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User`

- Inspect the current BCD entry before touching the Boot tab:

`bcdedit.exe /enum '{current}' /v`
<!-- mant:tldr:end -->

# msconfig.exe

## Overview

`msconfig.exe` opens System Configuration, an interactive troubleshooting tool
for isolating startup services, startup items and boot options. It is not a
general service manager, autorun inventory, boot editor or permanent hardening
tool. A clean-boot test is useful only when its baseline, excluded components,
restart and result are recorded.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `msconfig.exe`: Open the interactive System Configuration troubleshooting UI
  for controlled startup/service/boot isolation and later baseline restoration.

## Common mistakes

- Disabling many services/startup items at once and learning nothing about
  which single component caused the symptom. Use a binary or one-at-a-time
  isolation plan and keep a reversible change log.
- Clearing Microsoft, security, storage, networking, authentication or
  remote-access services without console/recovery access. “Hide all Microsoft
  services” is a convenience filter, not proof that every remaining service is
  safe to disable.
- Leaving the machine in Selective or Diagnostic startup after troubleshooting,
  or mistaking that temporary state for an application uninstall or durable
  policy.
- Treating the Startup tab as a complete persistence inventory. Modern Windows
  redirects startup-app management to Task Manager, while services, scheduled
  tasks, drivers, shell extensions, policies and other mechanisms remain
  separate.
- Changing Boot options without exporting and reviewing BCD state, BitLocker
  and Secure Boot implications, restart behavior and a console recovery path.
- Assuming a checkbox or successful restart proves root cause. Reproduce the
  original workload and compare logs, timing and health after each change.

## PowerShell boundaries

Use `Start-Process msconfig.exe` for an interactive launch. PowerShell cannot
reliably automate localized System Configuration controls. Use dedicated,
structured inventory such as `Get-CimInstance Win32_StartupCommand`, service
and task cmdlets, `gpresult`, and explicit `bcdedit.exe` queries; preserve native
exit status and quote BCD identifiers such as `'{current}'`.

## Version and platform differences

`msconfig.exe` is Windows-only. Tabs, Startup redirection, boot options,
required elevation and the components present vary by Windows release, edition,
role, policy and installed software. Older documentation may discuss
`BOOT.INI`; supported current systems use BCD.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\msconfig.exe`. Its fixed numeric file version was
`10.0.26100.8737`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [taskmgr.exe](taskmgr.exe.md)
- [services.msc](services.msc.md)
- [bcdedit.exe](bcdedit.exe.md)
- [gpresult.exe](gpresult.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows startup troubleshooting guidance](https://learn.microsoft.com/troubleshoot/windows-client/performance/windows-boot-issues-troubleshooting)
and [BCDEdit safety guidance](https://learn.microsoft.com/windows-hardware/drivers/devtest/bcdedit--set).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
