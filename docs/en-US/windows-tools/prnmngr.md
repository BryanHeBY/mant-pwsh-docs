<!-- mant:tldr:start -->
# prnmngr

> Inventory Windows printer queues, connections, and the current user's default printer.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/prnmngr.

- Locate every installed language copy of the inbox script:

`Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter prnmngr.vbs -Recurse | Select-Object -ExpandProperty FullName`

- List local printers and printer connections:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prnmngr.vbs}}" -l`

- Display the interactive user's default printer:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prnmngr.vbs}}" -g`

- Get typed local printer inventory with scope-relevant fields:

`Get-Printer | Select-Object Name,Type,ComputerName,DriverName,PortName,Shared,Published,PrinterStatus`
<!-- mant:tldr:end -->

# prnmngr

## Overview

`prnmngr.vbs` adds/deletes/lists local printers or connections and gets/sets
the default printer. It is a language-resource VBScript invoked by
`cscript.exe`, not a standalone `prnmngr` executable.

## Common mistakes

### Confusing per-user connections with per-computer queues

Printer visibility depends on the user session, connection type, local queue,
deployment policy, and timing. An elevated/admin or service context can see a
different set from the interactive user. Record the identity and session with
every inventory.

### Trying to set another user's default printer remotely

The default printer is user-context state, and Windows can manage it dynamically.
Remote process creation under an administrator does not necessarily change the
intended interactive user's setting. Use supported user policy or run in the
correct user context.

### Using `-x` as a reset

`-x` deletes all printers in the selected scope; with connection mode it has a
different broad target. It is destructive, not an inventory or repair probe.
Export queue/connection identity and define redeployment before deletion.

### Creating a queue before driver and port identity exist

`-m` is a driver model name and `-r` is an existing port name. Validate the
signed driver, exact model, port address/protocol, and name collision first.

### Parsing localized output or exposing `-w`

Use `Get-Printer` for structured automation. Do not place a remote administrator
password in command history/process arguments; use an approved current identity.

## PowerShell behavior

Invoke the full script path through `cscript.exe //NoLogo` and use
`$env:WINDIR`, not `%WINDIR%`. Text output is localized. Check `$LASTEXITCODE`
and distinguish the PowerShell run-as user/session from the target print scope.

## Version and platform differences

Windows-only. Script location, default-printer policy, connection realization,
Point and Print rules, remote access, and PrintManagement support vary by build,
edition, session, and policy.

## Related documents

- [prncnfg](prncnfg.md)
- [prnport](prnport.md)
- [prndrvr](prndrvr.md)
- [cscript](cscript.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prnmngr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prnmngr).
Per-user/per-computer inventory gaps and localized-text parsing demand were
cross-checked against practitioner discussions of
[listing all printers](https://serverfault.com/questions/419866/list-all-printers-using-powershell)
and [script output parsing](https://stackoverflow.com/questions/48077575/prnmngr-vbs-parse-and-format-output-as-csv-from-a-windows-batch-file).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Exchange contributions are licensed under CC BY-SA 4.0.
