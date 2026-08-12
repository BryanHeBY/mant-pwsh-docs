<!-- mant:tldr:start -->
# prncnfg.vbs

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

# prncnfg.vbs

## Overview

`prncnfg.vbs` displays (`-g`), configures (`-t`), or renames (`-x`) a logical
printer queue. It is a VBScript under
`%WINDIR%\System32\Printing_Admin_Scripts\<language>` and must be passed to
`cscript.exe`; it is not a standalone executable.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `prncnfg.vbs`: Display, configure, or rename one logical Windows printer queue.

Run the localized script through `cscript.exe`; every plus/minus state operand
has a distinct effect and should be passed only with configuration mode `-t`.

<!-- mant:entries role=option case=insensitive -->
- `-g`: Display configuration for the selected queue.
- `-t`: Change queue configuration and behavioral flags.
- `-x`: Rename the queue selected by `-P`.
- `-S`: Select a remote print server; omission targets the local host.
- `-P`: Select the required logical printer name.
- `-z`: Set the new name used by rename mode.
- `-u`: Select an alternate remote account.
- `-w`: Supply its password inline and expose the secret.
- `-r`: Set the spooler port name.
- `-l`: Set printer location metadata.
- `-h`: Set the share name.
- `-m`: Set the printer comment.
- `-f`: Set the separator-page filename.
- `-y`: Set the accepted spool data type.
- `-st`: Set the daily availability start time in 24-hour form.
- `-ut`: Set the daily availability end time in 24-hour form.
- `-i`: Set the default priority assigned to jobs.
- `-o`: Set the queue routing priority.
- `+shared`: Share the printer queue on the network using its configured share name.
- `-shared`: Stop sharing the printer queue on the network.
- `+direct`: Send documents directly to the printer without first spooling them.
- `-direct`: Restore normal print spooling instead of direct printing.
- `+hidden`: Set the script's reserved hidden state flag.
- `-hidden`: Clear the script's reserved hidden state flag.
- `+published`: Publish the printer in Active Directory for discovery.
- `-published`: Remove the printer's Active Directory publication.
- `+rawonly`: Allow only raw-data print jobs in the queue.
- `-rawonly`: Allow the queue's supported non-raw data types again.
- `+queued`: Wait until the final page is spooled before starting to print.
- `-queued`: Permit printing to begin before the complete document is spooled.
- `+enablebidi`: Enable printer-to-spooler bidirectional status reporting.
- `-enablebidi`: Disable bidirectional status reporting.
- `+keepprintedjobs`: Retain documents in the queue after they are printed.
- `-keepprintedjobs`: Remove printed documents according to normal spooler behavior.
- `+workoffline`: Allow users to queue print jobs while the printer is offline.
- `-workoffline`: Disable offline print-job submission for the queue.
- `+enabledevq`: Hold jobs whose data type does not match the printer setup.
- `-enabledevq`: Disable the mismatch-hold behavior.
- `+docompletefirst`: Let completely spooled lower-priority jobs run before incomplete higher-priority jobs.
- `-docompletefirst`: Preserve normal priority ordering instead of preferring completely spooled jobs.
- `-?`: Display installed script syntax.

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

## PowerShell boundaries

Call `cscript.exe //NoLogo` and pass the script's full path. PowerShell does not
expand `%WINDIR%`; use `$env:WINDIR`. The result is text, not objects. Check
`$LASTEXITCODE` immediately and do not infer success from nonempty output.

## Version and platform differences

Windows-only. Script presence, language path, fields, queue capabilities,
permissions, and remote spooler access vary by build and policy. PrintManagement
cmdlets are preferable when installed, but they are not evidence that the
legacy script behaves identically.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`prncnfg.vbs` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains script discovery, help, exact queue reads
and typed inventory only; no queue configuration, rename, publication,
scheduling, retention, sharing, port, credential or spooler mutation is
permitted merely for evidence.

## Related documents
- [prnmngr.vbs](prnmngr.vbs.md)
- [prnport.vbs](prnport.vbs.md)
- [prndrvr.vbs](prndrvr.vbs.md)
- [cscript.exe](cscript.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prncnfg reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prncnfg).
Localized-text parsing demand was cross-checked against a
[Printing Administration Scripts discussion](https://stackoverflow.com/questions/48077575/prnmngr-vbs-parse-and-format-output-as-csv-from-a-windows-batch-file).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
