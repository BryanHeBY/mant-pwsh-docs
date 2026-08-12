<!-- mant:tldr:start -->
# prndrvr.vbs

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

# prndrvr.vbs

## Overview

`prndrvr.vbs` lists (`-l`), installs (`-a`), deletes one (`-d`), or deletes all
unused/additional (`-x`) printer drivers. Run the language-specific VBScript
through `cscript.exe`; it is not a native executable.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `prndrvr.vbs`: List, install, or delete Windows printer drivers.

This is a localized VBScript invoked through `cscript.exe`, not an executable.

<!-- mant:entries role=option case=insensitive -->
- `-a`: Install the exact driver model from approved package files.
- `-d`: Delete one selected driver.
- `-l`: List printer drivers on the selected server.
- `-x`: Delete every unused/additional driver and potentially fax drivers.
- `-m`: Select the exact driver model name defined by the INF.
- `-v`: Select the historical driver version/type value.
- `-e`: Select the driver environment/architecture.
- `-s`: Select a remote print server; omission targets the local host.
- `-u`: Select an alternate remote account.
- `-w`: Supply its password inline and expose the secret.
- `-h`: Select the directory containing driver files.
- `-i`: Select the complete printer INF path.
- `-?`: Display installed script syntax.

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

## PowerShell boundaries

Use `cscript.exe //NoLogo`, a full literal script path, and `$env:WINDIR` rather
than `%WINDIR%`. Output is localized text. Check `$LASTEXITCODE`; for automation,
prefer typed `Get-PrinterDriver` and package-aware driver cmdlets/tools.

## Version and platform differences

Windows-only. Script availability, model/version/environment values, Type 3/4
support, Point and Print policy, signature enforcement, and permissions vary by
release. The official page contains old environments and inconsistent examples;
local script help and signed INF metadata govern the target.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`prndrvr.vbs` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains script discovery/help and
local/exact-server driver listing only; no install, delete, delete-all,
staging, package, credential or spooler mutation is permitted merely for
evidence.

## Related documents
- [pnputil.exe](pnputil.exe.md)
- [prnmngr.vbs](prnmngr.vbs.md)
- [rundll32.exe](rundll32.exe.md)
- [cscript.exe](cscript.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prndrvr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prndrvr).
The recurring INF model-name failure was cross-checked against a
[PrintUI driver-installation question](https://serverfault.com/questions/393755/error-when-attempting-to-install-network-printer-driver-using-printui-command).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
