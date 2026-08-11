<!-- mant:tldr:start -->
# secpol.msc

> Open Local Security Policy only for an explicitly identified local-policy target; distinguish configured local settings from effective domain/MDM policy and runtime state.
> More information: https://learn.microsoft.com/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/how-to-configure-security-policy-settings.

- Resolve the console file without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\secpol.msc')`

- Open Local Security Policy interactively:

`Start-Process secpol.msc`

- Inspect effective advanced audit policy without changing it:

`auditpol.exe /get '/category:*'`
<!-- mant:tldr:end -->

# secpol.msc

## Overview

`secpol.msc` opens the Local Security Policy MMC console. It exposes local audit
policy, user-rights assignment, security options, Windows Defender Firewall,
public-key policy, software restriction, application control, IP security, and
other nodes depending on the operating system and installed components.

The console edits local policy; it is not a complete effective-policy viewer.
Domain Group Policy, MDM, security baselines, product configuration, and runtime
state can override or supplement what it displays.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `secpol.msc`: Open the Local Security Policy console for the local computer's configured policy.

The console file exposes no supported option interface documented here. Use
`secedit.exe`, `auditpol.exe`, `gpresult.exe`, policy-management tooling, CSP, or
the relevant security API for repeatable inventory and deployment.

## Configured versus effective policy

Record the setting path, local value, winning policy authority/GPO, scope,
security principal, target, refresh time, restart/sign-in requirements, and the
runtime evidence that demonstrates enforcement.

For advanced auditing, `auditpol` can report granular effective subcategories
that do not match the legacy/local summary visible in Local Security Policy.
Use `gpresult` or Group Policy Results for broader applied-policy evidence.

## Common mistakes

- Treating a value shown in `secpol.msc` as the merged effective result when the
  computer is managed by domain policy, MDM, or a security product.
- Changing user-rights assignment by account display name without preserving
  SIDs, existing principals, service identities, logon impact, and recovery.
- Mixing legacy audit categories with advanced audit subcategories and reading
  an apparent mismatch as corruption rather than querying `auditpol`.
- Assuming policy refresh means every setting is active immediately; some
  changes require a new token, sign-in, service restart, or system restart.
- Applying a security template or baseline without diff, ownership, exception,
  staged rollout, remote-access protection, and rollback.
- Automating localized console labels instead of exporting/querying the
  documented policy representations.

## PowerShell behavior

`Start-Process secpol.msc` only opens the GUI. Native tools such as `auditpol.exe`,
`secedit.exe`, and `gpresult.exe` emit text/files and native exit codes; call them
explicitly, quote slash parameters, capture output, and inspect `$LASTEXITCODE`
immediately.

Do not translate a GUI action into a direct registry write merely because a
backing value is observable. Policy processing can require additional metadata,
security descriptors, services, refresh, and supported ownership semantics.

## Version and platform differences

`secpol.msc` is Windows-only and its presence/nodes vary by client edition,
server role, installed features, and management policy. Domain controllers do
not have the same local-account/local-policy boundary as member computers.

## Related documents

- [auditpol.exe](auditpol.exe.md)
- [secedit.exe](secedit.exe.md)
- [gpresult.exe](gpresult.exe.md)
- [gpedit.msc](gpedit.msc.md)

## Sources and license

This original guide was adapted from Microsoft's
[security-policy configuration guidance](https://learn.microsoft.com/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/how-to-configure-security-policy-settings)
and [audit-policy result troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/auditpol-local-security-policy-results-differ).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
