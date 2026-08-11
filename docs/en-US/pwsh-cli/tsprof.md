<!-- mant:tldr:start -->
# tsprof

> Query an exact local or domain user's legacy RDS profile-path field before updating or copying RDS user configuration.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tsprof.

- Resolve the exact legacy executable:

`Get-Command tsprof.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Query one exact local user's RDS profile path:

`tsprof.exe /q /local "{{local_user}}"`

- Query one exact domain user's RDS profile path:

`tsprof.exe /q /domain:"{{example.com}}" "{{domain_user}}"`

- Collect resultant profile/folder-redirection policy in that user's real session before any update:

`gpresult.exe /user "{{EXAMPLE\domain_user}}" /scope user /r`
<!-- mant:tldr:end -->

# tsprof

## Overview

`tsprof.exe` queries or updates a user's legacy Remote Desktop Services profile
path and can copy RDS user-configuration information between two users. It
modifies fields exposed by RDS extensions in Local Users and Groups or Active
Directory Users and Computers; it does not copy profile files.

## Command forms

- `/q {/local | /domain:<domain>} <user>` queries the stored RDS profile path.
- `/update ... /profile:<path> <user>` updates that field.
- `/copy ... [/profile:<path>] <source> <destination>` copies RDS configuration
  from source to destination and optionally updates the destination path.
- Source and destination for `/copy` must both be local or in the named domain.

## Common mistakes

### Assuming `/copy` migrates the user's profile directory

It copies RDS configuration fields, not files, ACLs, registry hive, FSLogix
container, folder-redirection data or ownership. Design and validate the data
migration separately with the user signed out and a rollback copy.

### Treating the stored field as the effective profile or AppData path

Computer/user Group Policy, loopback processing, folder redirection, profile
version suffixes, FSLogix/other containers, local caches and session state can
override or supplement it. Correlate `gpresult`, event logs and actual paths in
a new test session.

### Confusing `/local` with the current computer in remote orchestration

TSProf has no documented remote-server operand. `/local` means accounts on the
machine where the process runs. Record exact host and execute only through an
approved remote-management channel when targeting another server.

### Copying from the wrong template user or overwriting the destination blindly

Query and export both identities/configurations, resolve stable SID/UPN/domain,
check active sessions and obtain the destination owner's approval. A same-name
user in another domain or local SAM is a different principal.

### Using a local drive path for a multi-host collection

A path such as `C:\Profiles` is local to each Session Host and may not roam.
For UNC paths, verify share/NTFS permissions, availability, capacity, version
layout, backup and access from every host under the user's token.

## PowerShell behavior

Call `tsprof.exe` explicitly, quote domain/profile/user arguments, and inspect
`$LASTEXITCODE`. Output is legacy human text. Prefer typed AD/local-account and
policy inventory for automation, but do not assume a modern cmdlet changes the
same RDS extension field.

## Version and platform differences

Windows-only legacy RDS profile administration. The executable may be absent or
the field may be superseded by policy/profile-container design on current
deployments. Broad Learn applicability does not prove the workflow is current.

## Related documents

- [gpresult](gpresult.md)
- [query](query.md)
- [robocopy](robocopy.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tsprof reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tsprof).
Precedence and effective-path failure modes were cross-checked against a Server
Fault case where the [RDS user-profile field and AppData path diverged](https://serverfault.com/questions/1047494/changes-to-the-value-for-remote-desktop-services-user-profile-path-do-not-take).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
