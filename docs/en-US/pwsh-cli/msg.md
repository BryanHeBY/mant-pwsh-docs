<!-- mant:tldr:start -->
# msg.exe

> Send a bounded notice to one verified active Windows session; avoid accidental server-wide broadcasts and do not treat delivery as durable acknowledgment.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/msg.

- Inventory session IDs, owners, and states on the exact target first:

`query.exe user /server:"{{server}}"`

- Re-query the intended numeric session ID immediately before messaging:

`query.exe user {{session-id}} /server:"{{server}}"`

- Send one short notice to that exact active session with a display timeout:

`msg.exe {{session-id}} /server:"{{server}}" /time:{{60}} "{{Maintenance starts at 18:00; save work and contact the service desk.}}"`

- Ask the target session for an interactive response only when blocking is intended:

`msg.exe {{session-id}} /server:"{{server}}" /time:{{120}} /w "{{Reply when your work is saved.}}"`
<!-- mant:tldr:end -->

# msg.exe

## Overview

`msg.exe` sends a message to an active user/session on a Windows Remote Desktop
Session Host. A target can be a username, session name, numeric session ID, an
`@file` list, or `*` for every user. `/server:` selects the host, `/time:` bounds
the displayed/wait interval, `/w` waits for a response, and `/v` is verbose.

Use an exact, freshly verified session ID for operational notices. Usernames can
own multiple sessions, session names/IDs change, and `*` broadcasts much more
widely than a troubleshooting operator may intend.

## Safe workflow

1. Record source/target host, caller identity, change/ticket, audience, message,
   time zone, delivery window, and approved alternate communication channel.
2. Use `query user` and `query session` to bind the target session ID to owner,
   state, session name, host, and timestamp.
3. Send a concise non-secret notice to one active session with `/time:`. Use
   `/w` only if the caller is expected and allowed to block.
4. Record native output and `$LASTEXITCODE`, but confirm critical communication
   through an approved durable channel; a pop-up is not an audit trail.

## Common mistakes

### Using `*` or a username before enumerating sessions

`*` means all users on the target system. A username can match multiple sessions
or a different active session than expected. Use a verified session ID; review
an `@file` recipient list as sensitive change input before use.

### Treating display as delivery, reading, or consent

Microsoft notes messages do not queue on the client screen. A session can
disconnect, time out, hide the dialog, or be unattended. Native success is not
proof that a human read, understood, accepted, or saved work. Use a supported
notification/approval system for consequential action.

### Omitting `/time:` or adding `/w` in unattended automation

An unbounded or waiting message can block a script, task, or operator workflow.
Choose a reviewed timeout and independently time-bound the automation. Keep
delivery, user response, and the later session action as separate results.

### Sending secrets or untrusted text

Messages are visible on screen and can be captured in logs, history, transcripts,
and screenshots. Do not include passwords, tokens, personal data, or confidential
incident detail. Pass text as a scalar argument; do not build and execute a
PowerShell expression from message content.

### Assuming `/server:` supplies credentials

It changes the target only. The caller needs Message special access permission;
remote failure can also involve session state, service, transport, firewall, or
name resolution. Do not embed credentials or broaden rights/firewalls just to
make a pop-up work.

## PowerShell behavior

Call `msg.exe` explicitly, quote the complete message as one scalar argument,
and capture stdout/stderr plus `$LASTEXITCODE` immediately. Avoid `*`, `@file`,
and `/w` in general automation. Newlines, shell metacharacters, native argument
parsing, and locale can change presentation; test the exact approved text on a
disposable session.

## Version and platform differences

`msg.exe` is Windows-only. Availability, permissions, user experience, timeout/
response behavior, and remote reachability vary by build, edition, RDS role,
session state, policy, and client. Installed help and representative runtime
testing are required.

## Related documents

- [query.exe](query.md)
- [logoff](logoff.md)
- [tsdiscon](tsdiscon.md)
- [rwinsta](rwinsta.md)

## Sources and license

This original guide was adapted from Microsoft's official
[msg reference](https://learn.microsoft.com/windows-server/administration/windows-commands/msg)
and [Terminal Server MSG notes](https://learn.microsoft.com/troubleshoot/windows-server/remote/terminal-server-commands-msg).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
