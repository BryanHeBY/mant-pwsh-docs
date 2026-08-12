<!-- mant:tldr:start -->
# secedit.exe

> Validate, export, and analyze Windows security templates before applying any settings.
> Except for installed help and syntax validation, run security database/system queries from an elevated, explicitly recorded context.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/secedit.

- Validate one security template's syntax without applying it:

`secedit.exe /validate "{{security-template.inf}}"`

- Reject existing output/log paths, then export selected effective security areas to new protected files:

`$cfg = "{{existing-directory\current-security.inf}}"; $log = "{{existing-directory\export.log}}"; foreach ($path in $cfg,$log) { if (Test-Path -LiteralPath $path) { throw "Refusing to replace $path" } }; secedit.exe /export /cfg $cfg /areas securitypolicy user_rights /log $log; if ($LASTEXITCODE -ne 0) { throw "SecEdit export failed: $LASTEXITCODE" }; Get-Item -LiteralPath $cfg,$log`

- Analyze against one template only after proving the dedicated database and log paths are new:

`$db = "{{existing-directory\analysis.sdb}}"; $log = "{{existing-directory\analysis.log}}"; foreach ($path in $db,$log) { if (Test-Path -LiteralPath $path) { throw "Refusing to replace $path" } }; secedit.exe /analyze /db $db /cfg "{{security-template.inf}}" /overwrite /log $log; if ($LASTEXITCODE -ne 0) { throw "SecEdit analyze failed: $LASTEXITCODE" }`

- Inspect the produced template and logs before considering configuration:

`Get-Content -LiteralPath '{{existing-directory\current-security.inf}}'; Get-Content -LiteralPath '{{existing-directory\analysis.log}}'`
<!-- mant:tldr:end -->

# secedit.exe

## Overview

`secedit.exe` validates security templates, imports them into a security
database, analyzes current settings against a database/template, exports
settings, generates rollback templates, and configures the local system.
Security areas include policy, restricted groups, user rights, registry/file
ACLs, and service security. Analyze/import operations change their `.sdb`
database even when they do not configure the operating system.

## Modes and options

<!-- mant:entries role=command case=insensitive -->
- `secedit.exe`: Validate/import/export/analyze security templates and databases,
  generate rollback material, or configure selected local security areas.

The leading slash modes are mutually distinct. `/analyze` compares;
`/configure` applies operating-system settings.

<!-- mant:entries role=option case=insensitive -->
- `/validate`: Validate the syntax of the following security-template INF file
  without proving target applicability or safety.
- `/import`: Import the selected template into a security database for later
  analysis/configuration.
- `/export`: Export selected security settings from a database/system to an INF.
- `/analyze`: Compare current system settings against the selected
  database/template and store analysis results in the database/log.
- `/configure`: Apply selected settings from the security database to the local
  system; this is the state-changing mode.
- `/generaterollback`: Generate a rollback template relative to a configuration
  template; it is not a complete recovery plan.
- `/db`: Select the required security database path.
- `/cfg`: Select the security-template INF path or required export destination,
  depending on mode; do not assume it always means an input template.
- `/mergedpolicy`: With `/export`, merge domain and local policy security
  settings into the output; this can expose domain policy in the artifact.
- `/rbk`: With `/generaterollback`, select the required rollback-template
  output path.
- `/overwrite`: Replace the database's prior composite template state instead
  of appending the supplied `/cfg` template.
- `/areas`: Restrict work to named security areas such as `securitypolicy`,
  `group_mgmt`, `user_rights`, `regkeys`, `filestore`, or `services`.
- `/log`: Write operation details to the following explicit log path.
- `/quiet`: Suppress screen/log output where supported; avoid it during review
  because silence is not success.
- `/?`: Display installed family help. On the recorded build, appending `/?`
  after any of the six modes still printed only the same two-line family
  syntax; use the official mode page for parameter details.

## PowerShell boundaries

`secedit.exe` changes its `.sdb` database even in workflows that do not apply
system settings. Use absolute protected paths, pass each file/value separately,
capture stdout, stderr, and `$LASTEXITCODE`, and preserve exported baseline and
logs. Do not infer safety from INF syntax validation; re-query effective policy,
accounts, ACLs, services, and recovery access after an approved configuration.

Read-only intent does not remove the privilege boundary. On the recorded
ordinary token, `/export /areas securitypolicy` returned 740
(`ERROR_ELEVATION_REQUIRED`), created no INF, and left a two-byte log at the
new requested path. Treat that as an access failure plus a partial output side
effect—not as an empty policy or a clean no-op—and clean only verified fixture
paths.

## Common mistakes

### Running `/configure` instead of `/analyze`

`/configure` applies settings from the database to the current system.
`/analyze` compares them. Keep distinct paths and reviewable commands, validate
the INF, export current state, analyze with a dedicated database, and require
explicit change approval before configure.

### Expecting `<mode> /?` to document that mode

On the recorded build, `/configure /?`, `/analyze /?`, `/import /?`,
`/export /?`, `/validate /?`, and `/generaterollback /?` all returned 0 but
only repeated the top-level two-line mode list. That is not evidence that
`/mergedpolicy`, `/rbk`, or other official mode parameters are unavailable.
Use the installed family list to discover modes and the current official mode
page to construct syntax; never probe syntax by supplying real paths.

### Omitting `/areas`

When configure has no area selection, all settings defined in the database can
apply, including group membership, user rights, registry/file ACLs, and service
security. Name the minimum intended areas and inspect every applicable entry.

### Reusing a database without understanding composition

Import/analyze can append a template to the database unless `/overwrite` is
used with `/cfg`. A reused composite database can contain earlier settings.
Use a dedicated, versioned path and record whether composition or replacement
is intentional.

### Assuming “new” in a runbook prevents file replacement

SecEdit receives ordinary paths and does not enforce the author's intent that
they be new. Preflight the database, INF, rollback, and log targets. `/overwrite`
explicitly replaces prior composite database state when a database exists, and
even a failed elevated-only operation can leave a log artifact. Verify every
output and native status before cleanup or follow-on work.

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
snap-in, so retain logs and exported artifacts usable without the GUI. On
Windows NT `10.0.26200.0`, installed file version `10.0.26100.8115` returned
0 for top-level `/?` and each tested `<mode> /?` form, but every form printed
only two nonempty family-syntax lines.

## Runtime evidence

Installed file version `10.0.26100.8115` returned 0 for top-level `/?` and each
of the six `<mode> /?` probes, but all printed only the same two nonempty
family-syntax lines. The page adds official `/mergedpolicy`, `/rbk`, and
mode-dependent `/cfg` direction and requires the locked per-mode reference for
details. No path or state was supplied in these help probes; elevated
disposable verification remains pending and configure is never required merely
for evidence.

## Related documents
- [auditpol.exe](auditpol.exe.md)
- [gpresult.exe](gpresult.exe.md)
- [reg.exe](reg.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[secedit family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/secedit),
[analysis syntax](https://learn.microsoft.com/windows-server/administration/windows-commands/secedit-analyze),
and [configuration syntax](https://learn.microsoft.com/windows-server/administration/windows-commands/secedit-configure).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
