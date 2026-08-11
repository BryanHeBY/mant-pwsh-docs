<!-- mant:tldr:start -->
# mrt.exe

> Run Microsoft's Malicious Software Removal Tool only as a current, elevated, incident-aware supplement to antivirus; detect-only and quiet modes still perform a real scan.
> More information: https://support.microsoft.com/en-US/servicing/os/windows/2021/01/remove-specific-prevalent-malware-with-windows-malicious-software-removal-tool-kb890830.

- Show the supported command-line switches:

`mrt.exe /?`

- Start a detect-only scan that reports but does not remove detected malware:

`Start-Process mrt.exe -ArgumentList '/N' -Verb RunAs -Wait`

- Verify the installed file identity before an incident-response run:

`Get-Item (Get-Command mrt.exe).Source | Select-Object FullName, Length, LastWriteTime, VersionInfo`
<!-- mant:tldr:end -->

# mrt.exe

## Overview

`mrt.exe` runs the Windows Malicious Software Removal Tool (MSRT). Microsoft
releases it to find and remove specific prevalent malware from supported
Windows systems. It is a post-infection removal tool with a limited target set,
not a replacement for real-time antivirus or a complete incident-response scan.

Running a scan can consume substantial CPU, disk, and time. Removal can change
the system. Confirm the current signed tool, preserve evidence requirements,
obtain authorization, and plan isolation, recovery, and follow-up before use on
a suspected compromise.

## Syntax and status

```text
mrt.exe [/Q | /quiet] [/?] [/N] [/F] [/F:Y]
```

<!-- mant:entries role=command case=insensitive -->
- `mrt.exe`: Start MSRT interactively when no switch is supplied, or run the explicitly selected scan mode.

The following options are the complete switch set published by Microsoft for
the current tool contract.

<!-- mant:entries role=option case=insensitive -->
- `/Q`, `/quiet`: Suppress the MSRT user interface; this does not make the scan read-only or eliminate reporting and log review.
- `/?`: Display the supported MSRT command-line switches in a dialog.
- `/N`: Run in detect-only mode; report detected targeted malware without removing it.
- `/F`: Force an extended scan of the computer.

The cleanup form has a fixed attached value rather than an arbitrary `/F`
argument.

<!-- mant:entries role=option case=insensitive attached=fixed -->
- `/F:Y`: Force an extended scan and automatically clean detected targeted malware.

`/N` changes remediation behavior, not scan scope. `/F:Y` authorizes automatic
cleanup and must not be treated as a harmless spelling of `/F`.

## Before running

Resolve the exact executable, inspect its signature/version and freshness,
confirm a supported Windows release and an administrator account, and record
the host, time, arguments, authorization, evidence/containment requirements,
active security products, and recovery path. Obtain a current copy through an
approved Microsoft update or download channel when the installed tool is stale.

Prefer a normal antivirus full/offline scan or an approved endpoint-response
workflow when the investigation requires broad detection, continuous
protection, centralized telemetry, quarantine policy, or forensic collection.

## Common mistakes

- Treating a clean MSRT result as proof that the computer is malware-free; the
  tool targets a specific set of prevalent malware and is not full antivirus.
- Assuming `/N` means “no impact”; it still scans the system and can consume
  resources, access files, create logs, and participate in reporting behavior.
- Running `/F:Y` casually: it combines the extended scan with automatic cleanup
  and can alter evidence and system state.
- Using `/Q` in unattended automation without collecting completion, logs,
  detection/remediation results, tool version, and the intended host identity.
- Running an old copied `mrt.exe`, a same-name untrusted executable, or a tool
  from an unverified path during an incident.
- Treating process exit alone as containment, eradication, persistence removal,
  credential recovery, vulnerability remediation, or safe reconnection.
- Ignoring Microsoft's reporting behavior or organizational privacy, proxy,
  telemetry, and incident-handling requirements.

## PowerShell behavior

Invoke `mrt.exe` explicitly. Use `Start-Process -Wait -PassThru` when elevation
or process metadata is needed; direct invocation lets PowerShell capture native
streams and exposes `$LASTEXITCODE`. Neither mechanism turns the scan result
into PowerShell objects, and process completion alone is not a security verdict.

Do not pipe arbitrary host names or paths into MSRT: its documented switches do
not define a per-file or remote-target pipeline contract. Collect and preserve
the documented MSRT log and security-product/incident evidence separately.

## Version and platform differences

`mrt.exe` is Windows-only and requires an administrator account. Supported
Windows releases, malware families, tool version, delivery method, reporting,
and behavior change over time; consult the current Microsoft KB before use.

## Related documents

- [sfc.exe](sfc.exe.md)
- [certutil.exe](certutil.exe.md)
- [taskmgr.exe](taskmgr.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Windows Malicious Software Removal Tool KB890830](https://support.microsoft.com/en-US/servicing/os/windows/2021/01/remove-specific-prevalent-malware-with-windows-malicious-software-removal-tool-kb890830).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

This adaptation is licensed under CC BY 4.0. Microsoft Support content is
governed by Microsoft Web Terms.
