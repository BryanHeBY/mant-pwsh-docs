<!-- mant:tldr:start -->
# taskmgr.exe

> Open Windows Task Manager for an explicitly identified interactive session; treat displayed activity as a live snapshot and review identity, impact, dependencies, and evidence before ending or reconfiguring anything.
> More information: https://learn.microsoft.com/troubleshoot/windows-server/support-tools/support-tools-task-manager.

- Open Task Manager in the current interactive session:

`taskmgr.exe`

- Resolve every executable named taskmgr before launching in automation:

`Get-Command taskmgr.exe -All`
<!-- mant:tldr:end -->

# taskmgr.exe

## Overview

Task Manager is an interactive Windows monitor/startup manager for processes,
performance, applications, services, users, details, and startup items. Its UI is
not a stable structured API, and visible rows/metrics depend on privilege, session,
filters, update speed, Windows build, process lifetime and protected boundaries.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `taskmgr.exe`: Open Task Manager in the current interactive Windows session.

The launcher exposes no stable process/query option interface documented here.
Use typed process, service, counter, event, and startup-management interfaces
when the operation must be automated or independently verified.

## Common mistakes

- Ending a process from name/CPU alone without PID, owner/session, command line,
  parent/children, service/job/container, open work, dump and recovery context.
- Comparing an instantaneous UI metric with a differently sampled/normalized
  counter, or treating a disappeared row as proof of clean termination.
- Disabling a startup item without identifying its owner, scope, trigger, policy,
  update/repair behavior and rollback; startup is not the same as all persistence.
- Assuming “Run new task,” priority/affinity, efficiency mode, dump, service or
  user-session actions are harmless because they are exposed in a monitoring UI.
- Automating clicks/screenshots/localized labels instead of `Get-Process`,
  `tasklist`, `taskkill`, service/task tools, counters, ETW, or documented APIs.

## PowerShell behavior

Use `Start-Process taskmgr.exe` only for interactive launch. For automation,
resolve the exact question and use structured PowerShell or a documented native
tool, preserving PID/start time/identity/session and native results.

## Version and platform differences

`taskmgr.exe` is Windows-only. Pages, columns, metrics, permissions, process dump,
startup/service integration and UI behavior vary by build and session identity.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\Taskmgr.exe`. Its fixed numeric file version was
`10.0.26100.8737`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [tasklist.exe](tasklist.exe.md)
- [taskkill.exe](taskkill.exe.md)
- [perfmon.exe](perfmon.exe.md)
- [sc.exe](sc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Task Manager troubleshooting guide](https://learn.microsoft.com/troubleshoot/windows-server/support-tools/support-tools-task-manager).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
