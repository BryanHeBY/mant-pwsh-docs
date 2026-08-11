<!-- mant:tldr:start -->
# powercfg.cpl

> Open Power Options for interactive plan inspection; use `powercfg.exe` with explicit scheme/subgroup/setting GUIDs for reproducible queries and distinguish configured values from effective hardware, policy, and runtime behavior.
> More information: https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items.

- Resolve the module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\powercfg.cpl')`

- Open Power Options through its canonical name:

`control.exe /name Microsoft.PowerOptions`

- Query the active power scheme without changing it:

`powercfg.exe /getactivescheme`
<!-- mant:tldr:end -->

# powercfg.cpl

## Overview

`powercfg.cpl` is the classic Power Options Control Panel module. It exposes
available plans and selected display, sleep, lid/button, wake, password, fast
startup, and advanced settings depending on device and policy.

The similarly named `powercfg.exe` is the supported native command-line tool.
Do not confuse launching the `.cpl` with running the `.exe` or assume a friendly
plan/setting name is stable identity.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `powercfg.cpl`: Open the classic Power Options module through shell association.
- `control.exe /name Microsoft.PowerOptions`: Open the canonical Power Options Control Panel item.

For automation, use `powercfg.exe` and preserve scheme, subgroup, and setting
GUIDs plus AC/DC indices. GUI visibility is not a complete settings inventory.

## Effective power behavior

Record active scheme/overlay, AC versus DC value, subgroup/setting GUID, hidden
settings, policy overrides, permissions, power requests/overrides, sleep states,
Modern Standby capability, hibernation/fast-startup state, firmware, drivers,
device hardware, workload, and measurement interval.

A configured timeout does not prove entry into a low-power state; active power
requests, devices, sessions, policy, firmware, or platform design can prevent it.

## Common mistakes

- Editing a similarly named plan rather than the active plan/GUID.
- Confusing minutes, seconds, percentages, indexes, AC/DC values, aliases, and
  hexadecimal values between interfaces.
- Disabling hibernation to diagnose sleep without accounting for Fast Startup,
  hiberfile, BitLocker/recovery, battery, and rollback effects.
- Assuming a missing advanced setting is unsupported rather than hidden, managed,
  hardware-dependent, or represented differently on Modern Standby systems.
- Setting a timeout while ignoring `powercfg /requests`, policy, and real energy/
  sleep reports.
- Using the GUI for mass configuration instead of policy/provisioning/deployment.

## PowerShell behavior

`Start-Process powercfg.cpl` opens a GUI. Invoke `powercfg.exe` explicitly, quote
paths, preserve GUID strings, and inspect `$LASTEXITCODE` before another native
command. Its output is text and can vary; avoid using display names as identity.

## Version and platform differences

`powercfg.cpl` is Windows-only. Plans, overlays, sleep states, settings, UI,
policy, Modern Standby, battery, firmware, and permission behavior vary by build,
edition, device class, hardware, drivers, and management authority.

## Related documents

- [powercfg.exe](powercfg.exe.md)
- [shutdown.exe](shutdown.exe.md)
- [gpedit.msc](gpedit.msc.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Control Panel execution guidance](https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items),
[PowerCfg options](https://learn.microsoft.com/windows-hardware/design/device-experiences/powercfg-command-line-options),
and [power-policy override guidance](https://learn.microsoft.com/windows/win32/power/administrator-overrides).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
