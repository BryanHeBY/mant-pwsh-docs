<!-- mant:tldr:start -->
# powercfg.exe

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

# powercfg.exe

## Overview

`powercfg.exe` inventories and controls Windows power schemes, AC/DC settings,
sleep states, hibernation, wake devices/timers, power requests/overrides, and
diagnostic reports. Many commands mutate system-wide policy or boot/sleep
behavior; a successful command does not prove the hardware honors the setting.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `powercfg.exe`: Inspect or change Windows power policy and produce supported
  power diagnostics.

Each slash command has its own argument contract. Run `powercfg.exe /? command`
on the target before using a build-dependent or mutating family.

<!-- mant:entries role=option case=insensitive -->
- `/list`: List installed power schemes and identify the active one; alias `/l`.
- `/query`: Display settings for a scheme or subgroup; alias `/q`.
- `/change`: Change one timeout value in the active scheme, in minutes; alias `/x`.
- `/changename`: Change a scheme's name and optional description.
- `/duplicatescheme`: Clone an existing power scheme.
- `/delete`: Delete a power scheme; alias `/d`.
- `/deletesetting`: Delete one power setting from a scheme.
- `/setactive`: Make one scheme active; alias `/s`.
- `/getactivescheme`: Display the active scheme and GUID.
- `/setacvalueindex`: Set a setting value used while connected to AC power.
- `/setdcvalueindex`: Set a setting value used while on DC/battery power.
- `/import`: Import power settings from a file, optionally under a chosen GUID.
- `/export`: Export one power scheme to a file.
- `/aliases`: Display recognized aliases and their GUIDs.
- `/getsecuritydescriptor`: Display the security descriptor for a supported
  power setting, scheme, or action.
- `/setsecuritydescriptor`: Replace a supported power object's security descriptor.
- `/hibernate`: Enable, disable, size, or select the hibernation-file type; alias `/h`.
- `/availablesleepstates`: Display supported and unavailable sleep states; alias `/a`.
- `/devicequery`: List devices matching a documented wake or power capability.
- `/deviceenablewake`: Allow one exact device to wake the system.
- `/devicedisablewake`: Remove wake permission from one exact device.
- `/lastwake`: Report information recorded for the most recent wake transition.
- `/waketimers`: List active wake timers.
- `/requests`: List current power requests from applications and drivers.
- `/requestsoverride`: List, create, or remove a power-request override.
- `/energy`: Trace an idle interval and write an energy-efficiency report.
- `/batteryreport`: Write a battery usage and capacity report.
- `/sleepstudy`: Write a Modern Standby session report where supported.
- `/srumutil`: Export System Resource Usage Monitor energy-estimation data.
- `/systemsleepdiagnostics`: Write a report about recent sleep-transition eligibility.
- `/systempowerreport`: Write a system power-transition report where supported.
- `/powerthrottling`: Inspect or change per-application power-throttling policy.
- `/setacprofileindex`: Set an AC value in an overlay/profile setting where supported.
- `/setdcprofileindex`: Set a DC value in an overlay/profile setting where supported.
- `/listprofiles`: List nonempty processor power-management profiles; alias `/lp`.
- `/pxml`: Generate provisioning XML for supported runtime power overrides.
- `/?`: Display top-level or command-specific installed help.

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

## PowerShell boundaries

Use `powercfg.exe` explicitly; capture native streams/status and do not parse
localized tables as invariant objects. Preserve `/getactivescheme`, `/list`,
`/query`, `/requests`, `/requestsoverride`, `/a`, wake inventory, report path and
policy source before mutation, then re-query and test AC/DC/sleep/wake behavior.

## Version and platform differences

`powercfg.exe` is Windows-only. Options such as SleepStudy, system power reports,
Modern Standby diagnostics, overlays/profiles and device controls depend on build,
hardware, firmware, drivers, edition, power source, OEM configuration and policy.

## Related documents

- [shutdown.exe](shutdown.exe.md)
- [systeminfo.exe](systeminfo.exe.md)
- [driverquery.exe](driverquery.exe.md)
- [wevtutil.exe](wevtutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Powercfg command-line options](https://learn.microsoft.com/windows-hardware/design/device-experiences/powercfg-command-line-options).
Report-output failure demand was cross-checked against a practitioner question
about [battery and sleep reports not being produced](https://superuser.com/questions/1472017/powercfg-wont-produce-battery-report-or-sleep-study).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
