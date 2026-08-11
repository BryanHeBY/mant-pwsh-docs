<!-- mant:tldr:start -->
# prnport

> Inventory Standard TCP/IP printer-port names, endpoints, protocols, and SNMP settings.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/prnport.

- Locate every installed language copy of the inbox script:

`Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter prnport.vbs -Recurse | Select-Object -ExpandProperty FullName`

- List Standard TCP/IP printer ports on the local computer:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs}}" -l`

- Display one exact port's configuration on one print server:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs}}" -g -s "{{PRINT01}}" -r "{{IP_192.0.2.40}}"`

- Get typed local port inventory with the modern PrintManagement module:

`Get-PrinterPort | Select-Object Name,Description,PrinterHostAddress,PortNumber,Protocol,SNMPEnabled,SNMPCommunity,SNMPIndex`
<!-- mant:tldr:end -->

# prnport

## Overview

`prnport.vbs` lists, displays, creates, changes, or deletes Standard TCP/IP
printer ports. It is a localized VBScript that must be run through
`cscript.exe`. A port is spooler configuration; it is not the printer queue or
proof that the network endpoint is the intended physical device.

## Common mistakes

### Supplying the printer IP where a port name is required

`-r` selects the logical port name; `-h` is the host address. Names often look
like `IP_192.0.2.40`, but that convention is not enforced. Read the exact port
and queue binding rather than deriving one from the other.

### Mixing RAW and LPR settings

RAW normally uses a TCP port number; LPR uses a remote queue name and may use
byte counting. These are protocol choices, not interchangeable labels. Match
the device/print-server configuration and test a disposable queue first.

### Treating SNMP community text as harmless metadata

SNMP settings affect status detection and may disclose a credential-like
community string in output/logs. Preserve current enablement, index, version
expectations, and secret-handling policy; do not disable SNMP merely to hide an
underlying routing, firewall, or device problem.

### Deleting a port before checking queue references

Inventory every queue bound to the port and any cluster/server migration plan.
A name that looks unused in one user view may still be referenced by a shared
queue or deployment workflow.

### Omitting `-s` or passing `-w`

Without `-s`, the local spooler is targeted. Never embed remote administrator
passwords in command arguments; use the current approved identity and record
the exact server.

## PowerShell behavior

Invoke the full `.vbs` path with `cscript.exe //NoLogo`; use `$env:WINDIR`
instead of Cmd expansion. Output is localized text. Prefer `Get-PrinterPort`
for objects and check `$LASTEXITCODE` for the script.

## Version and platform differences

Windows-only. Script path, Standard TCP/IP Port Monitor capabilities, SNMP,
LPR/RAW defaults, firewall access, cluster behavior, and PrintManagement
availability vary by build and role.

## Related documents

- [prnmngr](prnmngr.md)
- [prncnfg](prncnfg.md)
- [ping](ping.md)
- [cscript](cscript.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prnport reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prnport).
Driver/model/port identity confusion was cross-checked against a
[PrintUI installation case](https://serverfault.com/questions/393755/error-when-attempting-to-install-network-printer-driver-using-printui-command).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
