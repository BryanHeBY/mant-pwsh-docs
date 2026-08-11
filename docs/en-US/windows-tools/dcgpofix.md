<!-- mant:tldr:start -->
# dcgpofix

> Inventory and back up the two well-known default GPOs first; DcgpoFix is a
> last-resort disaster-recovery tool, not a cleanup or security-baseline command.
> More information: https://learn.microsoft.com/troubleshoot/windows-server/group-policy/dcgpofix-not-restore-default-domain-controller-policy-security-settings.

- Confirm the installed executable and display only its help:

`$cmd = Get-Command dcgpofix.exe -ErrorAction Stop; $cmd | Select-Object Source, Version; & $cmd.Source '/?'`

- Inventory the well-known default GPO identities in one exact domain:

`'31B2F340-016D-11D2-945F-00C04FB984F9','6AC1786C-016F-11D2-945F-00C04FB984F9' | ForEach-Object { Get-GPO -Domain "{{example.com}}" -Guid $_ } | Select-Object DisplayName, Id, GpoStatus, CreationTime, ModificationTime`

- Generate a read-only XML report for one exact default GPO:

`Get-GPOReport -Domain "{{example.com}}" -Guid "{{31B2F340-016D-11D2-945F-00C04FB984F9}}" -ReportType Xml`

- Back up one exact GPO to a protected existing directory before recovery work:

`Backup-GPO -Domain "{{example.com}}" -Guid "{{31B2F340-016D-11D2-945F-00C04FB984F9}}" -Path "{{D:\protected-gpo-backups}}" -Comment "Pre-recovery evidence {{change-id}}"`

<!-- mant:tldr:end -->

# dcgpofix

## Overview

`dcgpofix.exe` recreates the Default Domain Policy, the Default Domain
Controllers Policy, or both. It does not restore administrator-created GPOs and
does not reconstruct the exact prior security state. Microsoft recommends GPMC
backup/restore and reserves DcgpoFix for disaster recovery when a usable backup
of the default GPOs does not exist.

The well-known GUID identifies each default GPO even if someone renamed it.
Inventory GUID, display name, AD object, SYSVOL content, ACLs, links, versions,
WMI filters, and RSoP before interpreting what “default” means in that forest.

## Target map

- `/target:domain` recreates the Default Domain Policy, including settings that
  can affect password, account lockout, and Kerberos policy.
- `/target:dc` recreates the Default Domain Controllers Policy, including
  security rights and audit policy that can affect every DC.
- `/target:both` changes both well-known GPOs.
- `/ignoreschema` bypasses the tool/schema-version check; it is not a general
  compatibility solution and increases recovery uncertainty.

There is no preview, report-only, or rollback switch. Help is the only routine
safe DcgpoFix invocation.

## Common mistakes

### Using DcgpoFix to “clean up” an old domain

It is not a current Microsoft security baseline and cannot know legitimate
application, service, audit, user-right, or historical promotion changes. Build
new purpose-specific GPOs and review effective policy instead of erasing the two
default policies to make them look like a lab.

### Assuming it restores factory-exact security settings

Microsoft documents differences between a freshly promoted DC and the policy
recreated by DcgpoFix. Promotion builds security incrementally from preexisting
server state, which DcgpoFix cannot reconstruct. After an authorized recovery,
review every setting against the organization's approved baseline and current
Server security guidance.

### Running `/ignoreschema` after a version mismatch

The mismatch is a stop signal to identify the tool build, schema version,
forest history, and supported recovery method. Bypassing it can apply defaults
from an incompatible tool generation. Obtain matching tooling or Microsoft
support direction before considering the override.

### Backing up only the policy report

HTML/XML reports are evidence, not restorable GPO backups. Create and validate
GPMC backups, protect backup metadata and content, inventory AD/SYSVOL versions
and replication, and test restore in an isolated representative environment.

### Ignoring links and downstream impact

The well-known policies normally have sensitive domain/domain-controller links.
Recreation can alter authentication, audit coverage, logon rights, services,
applications, and incident evidence after replication. Capture RSoP for
representative principals and systems and define post-recovery verification.

### Treating a successful exit as completed recovery

Verify both AD and SYSVOL convergence on every relevant DC, GPO version pairs,
ACLs, links, effective policy, security logs, authentication, and business
workloads. Do not force replication or delete conflict artifacts merely to make
timestamps match.

## PowerShell behavior

Use `dcgpofix.exe` explicitly and capture `$LASTEXITCODE` and all output in an
approved recovery record. The GroupPolicy module provides typed inventory,
reports, backup, and restore operations but still requires domain, DC, GUID,
backup ID, and permissions to be explicit. GPO reports/backups can expose
scripts, paths, accounts, preferences, and security configuration; protect them.

## Version and platform differences

DcgpoFix is Windows Server tooling and requires the applicable AD DS/GPMC
environment and privileges. Defaults, schema compatibility, audit/security
settings, replication technology, and Group Policy features vary by Server
generation. Use the exact target build's help plus current Microsoft recovery
guidance.

## Related documents

- [gpresult](gpresult.md)
- [gpupdate](gpupdate.md)
- [gpfixup](gpfixup.md)
- [repadmin](repadmin.md)
- [dcdiag](dcdiag.md)

## Sources and license

This original guide was adapted from Microsoft's
[DcgpoFix reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dcgpofix),
its current warning that
[DcgpoFix cannot restore the original security state](https://learn.microsoft.com/troubleshoot/windows-server/group-policy/dcgpofix-not-restore-default-domain-controller-policy-security-settings),
and the official
[GPO backup and restore guide](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-backup-restore).
Real recovery concerns were cross-checked against a
[Server Fault default-policy question](https://serverfault.com/questions/1114901/).
Microsoft documentation governs recovery behavior. Exact sources and licenses
are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
