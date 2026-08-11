<!-- mant:tldr:start -->
# logman.exe

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

# logman.exe

## Overview

`logman.exe` creates and manages counter, trace, alert, configuration, and API
Data Collector Sets/ETW sessions. Its families are `create`, `query`, `start`,
`stop`, `delete`, `update`, `import`, and `export`. A successful start means a
collector was activated, not that the chosen providers/counters, sampling,
buffers, output, symbols, workload window, and analysis answer the question.
Use `typeperf -q` or `-qx`, not an invented `logman query counters` form, to
discover performance-counter paths.

## Commands and shared parameters

<!-- mant:entries role=command case=insensitive -->
- `logman.exe`: Create or manage Windows Data Collector Sets and ETW sessions.
- `create`: Create a counter, trace, alert, configuration, or API collector.
- `query`: List collectors, inspect one collector, or enumerate ETW providers.
- `start`: Start one existing collector or ETW session.
- `stop`: Stop one existing collector or ETW session.
- `delete`: Delete one collector definition after preserving ownership/evidence.
- `update`: Change one existing collector definition.
- `import`: Create/update a collector from reviewed XML.
- `export`: Write one collector definition to XML.

Options vary by family and collector type. The following high-value locators
must be interpreted within the exact subcommand's installed help.

<!-- mant:entries role=option case=insensitive -->
- `-s`: Select a remote computer for a family that supports it.
- `-config`: Read command options from a settings file.
- `-n`: Set or select the collector name where that form requires it.
- `-f`: Select counter-log output format such as BIN, CSV, TSV, or SQL.
- `-o`: Select a base output path or SQL destination.
- `-c`: Supply one or more exact performance-counter paths.
- `-cf`: Read performance-counter paths from a file.
- `-si`: Set the performance-counter sampling interval.
- `-p`: Select an ETW provider with optional keyword mask and level.
- `-pf`: Read ETW provider selections from a file.
- `-xml`: Select the XML path for import/export operations.
- `-b`: Set a begin time for a scheduled collector.
- `-e`: Set an end time for a scheduled collector.
- `-rf`: Set a maximum run duration.
- `-max`: Set a maximum log size.
- `-cnf`: Create a new output filename at the specified interval or size behavior.
- `-u`: Select a run-as or remote identity; avoid inline passwords.
- `-ets`: Send a supported command directly to an ETW session without scheduling.
- `-y`: Suppress confirmation by answering Yes.
- `/?`: Display top-level or family-specific installed help.

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

## PowerShell boundaries

Use `logman.exe` explicitly and pass names/paths as scalar strings. Capture
stdout/stderr and `$LASTEXITCODE`, then verify collector status, file growth,
events, sampled/provider content, timestamps, dropped events, and artifact hash.
Do not build provider/counter lists with `Invoke-Expression`.

## Version and platform differences

`logman.exe` is Windows-only. Collector types/options, providers/counters,
permissions, remote behavior, ETW schema, and output vary by build, installed
roles/products, architecture, language, policy, and caller identity.

## Related documents

- [typeperf.exe](typeperf.exe.md)
- [relog.exe](relog.exe.md)
- [tracerpt.exe](tracerpt.exe.md)
- [lodctr.exe](lodctr.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[logman reference](https://learn.microsoft.com/windows-server/administration/windows-commands/logman)
and [performance-counter tools map](https://learn.microsoft.com/windows/win32/perfctrs/performance-counters-tools).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
