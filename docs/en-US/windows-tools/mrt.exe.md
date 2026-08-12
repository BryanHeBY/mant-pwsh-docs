<!-- mant:tldr:start -->
# mrt.exe

> Run Microsoft's Malicious Software Removal Tool only as a current, elevated, incident-aware supplement to antivirus; detect-only and quiet modes still perform a real scan.
> More information: https://support.microsoft.com/en-US/servicing/os/windows/2021/01/remove-specific-prevalent-malware-with-windows-malicious-software-removal-tool-kb890830.

- Verify the exact in-box executable and Microsoft signature without starting a scan or GUI:

`$mrt = Join-Path $env:SystemRoot 'System32\MRT.exe'; Get-Item -LiteralPath $mrt | Select-Object FullName, Length, VersionInfo; Get-AuthenticodeSignature -LiteralPath $mrt`

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

There is no documented console-only discovery switch. `/?` launches the
executable and displays a GUI dialog rather than writing ordinary command-line
help. An Agent that needs only syntax should read this page or the current KB;
it should not start MSRT merely to prove that the dialog exists.

## Before running

Resolve the exact executable, inspect its signature/version and freshness,
confirm a supported Windows release and an administrator account, and record
the host, time, arguments, authorization, evidence/containment requirements,
active security products, and recovery path. Obtain a current copy through an
approved Microsoft update or download channel when the installed tool is stale.

Prefer a normal antivirus full/offline scan or an approved endpoint-response
workflow when the investigation requires broad detection, continuous
protection, centralized telemetry, quarantine policy, or forensic collection.

Microsoft states that an MSRT full scan can take several hours, scans fixed and
removable drives, and does not scan mapped network drives. Cleanup can lose
data, may not restore infected files to their original state, and can require a
restart or manual follow-up. A run can also create a randomly named temporary
directory at a drive root; it is usually removed automatically but can remain.
Include these effects in before/after evidence and cleanup planning.

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

Microsoft's current KB says MSRT sends basic information when it detects
malware or encounters an error, including tool/system metadata, the result,
an anonymous GUID, and a one-way hash derived from removed-file paths. Sending
suspected files or their hashes requires an additional prompt and consent.
Enterprise policy can disable reporting; verify the current policy instead of
assuming that `/Q` or `/N` disables network reporting.

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

On the recorded Windows NT `10.0.26200.0` host, an identity-only observation
earlier on 2026-08-12 found MSRT fixed file/product version
`5.143.26070.2001`, a valid `Microsoft Windows` signature, and SHA-256
`AF76DE1A3016E20A92B67DEF4EB0ECE7ECBC9BEDF2C6172938ED122F6D76B07D`.
Later that day, the file changed without this audit invoking it: at
`2026-08-12T12:56:39+08:00`, fixed/string versions were
`5.144.26080.1002`, last-write time was `2026-08-12T04:52:43Z`, the signature
remained valid, and SHA-256 was
`84BE2A00027E27AAA53C0BC942C32E9B625490C4BC048C16163A836D0AEE71BA`.
Microsoft's public KB/catalog still exposed July v5.143 when checked, so the
local v5.144 identity is recorded as newer local evidence rather than assigned
an unverified public release label. No help dialog, scan, cleanup, reporting,
log write, temporary extraction, update request, or restart path was started.

## Runtime evidence

Two identity-only observations on Windows NT 10.0.26200.0 captured a real
same-day file transition. Earlier on 2026-08-12, MRT fixed version
5.143.26070.2001 had SHA-256
AF76DE1A3016E20A92B67DEF4EB0ECE7ECBC9BEDF2C6172938ED122F6D76B07D and matched
the public KB's July v5.143 family. At 2026-08-12T12:56:39+08:00, the exact
file had fixed/string version 5.144.26080.1002, last-write
2026-08-12T04:52:43Z, valid Microsoft Windows signature, and SHA-256
84BE2A00027E27AAA53C0BC942C32E9B625490C4BC048C16163A836D0AEE71BA, while the
public KB/catalog still exposed v5.143. The audit did not invoke or update MRT;
no help dialog, scan, cleanup, reporting, log write, temporary extraction,
update request, or restart path ran.

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
