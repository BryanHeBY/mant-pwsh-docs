<!-- mant:tldr:start -->
# lpq

> Query one exact legacy LPD print queue without submitting or canceling a job.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/lpq.

- Confirm that the optional LPR Port Monitor client is installed:

`Get-Command lpq.exe -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Display the status of one exact LPD queue (uppercase `-S` and `-P` are required):

`lpq.exe -S "{{lpd01.example.com}}" -P "{{queue_name}}"`

- Display detailed status for that exact queue:

`lpq.exe -S "{{lpd01.example.com}}" -P "{{queue_name}}" -l`

- Test TCP reachability to the standard LPD service separately:

`Test-NetConnection "{{lpd01.example.com}}" -Port 515 -InformationLevel Detailed`
<!-- mant:tldr:end -->

# lpq

## Overview

`lpq.exe` queries a queue hosted by a Line Printer Daemon (LPD). Both `-S`
server and `-P` queue are required and case-sensitive as option letters. It is
an optional legacy printing client and does not query an arbitrary Windows
spooler queue unless that queue is exposed through LPD.

## Common mistakes

### Lowercasing `-S` or `-P`

Microsoft explicitly requires capitalization. Preserve the native spelling;
do not normalize switches as if they were PowerShell parameter names.

### Using a display name, share name, DNS name, and LPD queue name interchangeably

Bind the exact host/device and LPD queue configured by its owner. TCP 515
success does not prove the queue exists, and a queue response does not prove
the intended physical printer is behind it.

### Treating queue text as trusted or structured output

Remote LPD text and job metadata can expose users, filenames and document
details. Retain raw output, protect it, and do not parse fixed English columns
as a stable object contract.

### Assuming status predicts print rendering or completion

LPQ cannot validate file language, text/binary selection, banner behavior,
spooling, device buffers, media, or physical output. Correlate server/device
evidence before using `lpr`.

## PowerShell behavior

Call `lpq.exe` explicitly, quote values and check `$LASTEXITCODE`. PowerShell
does not treat uppercase/lowercase native switches as equivalent. Output is
plain remote-provided text.

## Version and platform differences

Windows-only and optional-feature dependent. LPD implementations vary in queue
names, status fields and extensions. Prefer supported authenticated/encrypted
print management when available; LPR/LPD itself is a legacy trust model.

## Related documents

- [lpr](lpr.md)
- [prnjobs](prnjobs.md)
- [prnport](prnport.md)
- [print](print.md)

## Sources and license

This original guide was adapted from Microsoft's official
[lpq reference](https://learn.microsoft.com/windows-server/administration/windows-commands/lpq).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
