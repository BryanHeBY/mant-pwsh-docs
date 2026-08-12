<!-- mant:tldr:start -->
# rsop.msc

> Open Resultant Set of Policy for an interactive policy investigation; use `gpresult.exe` when the report must be complete, reproducible, saved, or processed as data.
> More information: https://learn.microsoft.com/troubleshoot/windows-server/group-policy/use-resultant-set-of-policy-logging.

- Resolve the console file without launching a GUI:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\rsop.msc')`

- Open the RSoP snap-in in the current interactive session:

`Start-Process rsop.msc`

- Save the applied user and computer policy as an HTML report instead:

`gpresult.exe /h "$env:TEMP\gpresult.html" /f`
<!-- mant:tldr:end -->

# rsop.msc

## Overview

`rsop.msc` opens the Resultant Set of Policy (RSoP) MMC snap-in. It can collect
and display policy results for an explicitly selected user and computer and can
help explain which Group Policy object won when settings overlap.

The snap-in is an interactive diagnostic view, not a complete or stable export
contract. Microsoft notes that RSoP reports do not show every Group Policy
setting on current Windows. Use `gpresult.exe` when completeness, saved evidence,
remote collection, or repeatable automation matters.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `rsop.msc`: Open the Resultant Set of Policy MMC snap-in for an explicitly identified user and computer.

The console file exposes no supported parameter interface documented here. Do
not invent slash switches or scrape localized tree labels. Use `gpresult.exe`
and its documented output options for command-line reporting.

## Investigation workflow

Record the computer, user SID, domain and site, collection time, sign-in and
restart history, network/DC reachability, policy refresh result, loopback mode,
security/WMI filters, winning and denied GPOs, and whether the observation came
from RSoP logging, RSoP modeling, `gpresult`, registry state, or product behavior.

Preserve the original `gpresult /h` or `/x` artifact when findings must be
reviewed later. A screenshot of one RSoP node is not a complete policy record.

## Common mistakes

- Treating RSoP output as a complete list of all configured or applied settings;
  Microsoft directs users to `gpresult` for the full applied-policy report.
- Confusing logging data gathered from an actual user/computer with modeling or
  planning data calculated for a hypothetical site, OU, user, or computer.
- Inspecting the current administrator instead of the affected user's SID, or
  inspecting user scope while the setting belongs to computer scope.
- Assuming the locally configured value is authoritative when domain Group
  Policy, MDM, security baselines, scripts, preferences, or application policy
  can own or overwrite the effective state.
- Reading a winning GPO name without checking security filtering, WMI filters,
  inheritance, enforcement, blocks, loopback, replication, refresh, and errors.
- Changing policy or deleting registry values before preserving the result and
  the Group Policy operational events needed to explain it.

## PowerShell behavior

`Start-Process rsop.msc` launches the interactive console and returns no policy
objects. For a saved report, invoke `gpresult.exe` explicitly, check
`$LASTEXITCODE` immediately, verify that the output file was created, and retain
its target identity and collection time with the artifact.

PowerShell redirection of `gpresult /r`, `/v`, or `/z` produces text whose
format and language are not a durable parser contract. Prefer the documented
HTML or XML output modes when a preserved report is needed, and use supported
policy APIs or MDM reports for structured automation.

## Version and platform differences

`rsop.msc` is Windows-only. Availability, permissions, report contents, remote
collection, policy extensions, and modeling support vary by Windows edition,
build, domain membership, management authority, firewall, and installed tools.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` did not resolve the exact
`rsop.msc` entry point. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. Local absence is availability evidence for this
host, not proof that the documented component is unavailable on another Windows
edition, role, or optional-feature set; it does not prove that the UI loads,
the current user is authorized, an optional snap-in or component is functional,
or any displayed or requested operation succeeds.

## Related documents
- [gpresult.exe](gpresult.exe.md)
- [gpedit.msc](gpedit.msc.md)
- [secpol.msc](secpol.msc.md)
- [gpupdate.exe](gpupdate.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[RSoP logging guidance](https://learn.microsoft.com/troubleshoot/windows-server/group-policy/use-resultant-set-of-policy-logging),
[Group Policy CSP guidance](https://learn.microsoft.com/windows/client-management/mdm/policy-csp-admx-grouppolicy),
and [`gpresult` reference](https://learn.microsoft.com/windows-server/administration/windows-commands/gpresult).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
