<!-- mant:tldr:start -->
# sxstrace

> Diagnose one reproducible side-by-side activation failure with a new protected ETL path: start a bounded trace, reproduce once, always stop tracing, then parse a copy and verify the exact manifest/assembly identity before repair.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/sxstrace.

- Show installed syntax without starting a trace:

`sxstrace.exe -?`

- Parse an existing copied trace without changing the source ETL:

`sxstrace.exe parse -logfile:'C:\trace\app.etl' -outfile:'C:\trace\app.txt'`

- Start a trace to a new approved path without an interactive stop prompt:

`sxstrace.exe trace -logfile:'C:\trace\app.etl' -nostop`

- Stop the active side-by-side trace immediately after one reproduction:

`sxstrace.exe stoptrace`
<!-- mant:tldr:end -->

# sxstrace

## Overview

`sxstrace.exe` records and parses Windows side-by-side (SxS) activation-context
events. It helps identify manifest, architecture, version, policy, culture,
publisher and dependent-assembly resolution failures. It diagnoses evidence;
it does not install runtimes, repair manifests or choose a safe replacement.

## Capture lifecycle

```text
sxstrace trace -logfile:TRACE.etl [-nostop]
reproduce the exact failure once
sxstrace stoptrace
sxstrace parse -logfile:TRACE.etl -outfile:TRACE.txt [-filter:APP]
```

Use a new path, record time/user/process/architecture/working directory and stop
in a finally/cleanup path. Hash and preserve the ETL before parsing when it is
support or incident evidence.

## Common mistakes

- Starting `-nostop` and forgetting `stoptrace`, leaving a global diagnostic
  session active or contaminating the trace with unrelated launches.
- Parsing a stale/default ETL from an earlier reproduction, overwriting evidence,
  or failing to verify that the intended process and failure appear.
- Reproducing under a different user, bitness, working directory, service
  account or environment than the failing workload.
- Reading “assembly not found” and downloading a random DLL/runtime. Resolve the
  complete assembly identity, requesting manifest/configuration, architecture,
  version/policy and supported application deployment first.
- Deploying a Debug CRT or copying WinSxS files manually. Debug runtimes may not
  be redistributable, and component-store copying bypasses servicing.
- Assuming every “side-by-side configuration is incorrect” message has the same
  cause; malformed application configuration can also break activation context.
- Publishing parsed traces without reviewing paths, user/application names,
  versions and other environment information.

## PowerShell behavior

Pass each `-logfile:`/`-outfile:` token as one quoted native argument. Check
`$LASTEXITCODE`, file existence, timestamps and content. Wrap start/reproduce in
`try`/`finally` so `stoptrace` runs after failure. Use `Start-Process -Wait` only
when the reproduction executable's completion is part of the evidence contract.

## Version and platform differences

`sxstrace.exe` is Windows-only. SxS policies, installed assemblies, manifests,
trace permissions and application architecture vary by build, servicing state,
edition and installed runtimes.

## Related documents

- [wevtutil](wevtutil.md)
- [tracerpt](tracerpt.md)
- [sfc](sfc.md)
- [dism](dism.md)

## Sources and license

Microsoft's official [sxstrace reference](https://learn.microsoft.com/windows-server/administration/windows-commands/sxstrace)
defines capture and parse syntax. A highly viewed
[Stack Overflow side-by-side question](https://stackoverflow.com/questions/3961742/the-application-has-failed-to-start-because-its-side-by-side-configuration-is-in)
demonstrates that identical surface errors can have different manifest,
dependency or configuration causes; it is diagnostic demand evidence, not
repair authority. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
