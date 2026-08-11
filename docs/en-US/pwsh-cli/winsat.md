<!-- mant:tldr:start -->
# winsat

> Run bounded Windows System Assessment Tool workloads only on an idle test host; WinSAT is a benchmark, not a memory-integrity or codec-correctness test.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/winsat-mem.

- Read installed assessment families and options:

`winsat.exe /?`

- Run a bounded normal-priority memory-bandwidth assessment:

`winsat.exe mem -rn -mint {{2}} -maxt {{5}}; $winsatExitCode = $LASTEXITCODE`

- Save a bounded memory result to a new XML artifact after checking the path:

`$out = "{{C:\Evidence\winsat-mem.xml}}"; if (Test-Path -LiteralPath $out) { throw 'Output exists' }; winsat.exe mem -rn -mint {{2}} -maxt {{5}} -xml $out`

- Assess Media Foundation decoding with one trusted local clip, normal playback timing, and no audio:

`winsat.exe mfmedia -input "{{C:\Fixtures\clip.mp4}}" -ns; $winsatExitCode = $LASTEXITCODE`

- Parse a copied XML result as data rather than scraping localized console text:

`[xml]$result = Get-Content -LiteralPath "{{C:\Evidence\winsat-mem.xml}}" -Raw`
<!-- mant:tldr:end -->

# winsat

## Overview

`winsat.exe` runs Windows performance assessments. This family page covers the
catalog entries `winsat mem`, which measures memory-copy bandwidth, and
`winsat mfmedia`, which measures Media Foundation video decoding. Both impose
real CPU, memory, storage, GPU/media, and scheduling load and require elevation
according to their command references.

## Memory assessment

`mem` defaults to one thread per physical CPU/core at high priority. `-up`
forces one thread and `-rn` uses normal priority. `-mint` and `-maxt` accept
1–30 seconds; minimum cannot exceed maximum. `-buffersize` is 64 KB–384 MB and
allocates twice that amount per CPU. `-nc` bypasses processor caches. Use the
smallest bounded workload that answers the question.

## Media Foundation assessment

`mfmedia` requires `-input <file>`. It decodes as fast as possible unless `-ns`
requests normal presentation timing. `-play` enables audio through the default
device; omit it for unattended or shared environments. `-pmp` and `-nopmp`
control the Protected Media Pipeline and change what is being measured.

## Common mistakes

### Calling `mem` a RAM health test

It measures copy bandwidth; it does not exhaustively detect faulty memory.
Use platform/vendor memory diagnostics and correlate hardware events for
integrity investigations.

### Benchmarking a busy production machine

Default priority and per-core allocation can disturb workloads and distort the
result. Use an idle, thermally stable, power-policy-controlled test host and
record virtualization, NUMA, CPU topology, memory configuration, and background
load. Avoid comparing unlike systems as if the score were universal.

### Letting `-xml` overwrite evidence

Microsoft documents that an existing file is overwritten. Create a protected
new path, hash the artifact, and retain command/build/context alongside it.

### Using an untrusted media file

Media parsing exercises codecs and may expose malicious content; `-play` can
also emit audio. Use a trusted local fixture, record its hash and format, omit
playback, and isolate codec/security research.

### Comparing default and `-ns` or PMP modes as equivalent

Fast-as-possible versus presentation-timed decoding and protected versus
unprotected pipelines are different tests. Record every switch and effective
codec/hardware acceleration.

## PowerShell behavior

WinSAT is native and emits localized progress/text. Capture `$LASTEXITCODE`
immediately and prefer a protected XML artifact for structured retention. XML
field availability can vary, so validate nodes rather than assuming a fixed
object shape.

## Version and platform differences

This is Windows-only. Results depend on Windows build, drivers, firmware, power
plan, virtualization, security features, media codecs, hardware acceleration,
thermal state, topology, and installed WinSAT assets. It is not a portable
cross-platform benchmark contract.

## Related documents

- [perfmon](perfmon.md)
- [typeperf](typeperf.md)
- [dxdiag](dxdiag.md)

## Sources and license

This original family guide was adapted from Microsoft's official
[WinSAT memory](https://learn.microsoft.com/windows-server/administration/windows-commands/winsat-mem)
and [WinSAT Media Foundation](https://learn.microsoft.com/windows-server/administration/windows-commands/winsat-mfmedia)
references. Exact provenance is recorded in `upstream/cli.json`. Microsoft
documentation and this adaptation are licensed under CC BY 4.0.
