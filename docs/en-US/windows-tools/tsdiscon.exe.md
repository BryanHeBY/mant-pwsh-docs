<!-- mant:tldr:start -->
# tsdiscon.exe

> Disconnect one verified Remote Desktop session while leaving its applications running; never omit the session operand in generic automation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tsdiscon.

- Inventory session IDs, owners, and states on the target:

`query.exe user /server:"{{server}}"`

- Re-query the intended session ID immediately before changing its state:

`query.exe session {{session-id}} /server:"{{server}}"`

- After owner/operational approval, disconnect that exact non-console session verbosely:

`tsdiscon.exe {{session-id}} /server:"{{server}}" /v`

- Verify that the same owner/session is now disconnected and its processes remain as expected:

`query.exe user {{session-id}} /server:"{{server}}"`
<!-- mant:tldr:end -->

# tsdiscon.exe

## Overview

`tsdiscon.exe` disconnects a session from a Remote Desktop Session Host. It
does not log the user off: applications and session state continue for later
reconnection. A session ID or name targets one session; `/server:` selects the
host; `/v` reports actions. With no session operand it disconnects the current
session, so omission is unsafe in reusable automation. The console session
cannot be disconnected by this command.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `tsdiscon.exe`: Disconnect one RDS session while leaving its processes running.

The positional name/ID is optional in native syntax but mandatory for safe
automation because omission disconnects the caller's current session.

<!-- mant:entries role=option case=insensitive -->
- `/server`: Select one exact Session Host; it does not supply credentials.
- `/v`: Display extended action information.
- `/?`: Display installed syntax.

## Common mistakes

### Confusing disconnect with logoff or reset

Disconnect retains applications, locks, memory, licenses, and unsaved work.
`logoff` ends processes and deletes a normal session; `rwinsta` forcibly resets
a malfunctioning session. Choose from the required lifecycle outcome, not from
which command happens to succeed.

### Omitting the session operand

No ID/name means the caller's current session. That can strand a remote
operator, interrupt an interactive workflow, or leave automation without a
desktop. Always supply a freshly verified ID and target host in scripts.

### Acting on a stale or ambiguous ID

Session IDs are host-local and reusable. Bind ID to host, owner, session name,
state, and timestamp; re-query immediately before and after. Never copy an ID
from another server or confuse it with a PID.

### Assuming disconnected applications are healthy

GUI rendering, device redirection, network resources, credential/token state,
session policy, and app behavior can differ while disconnected. Use an
application-level check and supported unattended design instead of relying on
an abandoned interactive desktop.

### Broadening rights after access denied

Disconnecting another user's session requires Full Control or Disconnect
special access permission. `/server:` does not provide credentials. Validate
caller token, delegated RDS rights, policy, target state, and network path; do
not grant broad administrative access for convenience.

## PowerShell boundaries

Use `tsdiscon.exe` explicitly with scalar ID/server arguments. Capture native
streams and `$LASTEXITCODE`, then re-query. A successful process exit does not
prove application health or that the same user can reconnect through the
broker/gateway/load-balanced path.

## Version and platform differences

`tsdiscon.exe` is Windows-only. Support and behavior depend on Windows build,
edition, RDS role, console versus remote session type, policy, permissions, and
deployment topology. Verify installed help and a disposable session.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found tsdiscon.exe absent; no PATH substitute or disconnect ran. Help
and lifecycle verification remains pending on an approved disposable session.

## Related documents
- [query.exe](query.exe.md)
- [logoff.exe](logoff.exe.md)
- [rwinsta.exe](rwinsta.exe.md)
- [msg.exe](msg.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tsdiscon reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tsdiscon).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
