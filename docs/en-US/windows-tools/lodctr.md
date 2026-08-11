<!-- mant:tldr:start -->
# lodctr

> Inventory and back up Windows performance-counter provider registration before enabling, disabling, registering, restoring, or globally rebuilding anything.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/lodctr.

- Query all registered performance counter providers and enabled/disabled state:

`lodctr.exe /q`

- Query one exact service/provider registration:

`lodctr.exe /q:"{{service-name}}"`

- Save current counter registry settings to a new backup file before approved repair:

`lodctr.exe /s:"{{C:\Evidence\perf-registry-backup.ini}}"`

- Corroborate which counter paths actually enumerate and sample:

`typeperf.exe -q "{{object-name}}"`
<!-- mant:tldr:end -->

# lodctr

## Overview

`lodctr.exe` registers performance counter names/explain text and provider data,
queries/enables/disables providers, saves settings, and can restore/rebuild
counter registration. It is provider installation/repair tooling—not a generic
performance sampler or harmless “refresh counters” command.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `lodctr.exe`: Register, query, save, restore, enable, or disable performance
  counter provider registration according to installed syntax.

A bare filename loads legacy initialization data. Query/enable/disable forms
exist on many installed builds even though the current family page omits them.

<!-- mant:entries role=option case=insensitive -->
- `/q`: Query all providers or one exact service/provider registration.
- `/e`: Enable one registered counter provider where installed help supports it.
- `/d`: Disable one registered counter provider where installed help supports it.
- `/s`: Save current counter registry settings and explanation text to a file.
- `/r`: Rebuild from system caches or replace settings from a named file.
- `/t`: Mark the named service as trusted.
- `/?`: Display installed syntax; a zero exit code proves syntax only.

## Common mistakes

- Running `/r` globally for one invalid/localized/missing path. First verify
  counter spelling/language, provider/service/workload, architecture, permissions,
  Perflib/provider events, target product version, and vendor repair guidance.
- Treating `/r` or `/r:<file>` as merge-only. Preserve `/q`, service/product
  state, registry/system backup and rollback; other providers can be affected.
- Loading an untrusted/out-of-version INI or manifest. Use the signed product
  installer matching architecture/version and verify paths/files/ACLs/signatures.
- Enabling a provider whose service/product is removed, broken, unsupported, or
  intentionally disabled; counter availability still needs runtime validation.
- Assuming `/s` alone is a complete recoverable backup; test protected recovery
  under vendor/Microsoft guidance and preserve OS/product configuration.
- Confusing localized display names with service/provider identity, or expecting
  successful registration to make every instance/data source valid immediately.

## PowerShell boundaries

Use `lodctr.exe` explicitly with exact service/path arguments. Capture native
status, save/query before and after, then verify provider events, `typeperf -q`,
two-sample counter validity, product health, and restart/reboot requirements.

## Version and platform differences

`lodctr.exe` is Windows-only. Syntax, manifests/INI, Perflib version, provider
architecture, localization, backup/rebuild sources, permissions, and servicing
behavior vary by build and installed products. The current Microsoft Learn
command page omits query/enable/disable forms exposed by many installed builds;
check `lodctr.exe /?` on the exact target before relying on `/q`, `/e`, or `/d`.

## Related documents

- [unlodctr](unlodctr.md)
- [typeperf](typeperf.md)
- [logman](logman.md)
- [sc.exe](sc.md)

## Sources and license

This original guide was adapted from Microsoft's official
[lodctr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/lodctr)
and [performance-counter tools map](https://learn.microsoft.com/windows/win32/perfctrs/performance-counters-tools).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
