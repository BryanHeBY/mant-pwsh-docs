<!-- mant:tldr:start -->
# taskschd.msc

> Open Task Scheduler for interactive inspection of an explicitly identified task and target; use ScheduledTasks cmdlets or `schtasks.exe` for reproducible queries and changes.
> More information: https://learn.microsoft.com/windows/win32/taskschd/task-scheduler-1-0-examples.

- Resolve the console file without launching a GUI:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\taskschd.msc')`

- Open Task Scheduler in the current interactive session:

`Start-Process taskschd.msc`

- Query registered tasks as objects instead of scraping the console:

`Get-ScheduledTask | Select-Object TaskPath, TaskName, State`
<!-- mant:tldr:end -->

# taskschd.msc

## Overview

`taskschd.msc` opens the Task Scheduler MMC console. It can inspect task folders,
definitions, triggers, actions, principals, conditions, settings, history, and
current state, and it can create, change, run, stop, import, export, or delete
tasks when the caller is authorized.

The console is an interactive management surface, not a stable output or
automation contract. Task identity is the full task path plus name, not merely
the visible leaf name.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `taskschd.msc`: Open the Task Scheduler MMC console for an explicitly identified local or remote target.

The console file exposes no supported parameter interface documented here. Use
`schtasks.exe`, ScheduledTasks cmdlets, or the Task Scheduler API when target,
input, output, exit status, and verification must be machine-readable.

## What to preserve

Before changing a task, record or export its XML and capture the complete task
path, author/URI, principal SID, logon type, run level, triggers, actions and
arguments, working directory, conditions, settings, ACL, last/next run time,
last task result, history channel state, and owning deployment mechanism.

An exported definition does not capture credentials and is not by itself a
complete rollback for ACLs, external scripts, files, secrets, or policy.

## Common mistakes

- Editing the first task with a matching display name while ignoring its folder,
  target computer, hidden state, URI, author, principal, or ACL.
- Treating “Run whether user is logged on or not,” highest privileges, a service
  account, or stored credentials as interchangeable security contexts.
- Assuming manual success in an interactive profile proves scheduled success;
  environment, current directory, mapped drives, network identity, bitness,
  desktop access, profile loading, quoting, and timeouts differ.
- Treating `0x0`, “Ready,” or a recent Last Run Time as proof of the intended
  business outcome without action logs and output artifact verification.
- Enabling history only after an incident or deleting/recreating a task before
  preserving XML, ACL, operational events, and external action files.
- Automating localized console labels or screenshots instead of the documented
  command/API surfaces.

## PowerShell behavior

Use `Start-Process taskschd.msc` only to launch the interactive console. Use
`Get-ScheduledTask` and `Get-ScheduledTaskInfo` for typed discovery, or invoke
`schtasks.exe` explicitly when its compatibility and XML contract are required.

PowerShell process completion is not task completion. If a script starts a task,
poll the exact task, collect Task Scheduler operational events and action output,
and verify the intended side effect under the scheduled principal.

## Version and platform differences

`taskschd.msc` is Windows-only. Console availability, remote management,
ScheduledTasks cmdlets, schema features, service accounts, security behavior,
and history depend on Windows edition/build, role, policy, and installed tools.

## Related documents

- [schtasks.exe](schtasks.exe.md)
- [eventvwr.msc](eventvwr.msc.md)
- [wevtutil.exe](wevtutil.exe.md)
- [mmc.exe](mmc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Task Scheduler examples](https://learn.microsoft.com/windows/win32/taskschd/task-scheduler-1-0-examples),
[SchTasks reference](https://learn.microsoft.com/windows/win32/taskschd/schtasks),
and [Task Scheduler access-denied troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/troubleshooting-task-scheduler-access-denied-error).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
