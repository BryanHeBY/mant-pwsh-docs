<!-- mant:tldr:start -->
# lusrmgr.msc

> Open Local Users and Groups for an explicitly identified member computer; use SIDs and typed account/group tools for automation, and do not confuse local SAM principals with domain or cloud identities.
> More information: https://learn.microsoft.com/windows/security/identity-protection/access-control/local-accounts.

- Resolve the console file without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\lusrmgr.msc')`

- Open Local Users and Groups interactively:

`Start-Process lusrmgr.msc`

- Query local users as objects where the LocalAccounts module is available:

`Get-LocalUser | Select-Object Name, SID, Enabled, PrincipalSource`
<!-- mant:tldr:end -->

# lusrmgr.msc

## Overview

`lusrmgr.msc` opens the Local Users and Groups MMC snap-in for accounts and groups
in a member computer's local Security Accounts Manager (SAM). It can create,
rename, disable, delete, and change memberships or selected account properties
when the caller is authorized and the snap-in is available.

Local principals are scoped to one computer. A matching display name does not
make a local account the same principal as a domain, Microsoft Entra, Microsoft,
or another computer's local account; preserve the SID and authority.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `lusrmgr.msc`: Open Local Users and Groups for an explicitly identified non-domain-controller Windows computer.

The console file exposes no supported parameter contract documented here. Use
Microsoft.PowerShell.LocalAccounts cmdlets or `net.exe user`/`net.exe localgroup`
for scripted local management, and directory-management tools for domain/cloud
identities.

## Identity and token boundaries

Before a change, record computer, account/group SID, name, enabled state, flags,
group memberships, profile/data ownership, service/task dependencies, sign-in
rights, password/rotation owner, remote-access effects, and recovery principal.

Group-membership changes do not rewrite an already issued access token. A user,
service, scheduled task, or remote session may require a new sign-in/token before
the effective membership changes.

## Common mistakes

- Managing a same-named principal from the wrong authority or computer because a
  GUI label omitted the SID/authority.
- Removing the last usable administrator or remote-management principal without
  console/out-of-band recovery.
- Deleting an account before preserving profile, EFS/DPAPI keys, file ownership,
  scheduled tasks, services, credentials, audit history, and rollback.
- Adding a user to Administrators to fix an object ACL, user right, service
  identity, network restriction, or UAC issue without diagnosing the boundary.
- Assuming a membership change affects existing tokens immediately.
- Expecting the snap-in on every Windows edition or using it on a domain
  controller as if the DC maintained ordinary local SAM users/groups.
- Automating localized MMC rows instead of stable SIDs and typed objects.

## PowerShell behavior

`Start-Process lusrmgr.msc` opens the GUI. `Get-LocalUser`, `Get-LocalGroup`, and
`Get-LocalGroupMember` return typed local-principal objects where the module and
architecture support them. Preserve `SID` and `PrincipalSource` in pipelines.

When using `net.exe`, call it explicitly and check `$LASTEXITCODE`; its text can
be localized. Neither interface manages Active Directory or Microsoft Entra
identities merely because their names are displayed in a membership list.

## Version and platform differences

`lusrmgr.msc` is Windows-only. Availability varies by client edition, server
role, installed management tools, policy, and architecture. Local Users and
Groups cannot manage accounts on a domain controller as ordinary local accounts.

## Related documents

- [net.exe](net.exe.md)
- [compmgmt.msc](compmgmt.msc.md)
- [secpol.msc](secpol.msc.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[local accounts guidance](https://learn.microsoft.com/windows/security/identity-protection/access-control/local-accounts)
and [LocalUsersAndGroups policy reference](https://learn.microsoft.com/windows/client-management/mdm/policy-csp-localusersandgroups).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
