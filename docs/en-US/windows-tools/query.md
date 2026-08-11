<!-- mant:tldr:start -->
# query.exe

> Inventory Windows interactive/Remote Desktop user sessions, all session objects, session-owned processes, and legacy Session Host discovery without changing session state.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/query.

- List user sessions on the local host, including active/disconnected state, idle time, and logon time:

`query.exe user`

- List local session objects, including listeners and rows without a user:

`query.exe session`

- List processes across every session; without `*`, the result is limited to the current user:

`query.exe process *`

- Display cumulative session create, disconnect, and reconnect counters:

`query.exe session /counter`

- Query user sessions on one exact remote Session Host using the caller's existing identity:

`query.exe user /server:"{{server}}"`

- Query all session objects on one exact remote Session Host:

`query.exe session /server:"{{server}}"`

- Filter processes by a previously verified session ID rather than confusing it with a process ID:

`query.exe process /id:{{session-id}}`

- Discover legacy Session Host registrations in one domain; treat the result as incomplete discovery:

`query.exe termserver /domain:"{{domain}}" /address /continue`
<!-- mant:tldr:end -->

# query.exe

## Overview

`query.exe` is the Windows Remote Desktop Services query dispatcher. Its four
subcommands answer different questions: `user` reports user-session activity,
`session` reports session/listener objects, `process` maps processes to users
and sessions, and `termserver` performs legacy Session Host discovery.

All four return localized, fixed-column human text rather than a stable object
schema. The TLDR remains read-only, but the output exposes usernames, activity,
host topology, process names, session identifiers, and logon times; protect it
as operational and identity data.

## Command-family map

| Form | Alias executable | Scope and distinguishing fields |
| --- | --- | --- |
| `query user` | `quser.exe` | User, session name, session ID, state, idle time, and logon time. |
| `query session` | `qwinsta.exe` | Sessions and listeners, including type/device plus mode/flow/connect details and counters. |
| `query process` | `qprocess.exe` | Process owner, session name/ID, executable name, and process ID. |
| `query termserver` | `qappsrv.exe` | Legacy network/domain discovery of Session Host servers and optional addresses. |

The aliases are separate lookup pages in this source, but they do not provide
different safety or output semantics.

## Session identity workflow

1. Record source and target hosts, Windows edition/build, RDS role, caller
   identity/token/elevation, time zone, and collection timestamp.
2. Run both `query user` and `query session`. A user-oriented row and a session/
   listener-oriented row are not interchangeable.
3. Preserve the exact session name, numeric session ID, username, state, and
   the leading current-session marker. Do not infer a missing column by splitting
   on whitespace.
4. If process correlation is required, immediately query the verified session
   ID and distinguish its `SESSION ID` from each returned process `ID`.
5. Re-query immediately before any separately authorized `logoff`, disconnect,
   reset, connect, shadow, message, or process action because session IDs and
   ownership can change.

## `query user`

With no selector, `query user` lists user sessions visible on the target. A
selector can be a username, session name, or numeric session ID; those
namespaces can overlap, so use corroborating `query session` output rather than
guessing from one token. `/server:<name>` changes the target, not the credential.

`STATE` distinguishes active and disconnected sessions. Disconnected does not
mean logged off: the user's processes and unsaved state can remain. Idle time
means time since keyboard or mouse input as reported for the session, not proof
that applications, transfers, compute jobs, or audio/video are idle.

## `query session`

`query session` includes session objects beyond signed-in users, such as RDP
listeners and rows with an empty username. The leading `>` marks the caller's
current session; it is not part of the session name and is not a reliable CSV
delimiter. Microsoft notes that sessions configured initially as disabled do
not appear until enabled, so absence is not a complete policy/configuration
inventory.

`/mode`, `/flow`, and `/connect` expose older line, flow-control, and connection
settings where applicable. `/counter` reports cumulative created, disconnected,
and reconnected counts. Record counter start/reset context and elapsed time;
totals alone are neither rates nor proof of current load or failure.

## `query process`

Without a selector, `query process` shows only processes belonging to the
current user. Use `*` for every accessible session. A bare number selects a
process ID; `/id:<n>` selects a session ID. A program-name filter requires the
`.exe` extension according to Microsoft. This distinction is critical before
passing a number to any terminating command.

The output is a point-in-time association. PIDs and session IDs can be reused;
shared/service processes, protected processes, short-lived children, and
permission filtering can make it incomplete. Correlate with `Get-Process`,
process creation time/path/owner, `tasklist`, service state, and events where
the decision matters.

## `query termserver`

`query termserver` searches legacy network/domain discovery state for Session
Host servers. `/domain:` selects the directory/browse scope, `/address` requests
network and node addresses, and `/continue` suppresses screen-by-screen pauses.
Its result can be affected by role registration, discovery services, permissions,
name resolution, network segmentation, and historical compatibility behavior.
Use an authoritative asset/RDS deployment inventory when completeness matters.

## Common mistakes

