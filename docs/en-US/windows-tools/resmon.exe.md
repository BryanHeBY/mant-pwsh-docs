<!-- mant:tldr:start -->
# resmon.exe

> Open Windows Resource Monitor for a live interactive snapshot; record host, session, privilege, filters, update interval, workload and time window before interpreting CPU, memory, disk or network activity.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/perfmon.

- Open Resource Monitor through its direct executable entry point:

`resmon.exe`

- Open the same Resource view through the documented Perfmon mode:

`perfmon.exe /res`
<!-- mant:tldr:end -->

# resmon.exe

## Overview

`resmon.exe` is the direct Resource Monitor launcher; Microsoft also documents
`perfmon.exe /res`. It correlates live process/resource activity interactively,
but is not a recorder, stable structured API, capacity baseline, or root-cause
engine. A process can change or exit between display and action.

## Entry points

<!-- mant:entries role=command case=insensitive -->
- `resmon.exe`: Open Resource Monitor directly in the current interactive session.
- `perfmon.exe`: Use `/res` to open the Resource Monitor view through the documented Performance Monitor launcher.

This is live presentation, not a recording contract. Use counters, ETW, or
other supported APIs when timing, reproducibility, or machine processing matters.

## Common mistakes

- Treating one quiet/busy instant as representative without sampling duration,
  workload phase, filters, privilege, clock, contention and a comparison baseline.
- Comparing UI values directly with Task Manager/counters without matching
  formulas, normalization, aggregation, instances and intervals.
- Ending/suspending a process or using Analyze Wait Chain without exact PID/start
  time, owner/session, dependencies, open work, dump and recovery context.
- Assuming missing rows/activity prove absence before checking access, protected
  processes, providers, refresh rate, filters, short-lived work and dropped data.
- Automating screenshots/localized UI instead of counters, ETW, event XML, or
  supported process/storage/network APIs.

## PowerShell behavior

Use `Start-Process resmon.exe` only for an interactive session. For reproducible
automation, select `typeperf`, `logman`, ETW, `Get-Process`, network/storage tools
or supported APIs and preserve time bounds, identity, status and raw artifacts.

## Version and platform differences

`resmon.exe` is Windows-only. Views, metrics, permissions and UI behavior vary by
Windows build, architecture, providers, installed features and session identity.

## Related documents

- [perfmon.exe](perfmon.exe.md)
- [typeperf.exe](typeperf.exe.md)
- [logman.exe](logman.exe.md)
- [taskmgr.exe](taskmgr.exe.md)

## Sources and license

This original guide uses Microsoft's official
[Perfmon `/res` reference](https://learn.microsoft.com/windows-server/administration/windows-commands/perfmon)
and records `resmon.exe` as the searchable direct entry point for the same view.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
