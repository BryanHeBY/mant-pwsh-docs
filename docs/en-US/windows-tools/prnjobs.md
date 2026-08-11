<!-- mant:tldr:start -->
# prnjobs

> List jobs in one exact Windows print queue before pausing, resuming, or canceling anything.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/prnjobs.

- Locate every installed language copy of the inbox script:

`Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter prnjobs.vbs -Recurse | Select-Object -ExpandProperty FullName`

- List jobs in one exact local queue:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prnjobs.vbs}}" -l -p "{{Queue Name}}"`

- List jobs in one exact remote-server queue using the current identity:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\prnjobs.vbs}}" -l -s "{{PRINT01}}" -p "{{Queue Name}}"`

- Get typed local job identity and state with the modern PrintManagement module:

`Get-PrintJob -PrinterName "{{Queue Name}}" | Select-Object ID,DocumentName,UserName,JobStatus,SubmittedTime,Size`
<!-- mant:tldr:end -->

# prnjobs

## Overview

`prnjobs.vbs` lists (`-l`), pauses (`-z`), resumes (`-m`), or cancels (`-x`) a
job in a named Windows printer queue. It is a localized inbox VBScript invoked
through `cscript.exe`.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `prnjobs.vbs`: List, pause, resume, or cancel jobs in one Windows print queue.

Re-list immediately before mutation because job IDs are runtime identities.

<!-- mant:entries role=option case=insensitive -->
- `-z`: Pause the exact job selected by `-j`.
- `-m`: Resume the exact job selected by `-j`.
- `-x`: Cancel the exact job selected by `-j`.
- `-l`: List all jobs in the selected queue.
- `-s`: Select a remote print server; omission targets the local host.
- `-p`: Select the required logical printer queue.
- `-j`: Select one freshly verified job ID.
- `-u`: Select an alternate remote account.
- `-w`: Supply its password inline and expose the secret.
- `-?`: Display installed script syntax.

## Common mistakes

### Using a job ID without binding it to queue and server

Job IDs are queue/server runtime identities and can be reused. Re-list the
exact `-s` plus `-p` scope immediately before a mutation and correlate owner,
document, submission time, size, and current state.

### Canceling a job before preserving evidence

The document name and user can be sensitive, but spooler, driver, event, and
job evidence may be needed to diagnose a stuck queue. Capture approved minimal
evidence before cancellation and protect it according to privacy policy.

### Clearing spool files as a first response

Deleting files under the spool directory or restarting the spooler affects
more than one job/queue and can destroy evidence. Start with queue/job inventory,
driver and port status, and one exact supported cancellation operation.

### Assuming a successful cancel means physical output stopped

Data may already be buffered by the port monitor or physical device. Verify
queue state and device-side jobs; handle sensitive physical pages separately.

### Passing `-w` or parsing localized text

Do not expose remote credentials in the process list. For automation use the
current approved identity and prefer `Get-PrintJob`; VBScript output is localized
and not a stable CSV/object contract.

## PowerShell boundaries

Invoke the full `.vbs` path with `cscript.exe //NoLogo`; PowerShell does not
expand `%WINDIR%`. Check `$LASTEXITCODE` immediately. `-x` is a script argument,
not PowerShell's error or removal syntax.

## Version and platform differences

Windows-only. Job fields, permissions, script language path, remote spooler
access, and PrintManagement availability vary by build/policy. A job can change
between listing and action; no command provides a transaction across that race.

## Related documents

- [prnqctl](prnqctl.md)
- [prnmngr](prnmngr.md)
- [print](print.md)
- [cscript](cscript.md)

## Sources and license

This original guide was adapted from Microsoft's official
[prnjobs reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prnjobs).
Stuck-job recovery demand and the risk of broad spool-directory deletion were
cross-checked against a [print-queue operations discussion](https://serverfault.com/questions/441278/why-do-windows-print-queues-occasionally-choke-on-a-print-job).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
