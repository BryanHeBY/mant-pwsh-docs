<!-- mant:tldr:start -->
# openfiles

> Query remotely opened shared files and optional local handle tracking.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/openfiles.

- Query open files without changing connections:

`openfiles.exe /query /fo csv /v`

- Inspect whether local handle tracking is enabled:

`openfiles.exe /local`

- Requery one connection ID before considering disconnection:

`openfiles.exe /query /fo list /v`
<!-- mant:tldr:end -->

# openfiles

## Overview

`openfiles.exe /query` inventories remotely opened shared files and, when local
tracking is enabled, local handles. `/disconnect` terminates matching remote
file connections. `/local on|off` changes the Maintain Objects List global flag
after a restart and can affect system performance.

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

## Related documents

- [tasklist](tasklist.md)
- [taskkill](taskkill.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[openfiles reference](https://learn.microsoft.com/windows-server/administration/windows-commands/openfiles).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
