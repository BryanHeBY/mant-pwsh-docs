<!-- mant:tldr:start -->
# print

> Review a text file, exact queue, driver, and port before submitting an
> irreversible print job; PRINT is not a general document-rendering command.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/print.

- Display target-local PRINT syntax without submitting a job:

`print.exe /?`

- Inventory installed queues and their driver/port identity:

`Get-Printer | Format-Table Name, Type, DriverName, PortName, Shared, Published`

- Inspect one exact source file before any print submission:

`Get-Item -LiteralPath "{{text-file}}" | Format-List FullName, Length, LastWriteTime, Attributes`

- Preview decoded text explicitly instead of sending unknown bytes to a device:

`Get-Content -LiteralPath "{{text-file}}" -Encoding {{utf8}} -TotalCount {{40}}`

<!-- mant:tldr:end -->

# print

## Overview

`print.exe [/d:<printer>] <file>...` sends text files to a local serial/parallel
port or a network queue. If `/d` is omitted, Microsoft documents LPT1 as the
default. Submission can consume paper, labels, ink/toner, reveal content, trigger
device-language commands, and be difficult to recall; therefore the TLDR does
not submit a sample job.

PRINT does not render arbitrary PDF, Office, image, HTML, PCL, PostScript, ZPL,
or application-native documents. Select a supported application/driver workflow
for the actual format and required media, duplex, orientation, color, finishing,
copies, authentication and accounting behavior.

## Common mistakes

### Omitting `/d` and accidentally targeting LPT1

Always resolve an exact queue or approved port and confirm server/share, driver,
port monitor, location, media and device identity. A display name alone can be
duplicated, renamed or point to a redirected/session printer.

### Passing a printer display name where a port or UNC queue is required

Microsoft documents LPT1–LPT3, COM1–COM4, or `\\server\queue`. Modern TCP/IP
addresses and friendly printer names are not automatically valid `/d` values.
Use `Get-Printer` and `Get-PrinterPort`, then choose a supported print API rather
than editing registry/port mappings to force PRINT to accept a name.

### Treating every file as printable text

Inspect type, size, encoding, line endings and content. Binary/control bytes can
truncate, garble or issue raw printer-language actions. Sensitive data can remain
in spool files, device storage and physical output. Use a reviewed inert test page
and explicit content classification before production submission.

### Expecting landscape, duplex, tray, copies or fonts from PRINT

PRINT exposes only destination and file selection. Page setup belongs to the
renderer, driver, queue defaults or printer language. Do not inject copied escape
sequences unless the exact device language and security policy explicitly allow
raw printing.

### Assuming command success means paper output

Submission, spooling, rendering, transmission and physical completion are
different states. Record the returned result, correlate the spool job and queue,
monitor error/offline/paper states, define a bounded wait, and verify the intended
physical outcome without repeatedly resubmitting duplicates.

### Printing untrusted content to privileged/shared devices

Documents and raw printer languages can exploit renderers or alter device state.
Scan and render in an isolated supported workflow, patch drivers/firmware, apply
least privilege and queue authorization, and never print secrets merely as a
diagnostic.

## PowerShell behavior

Use `print.exe` explicitly because `print` can collide with language/tool names.
`Out-Printer` uses Windows printing but still depends on host, renderer and queue
defaults; it does not solve format trust or completion verification. Native text
output is localized, and `$LASTEXITCODE` must be captured immediately.

## Version and platform differences

PRINT is Windows-only and retains serial/parallel-era semantics. Queue, driver,
Print Spooler, Point and Print policy, session redirection, architecture, server
availability and device language affect behavior. PowerShell print-management
cmdlets depend on Windows/module availability.

## Related documents

- [mode](mode.md)
- [net](net.md)
- [cscript](cscript.md)

## Sources and license

This original guide was adapted from Microsoft's official
[PRINT reference](https://learn.microsoft.com/windows-server/administration/windows-commands/print).
Real-world queue-name and page-layout confusion was cross-checked against
[queue initialization](https://stackoverflow.com/questions/22839084/command-line-print-call-from-batch-file)
and [landscape rendering](https://stackoverflow.com/questions/30255647/print-a-file-in-landscape-from-windows-command-line-or-powershell)
questions. Microsoft sources govern syntax. Exact sources/licenses are recorded
in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
