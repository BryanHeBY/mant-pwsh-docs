<!-- mant:tldr:start -->
# fltmc.exe

> Inventory and administer Windows file-system minifilters and their instances.
> More information: https://learn.microsoft.com/windows-hardware/drivers/ifs/development-and-testing-tools.

- List loaded minifilter drivers and their altitudes:

`fltmc.exe filters`

- List filter instances attached to volumes:

`fltmc.exe instances`

- List volumes visible to Filter Manager:

`fltmc.exe volumes`
<!-- mant:tldr:end -->

# fltmc.exe

## Overview

`fltmc.exe` queries and controls the Windows Filter Manager (`FltMgr`) stack.
Antivirus, encryption, backup, cloud-file, virtualization, and other security or
storage products can install minifilters. Inventory is generally diagnostic;
load, unload, attach, and detach change kernel-driver state and can disrupt I/O.

## Syntax

```text
fltmc.exe [filters | instances | volumes | load | unload | attach | detach | help]
          [arguments]
```

## Commands

<!-- mant:entries role=command case=insensitive -->
- `filters`: List registered/loaded minifilters, instance counts, altitudes, and frame information.
- `instances`: List attached instances, optionally restricted by filter or volume.
- `volumes`: List volumes and Filter Manager volume identities.
- `load`: Load a registered minifilter service by name.
- `unload`: Request unload of a minifilter by name; a driver can refuse or lack an unload callback.
- `attach`: Attach a filter instance to a volume, optionally naming the instance and altitude.
- `detach`: Detach one filter instance from a volume.
- `help`: Display top-level or command-specific installed help.

## Selection options

<!-- mant:entries role=option case=insensitive -->
- `-f FILTER`: Restrict instance inventory to one minifilter name where supported.
- `-v VOLUME`: Restrict instance inventory to one volume identity where supported.
- `-i INSTANCE`: Select or name a filter instance for an attach/detach operation where supported.
- `-a ALTITUDE`: Select an instance altitude for an attach operation where supported.
- `/?`: Display the exact grammar implemented by this Windows build.

The position and availability of `-f`, `-v`, `-i`, and `-a` are command-
specific. Run `fltmc.exe help COMMAND` before a mutation and use the exact
filter/volume/instance strings from read-only inventory.

## Read-only inventory

Capture all three correlated views from an elevated diagnostic session:

```powershell
$filters = fltmc.exe filters 2>&1
$filterCode = $LASTEXITCODE
$instances = fltmc.exe instances 2>&1
$instanceCode = $LASTEXITCODE
$volumes = fltmc.exe volumes 2>&1
$volumeCode = $LASTEXITCODE

[pscustomobject]@{
    FilterExitCode = $filterCode
    InstanceExitCode = $instanceCode
    VolumeExitCode = $volumeCode
    Filters = $filters
    Instances = $instances
    Volumes = $volumes
}
```

Altitudes determine minifilter attachment ordering; a numerically observed
altitude is not enough to identify owner, purpose, supported load order, or
whether it is safe to detach. Correlate the service, signed driver file,
publisher documentation, product health, and registered altitude range.

## Mutation boundary

Do not unload or detach an unfamiliar filter merely because it appears near a
suspected I/O failure. A filter may protect data integrity/security or maintain
state across operations. Obtain vendor/support guidance, quiesce dependent
workloads, confirm the exact volume and instance, establish console recovery and
rollback, and reproduce on a disposable or failover-protected fixture first.

Loading a service does not guarantee that it attaches to every volume; unloading
can be refused by the driver's `FilterUnloadCallback` policy. Never work around
that refusal by deleting services or driver files on a live system.

## PowerShell considerations

Output is fixed-width localized native text, not objects. Check
`$LASTEXITCODE` after every call and preserve raw output for support. Do not
split columns on spaces for durable automation because filter and volume display
formats can change across builds.

## Common mistakes

### Confusing altitude with priority or trust

Altitude establishes attachment order within Filter Manager ranges. It does
not rank quality, privilege, legitimacy, or performance impact.

### Unloading antivirus or encryption filters as a quick test

This changes a security/data path and can leave files unprotected or
inaccessible. Use vendor-approved diagnostic modes and a controlled fixture.

### Guessing a drive letter for attach/detach

Use the exact volume identity and current instance inventory shown by the
target build; mount points and underlying volumes are not interchangeable.

## Version and availability

Filter Manager ships with supported Windows, but installed commands, output,
filters, dynamic attach/unload support, privileges, and product policy vary.
The target's `fltmc.exe help` and minifilter vendor documentation define the
applicable contract.

## Verification boundary

Microsoft Filter Manager tooling and load/unload contracts were reviewed. No
Windows filter, instance, altitude, volume, service, or driver file was queried,
loaded, unloaded, attached, or detached.

## Related documents

- [driverquery.exe](driverquery.exe.md)
- [sc.exe](sc.exe.md)
- [fsutil.exe](fsutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Filter Manager development and testing tools](https://learn.microsoft.com/windows-hardware/drivers/ifs/development-and-testing-tools),
[minifilter loading and unloading](https://learn.microsoft.com/windows-hardware/drivers/ifs/loading-and-unloading),
and altitude guidance. Exact upstream revisions and paths are recorded in
`upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
