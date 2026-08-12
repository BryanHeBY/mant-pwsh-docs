<!-- mant:tldr:start -->
# qprocess.exe

> Exact executable alias for `query process`; correlate processes with Windows sessions without terminating them.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/qprocess.

- Open the complete session/process identity and remote-access guide:

`mant query.exe --source windows-tools`

- List processes across every accessible session; no selector shows only the current user's processes:

`qprocess.exe *`

- Filter by a previously verified session ID:

`qprocess.exe /id:{{session-id}}`

- Query all accessible session processes on one exact remote host:

`qprocess.exe * /server:"{{server}}"`

- Prefer the semantic dispatcher spelling in new procedures:

`query.exe process *`
<!-- mant:tldr:end -->

# qprocess.exe

## Meaning

`qprocess.exe` performs the same operation as `query.exe process`. It maps
accessible processes to owner and session identity. A bare numeric selector is
a process ID; `/id:<n>` is a session ID; a program-name selector requires the
`.exe` extension. Use [query.exe](query.exe.md) for full syntax, identity reuse,
permission/filtering, PowerShell exit handling, and corroboration guidance.

Without a selector, only the current user's processes are reported. This is
easy to misread as a system-wide list. `*` broadens inventory but does not make
the result complete across protected, short-lived, or inaccessible processes.

## Command identities and options

<!-- mant:entries role=command case=insensitive -->
- `qprocess.exe`, `query.exe process`: Map accessible processes to owner and Windows session identity.

The following switches select a session or remote host.

<!-- mant:entries role=option case=insensitive -->
- `/id:SESSION`: Select processes belonging to one exact session ID; this is not a process ID.
- `/server:SERVER`: Query one remote server with the caller's current authorization.

A bare numeric selector means process ID, a program selector requires its
documented `.exe` suffix, and `*` requests every accessible session process.

## PowerShell boundaries

Call the executable explicitly, preserve colon-bearing options as one native
argument, and capture `$LASTEXITCODE`. Revalidate PID, start time, executable,
owner, and session before any later action.

## Version and availability

This Windows/RDS query surface depends on target release, permissions, session
visibility, process lifetime, and remote management access. Exact System32
discovery on the recorded Windows NT `10.0.26200.0` Home China client found no
`qprocess.exe`; this is an edition/component availability observation, not a
claim about Session Host, Server, or other client installations. Do not
substitute a PATH match when exact discovery fails.

## Common mistakes

- Confusing a bare PID with `/id:` session identity.
- Omitting `*` and concluding another user's process is absent.
- Treating a point-in-time PID/session pairing as durable.
- Using an executable name without the documented `.exe` suffix.
- Feeding human-readable output directly into a termination command.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found qprocess.exe absent; no PATH substitute or process query ran.
Representative installations where the component exists remain required.

## Related documents
- [query.exe](query.exe.md)
- [tasklist.exe](tasklist.exe.md)
- [quser.exe](quser.exe.md)

## Sources and license

This original alias guide is based on Microsoft's official
[qprocess](https://learn.microsoft.com/windows-server/administration/windows-commands/qprocess)
and [query process](https://learn.microsoft.com/windows-server/administration/windows-commands/query-process)
references. Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
