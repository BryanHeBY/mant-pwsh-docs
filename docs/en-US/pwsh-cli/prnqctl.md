<!-- mant:tldr:start -->
# prnqctl

> Inspect a printer and its jobs before using the inbox script to pause, resume, purge, or print a test page.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/prnqctl.

- Locate every installed language copy of the inbox script:

`Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter prnqctl.vbs -Recurse | Select-Object -ExpandProperty FullName`

- Display the selected script's locally installed help without changing a queue:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prnqctl.vbs}}" -?`

- Inspect one exact queue before any queue-wide action:

`Get-Printer -Name "{{Queue Name}}" | Format-List Name,ComputerName,PrinterStatus,DriverName,PortName,JobCount`

- Preserve the identities of every current job before considering a purge:

`Get-PrintJob -PrinterName "{{Queue Name}}" | Select-Object ID,DocumentName,UserName,JobStatus,SubmittedTime,Size`
<!-- mant:tldr:end -->

# prnqctl

## Overview

`prnqctl.vbs` pauses (`-z`) or resumes (`-m`) an entire printer queue, prints a
test page (`-e`), or cancels every job (`-x`). It has no status/list operation;
use queue/job inventory before invoking this localized VBScript through
`cscript.exe`.

## Common mistakes

### Treating `-x` as one-job cancellation

It cancels all jobs in the named queue. Use `prnjobs` or `Remove-PrintJob` only
after binding one current job ID to server, queue, owner, document, and time.

### Printing a test page as a harmless health check

A test page consumes media, may expose device/location data, and can emerge at
an unattended or sensitive printer. Verify target port/device and physical
authorization first.

### Pausing a queue without an ownership and resume plan

Pause affects every producer and can accumulate sensitive jobs. Record why,
who owns recovery, the expected duration, job growth, and the exact resume and
verification steps.

### Restarting the spooler or deleting spool files too early

Those actions affect other queues and can destroy jobs/evidence. Preserve
queue, job, driver, port, event, and physical-device state before escalation.

### Omitting server identity or exposing `-w`

Without `-s`, the operation is local. Never put remote credentials in command
arguments; use an approved current identity and re-read the exact target.

## PowerShell behavior

Use `cscript.exe //NoLogo` plus the full `.vbs` path. PowerShell does not expand
`%WINDIR%`. The script returns text/native status; inspect `$LASTEXITCODE`.
Prefer PrintManagement cmdlets for structured pre/post evidence.

## Version and platform differences

Windows-only. Script availability, language path, spooler permissions, remote
access, queue state, and PrintManagement support vary by build and policy.

## Related documents

- [prnjobs](prnjobs.md)
- [prnmngr](prnmngr.md)
- [print](print.md)
- [cscript](cscript.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prnqctl reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prnqctl).
Broad spooler-recovery impact was cross-checked against a
[stuck-queue operations discussion](https://serverfault.com/questions/150472/jobs-stuck-in-print-queue-on-print-server).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
