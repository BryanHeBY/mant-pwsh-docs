<!-- mant:tldr:start -->
# quser.exe

> Exact executable alias for `query user`; list interactive/Remote Desktop user sessions without changing them.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/quser.

- Open the complete session-identity, parsing, and remote-access guide:

`mant query.exe --source windows-tools`

- List local user sessions with state, idle time, and logon time:

`quser.exe`

- Query one exact remote host using the caller's existing identity:

`quser.exe /server:"{{server}}"`

- Prefer the semantic dispatcher spelling in new procedures:

`query.exe user`
<!-- mant:tldr:end -->

# quser.exe

## Meaning

`quser.exe` performs the same operation as `query.exe user`. It reports user,
session name, numeric session ID, active/disconnected state, idle time, and
logon time on the local or `/server:` target. Use [query.exe](query.exe.md) for the
complete identity workflow, permission model, output-parsing hazards, native
exit handling, and relationship to session/process queries.

The short name does not mean “current username,” list every type of Windows
logon, or accept alternate credentials. `/server:` changes the target while
the caller's token supplies authorization.

## Command identities and option

<!-- mant:entries role=command case=insensitive -->
- `quser.exe`, `query.exe user`: List visible interactive and Remote Desktop user sessions through the same query operation.

The remote selector uses the caller's existing authorization.

<!-- mant:entries role=option case=insensitive -->
- `/server:SERVER`: Query one exact remote server using the caller's current credentials and permissions.

## PowerShell boundaries

Call `quser.exe` or `query.exe user` explicitly and capture `$LASTEXITCODE`.
The display has blank and localized fields, so whitespace splitting is not a
stable parser and native failure is not controlled by `-ErrorAction`.

## Version and availability

This Windows session query depends on target edition/version, Remote Desktop
services, permissions, session type/state, and remote connectivity.

## Common mistakes

- Splitting on whitespace when a disconnected row can have an empty session
  name and localized date/time columns contain spaces.
- Treating `>` as part of a username instead of the current-session marker.
- Treating disconnected/idle as logged off or safe to terminate.
- Passing a returned session ID to a process-ID command.
- Using `-ErrorAction Stop` as if native failure were a PowerShell exception;
  capture `$LASTEXITCODE` immediately.

## Related documents

- [query.exe](query.exe.md)
- [qwinsta.exe](qwinsta.exe.md)
- [logoff.exe](logoff.exe.md)

## Sources and license

This original alias guide is based on Microsoft's official
[quser](https://learn.microsoft.com/windows-server/administration/windows-commands/quser)
and [query user](https://learn.microsoft.com/windows-server/administration/windows-commands/query-user)
references. Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
