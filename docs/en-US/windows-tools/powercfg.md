<!-- mant:tldr:start -->
# powercfg

> Inventory the active power scheme, effective settings, supported sleep states, and current blockers before changing power, hibernation, wake, device, override, or security configuration.
> More information: https://learn.microsoft.com/windows-hardware/design/device-experiences/powercfg-command-line-options.

- Show the active power scheme and exact GUID:

`powercfg.exe /getactivescheme`

- List installed power schemes without changing the active scheme:

`powercfg.exe /list`

- Query all effective settings in the active scheme:

`powercfg.exe /query`

- Show current application/driver requests preventing display or system sleep:

`powercfg.exe /requests`

- Show sleep states supported or unavailable on this exact hardware/firmware/build:

`powercfg.exe /availablesleepstates`

- Write battery history to a new explicit report and verify the resulting file:

`powercfg.exe /batteryreport /output "{{C:\Evidence\battery-report.html}}"`
<!-- mant:tldr:end -->

# powercfg

## Overview

`powercfg.exe` inventories and controls Windows power schemes, AC/DC settings,
sleep states, hibernation, wake devices/timers, power requests/overrides, and
diagnostic reports. Many commands mutate system-wide policy or boot/sleep
behavior; a successful command does not prove the hardware honors the setting.

## Common mistakes

- Copying scheme/setting GUIDs or aliases without querying the target; OEM,
  policy, overlay, hidden settings, active scheme, and AC/DC context can differ.
- Changing timeout values without units and power-source context, then forgetting
  to activate/verify the intended scheme and effective policy.
- Adding `/requestsoverride` to silence a blocker instead of fixing the caller;
  overrides can permit sleep during recording, updates, transfers, or services.
- Running `/energy` under normal workload. Microsoft recommends an idle system;
  bound duration/output and treat findings as diagnostic signals, not verdicts.
- Reusing a default report path or trusting launch/status when an existing file
  blocks creation. Use a new path and verify timestamp, content, host, and hash.
- Publishing battery/sleep reports without review; they can reveal device,
  usage, application, identity, timing, and energy-history information.
- Disabling hibernation casually: it affects hibernate and can affect Fast Startup.
  Wake/device changes can break manageability or cause unexpected wakeups.

## PowerShell behavior

Use `powercfg.exe` explicitly; capture native streams/status and do not parse
localized tables as invariant objects. Preserve `/getactivescheme`, `/list`,
`/query`, `/requests`, `/requestsoverride`, `/a`, wake inventory, report path and
policy source before mutation, then re-query and test AC/DC/sleep/wake behavior.

## Version and platform differences

`powercfg.exe` is Windows-only. Options such as SleepStudy, system power reports,
Modern Standby diagnostics, overlays/profiles and device controls depend on build,
hardware, firmware, drivers, edition, power source, OEM configuration and policy.

## Related documents

- [shutdown](shutdown.md)
- [systeminfo](systeminfo.md)
- [driverquery](driverquery.md)
- [wevtutil](wevtutil.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Powercfg command-line options](https://learn.microsoft.com/windows-hardware/design/device-experiences/powercfg-command-line-options).
Report-output failure demand was cross-checked against a practitioner question
about [battery and sleep reports not being produced](https://superuser.com/questions/1472017/powercfg-wont-produce-battery-report-or-sleep-study).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
