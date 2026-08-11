<!-- mant:tldr:start -->
# unlodctr

> Unregister one product's performance-counter names/text only during its supported uninstall/repair lifecycle, after exact registration inventory and backup.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/unlodctr.

- Inventory the exact service/provider before considering removal:

`lodctr.exe /q:"{{service-name}}"`

- Save current counter registry settings to a new protected backup file:

`lodctr.exe /s:"{{C:\Evidence\perf-registry-backup.ini}}"`

- Display target-host unregister syntax without changing registration:

`unlodctr.exe /?`

- Only in the supported product uninstall/repair workflow, unregister the exact legacy service counter text:

`unlodctr.exe "{{service-name}}"`
<!-- mant:tldr:end -->

# unlodctr

## Overview

`unlodctr.exe` removes performance counter names/explain text for a service from
the registry; manifest-based forms apply to matching provider registration.
This can break monitoring, alerts, dashboards, diagnostics, and product repair.
Use the product's signed uninstaller/repair whenever possible.

## Common mistakes

- Removing a similarly named service/provider from a guessed error message.
  Resolve service key, product/version/architecture, provider GUID/manifest/INI,
  files/signatures, consumers, and current `/q` state.
- Treating unregister as disabling collection temporarily. It changes provider
  registration and may require reinstall/repair/restart; use supported collection
  filters or provider enable/disable semantics instead.
- Running it to fix one localized/invalid counter path before testing target-
  language paths, service/workload state, permissions, provider events, and data.
- Assuming the backup guarantees rollback across product/OS versions. Preserve
  installer/media/configuration and test vendor-supported restore/repair.
- Removing active counters during monitoring/incident collection, producing
  gaps and misleading zeros/absence without coordinating every consumer.

## PowerShell behavior

Use `unlodctr.exe` explicitly with one exact service/provider. Capture output and
`$LASTEXITCODE`, then verify registration, counter enumeration/sampling, product/
service health, monitoring state, events, and rollback. Never loop across all
providers or derive names from localized `typeperf` text.

## Version and platform differences

`unlodctr.exe` is Windows-only. Legacy INI/service and manifest-provider forms,
architecture, localization, permissions, and supported uninstall/repair behavior
vary by Windows build and product.

## Related documents

- [lodctr](lodctr.md)
- [typeperf](typeperf.md)
- [logman](logman.md)

## Sources and license

This original guide was adapted from Microsoft's official
[unlodctr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/unlodctr)
and [performance-counter tools map](https://learn.microsoft.com/windows/win32/perfctrs/performance-counters-tools).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
