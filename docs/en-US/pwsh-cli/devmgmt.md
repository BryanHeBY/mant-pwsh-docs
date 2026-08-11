<!-- mant:tldr:start -->
# devmgmt

> Open Device Manager for an explicitly identified local computer; inventory device instance, driver package, status, problem code, dependencies, recovery, and rollback before enabling, disabling, uninstalling, updating, or rescanning.
> More information: https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/error-connect-device-manager-remotely.

- Open the Device Manager MMC snap-in:

`devmgmt.msc`

- Launch Device Manager explicitly through Microsoft Management Console:

`mmc.exe devmgmt.msc`
<!-- mant:tldr:end -->

# devmgmt

## Overview

Device Manager is an MMC interface for Plug and Play devices, device instances,
drivers, status/problem codes, resources and selected lifecycle actions. A friendly
device label is not a stable identity; use instance IDs, class, hardware IDs,
driver package/provider/version and parent/container relationships.

## Common mistakes

- Acting on a duplicate friendly name without resolving the exact instance ID,
  physical device, parent stack, boot/critical role and current problem code.
- Treating “Update driver” as a general updater, or assuming the newest version
  is compatible with OEM firmware, policy, device stack and rollback requirements.
- Uninstalling a device while assuming its driver package is also removed—or
  deleting a package without checking every device and dependent stack using it.
- Disabling storage, network, display, input, security or remote-access hardware
  without console access, recovery media, BitLocker keys and a rollback route.
- Using “Scan for hardware changes” as repair when power, firmware, cabling,
  enumeration, service, driver-store, signature or hardware failure is unresolved.
- Automating localized UI rather than `pnputil`, CIM/PnP cmdlets or SetupAPI.

## PowerShell behavior

Use `Start-Process mmc.exe -ArgumentList 'devmgmt.msc'` for interactive launch.
For automation, use the dedicated PnP/driver tools, capture exact instance/package
identity and before/after state, and verify device, service, event and workload health.

## Version and platform differences

`devmgmt.msc` is Windows-only. Actions, remote support, device classes, drivers,
problem codes, permissions and UI vary by Windows build, hardware and policy.

## Related documents

- [pnputil](pnputil.md)
- [driverquery](driverquery.md)
- [msinfo32](msinfo32.md)
- [compmgmt](compmgmt.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Device Manager remote-connection guidance](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/error-connect-device-manager-remotely).
Exact sources and licenses are recorded in `upstream/cli.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
