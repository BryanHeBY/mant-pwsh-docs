<!-- mant:tldr:start -->
# schtasks.exe

> Inventory exact scheduled-task identity, definition, runtime context, history, and last result before running, changing, ending, overwriting, or deleting a task.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks.

- List tasks with verbose fields in CSV form for review or careful locale-aware parsing:

`schtasks.exe /query /fo CSV /v`

- Query one exact task by its full Task Scheduler Library path:

`schtasks.exe /query /tn "{{\folder\task-name}}" /fo LIST /v`

- Export the complete XML definition for one exact task without changing it:

`schtasks.exe /query /tn "{{\folder\task-name}}" /xml`

- Corroborate definition and runtime information with structured PowerShell objects:

`Get-ScheduledTask -TaskPath '{{\folder\}}' -TaskName '{{task-name}}' | Get-ScheduledTaskInfo`

- Read recent operational events; enable no log merely for this query:

`Get-WinEvent -LogName 'Microsoft-Windows-TaskScheduler/Operational' -MaxEvents {{50}}`

- Query one task on a remote computer using the current security context:

`schtasks.exe /query /s "{{server}}" /tn "{{\folder\task-name}}" /fo LIST /v`
<!-- mant:tldr:end -->

# schtasks.exe

## Overview

`schtasks.exe` queries, creates, changes, runs, ends, and deletes Task Scheduler
tasks locally or remotely. A task definition includes identity/path, triggers,
actions, principal/logon type/run level, conditions, settings, security
descriptor, and registration metadata. Runtime information includes state,
last/next run, result, and current instances.

The TLDR is query-only. A successful `/create`, `/change`, or `/run` response
does not prove that the action exists, the saved account can log on, the task
received network credentials, the child completed, or its output is correct.
Preserve the XML definition, operational events, action logs, and independent
postcondition.

## Resolvable operations

<!-- mant:entries role=option case=insensitive -->
- `/query`: List task registrations or return selected properties, formats, and XML.
- `/create`: Register a task from command switches or a reviewed XML definition.
- `/change`: Change supported action, principal, password, or interactive-only settings on an existing task.
- `/run`: Queue an immediate instance using the stored action and principal; it does not wait for completion.
- `/end`: Request termination of an instance started by the task.
- `/delete`: Delete task registration without undoing prior effects or necessarily stopping a running instance.
- `/tn TASK`: Select an exact task path and name.
- `/s COMPUTER`: Target a remote computer for the management operation.
- `/u DOMAIN\USER`, `/p PASSWORD`: Authenticate a remote management operation; these do not set the runtime principal.
- `/ru USER`, `/rp PASSWORD`: Select the task runtime principal and password; avoid command-line secret exposure.
- `/xml FILE`: Create from a complete XML file; in a supported query form, bare `/xml` returns the selected definition.
- `/fo FORMAT`: Select table, list, or CSV query output.
- `/v`: Request verbose query properties.
- `/hresult`: Display the last result in HRESULT form where supported.
- `/f`: Suppress confirmation for supported create/delete changes; it does not validate identity or rollback.

## Operation map

| Operation | Purpose | Boundary |
| --- | --- | --- |
| `/query` | List tasks, verbose properties, CSV/list/table, or XML | Visibility depends on task ACL and elevation; text/CSV headers are localized. |
| `/create` | Register a task from switches or XML | Schedule grammar is complex; SchTasks does not validate program location or saved account password. |
| `/change` | Change action, run-as identity/password, or add interactive-only | It cannot express every Task Scheduler setting or remove interactive-only. |
| `/run` | Queue an immediate run using saved action/principal | Ignores schedule only; does not wait for completion or change next scheduled run. |
| `/end` | Stop a program instance started by a task | Availability/data-loss risk; verify descendants and task instance state. |
| `/delete` | Delete task registration | Does not undo effects or necessarily stop an already running action. |

For definitions needing working directory, multiple actions/triggers, repetition,
maintenance, event subscriptions, network settings, complex principals, or
security descriptors, prefer reviewed Task Scheduler XML or the ScheduledTasks
PowerShell module over compressing policy into one `/create` line.

## Common mistakes

### Treating “task created successfully” as validation

Microsoft explicitly says SchTasks does not verify the program location or
account password. Query XML after creation, inspect the exact executable and
arguments, run in a disposable representative context, wait for completion,
read operational and application logs, interpret LastTaskResult, and verify the
intended output. Keep the previous definition for rollback.

### Confusing `/U` and `/P` with `/RU` and `/RP`

`/U` and `/P` authenticate the SchTasks management operation against a remote
`/S` computer. `/RU` and `/RP` define the task's runtime principal and saved
password. They are different tokens at different times. Never put either
password in source, history, transcript, process telemetry, or logs; prefer
managed service accounts, service identities, or a supported secret workflow.

### Assuming an interactive test matches a scheduled run

Scheduled tasks can have a different account, elevation, integrity level,
logon type, profile, environment, current directory, desktop/session, network
token, mapped drives, certificate stores, architecture, and power/network
conditions. High-quality support cases repeatedly show an action working
manually and failing under the task principal. Log `whoami /all`, absolute
paths, environment, working directory, and actual resource access in a safe lab.

