<!-- mant:tldr:start -->
# ver

> Display Cmd's compact Windows version string; use typed inventory for edition,
> release label, build revision, architecture, or automation decisions.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ver.

- Display the version string from a clean child Cmd:

`cmd.exe /d /c ver`

- Get typed operating-system identity and build fields:

`Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture`

- Inspect servicing release/build fields, including UBR where present:

`Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Select-Object ProductName, DisplayVersion, CurrentBuildNumber, UBR`

- Inspect the PowerShell engine separately from Windows:

`$PSVersionTable | Format-List PSEdition, PSVersion, OS, Platform`

<!-- mant:tldr:end -->

# ver

## Overview

`ver` is a parameterless `cmd.exe` builtin that displays a compact operating-
system version string. It is useful for an immediate human-readable build clue,
but it is not a complete Windows inventory contract. Windows product name,
edition, feature-update label, base build, update build revision (UBR),
architecture, installation type, and servicing state are separate fields.

Windows 11 intentionally remains in the `10.0` OS version family, so a script
that equates the major/minor value with the marketed product name will
misclassify it. Prefer a capability check for feature gating; when inventory is
required, collect explicit typed fields and record their source.

## Common mistakes

### Classifying Windows 10 versus Windows 11 from `10.0`

Both can report `10.0`. Do not invent an `11.0` expectation or compare a
localized full line. Use supported product/build inventory appropriate to the
task, and keep build thresholds in reviewed data rather than scattering magic
numbers through scripts.

### Confusing build, UBR, release label, edition, and product name

`BuildNumber` alone omits the servicing revision. `DisplayVersion` is a release
label, not a kernel version, and can be absent on older systems. `ProductName`
and captions are presentation/inventory data, not proof that a capability is
installed. Store fields separately rather than synthesizing one ambiguous
"Windows version."

### Using `$PSVersionTable` as universal OS inventory

`PSVersion` and `BuildVersion` describe the PowerShell engine/runtime, not a
complete Windows servicing identity. The `OS` and `Platform` fields vary by
PowerShell edition/version. Use them for shell context and typed Windows sources
for Windows inventory.

### Parsing localized display text

`ver` and `systeminfo` are display commands whose surrounding labels may be
localized. Avoid token positions and `findstr` against English labels. CIM and
registry values are easier to consume, but still require null handling and
documented field semantics.

### Treating version detection as a feature test

Optional features, edition, policy, hardware, architecture, compatibility
layers, containers, remote target, and servicing can differ at the same build.
Resolve the executable/module/API or query the specific capability whenever
possible.

## PowerShell behavior

`ver` is not a PowerShell command. Invoke it through `cmd.exe /d /c ver`. In
PowerShell, capture typed CIM or registry properties rather than scraping the
Cmd line. Record whether a query describes the local host, a remote session's
host, a container, or an offline image.

## Version and platform differences

The Cmd builtin is available on supported Windows client and server releases.
Fields exposed through CIM, the registry, and `$PSVersionTable` vary across
Windows and PowerShell versions. Windows application version APIs can also be
affected by compatibility manifests; do not generalize an API caveat to every
inventory source or vice versa.

## Related documents

- [systeminfo](systeminfo.md)
- [cmd](cmd.md)
- [dism](dism.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Ver reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ver).
Real-world demand for build/UBR distinctions and a documented agent-generated
Windows 11 misclassification were cross-checked against
[build and UBR](https://superuser.com/questions/1287950/how-to-find-the-build-ubr-kernel-version-of-windows-10-using-command-line-c)
and [Windows 10/11 detection](https://superuser.com/questions/1890128/batch-file-how-to-check-if-windows-10-if-windows-11)
questions. Microsoft sources govern supported behavior. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
