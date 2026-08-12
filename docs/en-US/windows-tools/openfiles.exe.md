<!-- mant:tldr:start -->
# openfiles.exe

> Query remotely opened shared files and optional local handle tracking.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/openfiles.

- Query open files without changing connections:

`openfiles.exe /query /fo csv /v`

- Inspect whether local handle tracking is enabled:

`openfiles.exe /local`

- Requery one connection ID before considering disconnection:

`openfiles.exe /query /fo list /v`
<!-- mant:tldr:end -->

# openfiles.exe

## Overview

`openfiles.exe /query` inventories remotely opened shared files and, when local
tracking is enabled, local handles. `/disconnect` terminates matching remote
file connections. `/local on|off` changes the Maintain Objects List global flag
after a restart and can affect system performance.

## Commands and options

<!-- mant:entries role=command case=insensitive -->
- `openfiles.exe`: Query tracked open files, disconnect selected remote shared
  file connections, or manage the host's local-handle tracking flag.

Query mode should precede every disconnect decision. Wildcards accepted by
disconnect selectors can terminate many clients and lose unflushed work.

<!-- mant:entries role=option case=insensitive -->
- `/query`: Display remotely opened shared files and any local handles visible
  when Maintain Objects List tracking is enabled.
- `/disconnect`: Terminate remote shared-file connections matching the supplied
  ID, user, open mode, and/or open-path selectors.
- `/local`: Display or set the host-wide Maintain Objects List flag; `on`/`off`
  changes require a restart and can affect performance.
- `/s`: Select the following remote computer; otherwise use the local computer.
- `/u`: Run the remote operation using the following account.
- `/p`: Supply the `/u` password; omit the entire switch for a non-echoed prompt
  rather than exposing a secret in command history/process listings.
- `/id`: Select a remote open-file connection ID for disconnection; `*` is
  broad and should not be used without an exact reviewed query.
- `/a`: Select remote open files by accessing user for disconnection.
- `/o`: Select remote open files by `read`, `write`, or `read/write` mode.
- `/op`: Select remote connections by open filename/path.
- `/fo`: Format query output as `TABLE`, `LIST`, or `CSV`.
- `/nh`: Suppress headers in `TABLE` or `CSV` query output.
- `/v`: Include verbose query details.
- `-?`, `/?`: Display installed top-level command help. Mode-specific help is
  `openfiles.exe /query /?`, `/local /?`, or `/disconnect /?`.

## PowerShell boundaries

`openfiles.exe` returns snapshots as localized/native text. Prefer `/fo csv`
with retained headers for bounded inventory, check `$LASTEXITCODE`, and requery
an exact ID immediately before any disconnect. Local tracking is persistent
host configuration requiring restart—not PowerShell session state—and must not
be enabled merely to satisfy one ad-hoc script.

The recorded ordinary token could display top-level and all three mode help
forms, each with exit 0, but `openfiles.exe /local` returned an administrator-
privilege diagnostic and exit 1. Treat that as an access failure, not proof
that local-handle tracking is off, and do not elevate merely to satisfy a
generic evidence run.

## Common mistakes

### Disconnecting with a wildcard before an exact query

Query verbose output, identify a current exact connection ID, user, path, mode,
and business owner, then requery immediately before action. A disconnect can
cause application errors and loss of unflushed work.

### Enabling local tracking just for a quick query

The flag requires a restart and may slow the system. Treat it as a planned host
configuration change with rollback, measurement, and maintenance approval.

### Assuming the query is a complete lock diagnostic

Permissions, tracking state, local-versus-remote handles, races, and subsystem
behavior limit visibility. Use an appropriate handle/debugging tool when the
question is which process owns a specific local handle.

### Supplying remote credentials inline

Omit `/p` to prompt. Command-line passwords are exposed to logs, process
inspection, history, and transcripts.

## Version and platform differences

This administrative executable is Windows-only. Results depend on elevation,
sharing services, remote access, tracking configuration, and restart state.
On Windows NT `10.0.26200.0`, installed file version `10.0.26100.1` printed
14 nonempty top-level help lines; `/query /?`, `/local /?`, and
`/disconnect /?` printed 25, 14, and 33 respectively, all with exit 0. No
tracking flag, restart, connection, file, user, credential, or remote state
was changed.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 top-level and
query/local/disconnect mode help returned 0 with 14/25/14/33 nonempty lines.
Ordinary-token /local status returned an administrator-privilege diagnostic and
exit 1, which the page separates from a disabled-tracking result. No tracking
flag, restart, connection, file, user, credential, or remote state changed.

## Related documents
- [tasklist.exe](tasklist.exe.md)
- [taskkill.exe](taskkill.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[openfiles reference](https://learn.microsoft.com/windows-server/administration/windows-commands/openfiles).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
