<!-- mant:tldr:start -->
# pnputil

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

# pnputil

## Overview

`pnputil.exe` manages Windows Driver Store packages and, on newer Windows
versions, enumerates or operates on devices and interfaces. Current verbs
include `/enum-drivers`, `/add-driver`, `/delete-driver`, `/export-driver`,
`/enum-devices`, `/disable-device`, `/enable-device`, `/restart-device`,
`/remove-device`, `/scan-devices`, and `/enum-interfaces`; availability varies
by Windows release.

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

- [driverquery](driverquery.md)
- [dism](dism.md)
- [systeminfo](systeminfo.md)

## Sources and license

This original guide was adapted from Microsoft's current
[PnPUtil overview](https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil)
and [examples](https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil-examples),
with the older Windows command page retained only for provenance comparison.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
