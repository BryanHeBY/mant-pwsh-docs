<!-- mant:tldr:start -->
# pnpunattend

> Search configured unattended driver paths without installing anything; omitting `/s` turns the audit into online driver installation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pnpunattend.

- Resolve the exact native tool without changing driver state:

`Get-Command pnpunattend.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Display installed syntax:

`pnpunattend.exe /?`

- Search for applicable drivers without installing and include log information:

`pnpunattend.exe auditsystem /s /l; $LASTEXITCODE`

- Correlate the result with signed Driver Store inventory:

`pnputil.exe /enum-drivers /files`
<!-- mant:tldr:end -->

# pnpunattend

## Overview

`pnpunattend.exe auditsystem` searches configured locations for applicable
device drivers and, by default, can install them online. `/s` changes the action
to search-only; `/l` displays log information. It is not a recursive arbitrary-
folder scanner supplied on the command line.

## Common mistakes

### Omitting `/s` from an “audit” command

The subcommand name is misleading: `auditsystem` specifies online installation.
Use `/s` for discovery. For any real install, snapshot device/driver identity,
verify the package and create an approved recovery/reboot plan first.

### Copying Windows 7 registry/PATH prerequisites onto current systems blindly

The official page mixes legacy preparation guidance with a broad modern
applicability banner. Inspect the affected build's installed help and existing
unattended driver-path configuration; do not persist global PATH/registry
changes merely to make a documentation example work.

### Trusting a driver folder by filename or INF presence

Verify catalog signature/publisher, hardware IDs, architecture, OS/build,
version/date and all referenced files. A signed but vulnerable, older or wrong-
device driver can still destabilize or weaken the host.

### Treating a search result as proof of the selected driver or install outcome

Driver ranking, policy, current package, device state and reboot/pending actions
still matter. Correlate SetupAPI/device events and `pnputil` inventory before
and after an approved install.

### Using it instead of current Driver Store lifecycle tooling

Use `pnputil.exe` for explicit package/device inventory and supported modern
driver operations. Preserve `pnpunattend` for an existing unattended workflow
whose configured search paths and deployment pass are understood.

## PowerShell behavior

Call `pnpunattend.exe` explicitly and capture `$LASTEXITCODE`. `/s` means search
without install, not silent; `/l` emits human-oriented log text. Do not parse
localized text as a stable driver-selection API.

## Version and platform differences

Windows-only. Microsoft's prerequisites explicitly reference Windows 7, while
the header lists current Windows versions. Driver search paths, ranking,
signing enforcement and device-install policy vary by build and deployment
phase; validate the exact environment.

## Related documents

- [pnputil](pnputil.md)
- [driverquery](driverquery.md)
- [devmgmt](devmgmt.md)
- [dism](dism.md)

## Sources and license

This original guide was adapted from Microsoft's official
[pnpunattend reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pnpunattend).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
