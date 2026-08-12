<!-- mant:tldr:start -->
# at.exe

> Inspect legacy AT jobs only; current Windows target help can deprecate AT even
> though the online page remains published, so use Task Scheduler for new work.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/at.

- Discover whether the compatibility executable exists and record its version:

`Get-Command at.exe -All -ErrorAction SilentlyContinue | Format-List Source, Version`

- Request the legacy AT-job inventory and preserve failure/deprecation status:

`at.exe; $atExitCode = $LASTEXITCODE`

- Inventory modern scheduled tasks with explicit, machine-readable CSV output:

`schtasks.exe /query /fo CSV /v`

- Inspect typed Task Scheduler identity, principal, actions, triggers, and state:

`Get-ScheduledTask | Select-Object TaskPath, TaskName, State, Principal, Actions, Triggers`

<!-- mant:tldr:end -->

# at.exe

## Overview

`at.exe` is the legacy Schedule-service interface for listing, creating, and
deleting time-based jobs. Current Windows installations can report in target-
local help that AT is deprecated and direct users to `schtasks.exe`, while the
current Microsoft Learn page still documents the old syntax. Treat that as a
version/runtime distinction: preserve AT only to inventory or migrate an
existing dependency, and use Task Scheduler for new automation.

The legacy model has materially different identity, principal, working-
directory, desktop-interaction, network-drive, command-parsing, duration, and
remote-host behavior. Do not translate a line mechanically into a modern task.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `at.exe`: List, create, or delete legacy Schedule-service jobs.

Use only for inventory/migration; new automation belongs in Task Scheduler.

<!-- mant:entries role=option case=insensitive -->
- `/delete`: Delete one ID or, when no ID is supplied, every AT job.
- `/yes`: Suppress confirmation for broad deletion.
- `/interactive`: Request obsolete interactive-desktop behavior.
- `/every:{{date}}`: Repeat on the supplied weekday/date set.
- `/next:{{date}}`: Run at the next occurrence of the supplied weekday/date.
- `/?`: Display installed syntax and deprecation status.

## Common mistakes

### Creating a new AT job because the online page still lists syntax

Query `at.exe /?` on the exact host and record availability. Design a named Task
Scheduler definition with explicit principal, logon type, action executable and
arguments, start-in directory, trigger/time zone, conditions, concurrency,
timeout, retries, result monitoring, and deletion/retention policy.

### Running `at /delete` without an ID

Microsoft documents that omitting the ID selects all AT jobs; `/yes` suppresses
confirmation. Inventory first, bind one verified ID to its full command and
schedule, export evidence, and migrate before any separately approved removal.

### Assuming the task runs as the interactive user

Legacy jobs are background service work. Mapped drives, profile variables,
desktop/UI, current directory, credentials, network access, and elevation differ
from the authoring shell. Microsoft documents `%SystemRoot%` as the execution
directory and requires absolute/UNC paths; `/interactive` is not a modern secure
automation solution.

### Forgetting the shell and parse layers

AT does not automatically load Cmd for builtins. Redirection, quoting, percent
expansion, and nested `cmd /c` add parse layers. Put reviewed logic in a signed,
versioned script with explicit executable/arguments rather than embedding a
large command string.

### Migrating only the clock time

Review day/date semantics, locale, daylight-saving transitions, missed starts,
system clock changes, the legacy 72-hour default, credentials, output, exit
status, and remote target. Run the migrated task in a nonproduction fixture and
verify Task Scheduler operational events plus the real artifact.

## PowerShell boundaries

Invoke `at.exe` explicitly; bare `at` can resolve differently by profile or
platform. Prefer the ScheduledTasks module for typed local management and
`schtasks.exe` where its documented remote/compatibility surface is required.
Neither authorizes storing a password on a command line.

## Version and platform differences

AT is Windows-only legacy compatibility. Executable presence, deprecation text,
Schedule service behavior, administrative requirements, and legacy-job
visibility vary by Windows build. The Microsoft Learn page and installed help
currently differ in emphasis; installed behavior must be recorded during
migration.

On the recorded Windows NT `10.0.26200.0` host, exact System32 `at.exe` had
fixed file/product version `10.0.26100.1150`, Windows PowerShell 5.1-selected
file/product version string `10.0.26100.8457`, description `Schedule service command line
interface`, a valid `Microsoft Windows` signature, and SHA-256
`16885037343CCDF6F1F2061FC769C27EC3333918A2D95C7D7B7D176818C056A0`.
`/?` returned 25 nonempty localized stdout lines, no stderr, and status 0; it
began by deprecating AT in favor of SchTasks and then displayed the complete
legacy grammar. A no-argument inventory attempt returned only the deprecation
message plus a localized invalid-binding-handle diagnostic, no job rows, no
stderr, and status 1. Therefore an empty-looking invocation on a current host
is not proof that no legacy jobs exist. Preserve output/status and use the Task
Scheduler APIs or SchTasks as the authoritative current inventory. No time,
command, ID, remote computer, delete option, or other mutating operand was
supplied.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 AT had fixed file/product version
10.0.26100.1150 and Windows PowerShell 5.1-selected version string
10.0.26100.8457, a valid Microsoft Windows signature, and SHA-256
16885037343CCDF6F1F2061FC769C27EC3333918A2D95C7D7B7D176818C056A0. /? returned
25 localized stdout lines/status 0 and explicitly deprecated AT; a no-argument
inventory returned only the deprecation and invalid-binding-handle
diagnostics/status 1, not job rows. No time, command, ID, remote host or delete
option was supplied. Task creation, edit, run and deletion remain forbidden
merely for evidence.

## Related documents
- [schtasks.exe](schtasks.exe.md)
- [cmd.exe](cmd.exe.md)
- [date](date.md)
- [time](time.md)

## Sources and license

This original migration guide was adapted from Microsoft's official
[AT reference](https://learn.microsoft.com/windows-server/administration/windows-commands/at).
Current deprecation and one-run deletion demand were cross-checked against a
[practitioner migration question](https://stackoverflow.com/questions/68831051/using-schtasks-exe-how-do-i-create-a-scheduled-task-then-delete-it-afterwards).
Installed help governs target availability; Microsoft sources govern supported
Task Scheduler behavior. Exact sources and licenses are in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
