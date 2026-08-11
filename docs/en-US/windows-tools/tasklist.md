<!-- mant:tldr:start -->
# tasklist

> List Windows processes locally or remotely with server-side filters.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tasklist.

- Inspect one exact process ID before acting on it:

`tasklist.exe /fi "PID eq {{1234}}" /fo list`

- List processes for one executable image in CSV form:

`tasklist.exe /fi "IMAGENAME eq {{app.exe}}" /fo csv`

- Inspect service-to-process relationships:

`tasklist.exe /svc /fi "SERVICES eq {{service-name}}"`

- Use PowerShell process objects when automation needs typed properties:

`Get-Process -Id {{1234}} | Select-Object Id, ProcessName, Path, StartTime`
<!-- mant:tldr:end -->

# tasklist

## Overview

`tasklist.exe` inventories running processes. `/fi` filters by PID, image,
session, user, service, memory, CPU time, module, and selected state fields;
multiple filters are combined. `/svc` maps hosted services, `/v` adds display
fields, and `/fo table|list|csv` selects presentation.

## Important options

<!-- mant:entries role=option case=insensitive -->
- `/fi FILTER`: Include or exclude processes with one filter; repeat to combine filters.
- `/fo FORMAT`: Select `table`, `list`, or `csv` presentation.
- `/nh`: Suppress headers for table or CSV output; retaining CSV headers is safer for named-field parsing.
- `/m MODULE`: List processes that loaded a matching DLL module, or list modules when no name is supplied.
- `/svc`: Show service information hosted by each process; use table format for the documented complete view.
- `/v`: Add verbose process fields; combine with `/svc` for the documented untruncated service view.
- `/s COMPUTER`: Query a remote computer by name or IP address.
- `/u DOMAIN\USER`: Authenticate the remote query as another user; valid only with `/s`.
- `/p PASSWORD`: Supply the remote password; omit the value to prompt rather than exposing a secret.
- `/?`: Show installed command help.

## PowerShell boundaries

Call `tasklist.exe` explicitly and pass an entire `/fi` expression as one
argument. CSV is still localized text; use `Get-Process` or CIM when typed
properties and stable property names are required.

## Common mistakes

### Parsing the default fixed-width table

Columns can truncate and visible text can be localized. Request CSV or use
`Get-Process`/CIM for typed automation; retain headers when importing CSV and
do not assume localized header names are stable across hosts.

### Assuming an image name identifies one process

Many processes can share an image name, including binaries from different
paths. Narrow by PID and verify path, owner/session, start time, and purpose
before using the result for termination.

### Passing a password on the command line

For remote queries, omit `/p` so the tool prompts. Command-line secrets can be
captured in history, logs, process inspection, and agent transcripts.

### Treating a snapshot as a stable handle

Processes exit and PIDs are reused. Revalidate immediately before action and
handle disappearance or identity change as a normal race.

## Version and platform differences

This executable is Windows-only. Permissions limit visible path, owner,
module, service, and remote details; some filters are unsupported remotely.

## Related documents

- [taskkill](taskkill.md)
- [whoami](whoami.md)
- [systeminfo](systeminfo.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tasklist reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tasklist).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
