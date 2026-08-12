<!-- mant:tldr:start -->
# tasklist.exe

> List Windows processes locally or remotely with server-side filters.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tasklist.

- Inspect one exact process ID before acting on it:

`tasklist.exe /fi "PID eq {{1234}}" /fo list`

- List processes for one executable image in CSV form:

`tasklist.exe /fi "IMAGENAME eq {{app.exe}}" /fo csv`

- Inspect service-to-process relationships:

`tasklist.exe /svc /fi "SERVICES eq {{service-name}}"`

- On builds whose installed help exposes `/APPS`, list packaged apps and their associated processes:

`tasklist.exe /apps /fo csv`

- Use PowerShell process objects when automation needs typed properties:

`Get-Process -Id {{1234}} | Select-Object Id, ProcessName, Path, StartTime`
<!-- mant:tldr:end -->

# tasklist.exe

## Overview

`tasklist.exe` inventories running processes. `/fi` filters by PID, image,
session, user, service, memory, CPU time, module, and selected state fields;
multiple filters are combined. `/svc` maps hosted services, `/v` adds display
fields, and `/fo table|list|csv` selects presentation.
The recorded Windows build also exposes `/apps`, which adds packaged-app
identity; Microsoft's current online Tasklist syntax does not list that switch,
so discover it from installed help instead of assuming cross-build support.

## Important options

<!-- mant:entries role=command case=insensitive -->
- `tasklist.exe`: Inventory local or explicitly selected remote Windows
  processes with reviewed filters and output format.

The following slash forms select filters, detail, remote access, and format.

<!-- mant:entries role=option case=insensitive -->
- `/fi FILTER`: Include or exclude processes with one filter; repeat to combine filters.
- `/fo FORMAT`: Select `table`, `list`, or `csv` presentation.
- `/nh`: Suppress headers for table or CSV output; retaining CSV headers is safer for named-field parsing.
- `/m MODULE`: List processes that loaded a matching DLL module, or list modules when no name is supplied.
- `/svc`: Show service information hosted by each process; use table format for the documented complete view.
- `/apps`: On supported builds, show Store/packaged apps with their associated processes and package names; treat the output as potentially identity-sensitive.
- `/v`: Add verbose process fields; combine with `/svc` for the documented untruncated service view.
- `/s COMPUTER`: Query a remote computer by name or IP address.
- `/u`: Authenticate the remote query as another user or `DOMAIN\USER`; valid only with `/s`.
- `/p PASSWORD`: Supply the remote password; omit the value to prompt rather than exposing a secret.
- `-?`, `/?`: Show installed command help.

## PowerShell boundaries

Call `tasklist.exe` explicitly and pass an entire `/fi` expression as one
argument. CSV is still localized text; use `Get-Process` or CIM when typed
properties and stable property names are required. Check `$LASTEXITCODE`
immediately; an empty filter result, an access-limited view, and a failed remote
query must not be collapsed into the same empty collection.

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

### Reusing local-only filters for a remote query

Microsoft and installed help state that `STATUS` and `WINDOWTITLE` filters are
not supported when `/s` selects a remote computer. Reject those combinations
before execution rather than treating a failure or ignored condition as proof
that no remote process matched.

### Treating a snapshot as a stable handle

Processes exit and PIDs are reused. Revalidate immediately before action and
handle disappearance or identity change as a normal race.

## Version and platform differences

This executable is Windows-only. Permissions limit visible path, owner,
module, service, app-package, and remote details. `STATUS` and `WINDOWTITLE`
filters are unsupported remotely. `/APPS` is present and returned CSV with a
`Package Name` column on Windows NT `10.0.26200.0`, but is absent from the
current Microsoft online syntax; gate it on installed help and target build.
Installed file version `10.0.26100.8457` printed 57 nonempty help lines and
returned 0 for both `/?` and `-?`. No process, PID, module, service, app,
filter, credential, remote host, or system state was queried by these help
probes.

## Runtime evidence

The repeatable read-only Windows CLI fixture resolved exact System32
`tasklist.exe`, captured localized `/?` help to completion, and ran local
`/fo csv /nh` with no filter or remote host. It returned exit code `0` and a
nonempty process snapshot under both PowerShell collectors; captured process
rows were counted but not emitted into test logs. Do not pipe a live native
producer directly to `Select-Object -First`: downstream early closure can
change the native exit result. Capture the bounded command completely before
selecting rows when exit status is evidence.

## Related documents

- [taskkill.exe](taskkill.exe.md)
- [whoami.exe](whoami.exe.md)
- [systeminfo.exe](systeminfo.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tasklist reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tasklist).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
