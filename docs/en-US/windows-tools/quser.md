<!-- mant:tldr:start -->
# quser

> Exact executable alias for `query user`; list interactive/Remote Desktop user sessions without changing them.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/quser.

- Open the complete session-identity, parsing, and remote-access guide:

`mant query --source windows-tools`

- List local user sessions with state, idle time, and logon time:

`quser.exe`

- Query one exact remote host using the caller's existing identity:

`quser.exe /server:"{{server}}"`

- Prefer the semantic dispatcher spelling in new procedures:

`query.exe user`
<!-- mant:tldr:end -->

# quser

## Meaning

`quser.exe` performs the same operation as `query.exe user`. It reports user,
session name, numeric session ID, active/disconnected state, idle time, and
logon time on the local or `/server:` target. Use [query.exe](query.md) for the
complete identity workflow, permission model, output-parsing hazards, native
exit handling, and relationship to session/process queries.

The short name does not mean “current username,” list every type of Windows
logon, or accept alternate credentials. `/server:` changes the target while
the caller's token supplies authorization.

## Common mistakes

- Splitting on whitespace when a disconnected row can have an empty session
  name and localized date/time columns contain spaces.
- Treating `>` as part of a username instead of the current-session marker.
- Treating disconnected/idle as logged off or safe to terminate.
- Passing a returned session ID to a process-ID command.
- Using `-ErrorAction Stop` as if native failure were a PowerShell exception;
  capture `$LASTEXITCODE` immediately.

## Sources and license

This original alias guide is based on Microsoft's official
[quser](https://learn.microsoft.com/windows-server/administration/windows-commands/quser)
and [query user](https://learn.microsoft.com/windows-server/administration/windows-commands/query-user)
references. Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
