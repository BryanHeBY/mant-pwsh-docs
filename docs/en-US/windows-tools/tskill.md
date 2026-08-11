<!-- mant:tldr:start -->
# tskill

> End one verified process in one Windows session only after graceful application shutdown fails; avoid names, wildcards, and `/a` by default.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tskill.

- Inventory processes with both session IDs and PIDs on the target:

`query.exe process * /server:"{{server}}"`

- Re-query the intended session and exact PID immediately before termination:

`query.exe process /id:{{session-id}} /server:"{{server}}"`

- Corroborate PID, owner, executable path, and creation time through structured process data:

`Get-CimInstance Win32_Process -ComputerName '{{server}}' -Filter 'ProcessId = {{process-id}}'`

- Only after graceful shutdown and owner approval fail, end that exact PID verbosely:

`tskill.exe {{process-id}} /server:"{{server}}" /v`
<!-- mant:tldr:end -->

# tskill

## Overview

`tskill.exe` ends a process in a Windows session. It accepts a PID or process
name, `/server:` target, `/id:` session filter, `/a` all-session scope, and `/v`.
Names can contain wildcards. A user can end owned processes; administrators can
end processes in other users' sessions. Microsoft warns that when every process
in a session ends, the session also ends.

Prefer application-specific graceful close/recovery and modern structured
process tools. Use `tskill` only when its session-aware legacy behavior is
required and one exact process identity is verified.

## Common mistakes

### Using a process name or wildcard instead of one PID

A name can match many instances, users, and sessions; wildcard expansion can
include critical processes. `/a` applies the named process across all sessions.
The TLDR deliberately uses an exact PID and never `/a`. Re-query PID, owner,
path, creation time, session, service/job role, and application state.

### Confusing PID with `/id:` session ID

The positional number is a PID; `/id:<n>` selects a session for a name-based
operation. Label every number with host and namespace. Session IDs and PIDs are
both reusable, so stale output is unsafe.

### Killing instead of diagnosing

Forced termination can lose unsaved data, corrupt transactions, trigger service/
cluster recovery, or restart immediately under a supervisor. Preserve dump,
events, handles, threads, child processes, job/service ownership, and app health
as appropriate before escalation.

### Assuming `/server:` carries credentials

It selects a target and uses the caller's rights. Do not put credentials in a
command, weaken remote management/firewall policy, or grant administrator just
to kill a process. Use an approved management channel and least privilege.

### Feeding query text directly into termination

Localized fixed-column output, blank fields, errors, and races can select the
wrong number. Capture `$LASTEXITCODE`, validate structured identity and an
allowlisted host/session/process, then require a fresh check immediately before
one action. Never fleet-loop a wildcard from text output.

## PowerShell behavior

Use `tskill.exe` explicitly with an exact PID. Capture stdout/stderr and
`$LASTEXITCODE`, then verify the original process creation identity is gone and
check application/session health. `Stop-Process` or supported service/application
APIs usually provide clearer local structured targeting, but remain destructive.

## Version and platform differences

`tskill.exe` is Windows-only. Availability, protected/process visibility,
session scope, remote access, and permissions vary by build, edition, RDS role,
security features, and caller token. Some practitioner environments report the
legacy executable absent; installed help is authoritative for the target.

## Related documents

- [query.exe](query.md)
- [qprocess](qprocess.md)
- [tasklist](tasklist.md)
- [taskkill](taskkill.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tskill reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tskill).
Wildcard demand and accidental breadth were cross-checked against a practitioner
[force-stop discussion](https://superuser.com/questions/1189975/how-can-i-force-stop-a-program-without-using-the-mouse-in-windows-10).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
