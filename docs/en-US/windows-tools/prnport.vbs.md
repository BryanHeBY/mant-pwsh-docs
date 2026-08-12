<!-- mant:tldr:start -->
# prnport.vbs

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

# prnport.vbs

## Overview

`prnport.vbs` lists, displays, creates, changes, or deletes Standard TCP/IP
printer ports. It is a localized VBScript that must be run through
`cscript.exe`. A port is spooler configuration; it is not the printer queue or
proof that the network endpoint is the intended physical device.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `prnport.vbs`: List, inspect, create, change, or delete Standard TCP/IP printer ports.

Run the localized script through `cscript.exe`; a port is spooler configuration,
not proof of physical device identity.

<!-- mant:entries role=option case=insensitive -->
- `-a`: Create a Standard TCP/IP printer port.
- `-d`: Delete one exact port after checking every queue reference.
- `-l`: List Standard TCP/IP ports on the selected server.
- `-g`: Display configuration for one exact port.
- `-t`: Change configuration for one exact port.
- `-r`: Select the logical spooler port name.
- `-s`: Select a remote print server; omission targets the local host.
- `-u`: Select an alternate remote account.
- `-w`: Supply its password inline and expose the secret.
- `-o`: Select RAW or LPR transport.
- `-h`: Set the printer or print-server network address.
- `-q`: Set the LPR remote queue name.
- `-n`: Set the RAW TCP port number, normally 9100.
- `-m`: Enable or disable SNMP using the attached `e` or `d` value.
- `-i`: Set the SNMP device index.
- `-y`: Set the SNMP community string.
- `-2`: Enable or disable LPR byte-count respooling.
- `-?`: Display installed script syntax.

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

## PowerShell boundaries

Invoke the full `.vbs` path with `cscript.exe //NoLogo`; use `$env:WINDIR`
instead of Cmd expansion. Output is localized text. Prefer `Get-PrinterPort`
for objects and check `$LASTEXITCODE` for the script.

## Version and platform differences

Windows-only. Script path, Standard TCP/IP Port Monitor capabilities, SNMP,
LPR/RAW defaults, firewall access, cluster behavior, and PrintManagement
availability vary by build and role.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`prnport.vbs` Application candidate under either PowerShell collector. This
does not search every localized Printing Administration script directory and
does not prove the feature absent. Exact localized-script discovery, help, and
port reads remain for an approved print host; no port, RAW/LPR/SNMP,
credential, queue, or device mutation is required merely for evidence.

## Related documents
- [prnmngr.vbs](prnmngr.vbs.md)
- [prncnfg.vbs](prncnfg.vbs.md)
- [ping.exe](ping.exe.md)
- [cscript.exe](cscript.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prnport reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prnport).
Driver/model/port identity confusion was cross-checked against a
[PrintUI installation case](https://serverfault.com/questions/393755/error-when-attempting-to-install-network-printer-driver-using-printui-command).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
