<!-- mant:tldr:start -->
# logoff.exe

> End every process and delete one verified non-console Windows session; warn the owner and protect unsaved data first.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/logoff.

- Inventory session IDs, owners, states, idle time, and logon time on the target:

`query.exe user /server:"{{server}}"`

- Re-query the intended session ID and its processes immediately before action:

`query.exe process /id:{{session-id}} /server:"{{server}}"`

- Send a bounded warning to that exact active session before an approved logoff:

`msg.exe {{session-id}} /server:"{{server}}" /time:{{120}} "{{Save work and sign out before the approved maintenance window.}}"`

- After owner/change approval and a final identity check, log off the exact session verbosely:

`logoff.exe {{session-id}} /server:"{{server}}" /v`
<!-- mant:tldr:end -->

# logoff.exe

## Overview

`logoff.exe` logs a user off a Remote Desktop session, ends all processes in
that session, and deletes the session. A session name or numeric ID targets a
session; `/server:` selects the host and `/v` reports actions. With no operand,
it logs off the current session. Microsoft states that the console session
cannot be logged off with this command.

This is not cleanup-only: unsaved documents, in-flight transfers, interactive
installers, shells, jobs, application transactions, and per-user services can
be terminated. Treat it as an approved user-impacting change.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `logoff.exe`: End all processes and delete one normal Windows/RDS user session.

The positional session name or ID is optional in native syntax but mandatory in
safe automation; omission targets the caller's current session.

<!-- mant:entries role=option case=insensitive -->
- `/server`: Select the exact Session Host; it does not provide credentials.
- `/v`: Display actions performed by the command.
- `/?`: Display installed syntax.

## Safe workflow

1. Bind host/session ID to owner, name, state, idle/logon time, processes, open
   work, application role, and collection timestamp.
2. Contact the owner through an approved channel; `msg` is supplemental and
   not proof of delivery or consent. Establish save/backup and maintenance time.
3. Prefer the user's normal application exit and sign-out. Use administrative
   logoff only when policy/change authorization permits it.
4. Re-query immediately, execute one explicit ID/server action, capture native
   status/events, and verify session deletion plus application/resource health.

## Common mistakes

### Omitting the session operand

No ID/name logs off the caller's current session. In a remote shell, task, or
reusable snippet this can terminate the operator or the wrong interactive
context. Always include a freshly verified host-local ID.

### Treating disconnected or idle as safe

Disconnected sessions retain processes and state; idle time measures keyboard/
mouse inactivity, not background work. Inventory processes and application
state and coordinate with the owner before deletion.

### Confusing logoff, disconnect, and reset

`tsdiscon` keeps the session for reconnection. `logoff` performs normal session
logoff and deletion. `rwinsta`/`reset session` forcibly deletes a malfunctioning
session and is not a shortcut for ordinary user lifecycle. Document the desired
outcome and escalation reason.

### Reusing a stale session ID

IDs are host-local and reusable. A delayed script can log off another owner.
Bind ID to host, owner, session name/state, processes, and timestamp, then
re-query immediately. Never select by an unescaped substring of localized text.

### Assuming `msg` made the action safe

Messages do not queue and can be missed or time out. Native send success is not
acknowledgment. Use the approved communication/change record and confirm work
is saved; do not place sensitive details in the pop-up.

### Granting Full Control for routine automation

A user can log off their own session; another user's session requires Full
Control permission. Use narrowly delegated, audited administration and an RDS
policy/workflow. `/server:` supplies no credential and access denial is not a
reason to expose a password or broaden permissions blindly.

## PowerShell boundaries

Call `logoff.exe` explicitly, pass scalar target arguments, and never rely on
the no-operand default in automation. Capture stdout/stderr and `$LASTEXITCODE`
immediately, then re-query session/process state and application health. Do not
feed parsed `query user` text directly into logoff without strict validation.

## Version and platform differences

`logoff.exe` is Windows-only. Behavior, visibility, delegation, and remote
reachability vary by build, edition, RDS role/configuration, session type,
policy, and caller token. Use installed help and a disposable representative
session before production use.

## Related documents

- [query.exe](query.exe.md)
- [msg.exe](msg.exe.md)
- [tsdiscon.exe](tsdiscon.exe.md)
- [rwinsta.exe](rwinsta.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[logoff reference](https://learn.microsoft.com/windows-server/administration/windows-commands/logoff).
The recurring remote-disconnected-session workflow was cross-checked against a
[widely viewed practitioner question](https://superuser.com/questions/650816/log-off-a-disconnected-user-remotely).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
