<!-- mant:tldr:start -->
# devmgmt.msc

> Open Device Manager for an explicitly identified local computer; inventory device instance, driver package, status, problem code, dependencies, recovery, and rollback before enabling, disabling, uninstalling, updating, or rescanning.
> More information: https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/error-connect-device-manager-remotely.

- Open the Device Manager MMC snap-in:

`devmgmt.msc`

- Launch Device Manager explicitly through Microsoft Management Console:

`mmc.exe devmgmt.msc`
<!-- mant:tldr:end -->

# devmgmt.msc

## Overview

Device Manager is an MMC interface for Plug and Play devices, device instances,
drivers, status/problem codes, resources and selected lifecycle actions. A friendly
device label is not a stable identity; use instance IDs, class, hardware IDs,
driver package/provider/version and parent/container relationships.

## Entry points

<!-- mant:entries role=command case=insensitive -->
- `devmgmt.msc`: Open Device Manager for interactive device and driver inspection.
- `mmc.exe`: Host the Device Manager snap-in explicitly; it is not a device automation API.

Use stable instance/package identities and the supported PnP/driver tools for
changes that must be logged, repeated, verified, or rolled back.

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

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\devmgmt.msc`. It exposed no nonzero four-part
fixed file version through `FileVersionInfo`; the audit retains that as absent
rather than inventing `0.0.0.0`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [pnputil.exe](pnputil.exe.md)
- [driverquery.exe](driverquery.exe.md)
- [msinfo32.exe](msinfo32.exe.md)
- [compmgmt.msc](compmgmt.msc.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Device Manager remote-connection guidance](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/error-connect-device-manager-remotely).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
