<!-- mant:tldr:start -->
# dism.exe

> Inspect and service an explicit online or offline Windows image.
> Use an elevated console; the recorded client build privilege-gates even `/?`.
> More information: https://learn.microsoft.com/windows-hardware/manufacture/desktop/what-is-dism.

- List optional features in the running Windows installation:

`dism.exe /Online /Get-Features /Format:Table`

- Inspect the exact Windows Sandbox optional-feature identity without changing it:

`dism.exe /Online /Get-FeatureInfo /FeatureName:Containers-DisposableClientVM`

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

Elevation can be required before DISM parses the requested operation. On the
recorded Windows client build, ordinary-token `dism.exe /?` returned 740
(`ERROR_ELEVATION_REQUIRED`) instead of help; that is an access result, not an
image-health result.

<!-- mant:entries role=command case=insensitive -->
- `dism.exe`: Inspect or service an explicitly selected online installation, offline Windows directory, or image container.

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
- `/Get-Features`, `/Get-FeatureInfo`, `/Enable-Feature`, `/Disable-Feature`: Inventory or change optional Windows features by exact feature name.
- `/FeatureName:NAME`: Select one exact optional-feature identity for a feature operation.
- `/All`: With `/Enable-Feature`, enable required parent features with their default values.
- `/Get-Capabilities`, `/Add-Capability`, `/Remove-Capability`: Inventory or change Windows capabilities by exact identity.
- `/Get-Packages`, `/Add-Package`, `/Remove-Package`: Inventory or service packages using exact package/path and target compatibility.
- `/Get-Drivers`, `/Add-Driver`, `/Remove-Driver`: Inventory or service offline driver packages; use PnPUtil for running-system device/Driver Store workflows.
- `/Format:FORMAT`: Select supported table or list display for operations that expose this option.
- `/LogPath:FILE`: Write the DISM log to an explicit path with adequate space and protected access.
- `/ScratchDir:PATH`: Select a scratch directory with sufficient local space for the operation.
- `/NoRestart`: Suppress an automatic restart where supported; it does not remove pending-restart requirements.
- `/?`: Request help for the current DISM context; the recorded build required elevation before showing even top-level help.

## PowerShell boundaries

Call `dism.exe` explicitly, pass colon-bearing options as single arguments,
and capture `$LASTEXITCODE` plus the DISM/CBS logs. Display tables are not a
stable object API, and completion can still leave a pending restart.

Record token elevation before classifying output. Exit 740 with the explicit
elevation diagnostic means DISM did not reach the requested help or servicing
operation; do not parse it as an empty feature list or component-store result.

## Optional-feature workflow

Use `/Get-Features` to discover identities and `/Get-FeatureInfo` to inspect one
exact feature before changing it. Display names from Settings or the Windows
Features dialog are not servicing identities. For example, the Windows Sandbox
feature is `Containers-DisposableClientVM`:

```powershell
$queryArguments = @(
    '/Online'
    '/Get-FeatureInfo'
    '/FeatureName:Containers-DisposableClientVM'
)

& dism.exe @queryArguments
if ($LASTEXITCODE -ne 0) {
    throw "DISM feature query failed with exit code $LASTEXITCODE."
}
```

The corresponding mutation targets the running installation and requires an
approved elevated session. Do not combine it with an unexplained pending
restart. `/All` enables required parents; `/NoRestart` leaves restart timing to
the caller but does not make the completed change immediately usable:

```powershell
$enableArguments = @(
    '/Online'
    '/Enable-Feature'
    '/FeatureName:Containers-DisposableClientVM'
    '/All'
    '/NoRestart'
)

& dism.exe @enableArguments
$enableExitCode = $LASTEXITCODE
"DISM exit code: $enableExitCode"
```

Preserve the complete native output and inspect the DISM/CBS logs when the
result is not unambiguously successful. After a deliberate restart, repeat the
`/Get-FeatureInfo` query and verify the application or command separately; a
successful servicing invocation alone is not proof that `wsb.exe` is present.

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

### Guessing a feature identity from its display name

The UI label `Windows Sandbox` is not accepted as the servicing identity used
by the command examples. Discover or verify the exact
`Containers-DisposableClientVM` name before enabling it, and do not generalize
that identity to a different Windows edition or image without querying the
target.

### Treating progress or exit status as final health

Review the command result, DISM log, component/package state, pending restart,
and relevant application behavior. A completed command can still require a
restart or further SFC verification.

### Reading error 740 as image corruption

`ERROR_ELEVATION_REQUIRED` is a host access failure. Preserve the arguments,
complete native output, token context, and `$LASTEXITCODE`; rerun only in an
approved elevated context. Do not infer anything about the online or offline
image from a command that privilege checks rejected.

## Version and platform differences

DISM is Windows-only. Available commands depend on the host tool, target image,
Windows edition/version, WinPE/WinRE/online context, architecture, packages,
features, and mounted image type. Elevation can be required for help and
inventory as well as changes. On Windows NT `10.0.26200.0`, installed
`dism.exe` file version `10.0.26100.8457` returned 740 and an explicit
elevation message for ordinary-token `/?`; no target or servicing operation
was supplied.

## Runtime evidence

On Windows NT 10.0.26200.0, installed DISM file version 10.0.26100.8457
returned 740 (ERROR_ELEVATION_REQUIRED) before showing ordinary-token /? help.
No image target, inventory, mount, cleanup, repair, feature, capability,
package, driver, commit, discard, log, or scratch operation ran.

## Related documents
- [sfc.exe](sfc.exe.md)
- [fondue.exe](fondue.exe.md)
- [pnputil.exe](pnputil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DISM overview](https://learn.microsoft.com/windows-hardware/manufacture/desktop/what-is-dism?view=windows-11),
[DISM command-line reference](https://learn.microsoft.com/windows-hardware/manufacture/desktop/deployment-image-servicing-and-management--dism--command-line-options?view=windows-11),
and [feature-servicing guidance](https://learn.microsoft.com/windows-hardware/manufacture/desktop/enable-or-disable-windows-features-using-dism?view=windows-11).
The Windows Sandbox example additionally uses Microsoft's
[installation guidance](https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
