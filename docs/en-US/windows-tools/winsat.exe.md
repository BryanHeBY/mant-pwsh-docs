<!-- mant:tldr:start -->
# winsat.exe

> Run bounded Windows System Assessment Tool workloads only on an idle test host; WinSAT is a benchmark, not a memory-integrity or codec-correctness test.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/winsat-mem.

- From an elevated shell on an approved idle test host, read installed
  assessment families and options without selecting a workload:

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

# winsat.exe

## Overview

`winsat.exe` runs Windows performance assessments. This family page covers the
catalog entries `winsat mem`, which measures memory-copy bandwidth, and
`winsat mfmedia`, which measures Media Foundation video decoding. Both impose
real CPU, memory, storage, GPU/media, and scheduling load and require elevation
according to their command references.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `winsat.exe`: Run an installed Windows System Assessment Tool family.
- `mem`: Measure memory-copy bandwidth under the selected thread/cache/timing policy.
- `mfmedia`: Measure Media Foundation decoding for one required trusted input clip.

The page covers parameters documented for `mem` and `mfmedia`; the same option
name can produce different workload behavior in another assessment family.

<!-- mant:entries role=option case=insensitive -->
- `-up`: Force the memory assessment to use one thread.
- `-rn`: Run memory assessment threads at normal rather than high priority.
- `-nc`: Allocate uncached memory and bypass processor caches for copying.
- `-do`: Set source-to-destination buffer offset in bytes for the memory test.
- `-mint`: Set the minimum assessment duration from 1 through 30 seconds.
- `-maxt`: Set the maximum assessment duration from 1 through 30 seconds.
- `-buffersize`: Set the per-thread memory-copy buffer from 64 KB through 384 MB.
- `-input`: Select the required trusted media file for `mfmedia`.
- `-dumpgraph`: Save a GraphEdit-compatible media filter graph before assessment.
- `-ns`: Run media decoding at normal presentation speed instead of as fast as possible.
- `-play`: Play input audio through the default device during decode assessment.
- `-nopmp`: Disable use of the Media Foundation Protected Media Pipeline.
- `-pmp`: Force use of the Media Foundation Protected Media Pipeline.
- `-v`: Emit verbose progress and error output.
- `-xml`: Write XML results and overwrite an existing destination.
- `-idiskinfo`: Include physical-volume and logical-disk data in XML results.
- `-iguid`: Add a generated GUID to XML results.
- `-note`: Add caller-supplied note text to XML results.
- `-icn`: Include the local computer name in XML results.
- `-eef`: Enumerate extra system information into XML results.
- `/?`: Display installed assessment families and help.

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

## PowerShell boundaries

WinSAT is native and emits localized progress/text. Capture `$LASTEXITCODE`
immediately and prefer a protected XML artifact for structured retention. XML
field availability can vary, so validate nodes rather than assuming a fixed
object shape.

## Version and platform differences

This is Windows-only. Results depend on Windows build, drivers, firmware, power
plan, virtualization, security features, media codecs, hardware acceleration,
thermal state, topology, and installed WinSAT assets. It is not a portable
cross-platform benchmark contract.

On Windows NT `10.0.26200.0`, exact System32 file version `10.0.26100.1`
could not be started with `/?` under the recorded ordinary token: Windows
rejected process creation with “The requested operation requires elevation.”
No child process or help payload existed, so no exit-code or syntax claim is
made from that attempt. No assessment, load, media parse/playback, XML artifact,
driver, codec, power, hardware, or system state changed.

## Runtime evidence

On Windows NT 10.0.26200.0, Windows rejected exact System32 file version
10.0.26100.1 /? process creation under the recorded ordinary token with
elevation required. No child/help payload/exit code existed and no
assessment/load/media/XML/audio/driver/codec/power/system mutation ran;
elevated help and workloads require an approved idle disposable host, with
trusted media for mfmedia.

## Related documents
- [perfmon.exe](perfmon.exe.md)
- [typeperf.exe](typeperf.exe.md)
- [dxdiag.exe](dxdiag.exe.md)

## Sources and license

This original family guide was adapted from Microsoft's official
[WinSAT memory](https://learn.microsoft.com/windows-server/administration/windows-commands/winsat-mem)
and [WinSAT Media Foundation](https://learn.microsoft.com/windows-server/administration/windows-commands/winsat-mfmedia)
references. Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft
documentation and this adaptation are licensed under CC BY 4.0.
