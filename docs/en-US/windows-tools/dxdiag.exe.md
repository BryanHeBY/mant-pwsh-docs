<!-- mant:tldr:start -->
# dxdiag.exe

> Open DirectX Diagnostic Tool or export a new access-controlled report while waiting for collection to finish; preserve driver, feature-level, architecture, WHQL, host, and artifact context.
> More information: https://learn.microsoft.com/answers/questions/2470635/dxdiag-from-command-line-has-no-output.

- Open the interactive DirectX Diagnostic Tool:

`dxdiag.exe`

- Display the target build's command-line help before automating undocumented or version-specific switches:

`dxdiag.exe /?`

- Export a new text report and wait for the GUI process to finish before verifying it:

`Start-Process dxdiag.exe -ArgumentList @('/t', '"{{C:\Evidence\dxdiag.txt}}"') -Wait`
<!-- mant:tldr:end -->

# dxdiag.exe

## Overview

`dxdiag.exe` collects DirectX, display, sound, input, driver, and system diagnostic
information through an interactive GUI and can export support reports on builds
that expose the corresponding command-line switches. It diagnoses and reports;
it does not install DirectX, update drivers, or prove an application will work.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `dxdiag.exe`: Open DirectX Diagnostic Tool or collect one support report on
  Windows builds that expose the requested export mode.

Export switches and architecture/WHQL behavior have varied; verify installed
`/?`, wait for completion, and validate a newly created artifact.

<!-- mant:entries role=option case=insensitive -->
- `/t`: Export a text diagnostic report to the following explicit path.
- `/x`: Export an XML diagnostic report where supported by the target build.
- `/whql`: Control WHQL signature checking where the installed version supports
  the switch/value; checking can add time/network/privacy considerations.
- `/dontskip`: Avoid skipping diagnostics previously bypassed after a failure;
  use only for a bounded support workflow on the target build.
- `/64bit`: Request 64-bit collection behavior on builds that expose it.
- `/?`: Display target-local launcher help.

## Common mistakes

- Treating the displayed DirectX version as the GPU's supported feature level,
  driver model/version, application API path, codec, or hardware capability.
- Launching export and reading the file immediately. Wait for `dxdiag.exe`, then
  verify a new file, size, timestamps, expected sections, host, encoding and hash.
- Omitting quotes or using a missing/unwritable directory; GUI-style tools may
  return before useful output or fail without a script-friendly error contract.
- Copying `/whql`, `/64bit`, `/dontskip`, `/t`, or `/x` order from old posts
  without checking `/?` on the target. Behavior has varied by Windows generation.
- Enabling signature/WHQL checks without considering network/privacy/time or
  interpreting “signed” as safe, current, correct, or compatible.
- Publishing full reports without redaction; they can expose machine, firmware,
  device IDs, drivers, paths, display/audio/input and troubleshooting details.

## PowerShell boundaries

Use `Start-Process -Wait` with an argument array and a new explicit output path.
Do not trust process start or an old file as success; validate content and record
`dxdiag.exe` version/architecture plus `$LASTEXITCODE` where available. For narrow
structured inventory, prefer supported CIM/DirectX/driver APIs over text parsing.

## Version and platform differences

`dxdiag.exe` is Windows-only. Switches, 32/64-bit collection, tabs/fields, WHQL
behavior, output formats and driver/feature reporting vary by Windows, DirectX,
GPU/audio drivers, hardware, architecture, language and session environment.

## Related documents

- [msinfo32.exe](msinfo32.exe.md)
- [driverquery.exe](driverquery.exe.md)
- [pnputil.exe](pnputil.exe.md)
- [systeminfo.exe](systeminfo.exe.md)

## Sources and license

This original guide was informed by a Microsoft-hosted discussion of
[missing DxDiag command-line output](https://learn.microsoft.com/answers/questions/2470635/dxdiag-from-command-line-has-no-output).
Automation failure modes were also cross-checked against a practitioner question
about [waiting for report export](https://stackoverflow.com/questions/30824928/opening-command-prompt-and-performing-commands).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft-hosted material and this adaptation are licensed under their recorded terms.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
