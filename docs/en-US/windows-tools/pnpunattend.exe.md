<!-- mant:tldr:start -->
# pnpunattend.exe

> Search configured unattended driver paths without installing anything; omitting `/s` turns the audit into online driver installation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pnpunattend.

- Resolve the exact native tool without changing driver state:

`Get-Command pnpunattend.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersionFixed';Expression={$_.FileVersionInfo.FileVersionRaw.ToString()}},@{Name='FileVersionString';Expression={$_.FileVersionInfo.FileVersion}}`

- Display installed syntax:

`pnpunattend.exe /?`

- Search for applicable drivers without installing and include log information:

`pnpunattend.exe auditsystem /s /l; $LASTEXITCODE`

- Correlate the result with signed Driver Store inventory:

`pnputil.exe /enum-drivers /files`
<!-- mant:tldr:end -->

# pnpunattend.exe

## Overview

`pnpunattend.exe auditsystem` searches configured locations for applicable
device drivers and, by default, can install them online. `/s` changes the action
to search-only; `/l` displays log information. It is not a recursive arbitrary-
folder scanner supplied on the command line.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `pnpunattend.exe`: Audit configured unattended-driver paths and optionally install matches.
- `auditsystem`: Search configured paths and, by default, install matching drivers online.

Search-only behavior requires `/s`; the subcommand name alone is not read-only.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Search only and suppress online driver installation.
- `/l`: Display human-oriented driver-search log information.
- `/help`, `/?`, `/h`: Display installed syntax. All three installed spellings
  return help status 87 on the recorded build, so classify the payload as well
  as the native status.

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

## PowerShell boundaries

Call `pnpunattend.exe` explicitly and capture `$LASTEXITCODE`. `/s` means search
without install, not silent; `/l` emits human-oriented log text. Do not parse
localized text as a stable driver-selection API.

## Version and platform differences

Windows-only. Microsoft's prerequisites explicitly reference Windows 7, while
the header lists current Windows versions. Driver search paths, ranking,
signing enforcement and device-install policy vary by build and deployment
phase; validate the exact environment.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 PnPUnattend file version
10.0.26100.1 /?, /help and /h each returned eight nonempty localized stdout
lines/status 87; /help and /h output was byte-identical and documented
auditsystem, /s and /L. The page indexes all three help aliases. Only help ran;
no auditSystem search, driver-path/PATH/registry, staging/install, device,
policy, reboot or removal mutation occurred.

## Related documents
- [pnputil.exe](pnputil.exe.md)
- [driverquery.exe](driverquery.exe.md)
- [devmgmt.msc](devmgmt.msc.md)
- [dism.exe](dism.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[pnpunattend reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pnpunattend).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
