<!-- mant:tldr:start -->
# pnputil.exe

> Inventory Windows driver packages, devices, and interfaces before changing them.
> More information: https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil.

- Enumerate third-party Driver Store packages and their files where supported:

`pnputil.exe /enum-drivers /files`

- List connected devices that currently report a problem:

`pnputil.exe /enum-devices /connected /problem`

- Inspect one exact device instance before any device operation:

`pnputil.exe /enum-devices /instanceid "{{device-instance-id}}" /drivers`

- Enumerate device interfaces with their associated instance IDs:

`pnputil.exe /enum-interfaces /enabled`
<!-- mant:tldr:end -->

# pnputil.exe

## Overview

`pnputil.exe` manages Windows Driver Store packages and, on newer Windows
versions, enumerates or operates on devices and interfaces. Current verbs
include `/enum-drivers`, `/add-driver`, `/delete-driver`, `/export-driver`,
`/enum-devices`, `/disable-device`, `/enable-device`, `/restart-device`,
`/remove-device`, `/scan-devices`, and `/enum-interfaces`; availability varies
by Windows release.

## Operations and filters

<!-- mant:entries role=option case=insensitive -->
- `/enum-drivers`: Enumerate third-party Driver Store packages and their published names.
- `/add-driver INF`: Add one INF or a reviewed wildcard set to the Driver Store.
- `/delete-driver OEM-INF`: Delete one exact published package such as `oem42.inf`.
- `/export-driver OEM-INF PATH`: Export one or all third-party packages to an explicit destination.
- `/enum-devices`: Enumerate devices with supported class, instance, problem, connection, bus, or other filters.
- `/enum-interfaces`: Enumerate device interfaces and associated device-instance identities.
- `/disable-device`, `/enable-device`, `/restart-device`, `/remove-device`: Change one exactly selected device instance or supported filtered set.
- `/scan-devices`: Request a Plug and Play hardware rescan.
- `/enum-classes`, `/enum-containers`: Enumerate installed device setup classes or device containers where supported.
- `/subdirs`: Include INF files in subdirectories during a reviewed add-driver operation.
- `/install`: With add-driver, install/update matching devices only when normal driver ranking selects the package.
- `/uninstall`: With delete-driver, uninstall the package from devices using it before package deletion.
- `/force`: Override selected delete protections; this increases device and recovery risk.
- `/reboot`: Reboot if needed to complete a supported operation; do not use without restart coordination.
- `/files`: Include package files in supported driver enumeration output.
- `/instanceid ID`: Select one exact Plug and Play device instance.
- `/class NAME`, `/class GUID`: Restrict supported device operations to a setup class.
- `/problem`, `/problem CODE`: Restrict enumeration to devices with any or one exact problem code.
- `/connected`, `/disconnected`: Restrict device enumeration by current connection state.
- `/drivers`: Include matching/installed driver information for enumerated devices.
- `/bus NAME`, `/bus GUID`: Restrict supported enumeration or operation to a bus identity.
- `/enabled`, `/disabled`: Restrict interface enumeration by current enabled state.

## PowerShell boundaries

Call `pnputil.exe` explicitly and pass native path strings rather than
`FileInfo` objects. Output is versioned text, so preserve the raw inventory,
check `$LASTEXITCODE`, and re-query exact package/device identity after change.

## Common mistakes

### Confusing source INF and published Driver Store name

An input file such as `vendor.inf` can be published as `oem42.inf`. Enumerate
provider, class, version, signer, files, and devices; use the exact current
published name for deletion rather than guessing from the source filename.

### Believing `/install` forces a lower-ranked driver

Adding and installing a package does not force Windows to select it when it is
not the highest-ranked match. Verify the device's selected driver and ranking
rather than treating a successful import as activation.

### Expanding a wildcard without reviewing every INF

`/add-driver path\*.inf /subdirs` can stage many packages. Inventory the
resolved files, signatures, hardware applicability, versions, and source
before elevation; do not pass `FileInfo` objects where a native path string is
required.

### Combining delete, uninstall, and force casually

`/delete-driver` removes a package; `/uninstall` can remove it from using
devices, and `/force` can override in-use protections. Record affected device
instances, console/recovery access, replacement driver, BitLocker/restart
impact, and rollback before any combination.

### Using a friendly name as device identity

Friendly names are not unique. Use the exact device instance ID or supported
class/bus/device ID filters, re-query immediately before action, and verify
device status and selected driver afterward.

### Missing System32 from a 32-bit host

File-system redirection can affect 32-bit processes. Confirm resolution with
`Get-Command pnputil.exe -All`; when an approved 32-bit automation host must
reach native 64-bit System32, use the documented `Sysnative` boundary rather
than copying the executable.

## Version and platform differences

PnPUtil ships with Windows Vista and later, but verbs and filters were added
across Windows 10 and Windows 11 releases. Query `pnputil /?` on the target and
consult the current version table. Most changes require elevation.

## Related documents

- [driverquery.exe](driverquery.exe.md)
- [dism.exe](dism.exe.md)
- [systeminfo.exe](systeminfo.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[PnPUtil overview](https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil)
and [examples](https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil-examples),
with the older Windows command page retained only for provenance comparison.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
