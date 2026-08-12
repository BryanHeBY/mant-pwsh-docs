<!-- mant:tldr:start -->
# dispdiag.exe

> Capture Windows display diagnostics to a new protected artifact; the output is diagnostic data, not a human-readable text report.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/dispdiag.

- Resolve the exact Windows command and version:

`Get-Command dispdiag.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersionFixed';Expression={$_.FileVersionInfo.FileVersionRaw.ToString()}},@{Name='FileVersionString';Expression={$_.FileVersionInfo.FileVersion}}`

- Display installed syntax without collecting data:

`dispdiag.exe -?`

- Confirm that the explicit destination does not already exist:

`Test-Path -LiteralPath "{{C:\Diagnostics\display.dat}}"`

- Capture display data after an optional bounded delay (`-out` must be last):

`dispdiag.exe -delay {{5}} -out "{{C:\Diagnostics\display.dat}}"; $code = $LASTEXITCODE; Get-Item -LiteralPath "{{C:\Diagnostics\display.dat}}" | Select-Object FullName,Length,LastWriteTime; $code`
<!-- mant:tldr:end -->

# dispdiag.exe

## Overview

`dispdiag.exe` logs display information to a file. It can delay collection,
run an interactive ACPI hotkey test, and add a dump artifact. The normal data
file is intended for display troubleshooting and is not a stable text or JSON
automation interface.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `dispdiag.exe`: Capture Windows display diagnostic data to a file.

The output path is an artifact destination, and Microsoft requires `-out` to
be the final parameter in the invocation.

<!-- mant:entries role=option case=insensitive -->
- `-testacpi`: Run the interactive hotkey diagnostic and display key/scan codes.
- `-d`: Generate an additional dump artifact with the test results.
- `-delay`: Wait the specified number of seconds before collecting data.
- `-out`: Select the output path and filename; this option must appear last.
- `-?`: Display installed command help.

## Common mistakes

### Putting another option after `-out`

Microsoft requires `-out <filepath>` to be the last parameter. Preserve that
ordering rather than relying on a permissive parser observed on one build.

### Opening the DAT in a text editor and treating fragments as the report

Visible strings do not define the file format or prove the rest is corrupt.
Preserve the original and give it to the intended support/debugging workflow;
do not build production parsing around incidental strings.

### Adding `-d` without a data-handling plan

A dump can be much larger and more sensitive than the base capture. Use a new
protected path, check free space, restrict access/retention, hash transfers and
never attach a dump publicly without review.

### Running `-testacpi` in unattended automation

The test observes key presses and is interactive. It can wait for input or
capture unrelated keystrokes; reserve it for a supervised console session with
a documented exit path.

### Assuming a clean capture proves the monitor, cable, GPU or driver is healthy

Correlate the artifact with exact display topology, driver/package version,
firmware, event logs, reproduction time and physical tests. Collection success
is not diagnosis.

## PowerShell boundaries

Call `dispdiag.exe` explicitly, keep `-out` last, and save `$LASTEXITCODE`
before running `Get-Item`. Pre-create only the parent directory, not the output
file. PowerShell objects are useful for artifact metadata, not decoding the
binary diagnostic format.

## Version and platform differences

Windows-only. Output schema, included data, privilege needs and display-stack
behavior can vary by Windows and graphics-driver build. Validate installed
help on the affected host.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 DispDiag file version
10.0.26100.8737 -? returned 15 nonempty stdout help lines/no stderr/status 1,
and a before/after workspace snapshot found no file change. The harness also
exposed an uncaptured Task.WaitAll boolean on PowerShell's success stream; that
contamination was separated from native output and added to both pipeline
guides. No base DAT, dump, interactive key test, driver/display change or
public disclosure occurred.

## Related documents
- [dxdiag.exe](dxdiag.exe.md)
- [msinfo32.exe](msinfo32.exe.md)
- [eventvwr.msc](eventvwr.msc.md)
- [driverquery.exe](driverquery.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[dispdiag reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dispdiag).
The non-text output pitfall was cross-checked against a long-running
[Microsoft Q&A request about reading DispDiag DAT output](https://learn.microsoft.com/answers/questions/2511147/i-need-to-look-at-the-output-file-fromdispdiag-dat).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation, Microsoft Q&A contribution, and this adaptation
are licensed under CC BY 4.0.
