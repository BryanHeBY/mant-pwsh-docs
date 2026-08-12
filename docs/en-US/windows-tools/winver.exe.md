<!-- mant:tldr:start -->
# winver.exe

> Open About Windows to inspect the installed Windows edition, display version, and OS build; use CIM or the registry when scripts need structured values.
> More information: https://learn.microsoft.com/windows/client-management/client-tools/windows-version-search.

- Resolve the exact executable without opening its window:

`Get-Command winver.exe -All`

- Open About Windows in the current interactive session:

`Start-Process winver.exe`

- Collect scriptable operating-system version fields:

`Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture`
<!-- mant:tldr:end -->

# winver.exe

## Overview

`winver.exe` opens About Windows and displays human-readable Windows product,
version, OS build, and licensing text. It is useful for a quick interactive
identity check and for asking a user to report the exact build shown on screen.

The window is not a machine-readable output interface. Edition, display version,
build, update revision, architecture, servicing channel, SDK version, Windows
App SDK version, and PowerShell version are different facts; record the fields
that are relevant instead of reducing all of them to “the Windows version.”

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `winver.exe`: Open the interactive About Windows dialog for the current operating-system installation.

No supported command-line parameter interface is documented here. Do not parse
window text, screenshots, or undocumented switches in unattended automation.

## Choosing a version signal

Use `winver.exe` for a human-readable confirmation. Use
`Win32_OperatingSystem` for typed operating-system identity and the documented
`HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion` values only when the
specific registry field and its applicability are understood. Record edition,
display version, full build/revision, architecture, and collection time when a
support or compatibility decision depends on them.

For application compatibility, prefer testing the required feature, API,
command, module, or capability directly. Microsoft recommends feature detection
over brittle equality checks against one remembered version number.

## Common mistakes

- Using `$PSVersionTable` as the Windows version; it identifies the PowerShell
  runtime and can differ while the operating system remains unchanged.
- Treating Windows 10 and Windows 11 as different Win32 major/minor versions;
  their product naming and build identity require more context.
- Comparing only a display version such as `24H2` while ignoring edition,
  build revision, architecture, servicing channel, or Server versus client.
- Parsing localized `systeminfo`, `ver`, `winver`, or window text when CIM or a
  documented registry value can provide a typed field.
- Gating a feature on an exact known build instead of checking that the actual
  API, command, module, role, feature, or optional capability is available.
- Assuming the reported build proves update compliance without checking the
  applicable servicing baseline and installed update inventory.

## PowerShell behavior

`Start-Process winver.exe` launches a GUI; it does not return version data.
`Get-CimInstance Win32_OperatingSystem` returns objects suitable for selection,
serialization, and comparison. If registry values are also collected, retain
their names and types rather than flattening them into an unlabeled string.

When querying another computer, record the target and transport explicitly and
do not silently fall back to the local computer after a remote query failure.

## Version and platform differences

`winver.exe` is Windows-only. Visible fields and terminology vary by Windows
client/server product, edition, build, servicing channel, and preview status.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\winver.exe`. Its fixed numeric file version was
`10.0.26100.1`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [msinfo32.exe](msinfo32.exe.md)
- [systeminfo.exe](systeminfo.exe.md)
- [ver](ver.md)
- [wmic.exe](wmic.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows version identification guide](https://learn.microsoft.com/windows/client-management/client-tools/windows-version-search),
[Windows versioning overview](https://learn.microsoft.com/windows/apps/get-started/versioning-overview),
and [operating-system version guidance](https://learn.microsoft.com/windows/win32/sysinfo/operating-system-version).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