### Depending on relative paths or mapped drives

The default working directory is not the script's directory, and SchTasks
switch syntax does not expose every action's “Start in” field. Mapped drive
letters are per logon session and often absent. Use absolute local/UNC paths,
set an explicit working directory through XML or ScheduledTaskAction, and grant
the runtime principal—not the interactive author—the required access.

### Building `/TR` through multiple unreviewed quote layers

PowerShell first builds arguments for SchTasks; Task Scheduler stores a command
and arguments; the target executable then parses them, and `cmd.exe` or
`powershell.exe` can add another layer. Practitioner questions show
valid-looking tasks with mangled quotes. Prefer an absolute executable plus a script
file and simple arguments, inspect exported XML, and avoid download-and-execute
or encoded one-liners.

### Formatting dates according to the author's locale

Microsoft documents that `/SD` and `/ED` date formats follow the target
computer's Regional and Language Options. Remote computers can differ from the
authoring host. Prefer XML/structured APIs with unambiguous timestamps and
record target time zone, DST behavior, repetition, start boundary, and next run.

### Misunderstanding `/IT`, `/NP`, SYSTEM, and run level

`/IT` requires the run-as user to be logged on and does not make a GUI reliable
automation. `/NP` stores no password and limits access to local resources.
SYSTEM is noninteractive and has a machine network identity, broad local rights,
and no ordinary user profile. `/RL HIGHEST` selects the highest available run
level for that principal; it does not grant missing permissions.

### Using `/F` as idempotency

Force-overwriting a same-named task can silently discard triggers, conditions,
ACLs, principals, actions, maintenance settings, and vendor ownership. Compare
canonical XML, validate owner/source, and perform a controlled update with
backup and rollback. A task path/name collision is not proof of equivalence.

### Believing `/run` proves the schedule and trigger

`/run` ignores the schedule but uses the saved action and principal. It is
useful for action testing, not for validating event filters, calendar/idle/
startup/logon triggers, missed-run behavior, DST, conditions, or repetition.
Exercise the actual trigger in a disposable environment and inspect history.

### Treating `/run` success as child-process success

The command queues the task. Query task state and history until a bounded
terminal state, then interpret the action's exit/result semantics and verify
output. LastTaskResult may be an HRESULT, Win32 value, application exit code,
or scheduler state; zero alone does not validate business outcome.

### Ending or deleting the wrong instance

`/end` can interrupt writes, backups, installers, and child processes; `/delete`
removes registration but not prior side effects and may not be the right way to
stop an active instance. Match full task path, instance/action process identity,
owner, start time, and purpose. Ask the workload to stop cleanly when possible.

### Assuming all administrators see the same task set

Tasks and folders have security descriptors; elevation and ACLs affect query
visibility. Absence from one non-elevated `schtasks /query` is not proof of
absence. Do not “fix” visibility by editing files/registry entries directly;
use Task Scheduler APIs and an approved ACL/ownership design.

### Forgetting that remote paths and context are remote

With `/S`, the task definition and action paths refer to the remote computer.
Remote management requires authentication, firewall/RPC policy, Task Scheduler
rights, and resource access for the separate runtime principal. Query after
registration from the target's perspective and never broaden trust/firewalls
or embed `/P` merely to make a one-liner pass.

### Allowing a privileged task to execute user-writable content

A SYSTEM/highest task pointing to a writable executable, script, directory,
configuration, DLL search path, or update location is a privilege-escalation
path. Verify canonical path, owner/DACL, signatures/hashes, parent directories,
arguments, working directory, network source, and change/update controls.

## PowerShell behavior

Use `schtasks.exe` explicitly and build an argument array rather than a single
interpolated command string. Avoid `--%` in reusable cross-version automation
because it prevents normal variable handling and can hide parsing assumptions.
For complex tasks, use `New-ScheduledTask*`/`Register-ScheduledTask` or reviewed
XML. Capture native output and `$LASTEXITCODE`, but use task info, XML, events,
action logs, and postconditions for the result.

## Version and platform differences

SchTasks is Windows-only. Task Scheduler 1.0 versus 2.0 compatibility, `/V1`,
schedule/date grammar, principal/logon options, event triggers, maintenance,
remote authentication, and XML schema vary by target Windows release. Query
installed subcommand help and export target-generated XML; do not use an old
client's syntax as the server contract.

## Related documents

- [sc.exe](sc.exe.md)
- [tasklist.exe](tasklist.exe.md)
- [taskkill.exe](taskkill.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[SchTasks family](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks),
[query](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks-query),
[create](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks-create),
[change](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks-change),
[run](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks-run),
[end](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks-end),
and [delete](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks-delete)
references. Recurring manual-versus-scheduled context and `/TR` parsing failures
were cross-checked against
[a Server Fault incident](https://serverfault.com/questions/440366/scheduled-task-fails-but-runs-fine-when-triggered-manually)
and [a detailed quoting question](https://stackoverflow.com/questions/55214284/how-to-escape-schtasks-tr-arguments),
then resolved using the official task/principal contract. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault and Stack Overflow contributions are licensed under CC BY-SA
4.0.
