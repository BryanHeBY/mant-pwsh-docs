<!-- mant:tldr:start -->
# qprocess

> Exact executable alias for `query process`; correlate processes with Windows sessions without terminating them.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/qprocess.

- Open the complete session/process identity and remote-access guide:

`mant query --source windows-tools`

- List processes across every accessible session; no selector shows only the current user's processes:

`qprocess.exe *`

- Filter by a previously verified session ID:

`qprocess.exe /id:{{session-id}}`

- Query all accessible session processes on one exact remote host:

`qprocess.exe * /server:"{{server}}"`

- Prefer the semantic dispatcher spelling in new procedures:

`query.exe process *`
<!-- mant:tldr:end -->

# qprocess

## Meaning

`qprocess.exe` performs the same operation as `query.exe process`. It maps
accessible processes to owner and session identity. A bare numeric selector is
a process ID; `/id:<n>` is a session ID; a program-name selector requires the
`.exe` extension. Use [query.exe](query.md) for full syntax, identity reuse,
permission/filtering, PowerShell exit handling, and corroboration guidance.

Without a selector, only the current user's processes are reported. This is
easy to misread as a system-wide list. `*` broadens inventory but does not make
the result complete across protected, short-lived, or inaccessible processes.

## Common mistakes

- Confusing a bare PID with `/id:` session identity.
- Omitting `*` and concluding another user's process is absent.
- Treating a point-in-time PID/session pairing as durable.
- Using an executable name without the documented `.exe` suffix.
- Feeding human-readable output directly into a termination command.

## Sources and license

This original alias guide is based on Microsoft's official
[qprocess](https://learn.microsoft.com/windows-server/administration/windows-commands/qprocess)
and [query process](https://learn.microsoft.com/windows-server/administration/windows-commands/query-process)
references. Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
