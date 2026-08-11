<!-- mant:tldr:start -->
# logman

> Inventory Windows Data Collector Sets, ETW providers, and one exact collector definition before creating, updating, starting, stopping, importing, or deleting collection.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/logman.

- List registered Data Collector Sets and current status:

`logman.exe query`

- Query one exact set's schedule, output, format, counters/providers, limits, and run-as identity:

`logman.exe query "{{collector-name}}"`

- Export one exact set definition to a new XML file for review:

`logman.exe export "{{collector-name}}" -xml "{{C:\Evidence\collector.xml}}"`

- Enumerate available ETW providers before selecting a GUID/name, keyword mask, and level:

`logman.exe query providers`
<!-- mant:tldr:end -->

# logman

## Overview

`logman.exe` creates and manages counter, trace, alert, configuration, and API
Data Collector Sets/ETW sessions. Its families are `create`, `query`, `start`,
`stop`, `delete`, `update`, `import`, and `export`. A successful start means a
collector was activated, not that the chosen providers/counters, sampling,
buffers, output, symbols, workload window, and analysis answer the question.
Use `typeperf -q` or `-qx`, not an invented `logman query counters` form, to
discover performance-counter paths.

## Common mistakes

- Starting a generic “all providers/counters” trace: overhead, disk growth,
  wraparound, sensitive data, and provider side effects can distort the incident.
- Reusing a set name/output with overwrite/circular options before preserving
  the prior definition and evidence.
- Selecting an ETW provider by display text without GUID, keyword/level semantics,
  provider version, stack policy, buffer sizing, and consumer requirements.
- Choosing a sampling interval too slow for bursts or too fast for cost/noise;
  duration, workload phases, clock, warm-up, and baseline must be recorded.
- Treating remote `-s` as credentials or PowerShell remoting; capture target,
  token, firewall/RPC behavior, output location, and service/task identity.
- Stopping/deleting a set owned by the OS, product, security tool, or another
  investigation. Query owner/purpose and coordinate before any lifecycle action.
- Importing unreviewed XML: it can change paths, commands, credentials, schedules,
  providers, resource use, and ACLs. Diff normalized definitions and use a fixture.

## PowerShell behavior

Use `logman.exe` explicitly and pass names/paths as scalar strings. Capture
stdout/stderr and `$LASTEXITCODE`, then verify collector status, file growth,
events, sampled/provider content, timestamps, dropped events, and artifact hash.
Do not build provider/counter lists with `Invoke-Expression`.

## Version and platform differences

`logman.exe` is Windows-only. Collector types/options, providers/counters,
permissions, remote behavior, ETW schema, and output vary by build, installed
roles/products, architecture, language, policy, and caller identity.

## Related documents

- [typeperf](typeperf.md)
- [relog](relog.md)
- [tracerpt](tracerpt.md)
- [lodctr](lodctr.md)

## Sources and license

This original guide was adapted from Microsoft's official
[logman reference](https://learn.microsoft.com/windows-server/administration/windows-commands/logman)
and [performance-counter tools map](https://learn.microsoft.com/windows/win32/perfctrs/performance-counters-tools).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
