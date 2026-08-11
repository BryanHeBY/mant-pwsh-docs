<!-- mant:tldr:start -->
# diskperf

> Query or change whether physical/logical disk performance counters start after reboot; use counter tools to collect data.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/diskperf.

- Display the configured disk-counter state without changing it:

`diskperf.exe`

- Confirm that the localized PhysicalDisk and LogicalDisk counter sets exist:

`Get-Counter -ListSet '*Disk*' | Select-Object CounterSetName, Paths`

- Take a bounded sample from one discovered counter path:

`Get-Counter -Counter '{{\PhysicalDisk(_Total)\Disk Transfers/sec}}' -SampleInterval {{1}} -MaxSamples {{5}}`

- Enable both physical and logical disk counters after an approved reboot plan:

`diskperf.exe -y; $diskperfExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# diskperf

## Overview

`diskperf.exe` queries or changes whether physical and logical disk performance
counters start on Windows. `-y` enables all, `-yd` physical disks, and `-yv`
logical disks/volumes; the corresponding `-n`, `-nd`, and `-nv` forms disable
them. Microsoft documents that changes take effect when the computer restarts.
DiskPerf configures collection support; it does not itself sample or diagnose
storage performance.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `diskperf.exe`: Query or configure startup of Windows disk performance counters.

With no switch, DiskPerf displays configured state. Every change documented by
Microsoft takes effect only after the computer restarts.

<!-- mant:entries role=option case=insensitive -->
- `-y`: Enable physical- and logical-disk counters after restart.
- `-yd`: Enable physical-disk counters after restart.
- `-yv`: Enable logical-disk/volume counters after restart.
- `-n`: Disable physical- and logical-disk counters after restart.
- `-nd`: Disable physical-disk counters after restart.
- `-nv`: Disable logical-disk/volume counters after restart.
- `-?`: Display context-sensitive help supported by the installed executable.

## Common mistakes

### Expecting a switch to take effect immediately

Plan and verify the restart. Closing Task Manager or reopening PerfMon does not
apply a documented next-restart configuration change by itself.

### Confusing physical and logical counter paths

`PhysicalDisk` instances describe disk devices; `LogicalDisk` instances
describe volumes. A Microsoft Q&A case showed per-volume data missing because
the LogicalDisk counter path was spelled incorrectly. Discover localized paths
on the target instead of copying a display-language string.

### Treating missing counters as proof of idle storage

Missing data can reflect configuration, provider/counter corruption, agent
configuration, localization, instance filters, or sampling interval. Confirm
the local counter set before changing DiskPerf or storage.

### Disabling counters to solve performance overhead without evidence

Measure the actual collection path and workload first. Disabling counters can
blind monitoring and requires coordination with observability owners.

## PowerShell boundaries

DiskPerf is a native configuration tool; `Get-Counter` returns typed samples.
Counter set and path names can be localized. Capture native status and
`$LASTEXITCODE`, but verify effective availability after reboot through the
consumer that needs the data.

## Version and platform differences

This is Windows-only. Counter implementation and consumers differ across
Windows versions, storage stacks, virtual machines, containers, and monitoring
agents. Confirm whether a restart is acceptable on the exact target.

## Related documents

- [typeperf](typeperf.md)
- [perfmon](perfmon.md)
- [lodctr](lodctr.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DiskPerf reference](https://learn.microsoft.com/windows-server/administration/windows-commands/diskperf)
and [performance-counter tools overview](https://learn.microsoft.com/windows/win32/perfctrs/performance-counters-tools).
A [Microsoft Q&A counter-path case](https://learn.microsoft.com/answers/questions/1526966/disk-performance-counter-is-not-fully-functional-f)
was used to prioritize discovery and path validation. Exact provenance is
recorded in `upstream/windows-tools.json`. Microsoft-hosted documentation and this
adaptation are licensed under CC BY 4.0.
