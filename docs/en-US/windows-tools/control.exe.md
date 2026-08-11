<!-- mant:tldr:start -->
# control.exe

> Open Control Panel or a named Control Panel item from an interactive Windows session.
> More information: https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items.

- Open Control Panel:

`control.exe`

- Open a canonical Control Panel item:

`control.exe /name {{Microsoft.ProgramsAndFeatures}}`

- Open a documented subpage of a canonical item:

`control.exe /name {{canonical-name}} /page {{page-name}}`
<!-- mant:tldr:end -->

# control.exe

## Overview

`control.exe` opens the legacy Control Panel shell or a specific Control Panel
item. On Windows Vista and later, Microsoft recommends canonical item names for
command-line launch because they are stable, nonlocalized identifiers that do
not depend on the underlying `.cpl`, DLL, or executable implementation.

This is a GUI launcher. It does not provide a supported general interface for
reading or changing every value displayed by Control Panel.

## Syntax

```text
control.exe
control.exe /name CANONICAL-NAME
control.exe /name CANONICAL-NAME /page PAGE-NAME
control.exe MODULE.cpl[,TAB]
```

Use legacy `.cpl` module or tab syntax only when the current official product
documentation requires it. Canonical names are preferred for modern scripts.

## Important options

<!-- mant:entries role=option case=insensitive -->
- `/name CANONICAL-NAME`: Open one nonlocalized Control Panel item by its documented canonical name.
- `/page PAGE-NAME`: With `/name`, request a documented subpage owned by that Control Panel item.

## Common canonical items

<!-- mant:entries role=command case=insensitive -->
- `Microsoft.ProgramsAndFeatures`: Open installed-program management where the Control Panel item remains available.
- `Microsoft.PowerOptions`: Open power-plan settings supported by the target Windows build and hardware.
- `Microsoft.NetworkAndSharingCenter`: Open the legacy network and sharing UI where available.
- `Microsoft.CredentialManager`: Open the interactive Credential Manager UI for the current desktop session.
- `Microsoft.DevicesAndPrinters`: Open the devices and printers shell item where the target release exposes it.

## Canonical names

Canonical names are always English, even on a localized system. Examples in
Microsoft's catalog include:

- `Microsoft.ProgramsAndFeatures`
- `Microsoft.PowerOptions`
- `Microsoft.NetworkAndSharingCenter`
- `Microsoft.CredentialManager`
- `Microsoft.DevicesAndPrinters`

Not every item exists on every Windows version, edition, hardware
configuration, or server installation. Some older names are deprecated or
remapped for compatibility.

## PowerShell boundaries

Use `control.exe` explicitly and pass `/name` and its canonical name as
separate arguments. Process creation or window appearance does not return the
selected configuration as a PowerShell object and cannot verify a user action.

## Common mistakes

### Treating visible labels as canonical names

The localized text shown in Control Panel is not the command identifier. Copy a
canonical name from Microsoft's catalog and preserve its English spelling.

### Assuming the opened page is still implemented by Control Panel

Windows continues to move settings to the Settings app. A legacy canonical
name can be absent, remapped, or open a different UI. Use [ms-settings](ms-settings.md)
when Microsoft documents an appropriate Settings URI.

### Treating launch as configuration success

`control.exe` returning or opening a window does not prove that a user changed
a setting. Use a supported management API, PowerShell cmdlet, policy provider,
or configuration service when state must be read, enforced, and verified.

### Depending on numbered legacy tabs

Tab numbers and legacy module layouts have changed across Windows versions.
Avoid commands such as `control.exe module.cpl,,N` unless the exact target
release documents and tests that contract.

## Version and platform differences

`control.exe` is Windows-only and requires an interactive shell for useful GUI
operation. Canonical names are supported from Windows Vista onward, but item
availability varies by client/server version, SKU, feature, and hardware.

## Related documents

- [ms-settings](ms-settings.md)
- [mmc.exe](mmc.exe.md)
- [explorer.exe](explorer.exe.md)
- [reg.exe](reg.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official references for
[executing Control Panel items](https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items)
and [Control Panel canonical names](https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names).
The exact checked pages and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
