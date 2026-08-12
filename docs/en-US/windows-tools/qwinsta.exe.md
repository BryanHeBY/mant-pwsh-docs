<!-- mant:tldr:start -->
# qwinsta.exe

> Exact executable alias for `query session`; inventory Windows session and listener objects before any session action.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/qwinsta.

- Open the complete session-identity, parsing, and permission guide:

`mant query.exe --source windows-tools`

- List local session and listener objects:

`qwinsta.exe`

- Query one exact remote host using the caller's existing identity:

`qwinsta.exe /server:"{{server}}"`

- Display cumulative session create, disconnect, and reconnect counters:

`qwinsta.exe /counter`

- Prefer the semantic dispatcher spelling in new procedures:

`query.exe session`
<!-- mant:tldr:end -->

# qwinsta.exe

## Meaning

`qwinsta.exe` performs the same operation as `query.exe session`. It reports
session and listener objects, not only signed-in users; optional forms expose
mode, flow, connection, and cumulative counter information. Use
[query.exe](query.exe.md) for the complete identity workflow, blank-field and
current-session handling, remote permission errors, counter interpretation, and
session-versus-process ID boundary.

The leading `>` marks the caller's current session. Listener or idle rows can
have no username, and Microsoft notes initially disabled sessions can remain
absent until enabled. Therefore the text is not a complete or stable CSV schema.

## Command identities and options

<!-- mant:entries role=command case=insensitive -->
- `qwinsta.exe`, `query.exe session`: Enumerate visible session and listener objects through the same query operation.

The following switches select the host and additional display fields.

<!-- mant:entries role=option case=insensitive -->
- `/server:SERVER`: Query one exact remote server with the caller's current authorization.
- `/mode`: Include current line settings for visible sessions.
- `/flow`: Include current flow-control settings.
- `/connect`: Include current connection settings.
- `/counter`: Display cumulative session creation, disconnection, and reconnection counters.

## PowerShell boundaries

Call the executable explicitly, preserve colon-bearing options, and capture
`$LASTEXITCODE`. Treat the leading `>` as a current-session marker and retain
blank columns rather than parsing by naïve whitespace positions.

## Version and availability

This Windows/RDS query depends on target release, roles/listeners, permissions,
session state, remote access, and counter lifetime. Exact System32 discovery on
the recorded Windows NT `10.0.26200.0` Home China client found no
`qwinsta.exe`; this is an edition/component availability observation, not a
claim about Session Host, Server, or other client installations. Do not
substitute a PATH match when exact discovery fails.

## Common mistakes

- Expanding the name as a supported modern concept: it is a historical
  executable name whose documented semantic equivalent is `query session`.
- Counting every row as a logged-on user even when listeners/empty rows exist.
- Treating a missing/disabled row as proof that no session configuration exists.
- Reusing a session ID after state/ownership changed.
- Using the inventory as authorization to disconnect, reset, shadow, or log off.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found qwinsta.exe absent; no PATH substitute or session query ran.
Representative installations where the component exists remain required.

## Related documents
- [query.exe](query.exe.md)
- [quser.exe](quser.exe.md)
- [rwinsta.exe](rwinsta.exe.md)

## Sources and license

This original alias guide is based on Microsoft's official
[qwinsta](https://learn.microsoft.com/windows-server/administration/windows-commands/qwinsta)
and [query session](https://learn.microsoft.com/windows-server/administration/windows-commands/query-session)
references. Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
