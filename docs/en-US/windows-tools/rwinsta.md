<!-- mant:tldr:start -->
# rwinsta

> Exact alias for `reset session`; forcibly delete one verified malfunctioning session only after warning, recovery review, and normal logoff fail.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rwinsta.

- Inventory session identity/state and select no target yet:

`query.exe user /server:"{{server}}"`

- Inspect every process owned by the intended session ID:

`query.exe process /id:{{session-id}} /server:"{{server}}"`

- Warn that exact active session through an approved channel before escalation:

`msg.exe {{session-id}} /server:"{{server}}" /time:{{120}} "{{Your unresponsive session may be reset; unsaved data can be lost.}}"`

- Only after final approval and re-query, reset the exact malfunctioning session verbosely:

`rwinsta.exe {{session-id}} /server:"{{server}}" /v`
<!-- mant:tldr:end -->

# rwinsta

## Overview

`rwinsta.exe` is the exact executable alias for `reset session`. It forcibly
resets (deletes) a session on a Remote Desktop Session Host. Microsoft says to
use reset only when a session malfunctions or appears to have stopped responding.
Resetting ends its processes and can lose data; it is not a harmless disconnect
or a generic stale-session cleanup primitive.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `rwinsta.exe`: Force-reset and delete one malfunctioning RDS session; exact
  alias of `reset session`.

The positional name/ID must be freshly bound to host and owner before use.

<!-- mant:entries role=option case=insensitive -->
- `/server`: Select one exact Session Host; it does not carry credentials.
- `/v`: Display extended action information.
- `/?`: Display installed reset-session syntax.

## Safe escalation

First identify host, owner, session ID/name/state, processes, open work, and
application/resource dependencies. Try owner coordination, application-specific
recovery, reconnect, and normal sign-out/logoff as appropriate. Preserve events
and diagnostic evidence before reset. Re-query immediately, reset one exact ID,
then verify deletion, released resources, profile/application health, and the
user's ability to establish a clean new session.

## Common mistakes

### Using reset where disconnect or logoff was intended

`tsdiscon` preserves a session. `logoff` performs normal user logoff. Reset is
forceful recovery for a malfunctioning session. Choosing reset merely because
it succeeds can discard recovery/cleanup paths and user data.

### Acting on “Disc” or idle time alone

Disconnected sessions can run valid work, and idle measures input only. A
session can also appear hung while an application is blocked on storage,
network, authentication, profile, or a dialog. Diagnose the workload and owner
before escalating.

### Resetting stale numeric identity

Session IDs are reusable and local to one host. Bind ID to owner, name, state,
processes, and timestamp and re-query immediately. A copied ID without `/server:`
can delete a same-numbered local session.

### Assuming forced deletion repairs the cause

Reset can release the symptom while leaving profile corruption, resource
exhaustion, RDS broker/licensing, storage, application, or network faults.
Preserve evidence and confirm root cause and recurrence after recovery.

### Broad permission or automation loops

Resetting another user's session requires Full Control. Never loop over parsed
localized output, every disconnected row, or a fleet without per-session
authorization and concurrency/race protection. `/server:` does not supply
credentials.

## PowerShell boundaries

Use `rwinsta.exe` explicitly with scalar session ID and server arguments.
Capture stdout/stderr and `$LASTEXITCODE`, then re-query and validate application
state. Do not pipe `query user` text directly into reset or use
`Invoke-Expression` to assemble the command.

## Version and platform differences

`rwinsta.exe` is Windows-only. Microsoft documents it as equivalent to `reset
session`; availability, delegation, remote behavior, and recovery consequences
vary by build, edition, RDS role/configuration, session type, and policy.

## Related documents

- [query.exe](query.md)
- [logoff](logoff.md)
- [tsdiscon](tsdiscon.md)
- [msg.exe](msg.md)

## Sources and license

This original guide was adapted from Microsoft's official
[rwinsta](https://learn.microsoft.com/windows-server/administration/windows-commands/rwinsta)
and [reset session](https://learn.microsoft.com/windows-server/administration/windows-commands/reset-session)
references. Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
