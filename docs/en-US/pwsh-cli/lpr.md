<!-- mant:tldr:start -->
# lpr

> Submit one reviewed text or printer-language file to an exact legacy LPD queue.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/lpr.

- Confirm the optional client and inspect syntax without printing:

`lpr.exe /?`

- Query the exact target queue before submitting anything:

`lpq.exe -S "{{lpd01.example.com}}" -P "{{queue_name}}" -l`

- Review and hash the exact artifact before irreversible physical output:

`Get-Item -LiteralPath "{{C:\Print\job.ps}}" | Select-Object FullName,Length,LastWriteTime; Get-FileHash -LiteralPath "{{C:\Print\job.ps}}" -Algorithm SHA256`

- Submit a reviewed binary/printer-language file (`-o l`) to the exact queue:

`lpr.exe -S "{{lpd01.example.com}}" -P "{{queue_name}}" -J "{{approved_job_name}}" -o l "{{C:\Print\job.ps}}"`
<!-- mant:tldr:end -->

# lpr

## Overview

`lpr.exe` sends one file to an LPD queue. `-o` selects text; `-o l` selects
binary data such as PostScript. `-C` banner content and `-J` job name may be
printed/disclosed. Submission acknowledgment is not physical completion.

## Common mistakes

### Lowercasing `-S`, `-P`, `-C`, or `-J`

Microsoft requires these option letters to be capitalized. Native options are
not PowerShell parameters and should not be normalized.

### Sending binary printer language as text

Text mode can transform bytes; binary mode preserves them but assumes the
target understands the embedded language. Confirm file type, trusted content,
driverless/raw policy and exact device capability before submission.

### Treating LPR as authenticated or encrypted delivery

Classic LPR/LPD provides weak host/queue trust and no modern confidentiality.
Use it only on an approved bounded network; do not submit sensitive artifacts
or expose the service to untrusted networks.

### Leaking data in banner/job/filename fields

Names can appear in queue status, logs and physical banner pages. Use an
approved nonsecret correlation label and account for unattended output.

### Retrying after an ambiguous response

Network timeout or nonzero exit does not prove the server rejected the job.
Query LPQ and server/device logs using a unique job label before resubmitting.

### Treating a repeated pause after 11 rapid jobs as a file-loop bug

Windows' legacy RFC-style LPR path can exhaust its 11 privileged source ports
and wait for them to time out. Correlate the queue and relevant TCP/IP events;
do not blindly retry and create duplicates. Microsoft recommends a Standard
TCP/IP port where possible. Any port-monitor registry/service change belongs
to separate change control, not a client-script workaround.

### Assuming `System32` resolves identically from a 32-bit automation host

WOW64 redirects a 32-bit process away from the native system directory, so an
optional native executable can appear missing even when an interactive 64-bit
shell finds it. Resolve `lpr.exe` inside the actual service/agent process.
`Sysnative` is a virtual bypass only for 32-bit callers, not a portable path.

## PowerShell behavior

Call `lpr.exe` explicitly; quote paths and inspect `$LASTEXITCODE` immediately.
Do not pipe PowerShell text/objects into LPR and assume encoding or framing.
Materialize and review the exact byte artifact first.

## Version and platform differences

Windows-only and optional-feature dependent. Queue extensions, text conversion,
banner policy and binary languages vary by LPD/device. `-x` exists only for old
SunOS compatibility and should not be added generically.

## Related documents

- [lpq](lpq.md)
- [print](print.md)
- [prnjobs](prnjobs.md)
- [certutil](certutil.md)

## Sources and license

This original guide was adapted from Microsoft's official
[lpr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/lpr),
[LPR 11-port exhaustion troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/printing/printing-pauses-event-2004-4227-lpr-port),
and [WOW64 file-system redirection](https://learn.microsoft.com/windows/win32/winprog64/file-system-redirector).
Real-world file-language, burst-delay and service-bitness failure shapes were
cross-checked against practitioner reports of [PDF bytes printing as text](https://stackoverflow.com/questions/27156706/windows-print-pdf-with-lpr-from-command-line-prints-as-text),
[periodic LPR submission delays](https://stackoverflow.com/questions/74096719/how-to-avoid-delays-printing-lpr-using-batch-file),
and [a 32-bit service failing to resolve LPR](https://stackoverflow.com/questions/11915241/lpr-command-to-print-pcl-file-from-windows-service-not-workingnow-a-tray-applic).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
