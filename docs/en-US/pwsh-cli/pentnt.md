<!-- mant:tldr:start -->
# pentnt

> Recognize the deprecated workaround for the 1994 Pentium FDIV hardware defect; do not use it for modern CPU diagnosis.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pentnt.

- Confirm whether a legacy script still resolves the deprecated executable:

`Get-Command pentnt.exe -ErrorAction SilentlyContinue`

- Inventory the current processor model instead of enabling legacy emulation:

`Get-CimInstance -ClassName Win32_Processor | Select-Object Manufacturer, Name, ProcessorId`

- Record the Windows build used for compatibility analysis:

`Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber`

- Search scheduled tasks and scripts for an exact legacy command before retirement:

`Get-ChildItem -LiteralPath "{{C:\Ops\Scripts}}" -File -Recurse | Select-String -Pattern '(?i)\bpentnt(?:\.exe)?\b'`
<!-- mant:tldr:end -->

# pentnt

## Overview

`pentnt.exe` detected the historical Intel Pentium floating-point division
defect and could disable floating-point hardware in favor of emulation.
Microsoft marks the command deprecated. It is retained here so old scripts,
images, incident notes, and command inventories can be interpreted and retired.

## Common mistakes

### Using PentNT for a modern floating-point or CPU problem

It addresses one historical processor erratum, not generic calculation errors,
thermal faults, firmware issues, virtualization behavior, or application bugs.
Use current hardware diagnostics and vendor guidance for the identified CPU.

### Running a deprecated mutation just to see what it reports

Do not enable emulation or alter boot behavior on a production host. Inventory
the binary, script reference, CPU, OS, and business dependency first; reproduce
legacy behavior only in an isolated, recoverable environment when necessary.

### Deleting the old line without understanding its environment

In a preserved legacy image, the command may document a compatibility
assumption. Record the image, hardware/VM, startup context, and replacement
decision before removing it.

## PowerShell behavior

PowerShell is useful for read-only legacy discovery. `Select-String` operates on
text files and can report false positives or miss encoded/binary/configuration
sources; scope it to an approved tree and review every match.

## Version and platform differences

This Windows-only command is deprecated and may be absent. Its original
hardware target is obsolete; modern Windows/hardware compatibility decisions
must follow current processor, firmware, hypervisor, and application support.

## Related documents

- [systeminfo](systeminfo.md)
- [wmic](wmic.md)

## Sources and license

This original retirement guide was adapted from Microsoft's official
[PentNT catalog entry](https://learn.microsoft.com/windows-server/administration/windows-commands/pentnt).
Exact provenance is recorded in `upstream/cli.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
