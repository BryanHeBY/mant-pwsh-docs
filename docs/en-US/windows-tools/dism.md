<!-- mant:tldr:start -->
# dism

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

# DISM

## Overview

Deployment Image Servicing and Management (`dism.exe`) inventories, mounts,
captures, applies, and services Windows images and the running system. Global
target selection such as `/Online` or `/Image:path` combines with a servicing
family such as `/Cleanup-Image`, `/Get-Features`, `/Get-Packages`,
`/Get-Capabilities`, `/Add-Driver`, or image-management operations.

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

- [sfc](sfc.md)
- [fondue](fondue.md)
- [pnputil](pnputil.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DISM overview](https://learn.microsoft.com/windows-hardware/manufacture/desktop/what-is-dism?view=windows-11),
[DISM command-line reference](https://learn.microsoft.com/windows-hardware/manufacture/desktop/deployment-image-servicing-and-management--dism--command-line-options?view=windows-11),
and [feature-servicing guidance](https://learn.microsoft.com/windows-hardware/manufacture/desktop/enable-or-disable-windows-features-using-dism?view=windows-11).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
