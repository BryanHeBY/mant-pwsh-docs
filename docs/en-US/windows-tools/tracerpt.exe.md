<!-- mant:tldr:start -->
# tracerpt.exe

> Parse copied ETL/performance traces into new report/summary/output artifacts while preserving the original trace, provider schema, clock, and symbol provenance.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tracerpt.

- Display installed input/output, symbol, time, merge, and overwrite options:

`tracerpt.exe /?`

- Parse one copied ETL into a new CSV plus XML summary/report without overwriting prior artifacts:

`tracerpt.exe "{{C:\Evidence\input.etl}}" -o "{{C:\Evidence\events.csv}}" -of CSV -summary "{{C:\Evidence\summary.xml}}" -report "{{C:\Evidence\report.xml}}"`

- Convert a copied ETL into a new EVTX for Event Viewer/WinEvent analysis:

`tracerpt.exe "{{C:\Evidence\input.etl}}" -o "{{C:\Evidence\events.evtx}}" -of EVTX`
<!-- mant:tldr:end -->

# tracerpt.exe

## Overview

`tracerpt.exe` processes ETW trace/performance logs and produces event output,
summary, and report files; it can combine inputs and use provider/symbol metadata.
Decoded output depends on provider manifests/TMF/PDB/version and collection flags.
An empty or partially rendered report does not prove the trace contained nothing.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `tracerpt.exe`: Parse copied ETL/performance logs or a named real-time ETW session.

Positional inputs select one or more files. Real-time mode attaches to active
sessions and therefore has a different lifecycle and disclosure boundary.

<!-- mant:entries role=option case=insensitive -->
- `-l`: Explicitly introduce one or more trace-log input paths.
- `-rt`: Read one or more named real-time Event Trace sessions.
- `-config`: Load command options from a settings file.
- `-y`: Answer Yes to prompts, including overwrite confirmation.
- `-f`: Select XML or HTML report format.
- `-of`: Select CSV, EVTX, or XML event-dump format.
- `-df`: Write a Microsoft-specific counting/reporting schema file.
- `-int`: Dump interpreted event structure to a file.
- `-rts`: Include the raw timestamp in trace headers for dump output only.
- `-tmf`: Select one Trace Message Format definition file.
- `-tp`: Select one or more trusted TMF search paths.
- `-i`: Select provider image paths used to locate matching symbols.
- `-pdb`: Select trusted symbol-server/search paths.
- `-gmt`: Convert WPP payload timestamps to GMT.
- `-rl`: Select system report level 1 through 5.
- `-summary`: Write a summary artifact, using a default name if omitted.
- `-o`: Write the event dump, using a default name if omitted.
- `-report`: Write the workload report, using a default name if omitted.
- `-lr`: Use best-effort decoding for events not matching available schema.
- `-export`: Export an event-schema manifest.
- `-?`: Display installed syntax.

## Common mistakes

- Parsing the only ETL in place or using overwrite: preserve a read-only original,
  acquisition metadata/hash, and generate uniquely named outputs on a safe volume.
- Merging traces from different hosts/boots/clocks/timezones without time-sync,
  boot/session/provider identity and start/stop/drop metadata.
- Using mismatched or untrusted symbols/TMF/PDB/manifests; symbol paths can cause
  network access and source disclosure. Pin trusted versions and record hashes.
- Treating CSV/EVTX/report rendering as lossless. Preserve raw ETL, event headers,
  activity IDs, process/thread/provider IDs, keywords/levels and dropped-event data.
- Assuming tracerpt diagnoses root cause automatically; correlate workload,
  configuration, event logs, counters, dumps, network/storage and baselines.
- Generating huge reports from unbounded/multi-provider traces without capacity,
  sensitive-data, retention, and access-control review.

## PowerShell boundaries

Use `tracerpt.exe` explicitly with exact copied input and new output paths.
Capture stdout/stderr and `$LASTEXITCODE`; verify outputs exist, parse correctly,
cover the intended time/providers, report lost/unrendered events, and hash every
artifact. Do not feed untrusted symbol/provider paths into automation.

## Version and platform differences

`tracerpt.exe` is Windows-only. Accepted formats, decoding, reports, manifests,
symbols, ETW provider schemas, timestamp handling, and output vary by build,
architecture, providers, trace flags, and analysis-host resources.
On exact System32 file version `10.0.26100.1`, `/?` printed 49 nonempty stdout
lines, produced no PowerShell error records, and returned 1. No trace/log,
real-time session, manifest, symbol/TMF path, report, summary, event dump,
schema export, input, or output was supplied or created.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 TraceRpt file version 10.0.26100.1
/? printed 49 nonempty stdout lines, no PowerShell error records, and returned
1. No trace/session/schema/symbol/report/summary/dump/input/output ran;
approved copied-trace verification remains pending.

## Related documents
- [logman.exe](logman.exe.md)
- [relog.exe](relog.exe.md)
- [wevtutil.exe](wevtutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tracerpt reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tracerpt)
and [ETW collection/Tracerpt example](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/event-tracing-for-windows-simplified).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
