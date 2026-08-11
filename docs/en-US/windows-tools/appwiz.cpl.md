<!-- mant:tldr:start -->
# appwiz.cpl

> Open Programs and Features for interactive inventory or a reviewed uninstall; identify package technology, exact product, scope, version, source, dependencies, data, restart, and rollback before changing it.
> More information: https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names.

- Resolve the Control Panel module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\appwiz.cpl')`

- Open Programs and Features through its canonical Control Panel name:

`control.exe /name Microsoft.ProgramsAndFeatures`

- Inventory WinGet-visible installed packages without using the GUI:

`winget.exe list`
<!-- mant:tldr:end -->

# appwiz.cpl

## Overview

`appwiz.cpl` is the classic Programs and Features Control Panel module. It
displays uninstall/change entries registered for supported desktop products and
links to installed updates and Windows features. It is not a complete software
inventory, package database, or unattended uninstall API.

Store/MSIX apps, per-user installations, portable programs, drivers, optional
features, packages managed by another account, broken registrations, and
enterprise deployment state can differ from the visible list.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `appwiz.cpl`: Open the classic Programs and Features module through shell association.
- `control.exe /name Microsoft.ProgramsAndFeatures`: Open the canonical Programs and Features Control Panel item.

Prefer the canonical `control.exe /name` form for a documented launcher. Use the
owning package manager/deployment system for automation and postchange evidence.

## Package identity and behavior

Record publisher, product/package ID, exact version/architecture, install scope
and user, source, package technology, uninstall command ownership, dependencies,
services/tasks/drivers, data/configuration retention, policy, expected restart,
recovery media, and rollback before removal or repair.

An entry disappearing proves only a registration/view change. Verify files,
services, drivers, scheduled tasks, processes, packages, data, and the business
outcome with the owning technology.

## Common mistakes

- Treating the visible display name as unique identity or selecting a similarly
  named runtime, architecture, language pack, SDK, or dependency.
- Assuming this list contains every installed executable or every package scope.
- Scraping localized rows or automating uninstall dialogs instead of using MSI,
  WinGet, MSIX/Appx, DISM, vendor, or enterprise deployment interfaces.
- Using `Win32_Product` as general inventory, which can be slow/incomplete and
  may trigger installer consistency checks.
- Removing a shared runtime, driver, agent, or security product without checking
  dependents, tamper protection, credentials, restart, and recovery.
- Treating an uninstaller exit or vanished entry as complete removal.

## PowerShell behavior

`Start-Process appwiz.cpl` delegates to shell association and returns no package
objects. `control.exe` is a native process, so check process launch separately
from package outcome. Use the package-specific CLI/API for automation and retain
its stable identity and native status before any pipeline formatting.

## Version and platform differences

`appwiz.cpl` is Windows-only. Programs and Features content, Settings migration,
package types, feature links, policy, elevation, and uninstall UI vary by build,
edition, architecture, installed products, and current user.

## Related documents

- [winget.exe](winget.exe.md)
- [optionalfeatures.exe](optionalfeatures.exe.md)
- [msiexec.exe](msiexec.exe.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Control Panel canonical names](https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names)
and [Control Panel execution guidance](https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
