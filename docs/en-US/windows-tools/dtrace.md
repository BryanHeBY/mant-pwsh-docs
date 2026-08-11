<!-- mant:tldr:start -->
# dtrace

> Discover and compile Windows DTrace probes before starting a bounded trace; parameters and probe names are case-sensitive.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/dtrace.

- Resolve the implementation and display its API version without enabling DTrace:

`Get-Command dtrace.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}; dtrace.exe -V`

- List syscall probes without tracing them:

`dtrace.exe -l -P syscall`

- Show verbose argument/stability information for matching probes:

`dtrace.exe -lvn "{{syscall:::entry}}"`

- Compile a reviewed D script without enabling probes or collecting data:

`dtrace.exe -e -s "{{C:\Tracing\reviewed.d}}"`
<!-- mant:tldr:end -->

# dtrace

## Overview

Windows DTrace dynamically instruments kernel and user-space activity using
providers, modules, functions, probe names and D scripts. Listing (`-l`) and
compile-only (`-e`) are distinct from enabling a trace. Windows Server 2025
includes a built-in port; earlier Windows guidance also describes a separate
MSI port with different parameters and capabilities.

## Command families

- `-l`, `-v`, `-V`: list probes/details and report API version.
- `-P`, `-m`, `-f`, `-n`, `-i`: select provider, module, function, probe tuple,
  or probe ID; incomplete tuples can expand to many probes.
- `-s`, `-e`, `-C`, `-D`, `-U`, `-I`, `-L`, `-X`: compile scripts and control
  preprocessing; without `-e` or `-l`, a valid program begins tracing.
- `-p`, `-c`: bind a PID or start a child command; PID reuse and parser layers
  must be controlled.
- `-b`, `-o`, `-q`, `-x`, `-y`: control buffers, artifacts, output, runtime
  options and symbols.
- `-w`: explicitly permits destructive actions and is never a harmless
  verbosity or write-output option.

## Common mistakes

### Enabling the boot option just to make discovery pass

`bcdedit /set dtrace on` changes boot configuration and requires a reboot.
It can interact with BitLocker, Secure Boot and other protections. Resolve the
binary/version first; enable only on an approved test or diagnostic host with
recovery-key custody, rollback and downtime planning.

### Omitting `-e` while validating a script

A valid script can immediately enable probes and run until its exit condition
or interruption. Compile with `-e`, inspect the matched set with `-l`, bound
duration/output, and document Ctrl+C or another tested stop path before capture.

### Expanding a selector to every function or syscall

Empty tuple fields and broad provider selectors can match thousands of probes,
creating load and huge/sensitive output. Count and review matches first, then
narrow by provider/module/function/PID and reproduce one bounded event.

### Treating `-w` as permission to write the output file

It permits destructive D actions, including changing behavior or crashing the
system. Ordinary `-o` output does not require `-w`. Reject untrusted scripts
and review pragmas as well as command-line flags.

### Reusing Solaris, illumos, or MSI-port recipes unchanged

Provider names, Windows extensions, symbol paths and flags differ. The built-in
Server 2025 port is explicitly not the same contract as the MSI distribution.
Resolve source/version and use installed help plus matching Microsoft guidance.

### Treating trace output or live dumps as nonsensitive telemetry

Arguments, paths, process identities, memory and kernel state may contain
secrets. Protect output, avoid public paste sites, define retention and never
trigger a live dump without space, privacy and incident-handling approval.

## PowerShell behavior

Call `dtrace.exe` explicitly. Single quotes often preserve D-language `$`,
braces and quotes in PowerShell, but scripts avoid multiple parser layers.
Capture native output carefully and do not lose `$LASTEXITCODE` after a child
command. Case matters even though many Windows CLI switches are insensitive.

## Version and platform differences

Windows-only page. Built-in availability begins with Windows Server 2025;
other Windows versions may have no DTrace or the distinct MSI/preview port.
Never infer Windows support from a Unix `dtrace` executable.

## Related documents

- [logman](logman.md)
- [tracerpt](tracerpt.md)
- [pktmon](pktmon.md)
- [bcdedit](bcdedit.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Windows command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dtrace),
[DTrace on Windows architecture and installation guide](https://learn.microsoft.com/windows-hardware/drivers/devtest/dtrace),
and [live-dump guide](https://learn.microsoft.com/windows-hardware/drivers/devtest/dtrace-live-dump).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
