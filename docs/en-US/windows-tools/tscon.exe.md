<!-- mant:tldr:start -->
# tscon.exe

> Connect one verified local Session Host session to another, disconnecting the destination; protect credentials and console/physical-access exposure.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tscon.

- Inventory source/target session IDs, names, owners, and state on the current Session Host:

`query.exe session`

- Re-query the intended source session ID and destination session name immediately before switching:

`query.exe session {{source-session-id}}`

- Connect to an owned session and let the current session disconnect:

`tscon.exe {{source-session-id}} /v`

- For a different owner's approved session, prompt instead of placing its password in history:

`tscon.exe {{source-session-id}} /dest:"{{destination-session-name}}" /password:* /v`
<!-- mant:tldr:end -->

# tscon.exe

## Overview

`tscon.exe` connects to another session on the current Remote Desktop Session
Host. The target is a session ID or name. `/dest:` names the current/destination
session that will be disconnected, `/password:*` prompts for the target owner's
password, and `/v` is verbose. Unlike related query/lifecycle commands, its
documented syntax has no `/server:` option: establish the authorized management
context on the intended host first.

Session switching changes which desktop is attached to a transport or console,
can disconnect a user, and can expose an interactive desktop to physical or
virtual-console access. Treat it as an identity and workstation-security change,
not merely an RDP connectivity trick.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `tscon.exe`: Connect one local Session Host session to another session/transport.

The positional source session is connected; `/dest` identifies the session that
will be disconnected. There is no documented remote-server switch.

<!-- mant:entries role=option case=insensitive -->
- `/dest`: Select the current/destination session that will be disconnected.
- `/password`: Supply or prompt for the source session owner's password; use `*`.
- `/v`: Display extended action information.
- `/?`: Display installed syntax.

## Common mistakes

### Reversing source and `/dest:`

The positional session is the one to connect to; `/dest:` is the session that
will be disconnected/replaced. Record a before/after diagram with host, owners,
IDs, names, console/transport, and physical access. Re-query immediately because
IDs are reusable and names can change.

### Putting `/password:<pw>` on the command line

A literal password leaks through history, transcripts, process/endpoint
telemetry, logs, and screen sharing. Use `/password:*` only for an approved
interactive legacy workflow. Prefer same-owner switching or a supported
administrative design that does not require another user's reusable password.

### Copying `/dest:console` as a GUI-automation fix

Transferring an interactive desktop to the console changes display resolution,
device/redirection and render context, and may expose the session to local/
hypervisor-console viewers. It does not make UI automation reliable, unattended,
or secure. Use a supported test/agent environment and noninteractive automation;
security-review any unavoidable console attachment.

### Assuming connect is remote administration

There is no documented `/server:` operand. Running `tscon` after landing on the
wrong host changes sessions there. Record target-host identity through trusted
means and keep RDP/WinRM/console authentication separate from session switching.

### Granting broad rights after failure

Connecting to another session requires Full Control or Connect special access;
a different owner also requires the password. Do not disable UAC, consent,
firewalls, or session security, and do not grant blanket RDS control to service
accounts just to make a workaround succeed.

## PowerShell boundaries

Use `tscon.exe` explicitly with scalar session values and `/password:*`, never a
literal secret. Capture native streams and `$LASTEXITCODE`, then re-query both
session identities and validate console lock/visibility plus application state.
The calling interactive channel may disconnect before it can report later steps.

## Version and platform differences

`tscon.exe` is Windows-only. Session/console restrictions, delegation, password
requirements, display behavior, and physical/virtual console exposure depend on
build, edition, RDS role/topology, policy, session ownership, and host platform.

## Related documents

- [query.exe](query.exe.md)
- [tsdiscon.exe](tsdiscon.exe.md)
- [logoff.exe](logoff.exe.md)
- [shadow.exe](shadow.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tscon reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tscon).
The fragility of using console transfer for unattended GUI work was cross-checked
against a practitioner report of [display changes after `tscon /dest:console`](https://stackoverflow.com/questions/78028752/unexpected-screen-resolution-change-in-windows-server-during-automated-ui-testin).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
