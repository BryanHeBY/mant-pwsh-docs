<!-- mant:tldr:start -->
# dism.exe

> Inspect and service an explicit online or offline Windows image.
> More information: https://learn.microsoft.com/windows-hardware/manufacture/desktop/what-is-dism.

- List optional features in the running Windows installation:

`dism.exe /Online /Get-Features /Format:Table`

- List capabilities in the running Windows installation:

`dism.exe /Online /Get-Capabilities /Format:Table`

- Inspect one WIM's image names and indexes before mounting or servicing:

`dism.exe /Get-ImageInfo /ImageFile:"{{path-to-install.wim}}"`

- Check whether the running component store is already flagged as corrupted, without repairing it:

`dism.exe /Online /Cleanup-Image /CheckHealth`
<!-- mant:tldr:end -->

# dism.exe

## Overview

Deployment Image Servicing and Management (`dism.exe`) inventories, mounts,
captures, applies, and services Windows images and the running system. Global
target selection such as `/Online` or `/Image:path` combines with a servicing
family such as `/Cleanup-Image`, `/Get-Features`, `/Get-Packages`,
`/Get-Capabilities`, `/Add-Driver`, or image-management operations.

## Targets and operations

<!-- mant:entries role=option case=insensitive -->
- `/Online`: Target the currently running Windows installation.
- `/Image:PATH`: Target an offline Windows directory, not a WIM container path.
- `/ImageFile:FILE`: Select a WIM, ESD, or FFU container for image-management operations.
- `/Index:NUMBER`, `/Name:NAME`: Select one image in a multi-image container.
- `/Get-ImageInfo`: Enumerate images in a container or inspect one selected image.
- `/Mount-Image`: Mount one selected image at an explicit empty directory for servicing.
- `/Unmount-Image`: Unmount a mounted image with an explicit commit or discard decision.
- `/Commit-Image`: Save changes to a mounted image while leaving it mounted.
- `/Cleanup-Mountpoints`: Remove resources associated with corrupted mounts; it is not a general image repair command.
- `/Cleanup-Image`: Select component-store health, cleanup, or repair operations for the target image.
- `/CheckHealth`: Report whether corruption was already detected without scanning or repairing.
- `/ScanHealth`: Scan component-store health without repairing; it can take substantially longer than `CheckHealth`.
- `/RestoreHealth`: Scan and repair component-store corruption using configured or explicit sources.
- `/Source:PATH`: Specify one or more known-compatible repair sources for a supported servicing operation.
- `/LimitAccess`: Prevent DISM from contacting Windows Update as a repair source or backup source.
- `/Get-Features`, `/Enable-Feature`, `/Disable-Feature`: Inventory or change optional Windows features by exact feature name.
- `/Get-Capabilities`, `/Add-Capability`, `/Remove-Capability`: Inventory or change Windows capabilities by exact identity.
- `/Get-Packages`, `/Add-Package`, `/Remove-Package`: Inventory or service packages using exact package/path and target compatibility.
- `/Get-Drivers`, `/Add-Driver`, `/Remove-Driver`: Inventory or service offline driver packages; use PnPUtil for running-system device/Driver Store workflows.
- `/Format:FORMAT`: Select supported table or list display for operations that expose this option.
- `/LogPath:FILE`: Write the DISM log to an explicit path with adequate space and protected access.
- `/ScratchDir:PATH`: Select a scratch directory with sufficient local space for the operation.
- `/NoRestart`: Suppress an automatic restart where supported; it does not remove pending-restart requirements.

## PowerShell boundaries

Call `dism.exe` explicitly, pass colon-bearing options as single arguments,
and capture `$LASTEXITCODE` plus the DISM/CBS logs. Display tables are not a
stable object API, and completion can still leave a pending restart.

## Common mistakes

### Servicing the wrong image

`/Online` means the currently running Windows installation. `/Image:` points
to an offline Windows directory, while `/ImageFile:` identifies a WIM/ESD/FFU
container for image operations. Record the target, edition, architecture,
version, index/name, mount state, and command family before changing anything.

### Using an older DISM against a newer image

The host DISM cannot service Windows images newer than the version it supports.
Use tooling matched to the target image and verify the applicable Windows/ADK
documentation instead of treating syntax acceptance as compatibility.

### Running RestoreHealth as the first observation

`/RestoreHealth` changes the component store and may contact configured repair
sources or Windows Update. Start with `/CheckHealth` or an intentionally timed
`/ScanHealth`, preserve DISM/CBS evidence, and define `/Source` and
`/LimitAccess` according to organizational servicing policy.

### Losing a mounted image's changes

Mounted-image work must end with a deliberate `/Commit` or `/Discard` during
unmount. Verify mount status, open handles, scratch space, and output image;
never leave a production workflow dependent on an abandoned mount directory.

### Confusing features, capabilities, and packages

They use different identities and servicing verbs. Enumerate the correct
family, copy the exact name, account for dependencies and source payloads, and
query the result including pending-restart state.

### Treating progress or exit status as final health

Review the command result, DISM log, component/package state, pending restart,
and relevant application behavior. A completed command can still require a
restart or further SFC verification.

## Version and platform differences

DISM is Windows-only. Available commands depend on the host tool, target image,
Windows edition/version, WinPE/WinRE/online context, architecture, packages,
features, and mounted image type. Most servicing changes require elevation.

## Related documents

- [sfc.exe](sfc.exe.md)
- [fondue.exe](fondue.exe.md)
- [pnputil.exe](pnputil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DISM overview](https://learn.microsoft.com/windows-hardware/manufacture/desktop/what-is-dism?view=windows-11),
[DISM command-line reference](https://learn.microsoft.com/windows-hardware/manufacture/desktop/deployment-image-servicing-and-management--dism--command-line-options?view=windows-11),
and [feature-servicing guidance](https://learn.microsoft.com/windows-hardware/manufacture/desktop/enable-or-disable-windows-features-using-dism?view=windows-11).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