### Splitting `query user` output on whitespace

A disconnected row can have no session name, while idle/logon-time fields and
localized headers contain spaces. Naive `-split '\s+'`, CSV replacement, fixed
English column names, or subtracting one header row silently shifts fields or
miscounts error text. Preserve raw output and locale. For automation, prefer a
supported structured RDS/WTS API; if legacy parsing is unavoidable, validate
against fixtures containing blank fields, long names, every state, localized
dates, errors, and the `>` marker.

### Treating `>` as part of the session or username

Microsoft uses a leading greater-than sign to mark the current session. Trimming
or tokenizing it incorrectly can alter the first field, while assuming the
first returned session is current is also unsafe. Record the marker separately
and corroborate target host/session identity.

### Confusing a session ID with a process ID

`query process 12` means PID 12, while `query process /id:12` means session 12.
Other RDS commands also accept session IDs, and process tools accept PIDs. Label
every numeric identifier with host, namespace, owner, state, and timestamp;
re-query before any mutation because identifiers can be reused.

### Treating disconnected as idle or safe to log off

Disconnected sessions can run applications, hold files/locks, own jobs, and
contain unsaved data. Idle time measures input inactivity only. Contact the
owner, inspect processes and application state, honor session policy, and
confirm backup/recovery before an approved logoff or reset.

### Assuming `query user` lists every kind of logon

It reports interactive/RDS session state, not every service, batch, network,
cached, remote-management, or token/logon event. Use security events and the
appropriate service, SMB, process, WTS, or identity API for the actual question.
Do not equate a missing row with “the account is not in use.”

### Supplying a password to a command that has no credential option

`/server:` chooses the target; it does not establish alternate credentials.
Remote access uses the caller's security context and requires RDS session-query
rights. Error 5 can be authorization/token policy, and RPC-unavailable errors
can involve service, firewall, resolution, transport, or target state. Do not
embed a password, weaken a firewall, enable broad remoting, or grant Full
Control merely to make inventory succeed.

### Losing the native failure behind a PowerShell pipeline

`-ErrorAction Stop` does not convert an ordinary native nonzero exit into a
PowerShell terminating error in Windows PowerShell 5.1. A filter or later
command can also overwrite `$?`. Capture stdout, stderr, and `$LASTEXITCODE`
immediately before parsing; reject nonzero status and recognizable error output
instead of treating an empty array as “no sessions.”

### Counting lines as logged-on users

Headers, wrapped lines, errors, blank session-name fields, listeners, and
localization break `Count - 1`. Define whether active, disconnected, console,
RDP, or all user sessions count, then use structured data or a thoroughly
validated parser and keep collection failures separate from a zero result.

### Treating discovery or counters as authoritative health

`termserver` visibility is not a complete deployment inventory, and cumulative
session counters lack time/rate/error context. Correlate broker/collection/
host configuration, event logs, performance counters, licensing, network path,
and application-level tests before diagnosing capacity or availability.

## PowerShell behavior

Use `query.exe` explicitly. The first token after it selects a subcommand; pass
`/server:...`, `/id:...`, and other native arguments as scalar strings. Capture
native streams and `$LASTEXITCODE` immediately. Do not pipe raw output into a
mutation or construct a command with `Invoke-Expression`.

Because the output is localized fixed-column text, PowerShell formatting and
regex convenience do not make it a stable object API. Prefer supported WTS/RDS
APIs or management tooling for unattended inventory, retaining raw legacy
output as diagnostic evidence rather than a sole control input.

## Version and platform differences

`query.exe` is Windows-only. Microsoft currently lists supported Windows client
and server releases, but useful fields, visible sessions/processes, permissions,
remote behavior, discovery, and legacy mode/flow data depend on build, edition,
RDS role/configuration, session type, language, and caller rights. Use installed
help and representative target runtime evidence.

## Related documents

- [quser](quser.md)
- [qwinsta](qwinsta.md)
- [qprocess](qprocess.md)
- [qappsrv](qappsrv.md)
- [tasklist](tasklist.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[query family](https://learn.microsoft.com/windows-server/administration/windows-commands/query),
[query user](https://learn.microsoft.com/windows-server/administration/windows-commands/query-user),
[query session](https://learn.microsoft.com/windows-server/administration/windows-commands/query-session),
[query process](https://learn.microsoft.com/windows-server/administration/windows-commands/query-process),
and [query termserver](https://learn.microsoft.com/windows-server/administration/windows-commands/query-termserver)
references. Failure demand was cross-checked against practitioner questions
about [parsing blank session fields](https://stackoverflow.com/questions/39212183/easier-way-to-parse-query-user-in-powershell-or-quser),
[native error capture](https://stackoverflow.com/questions/69946388/ps-capture-returned-error-codes-from-quser-query),
and [remote access denial](https://serverfault.com/questions/194002/how-to-query-what-users-are-logged-on-to-a-remote-servers-terminal-services).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Exchange contributions are licensed under CC BY-SA 4.0.
