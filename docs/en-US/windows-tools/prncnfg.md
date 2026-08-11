<!-- mant:tldr:start -->
# prncnfg

> Display one Windows printer queue's configuration through the inbox Printing Administration script.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/prncnfg.

- Locate every installed language copy instead of assuming `en-US`:

`Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter prncnfg.vbs -Recurse | Select-Object -ExpandProperty FullName`

- Display one exact local printer queue with a previously selected script path:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prncnfg.vbs}}" -g -P "{{Queue Name}}"`

- Display one exact queue on one print server using the current Windows identity:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prncnfg.vbs}}" -g -S "{{PRINT01}}" -P "{{Queue Name}}"`

- Get typed local queue properties with the modern PrintManagement module:

`Get-Printer -Name "{{Queue Name}}" | Format-List Name,ComputerName,DriverName,PortName,Shared,Published,PrinterStatus`
<!-- mant:tldr:end -->

# prncnfg

## Overview

`prncnfg.vbs` displays (`-g`), configures (`-t`), or renames (`-x`) a logical
printer queue. It is a VBScript under
`%WINDIR%\System32\Printing_Admin_Scripts\<language>` and must be passed to
`cscript.exe`; it is not a standalone executable.

## Common mistakes

### Hard-coding the `en-US` directory

The script directory follows installed Windows language resources. Discover
the exact file first and reject zero or ambiguous matches in automation.

### Confusing a queue, share, driver, port, and physical device

`-P` identifies the logical printer name. `-h` is a share name and `-r` is a
port name; neither is necessarily the device hostname. Preserve all identities
before a change and verify the exact server with `-S`.

### Parsing localized display text as a stable object format

The VBScript emits human text whose labels and layout can vary by language and
Windows build. Prefer `Get-Printer` for structured automation and keep raw
script output when compatibility requires the legacy interface.

### Treating `-g` and `-t` as interchangeable

`-g` reads; `-t` changes queue flags, scheduling, priority, port, metadata, and
sharing/publication behavior. Flags such as `+direct`, `+keepprintedjobs`, and
`+published` can affect availability, retention, privacy, and AD discovery.

### Passing `-w` credentials on the command line

Inline passwords can leak through process inspection, transcripts, logs, and
history. Use the current approved identity or a secret-safe remote-management
channel rather than embedding `-u`/`-w`.

## PowerShell behavior

Call `cscript.exe //NoLogo` and pass the script's full path. PowerShell does not
expand `%WINDIR%`; use `$env:WINDIR`. The result is text, not objects. Check
`$LASTEXITCODE` immediately and do not infer success from nonempty output.

## Version and platform differences

Windows-only. Script presence, language path, fields, queue capabilities,
permissions, and remote spooler access vary by build and policy. PrintManagement
cmdlets are preferable when installed, but they are not evidence that the
legacy script behaves identically.

## Related documents

- [prnmngr](prnmngr.md)
- [prnport](prnport.md)
- [prndrvr](prndrvr.md)
- [cscript](cscript.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prncnfg reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prncnfg).
Localized-text parsing demand was cross-checked against a
[Printing Administration Scripts discussion](https://stackoverflow.com/questions/48077575/prnmngr-vbs-parse-and-format-output-as-csv-from-a-windows-batch-file).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
