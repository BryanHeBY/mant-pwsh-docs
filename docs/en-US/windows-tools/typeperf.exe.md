<!-- mant:tldr:start -->
# typeperf.exe

> Discover target-localized Windows performance counter paths and collect a bounded series with explicit interval, count, host, and output provenance.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/typeperf.

- List available performance objects/counters on the local host:

`typeperf.exe -q`

- List expanded paths including current instances:

`typeperf.exe -qx`

- Collect five one-second samples for one exact target-localized counter path:

`typeperf.exe "{{\Processor(_Total)\% Processor Time}}" -si {{1}} -sc {{5}}`

- Write a bounded binary counter log to a new explicit path for later Relog analysis:

`typeperf.exe "{{\Processor(_Total)\% Processor Time}}" -si {{1}} -sc {{60}} -f BIN -o "{{C:\Evidence\cpu.blg}}"`
<!-- mant:tldr:end -->

# typeperf.exe

## Overview

`typeperf.exe` enumerates PDH performance counter paths and samples selected
counters to console or CSV/TSV/BIN/SQL output. Counter object/name and instance
text is commonly localized and availability depends on provider/service/workload.
Discovery on one machine is not proof the same path works elsewhere.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `typeperf.exe`: Enumerate or sample Windows PDH performance counters.

Without `-sc`, sampling continues until interrupted. Counter paths and files are
separate input modes and should be discovered on the actual target language.

<!-- mant:entries role=option case=insensitive -->
- `-f`: Select CSV, TSV, BIN, or SQL output format.
- `-cf`: Read one exact performance-counter path per line from a file.
- `-si`: Set the sampling interval in `[[hh:]mm:]ss` form.
- `-o`: Select an output file or SQL destination instead of standard output.
- `-q`: List installed counter paths without current instances.
- `-qx`: List installed counter paths expanded with current instances.
- `-sc`: Stop after the specified number of samples.
- `-config`: Read command options from a settings file.
- `-s`: Select a remote computer when the counter path does not name one.
- `-y`: Answer Yes to prompts such as output replacement.
- `/?`: Display installed syntax.

## Common mistakes

- Hard-coding English counter names on non-English Windows, or numeric Perflib
  indices as if they were accepted counter paths. Discover `-q`/`-qx` on target.
- Treating the first sample of a rate/delta counter as meaningful; many formulas
  require two raw samples and warm-up, and instance churn resets relationships.
- Comparing one counter directly with Task Manager: UI metrics can use different
  counter sets/formulas/normalization/aggregation and sampling windows.
- Using `(*)` without bounding instances/output; process/disk/network instances
  can appear, disappear, rename, or collide (`#1`) during collection.
- Choosing `-si`/`-sc` without workload duration, burst resolution, overhead,
  storage, clock synchronization, and baseline/seasonality.
- Parsing localized CSV decimal/time/header fields as invariant. Prefer BLG for
  fidelity, preserve locale/timezone, and convert a copy with Relog.
- Assuming an invalid counter means counters need a global rebuild. Verify exact
  path, localization, provider/service, instance, architecture, permissions, and
  provider events before considering registration repair.

## PowerShell boundaries

Quote each counter path as one scalar string; `$` in instance/object names needs
single-quoted or escaped PowerShell text. Capture native status and output path,
then verify sample count, timestamps, validity/status, gaps, size, and hash.
`Get-Counter` offers objects but shares PDH/localization/provider semantics.

## Version and platform differences

`typeperf.exe` is Windows-only. Counters, names, formulas, instances, providers,
formats, remote access, and localization vary by build, language, roles/products,
architecture, service/workload state, and privilege.

## Related documents

- [logman.exe](logman.exe.md)
- [relog.exe](relog.exe.md)
- [lodctr.exe](lodctr.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[typeperf reference](https://learn.microsoft.com/windows-server/administration/windows-commands/typeperf)
and [performance-counter tools map](https://learn.microsoft.com/windows/win32/perfctrs/performance-counters-tools).
Localization/path demand was cross-checked against a practitioner question on
[non-English counter names and numeric IDs](https://stackoverflow.com/questions/77629160/missing-counters-ids-in-typeperf-on-non-english-windows).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
