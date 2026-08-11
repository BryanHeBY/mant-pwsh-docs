<!-- mant:tldr:start -->
# prndrvr

> Inventory Windows printer drivers before any signed-package installation or removal.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/prndrvr.

- Locate every installed language copy of the inbox script:

`Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter prndrvr.vbs -Recurse | Select-Object -ExpandProperty FullName`

- List printer drivers on the local computer:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs}}" -l`

- List printer drivers on one exact print server using the current identity:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs}}" -l -s "{{PRINT01}}"`

- Get typed driver inventory with the modern PrintManagement module:

`Get-PrinterDriver -ComputerName "{{PRINT01}}" | Select-Object Name,Manufacturer,MajorVersion,PrinterEnvironment,InfPath`
<!-- mant:tldr:end -->

# prndrvr

## Overview

`prndrvr.vbs` lists (`-l`), installs (`-a`), deletes one (`-d`), or deletes all
unused/additional (`-x`) printer drivers. Run the language-specific VBScript
through `cscript.exe`; it is not a native executable.

## Common mistakes

### Supplying a friendly queue name as the driver model

`-m` must match a model name defined by the selected INF, not the printer's
display/base name. Inspect the signed package, architecture, environment,
model list, dependencies, and existing queues before installation.

### Treating `-x` as ordinary cleanup

`-x` has broad removal scope and can remove additional client drivers and fax
drivers. Inventory driver-to-queue use and recovery packages first; never run
it as a diagnostic probe.

### Installing from an untrusted or incomplete driver directory

An INF can reference catalogs, binaries, and dependent INFs. Validate publisher
signature and package integrity, stage through approved driver-management
controls, and test spooler isolation/compatibility on the target architecture.

### Confusing architecture with process bitness

The printer environment (`Windows x64`, legacy x86/IA64) describes the target
driver package. It is not chosen merely from the shell's bitness. WOW64 path
redirection can also change which script or system path a 32-bit host sees.

### Embedding remote administrator credentials

Avoid `-u`/`-w` secrets in command lines. Use an approved current identity and
record the exact server; omission of `-s` silently changes scope to local.

## PowerShell behavior

Use `cscript.exe //NoLogo`, a full literal script path, and `$env:WINDIR` rather
than `%WINDIR%`. Output is localized text. Check `$LASTEXITCODE`; for automation,
prefer typed `Get-PrinterDriver` and package-aware driver cmdlets/tools.

## Version and platform differences

Windows-only. Script availability, model/version/environment values, Type 3/4
support, Point and Print policy, signature enforcement, and permissions vary by
release. The official page contains old environments and inconsistent examples;
local script help and signed INF metadata govern the target.

## Related documents

- [pnputil](pnputil.md)
- [prnmngr](prnmngr.md)
- [rundll32](rundll32.md)
- [cscript](cscript.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prndrvr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prndrvr).
The recurring INF model-name failure was cross-checked against a
[PrintUI driver-installation question](https://serverfault.com/questions/393755/error-when-attempting-to-install-network-printer-driver-using-printui-command).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
