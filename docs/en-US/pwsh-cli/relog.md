<!-- mant:tldr:start -->
# relog

> Inspect counter paths and time coverage in copied performance logs, then convert or resample into a new output without claiming missing samples become new evidence.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/relog.

- List counters contained in one copied input log:

`relog.exe "{{C:\Evidence\input.blg}}" -q`

- Convert the copied BLG to a new CSV while preserving every available sample:

`relog.exe "{{C:\Evidence\input.blg}}" -f CSV -o "{{C:\Evidence\output.csv}}"`

- Select exact counters through a reviewed counter-list file:

`relog.exe "{{C:\Evidence\input.blg}}" -cf "{{C:\Evidence\counters.txt}}" -f BIN -o "{{C:\Evidence\selected.blg}}"`

- Resample by taking every Nth input sample into a new log; document the lost resolution:

`relog.exe "{{C:\Evidence\input.blg}}" -t {{10}} -f BIN -o "{{C:\Evidence\downsampled.blg}}"`
<!-- mant:tldr:end -->

# relog

## Overview

`relog.exe` reads one or more performance counter logs and selects, merges,
converts, time-bounds, or resamples data to CSV/TSV/BIN/SQL output. It transforms
existing samples; it does not recover events that were never collected, validate
counter meaning, align unsynchronized clocks, or make sparse data representative.

## Common mistakes

- Using `-y`/an existing output and overwriting source or prior analysis. Work on
  read-only copies, generate a new path, hash input/output, and preserve metadata.
- Treating `-t N` as statistical aggregation/interpolation; it selects every Nth
  sample and loses temporal resolution/bursts.
- Merging hosts/logs with different clocks, intervals, counter versions, locale,
  instance identity, gaps, or overlapping timestamps without provenance.
- Applying local counter-path expectations to logs from another language/build.
  Use `-q` on each input and retain machine/source metadata.
- Filtering out base counters/status needed to calculate or validate derived
  counters, or interpreting invalid/missing samples as zero.
- Converting to CSV then losing precision, status, locale, timezone, instance
  identity, or counter metadata. Preserve original BLG as evidence.
- Writing SQL with unreviewed DSN/table/credential/overwrite semantics.

## PowerShell behavior

Use `relog.exe` explicitly with scalar paths. Resolve and protect output before
execution; do not use wildcards that absorb unrelated logs. Capture streams and
`$LASTEXITCODE`, verify input/output hashes, counter list, sample/time range,
gaps/status, and transformation parameters.

## Version and platform differences

`relog.exe` is Windows-only. Input/output formats, SQL support, counters,
localization, timestamp precision, merging, and provider metadata vary by build
and the producing systems/tools.

## Related documents

- [typeperf](typeperf.md)
- [logman](logman.md)
- [tracerpt](tracerpt.md)

## Sources and license

This original guide was adapted from Microsoft's official
[relog reference](https://learn.microsoft.com/windows-server/administration/windows-commands/relog)
and [performance-counter tools map](https://learn.microsoft.com/windows/win32/perfctrs/performance-counters-tools).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
