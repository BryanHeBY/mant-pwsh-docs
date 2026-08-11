<!-- mant:tldr:start -->
# pushprinterconnections.exe

> Diagnose Group Policy-deployed printer connections without manually replaying the startup/logon utility.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pushprinterconnections.

- Confirm the inbox utility's exact executable and file version without running it:

`Get-Command PushPrinterConnections.exe | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Capture the effective user Group Policy summary in the affected user's session:

`gpresult.exe /scope user /r`

- Capture the effective computer Group Policy summary for machine-deployed connections:

`gpresult.exe /scope computer /r`

- Inventory realized printers with user/computer and connection fields:

`Get-Printer | Select-Object Name,Type,ComputerName,Shared,Published,PrinterStatus`
<!-- mant:tldr:end -->

# pushprinterconnections.exe

## Overview

`PushPrinterConnections.exe` reads Deployed Printer Connections policy and
adds/removes connections during machine startup or user logon. Microsoft says
it is for startup/logon scripts and should not be run interactively. `-log`
writes a per-user log under `%TEMP%` or a per-machine log under
`%WINDIR%\Temp`.

## Invocation boundary

<!-- mant:entries role=command case=insensitive -->
- `PushPrinterConnections.exe`: Apply deployed-printer Group Policy at startup/logon.

Microsoft says not to run the utility interactively; its supported parameters
serve policy-script diagnostics rather than ad hoc printer deployment.

<!-- mant:entries role=option case=insensitive -->
- `-log`: Write a per-user or per-machine debug log in the documented temp path.
- `-?`: Display installed syntax.

## Common mistakes

### Running it manually as a repair command

Interactive execution changes timing, identity, session, network readiness,
policy scope, and profile state. Diagnose the configured GPO, effective RSoP,
event/task/script execution, logs, and realized connections in the actual
startup/logon context.

### Mixing user and computer deployment

User connections follow the user/session; machine connections apply to the
computer and realize for users at logon. Capture both RSoP scopes and do not
assume an administrator's interactive printer list represents the affected user.

### Expecting immediate removal or addition

Policy refresh, startup/logon, network/DC availability, spooler readiness,
driver policy, and user profile timing all participate. Record the GPO version,
target, last application, event evidence, and next controlled logon/restart.

### Enabling logs without protecting them

Debug logs can expose user names, servers, shares, paths, and failures. Set a
retention/access plan and distinguish `%TEMP%` for the actual user from the
machine `%WINDIR%\Temp` location.

### Blaming the deployment utility for driver-policy failure

Point and Print restrictions, package signatures, architecture, server trust,
and spooler hardening can block connection realization after policy selection.
Correlate the print and Group Policy event channels.

## PowerShell boundaries

Use `Get-Command` for nonexecuting discovery. PowerShell's current identity and
session may differ from startup (`SYSTEM`) or the affected logon user. Invoke
`gpresult.exe` explicitly and check `$LASTEXITCODE`; its output is sensitive text.

## Version and platform differences

Windows-only. The utility exists for compatibility with deployed-printer Group
Policy workflows; modern policy processing, security updates, driver rules, and
connection behavior vary by Windows build and domain policy.

## Related documents

- [gpresult.exe](gpresult.exe.md)
- [gpupdate.exe](gpupdate.exe.md)
- [prnmngr.vbs](prnmngr.vbs.md)
- [rundll32-printui](rundll32-printui.md)

## Sources and license

This original guide was adapted from Microsoft's official
[pushprinterconnections reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pushprinterconnections).
Per-user versus per-computer printer visibility was cross-checked against a
[high-demand inventory discussion](https://serverfault.com/questions/419866/list-all-printers-using-powershell).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
