<!-- mant:tldr:start -->
# secedit

> Validate, export, and analyze Windows security templates before applying any settings.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/secedit.

- Validate one security template's syntax without applying it:

`secedit.exe /validate "{{security-template.inf}}"`

- Export selected effective security areas to a new protected template file:

`secedit.exe /export /cfg "{{existing-directory\current-security.inf}}" /areas securitypolicy user_rights /log "{{existing-directory\export.log}}"`

- Analyze the current system against one template using a dedicated database and log:

`secedit.exe /analyze /db "{{existing-directory\analysis.sdb}}" /cfg "{{security-template.inf}}" /overwrite /log "{{existing-directory\analysis.log}}"`

- Inspect the produced template and logs before considering configuration:

`Get-Content -LiteralPath '{{existing-directory\current-security.inf}}'; Get-Content -LiteralPath '{{existing-directory\analysis.log}}'`
<!-- mant:tldr:end -->

# secedit

## Overview

`secedit.exe` validates security templates, imports them into a security
database, analyzes current settings against a database/template, exports
settings, generates rollback templates, and configures the local system.
Security areas include policy, restricted groups, user rights, registry/file
ACLs, and service security. Analyze/import operations change their `.sdb`
database even when they do not configure the operating system.

## Common mistakes

### Running `/configure` instead of `/analyze`

`/configure` applies settings from the database to the current system.
`/analyze` compares them. Keep distinct paths and reviewable commands, validate
the INF, export current state, analyze with a dedicated database, and require
explicit change approval before configure.

### Omitting `/areas`

When configure has no area selection, all settings defined in the database can
apply, including group membership, user rights, registry/file ACLs, and service
security. Name the minimum intended areas and inspect every applicable entry.

### Reusing a database without understanding composition

Import/analyze can append a template to the database unless `/overwrite` is
used with `/cfg`. A reused composite database can contain earlier settings.
Use a dedicated, versioned path and record whether composition or replacement
is intentional.

### Treating `/generaterollback` as a complete recovery plan

It creates a rollback template relative to a configuration template and can
overwrite an existing rollback file. Protect the artifact and still maintain
tested console access, backup/recovery, account/ACL ownership records, and a
way to reverse changes that a template does not restore safely.

### Using `/quiet` while developing a security change

Suppressed output makes scope and failures easier to miss. Preserve an
explicit log and inspect `scesrv.log`, database analysis, exit status, and
post-change effective state; remember common logs can be overwritten.

### Moving a template between unlike computers blindly

SIDs, local accounts/groups, services, registry/file paths, policies, edition,
and domain authority can differ. Resolve identities and applicability on the
target and do not treat successful syntax validation as semantic safety.

## Version and platform differences

This executable is Windows-only and security configuration typically requires
elevation. Server Core lacks the MMC Security Configuration and Analysis
snap-in, so retain logs and exported artifacts usable without the GUI.

## Related documents

- [auditpol](auditpol.md)
- [gpresult](gpresult.md)
- [reg](reg.md)

## Sources and license

This original guide was adapted from Microsoft's official
[secedit family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/secedit),
[analysis syntax](https://learn.microsoft.com/windows-server/administration/windows-commands/secedit-analyze),
and [configuration syntax](https://learn.microsoft.com/windows-server/administration/windows-commands/secedit-configure).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
