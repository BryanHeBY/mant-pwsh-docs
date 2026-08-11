<!-- mant:tldr:start -->
# flattemp

> Query RD Session Host temporary-folder flattening before changing per-session isolation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/flattemp.

- Resolve the command and confirm RD Session Host role state:

`Get-Command flattemp.exe -All -ErrorAction SilentlyContinue; Get-WindowsFeature -Name RDS-RD-Server -ErrorAction SilentlyContinue`

- Query the current flat-temporary-folder setting:

`flattemp.exe /query`

- Inspect the current session's effective paths without assuming other users match:

`[pscustomobject]@{SessionId=(Get-Process -Id $PID).SessionId; TEMP=$env:TEMP; TMP=$env:TMP; TempPath=[IO.Path]::GetTempPath()}`

- Inventory active/disconnected sessions before any change:

`query.exe session`
<!-- mant:tldr:end -->

# flattemp

## Overview

`flattemp.exe` queries, enables, or disables flat temporary folders on an RD
Session Host. With flat folders enabled, users can share the pointed-to folder
unless each user's TEMP/TMP is already isolated in a home directory. With them
disabled, RDS normally adds a session-ID subfolder.

## Common mistakes

### Enabling flat folders while users point to one shared local path

This removes session subfolder separation and can cause data disclosure,
collisions, unsafe permissions and application corruption. Prove that every
user has a unique, access-controlled temp root before `/enable`.

### Moving TEMP/TMP to a network share as the automatic fix

Microsoft warns that transient network loss can make applications behave as if
the disk failed and can desynchronize temporary data. Validate latency,
availability, offline behavior, quotas, cleanup, ACLs and application support;
local storage is the default recommendation.

### Assuming `/query` describes each session's effective path

It reports the flattening setting, not Group Policy, environment expansion,
profile/home-folder availability, ACLs, session subfolder existence or process-
inherited values. Sample approved users/sessions and test the real application.

### Changing the setting while applications are active

Existing processes retain environment values and open files. Drain new logons,
inventory sessions/workloads, choose a maintenance boundary and verify new
sessions; do not delete old temp trees until ownership/retention is resolved.

### Ignoring the separate-temporary-folders policy

Microsoft notes that FlatTemp is ignored when separate per-session temporary
folders are disabled elsewhere. Collect resultant policy and actual paths
instead of repeatedly toggling this command.

## PowerShell behavior

Call `flattemp.exe` explicitly and capture `$LASTEXITCODE`. `$env:TEMP` and
`$env:TMP` are process-inherited current-session evidence only. Do not remotely
change a live farm host without exact host identity and console recovery.

## Version and platform differences

Windows-only and available when the RD Session Host role service is installed.
The broad Learn header includes client Windows, but that does not make the
server setting applicable. Profile containers and newer application packaging
may add further path semantics.

## Related documents

- [change](change.md)
- [query](query.md)
- [gpresult](gpresult.md)
- [set](set.md)

## Sources and license

This original guide was adapted from Microsoft's official
[flattemp reference](https://learn.microsoft.com/windows-server/administration/windows-commands/flattemp).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
