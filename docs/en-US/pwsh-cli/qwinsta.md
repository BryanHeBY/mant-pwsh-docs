<!-- mant:tldr:start -->
# qwinsta

> Exact executable alias for `query session`; inventory Windows session and listener objects before any session action.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/qwinsta.

- Open the complete session-identity, parsing, and permission guide:

`mant query --source pwsh-cli`

- List local session and listener objects:

`qwinsta.exe`

- Query one exact remote host using the caller's existing identity:

`qwinsta.exe /server:"{{server}}"`

- Display cumulative session create, disconnect, and reconnect counters:

`qwinsta.exe /counter`

- Prefer the semantic dispatcher spelling in new procedures:

`query.exe session`
<!-- mant:tldr:end -->

# qwinsta

## Meaning

`qwinsta.exe` performs the same operation as `query.exe session`. It reports
session and listener objects, not only signed-in users; optional forms expose
mode, flow, connection, and cumulative counter information. Use
[query.exe](query.md) for the complete identity workflow, blank-field and
current-session handling, remote permission errors, counter interpretation, and
session-versus-process ID boundary.

The leading `>` marks the caller's current session. Listener or idle rows can
have no username, and Microsoft notes initially disabled sessions can remain
absent until enabled. Therefore the text is not a complete or stable CSV schema.

## Common mistakes

- Expanding the name as a supported modern concept: it is a historical
  executable name whose documented semantic equivalent is `query session`.
- Counting every row as a logged-on user even when listeners/empty rows exist.
- Treating a missing/disabled row as proof that no session configuration exists.
- Reusing a session ID after state/ownership changed.
- Using the inventory as authorization to disconnect, reset, shadow, or log off.

## Sources and license

This original alias guide is based on Microsoft's official
[qwinsta](https://learn.microsoft.com/windows-server/administration/windows-commands/qwinsta)
and [query session](https://learn.microsoft.com/windows-server/administration/windows-commands/query-session)
references. Exact locked provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
