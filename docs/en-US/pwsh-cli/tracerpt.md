<!-- mant:tldr:start -->
# tracerpt

> Parse copied ETL/performance traces into new report/summary/output artifacts while preserving the original trace, provider schema, clock, and symbol provenance.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tracerpt.

- Display installed input/output, symbol, time, merge, and overwrite options:

`tracerpt.exe /?`

- Parse one copied ETL into a new CSV plus XML summary/report without overwriting prior artifacts:

`tracerpt.exe "{{C:\Evidence\input.etl}}" -o "{{C:\Evidence\events.csv}}" -of CSV -summary "{{C:\Evidence\summary.xml}}" -report "{{C:\Evidence\report.xml}}"`

- Convert a copied ETL into a new EVTX for Event Viewer/WinEvent analysis:

`tracerpt.exe "{{C:\Evidence\input.etl}}" -o "{{C:\Evidence\events.evtx}}" -of EVTX`
<!-- mant:tldr:end -->

# tracerpt

## Overview

`tracerpt.exe` processes ETW trace/performance logs and produces event output,
summary, and report files; it can combine inputs and use provider/symbol metadata.
Decoded output depends on provider manifests/TMF/PDB/version and collection flags.
An empty or partially rendered report does not prove the trace contained nothing.

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

## PowerShell behavior

Use `tracerpt.exe` explicitly with exact copied input and new output paths.
Capture stdout/stderr and `$LASTEXITCODE`; verify outputs exist, parse correctly,
cover the intended time/providers, report lost/unrendered events, and hash every
artifact. Do not feed untrusted symbol/provider paths into automation.

## Version and platform differences

`tracerpt.exe` is Windows-only. Accepted formats, decoding, reports, manifests,
symbols, ETW provider schemas, timestamp handling, and output vary by build,
architecture, providers, trace flags, and analysis-host resources.

## Related documents

- [logman](logman.md)
- [relog](relog.md)
- [wevtutil](wevtutil.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tracerpt reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tracerpt)
and [ETW collection/Tracerpt example](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/event-tracing-for-windows-simplified).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
