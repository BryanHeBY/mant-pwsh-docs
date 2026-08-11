<!-- mant:tldr:start -->
# scwcmd

> Analyze and render Security Configuration Wizard policy evidence without applying server or GPO changes.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/scwcmd.

- Display the installed Security Configuration Wizard command families:

`scwcmd.exe /?`

- Analyze the local computer against one reviewed SCW policy and write results to a new protected directory:

`scwcmd.exe analyze /p:"{{C:\SCW\Policies\WebServer.xml}}" /o:"{{C:\SCW\Results\Run-001}}" /l`

- Analyze one exact remote server with the current credentials (SCW must also be installed remotely):

`scwcmd.exe analyze /m:"{{SERVER01}}" /p:"{{C:\SCW\Policies\WebServer.xml}}" /o:"{{C:\SCW\Results\SERVER01-Run-001}}" /l`

- Render one existing SCW XML result with its default transform:

`scwcmd.exe view /x:"{{C:\SCW\Results\Run-001\result.xml}}"`
<!-- mant:tldr:end -->

# scwcmd

## Overview

`scwcmd.exe` automates Security Configuration Wizard (SCW) workflows. Its
families have materially different effects: `analyze` compares computers with
a policy and writes XML evidence; `view` renders XML; `configure` applies a
policy; `rollback` applies and then deletes the most recent rollback policy;
`register` extends the SCW database; and `transform` creates a new AD GPO.

The TLDR uses only analysis and rendering. Even analysis touches remote hosts,
writes results/logs, and can optionally log mismatch events, so its scope and
output still require approval.

## Common mistakes

### Using `configure` when the intent was compliance analysis

`configure` changes services, firewall, registry, audit, and other settings
described by the policy. It is not a stronger spelling of `analyze`. Preserve
effective configuration, verify role dependencies, test on a representative
server, and provide console access plus an approved rollback plan before apply.

### Assuming `rollback` is a preview or permanent undo stack

`rollback` applies the most recent rollback policy and then deletes that policy.
It is a mutation with a consumable recovery artifact, not a dry run. Confirm
that the rollback belongs to the exact machine and change before invoking it.

### Treating `transform` as a local XML conversion

`transform /p:... /g:...` creates a new GPO in AD DS and requires domain
administrator credentials. It does not link the GPO, and IIS settings are not
carried through Group Policy. Use a unique reviewed name, capture the resulting
GPO identity, and keep creation separate from linking and enforcement.

### Scanning an OU as if it were one server

`/ou` expands to every computer in that OU; `/i` can also describe many targets,
and `/t` permits substantial concurrency. Start with one exact `/m` target,
then control inventory, maintenance window, credentials, result naming,
network load, and partial failures before widening scope.

### Passing `/pw` in scripts or logs

Alternate usernames and passwords can appear in process inspection,
transcripts, CI logs, and command history. Prefer the current approved identity
or a secret-safe execution channel. Do not copy Microsoft's plaintext-shaped
syntax into reusable automation.

### Comparing against a stale or mismatched role policy

An analysis mismatch does not automatically mean the live server is wrong.
Record policy hash/version, target build, installed roles/features, approved
exceptions, SCW database extensions, time, and target identity. Review the XML
result rather than treating a rendered browser view as the primary artifact.

### Expecting remote analysis without SCW on the target

Microsoft requires SCW to be installed on a remote server for analyze,
configure, and rollback. A reachability or authorization failure is different
from noncompliance; preserve the native status and per-machine log.

## PowerShell behavior

Call `scwcmd.exe` explicitly and quote `/name:value` as one argument when its
value contains spaces. The command writes text plus XML/log artifacts rather
than PowerShell objects. Check `$LASTEXITCODE`, enumerate the exact new output,
and preserve hashes before parsing or rendering it.

## Version and platform differences

The tool is Windows-only and depends on the Security Configuration Wizard and
applicable server-role components. Availability and the SCW security database
vary by Windows edition/build and installed roles. A Microsoft Learn applicability
banner does not prove that the feature is installed on a particular desktop or
server image; verify `Get-Command`, feature state, and local help.

## Related documents

- [secedit](secedit.md)
- [gpresult](gpresult.md)
- [auditpol](auditpol.md)
- [netsh](netsh.md)

## Sources and license

This original guide was adapted from Microsoft's official
[scwcmd family](https://learn.microsoft.com/windows-server/administration/windows-commands/scwcmd),
[analyze](https://learn.microsoft.com/windows-server/administration/windows-commands/scwcmd-analyze),
and [view](https://learn.microsoft.com/windows-server/administration/windows-commands/scwcmd-view)
references. Role-policy expectations were cross-checked against a
[practitioner SCW workflow question](https://serverfault.com/questions/402735/how-to-use-scw-to-produce-xml-of-current-settings).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
