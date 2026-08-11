<!-- mant:tldr:start -->
# optionalfeatures

> Open Windows Features only after inventorying exact feature/capability names, online/offline target, state, payload source, dependencies, policy, download, servicing and restart requirements.
> More information: https://learn.microsoft.com/windows/client-management/client-tools/add-remove-hide-features.

- Open the classic Windows Features dialog:

`optionalfeatures.exe`

- Open the current Settings Optional features page:

`Start-Process 'ms-settings:optionalfeatures'`

- Inventory Windows optional-feature state as objects before considering a change:

`Get-WindowsOptionalFeature -Online`
<!-- mant:tldr:end -->

# optionalfeatures

## Overview

`optionalfeatures.exe` opens the classic Windows Features dialog. Modern Windows
also exposes Optional Features/Features on Demand in Settings. Windows optional
features, capabilities/FODs, packages, Server roles/features and winget features
are different inventories with different names, sources and servicing commands.

## Common mistakes

- Enabling a display label without resolving its exact feature/capability identity,
  current state, parent/dependencies, applicability and online/offline image target.
- Confusing `Enable-WindowsOptionalFeature`, `Add-WindowsCapability`, DISM package
  servicing, ServerManager roles and `winget features`; they are not substitutes.
- Assuming the UI is offline/self-contained. Feature payloads may require Windows
  Update, WSUS/UUP/FOD media, language/architecture/build match and network policy.
- Ignoring restart/pending servicing, component-store health, edition/license,
  security exposure, firewall/services and application compatibility.
- Removing payloads/features without rollback media and downstream dependency
  inventory, or treating hidden UI policy as the feature being disabled.
- Automating localized checkbox text instead of exact feature/capability names.

## PowerShell behavior

Use `Start-Process optionalfeatures.exe` only for interactive launch. For scripts,
inventory with `Get-WindowsOptionalFeature` and `Get-WindowsCapability`, select the
correct servicing API, capture restart-needed/native results, and re-query state.

## Version and platform differences

`optionalfeatures.exe` is Windows-only. Features, capabilities, payload sources,
UI location, servicing support and policy vary by client/server, edition, build,
architecture, language and mounted-image state.

## Related documents

- [dism](dism.md)
- [ms-settings](ms-settings.md)
- [winget](winget.md)
- [wsl](wsl.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Windows optional-feature management guide](https://learn.microsoft.com/windows/client-management/client-tools/add-remove-hide-features).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
