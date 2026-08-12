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

- Enumerate the connected device tree and include driver identities on supported builds:

`pnputil.exe /enum-devicetree /connected /drivers`
<!-- mant:tldr:end -->

# pnputil.exe

## Overview

`pnputil.exe` manages Windows Driver Store packages and, on newer Windows
versions, enumerates or operates on devices, interfaces, setup classes, device
trees, and containers. Command and filter availability varies substantially by
Windows release, and installed help can lead Microsoft's online version table.

## Operations and filters

<!-- mant:entries role=option case=insensitive -->
- `/enum-drivers`: Enumerate third-party Driver Store packages and their published names.
- `/add-driver INF`: Add one INF or a reviewed wildcard set to the Driver Store.
- `/delete-driver OEM-INF`: Delete one exact published package such as `oem42.inf`.
- `/export-driver`: Export one exact published package, or all third-party packages, to an explicit destination path.
- `/enum-devices`: Enumerate devices with supported class, instance, problem, connection, bus, or other filters.
- `/enum-interfaces`: Enumerate device interfaces and associated device-instance identities.
- `/enum-classes`: Enumerate device setup classes and optionally their services.
- `/enum-devicetree`: Enumerate the device tree from the root or one exact root device instance ID where supported.
- `/enum-containers`: Enumerate device containers and optionally their member devices where supported.
- `/disable-device`: Disable one exact device instance or a deliberately reviewed supported filtered set.
- `/enable-device`: Enable one exact device instance or a deliberately reviewed supported filtered set.
- `/restart-device`: Restart one exact device instance or a deliberately reviewed supported filtered set.
- `/remove-device`: Attempt to remove one exact device instance or a deliberately reviewed supported filtered set.
- `/scan-devices`: Request a Plug and Play hardware rescan.
- `/?`: Display the complete installed command interface; output can contain examples with real identity shapes but no current device values.
- `/subdirs`: Include INF files in subdirectories during a reviewed add-driver operation.
- `/install`: With add-driver, install/update matching devices only when normal driver ranking selects the package.
- `/uninstall`: With delete-driver, uninstall the package from devices using it before package deletion.
- `/force`: Override selected delete protections; this increases device and recovery risk.
- `/reboot`: Reboot if needed to complete a supported operation; do not use without restart coordination.
- `/files`: Include package files in supported driver enumeration output.
- `/ids`: Include driver-package and family IDs in supported driver enumeration output.
- `/devices`: Include devices using a package, or devices belonging to a container, in the applicable enumeration family.
- `/instanceid ID`: Select one exact Plug and Play device instance.
- `/deviceid ID`: Match a hardware or compatible ID; unlike an instance ID, it can select multiple devices.
- `/deviceids`: Display hardware and compatible IDs for enumerated devices; this plural display flag is distinct from `/deviceid ID`.
- `/class NAME`, `/class GUID`: Restrict supported device operations to a setup class.
- `/problem`, `/problem CODE`: Restrict enumeration to devices with any or one exact problem code.
- `/connected`, `/disconnected`: Restrict device enumeration by current connection state.
- `/drivers`: Include matching/installed driver information for enumerated devices.
- `/bus NAME`, `/bus GUID`: Restrict supported enumeration or operation to a bus identity.
- `/enabled`, `/disabled`: Restrict interface enumeration by current enabled state.
- `/relations`: Include parent and child relations for enumerated devices.
- `/services`: Include services for supported device, class, or tree enumeration.
- `/stack`: Include effective device stack information in supported device or tree enumeration.
- `/interfaces`: Include device interfaces in supported device or tree enumeration.
- `/properties`: Include device or interface properties where supported.
- `/resources`: Include device resources where supported.
- `/location`: Include device location information and paths where supported.
- `/subtree`: With remove-device, include every child device under the selected device.
- `/async`: Request an asynchronous Plug and Play scan instead of waiting for completion.
- `/containerid ID`: Select one exact device-container ID.
- `/format FORMAT`: Select `txt`, `xml`, or `csv` for enumeration families that expose structured formats on the installed build.
- `/output-file FILE`: Write supported formatted enumeration output to an optional explicit path; reject an existing path unless replacement is authorized.

## PowerShell boundaries

Call `pnputil.exe` explicitly and pass native path strings rather than
`FileInfo` objects. Output is versioned text, so preserve the raw inventory,
check `$LASTEXITCODE`, and re-query exact package/device identity after change.

Recent builds expose CSV/XML plus `/output-file` for several enumeration
families. Treat their fields as versioned installed interfaces rather than a
permanent schema, and preserve the command/build with the artifact. Hardware,
compatible, instance, container, interface, location, service, and driver IDs
can disclose host topology; redact them before sharing outside the approved
diagnostic boundary.

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

### Confusing `/instanceid`, `/deviceid`, and `/deviceids`

An instance ID selects one device instance. `/deviceid ID` matches a hardware
or compatible ID and can affect several devices. The plural `/deviceids` only
adds those IDs to enumeration output. Preserve the exact spelling, enumerate
the resulting set, and refuse a multi-device mutation unless that scope was
explicitly approved.

### Assuming an output path is a harmless display option

`/output-file` creates or replaces an artifact on supported builds. Resolve an
absolute protected path, reject an existing file by default, check free space
and ACLs, capture native status, and verify the final artifact. Prefer stdout
for exploratory inventory when durable output is not required.

### Copying new structured-output flags to older hosts

The recorded build exposed `/format` and `/output-file` on driver, device,
interface, class, and container enumeration, plus `/ids` and `/devices` on
driver enumeration. Microsoft's current online syntax page documents only a
subset. Gate automation on exact installed help and fail closed when a command
or field is absent; do not silently fall back to parsing a localized table.

### Missing System32 from a 32-bit host

File-system redirection can affect 32-bit processes. Confirm resolution with
`Get-Command pnputil.exe -All`; when an approved 32-bit automation host must
reach native 64-bit System32, use the documented `Sysnative` boundary rather
than copying the executable.

## Version and platform differences

PnPUtil ships with Windows Vista and later, but verbs and filters were added
across Windows 10 and Windows 11 releases. Query `pnputil /?` on the target and
consult the current version table. On Windows NT `10.0.26200.0`, installed file
version `10.0.26100.8521` returned 274 help lines and status 0 under an ordinary
token. Read-only CSV enumeration of drivers, devices, interfaces, classes, and
containers, plus device-tree text enumeration, also returned 0; only line
counts and headers were retained. This does not establish that mutations are
allowed without elevation. Most changes require an elevated approved context.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8521 help
returned 274 lines and status 0. Read-only CSV
driver/device/interface/class/container inventories and text device-tree
inventory also returned 0; only counts and headers were retained. Installed
/ids, /devices, /format and /output-file coverage exceeds the current online
syntax table, so those forms are build-gated. No driver, device, scan, reboot,
or output-file mutation ran.

## Related documents
- [driverquery.exe](driverquery.exe.md)
- [dism.exe](dism.exe.md)
- [systeminfo.exe](systeminfo.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[PnPUtil overview](https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil)
and [command syntax](https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil-command-syntax),
plus [examples](https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil-examples),
with the older Windows command page retained only for provenance comparison.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
