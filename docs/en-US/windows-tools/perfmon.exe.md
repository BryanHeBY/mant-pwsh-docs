<!-- mant:tldr:start -->
# perfmon.exe

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

# perfmon.exe

## Overview

`perfmon.exe` opens Windows Performance Monitor in a selected standalone mode.
`/sys` shows counters, `/res` opens Resource Monitor, `/rel` opens Reliability
Monitor, and `/report` starts the System Diagnostics Data Collector Set before
displaying results. These are interactive views, not stable machine-readable
APIs, and each answers a different question.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `perfmon.exe`: Open one Windows performance/resource/reliability view or start
  the System Diagnostics report workflow.

The launcher modes below select distinct interactive views or one collector
workflow; they do not turn GUI output into a machine-readable result.

<!-- mant:entries role=option case=insensitive -->
- `/sys`: Open the standalone Performance Monitor counter view.
- `/res`: Open Resource Monitor.
- `/rel`: Open Reliability Monitor.
- `/report`: Start the System Diagnostics Data Collector Set and display its
  report; this is not a read-only existing-report viewer.

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

## PowerShell boundaries

Use `Start-Process perfmon.exe -ArgumentList '/sys'` when launch semantics matter.
The GUI process lifetime is not the diagnostic result; record the exact mode and
export/save evidence deliberately. Use the dedicated native/PowerShell query
tools when scripts need data, status, time bounds, and reproducible parsing.

## Version and platform differences

`perfmon.exe` is Windows-only. Views, collectors, counters, providers, report
templates, elevation, service dependencies, and UI/export behavior vary by
Windows build, installed roles/products, language, policy, and session type.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\perfmon.exe`. Its fixed numeric file version was
`10.0.26100.7019`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [logman.exe](logman.exe.md)
- [typeperf.exe](typeperf.exe.md)
- [tracerpt.exe](tracerpt.exe.md)
- [systeminfo.exe](systeminfo.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[perfmon reference](https://learn.microsoft.com/windows-server/administration/windows-commands/perfmon).
The demand for a direct Resource Monitor entry point was cross-checked against
a practitioner question about a
[Resource Monitor shortcut](https://superuser.com/questions/65693/create-a-link-to-resource-monitor).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
