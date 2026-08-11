<!-- mant:tldr:start -->
# perfmon

> Open one explicit Windows performance, resource, reliability, or bounded system-diagnostics view; preserve host, workload window, counter/provider, and privilege context before drawing conclusions.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/perfmon.

- Open the Performance Monitor view:

`perfmon.exe /sys`

- Open Resource Monitor for current CPU, memory, disk, and network activity:

`perfmon.exe /res`

- Open Reliability Monitor for the host's stability timeline:

`perfmon.exe /rel`

- On an approved interactive host, run the bounded System Diagnostics collector and display its report:

`perfmon.exe /report`
<!-- mant:tldr:end -->

# perfmon

## Overview

`perfmon.exe` opens Windows Performance Monitor in a selected standalone mode.
`/sys` shows counters, `/res` opens Resource Monitor, `/rel` opens Reliability
Monitor, and `/report` starts the System Diagnostics Data Collector Set before
displaying results. These are interactive views, not stable machine-readable
APIs, and each answers a different question.

## Common mistakes

- Treating a quiet instant in Resource Monitor as a baseline. Record host,
  workload phase, interval, duration, clock, privilege, filters, and contention.
- Assuming `/report` only reads an existing report. It starts a diagnostic
  collector, can require elevation/services/providers, and may take time.
- Comparing one GUI value directly with Task Manager or a counter log without
  matching formula, normalization, instances, aggregation, and sample window.
- Automating screenshots or localized UI text as structured output. Use
  `typeperf`, `logman`, ETW tools, event XML, or supported APIs for automation.
- Ignoring session isolation: an elevated/scheduled/service invocation may open
  on another desktop or no usable interactive desktop at all.
- Interpreting missing counters, blank charts, or incomplete reports as absence
  of activity before checking providers, permissions, services, drops, and logs.

## PowerShell behavior

Use `Start-Process perfmon.exe -ArgumentList '/sys'` when launch semantics matter.
The GUI process lifetime is not the diagnostic result; record the exact mode and
export/save evidence deliberately. Use the dedicated native/PowerShell query
tools when scripts need data, status, time bounds, and reproducible parsing.

## Version and platform differences

`perfmon.exe` is Windows-only. Views, collectors, counters, providers, report
templates, elevation, service dependencies, and UI/export behavior vary by
Windows build, installed roles/products, language, policy, and session type.

## Related documents

- [logman](logman.md)
- [typeperf](typeperf.md)
- [tracerpt](tracerpt.md)
- [systeminfo](systeminfo.md)

## Sources and license

This original guide was adapted from Microsoft's official
[perfmon reference](https://learn.microsoft.com/windows-server/administration/windows-commands/perfmon).
The demand for a direct Resource Monitor entry point was cross-checked against
a practitioner question about a
[Resource Monitor shortcut](https://superuser.com/questions/65693/create-a-link-to-resource-monitor).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
