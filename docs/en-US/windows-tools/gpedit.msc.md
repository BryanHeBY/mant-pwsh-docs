<!-- mant:tldr:start -->
# gpedit.msc

> Open Local Group Policy Editor only after identifying computer versus user scope and the governing authority; verify the resultant policy afterward instead of treating the editor's configured value as effective state.
> More information: https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-modeling-results.

- Confirm that the local editor is installed on this Windows edition:

`Get-Item "$env:SystemRoot\System32\gpedit.msc" -ErrorAction Stop`

- Open the Local Group Policy Editor:

`gpedit.msc`

- Read the currently applied user policy result without changing policy:

`gpresult.exe /scope user /r`
<!-- mant:tldr:end -->

# gpedit.msc

## Overview

`gpedit.msc` opens the Local Group Policy Editor for local computer and user
policy objects. It edits configured policy, not the Resultant Set of Policy
(RSoP). Domain, site, organizational-unit, MDM, security baseline and local
authorities can overlap, and a higher-precedence source can win.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `gpedit.msc`: Open the Local Group Policy Editor snap-in when present on the
  Windows edition; it edits configured local policy, not resultant policy.

## Common mistakes

- Assuming `gpedit.msc` is missing or corrupt when Windows Home does not include
  the editor. Do not download an unofficial `gpedit.msc` installer or copy policy
  binaries/templates from another edition.
- Editing User Configuration while expecting a computer-wide result, or editing
  Computer Configuration while testing under a different device/restart state.
- Equating `Enabled`, `Disabled` and `Not Configured` with a registry value's
  apparent Boolean meaning. Policy definitions specify their own value mapping,
  supported versions and cleanup behavior.
- Assuming the local setting wins on a domain-joined or managed device. Local
  policy normally has lower precedence than conflicting domain policy, and MDM
  and Group Policy interaction depends on the policy area and configured rules.
- Editing registry-backed policy directly, then being surprised when policy
  refresh restores the managed value. Fix the authoritative policy instead.
- Calling `gpupdate` or repeatedly rebooting before capturing `gpresult`, event
  logs, scope, identity, network/DC state and the winning policy source.
- Automating localized editor labels or importing unreviewed ADMX files. Treat
  templates as versioned definitions and use supported management interfaces.

## PowerShell boundaries

Use `Start-Process mmc.exe -ArgumentList 'gpedit.msc'` for interactive editing.
For evidence, invoke `gpresult.exe` explicitly and check `$LASTEXITCODE`; an
empty or access-denied report is not “no policy.” Protect HTML reports because
they expose identities, groups, paths and configuration. Use Group Policy
cmdlets/GPMC for domain GPO lifecycle rather than UI automation.

## Version and platform differences

`gpedit.msc` is Windows-only and is not present on every client edition,
notably Home editions. Policy nodes, ADMX/ADML templates, supported-on metadata,
MDM interaction and effective settings vary by Windows build, edition, installed
products, language, domain role and management authority.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` did not resolve the exact
`gpedit.msc` entry point. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. Local absence is availability evidence for this
host, not proof that the documented component is unavailable on another Windows
edition, role, or optional-feature set; it does not prove that the UI loads,
the current user is authorized, an optional snap-in or component is functional,
or any displayed or requested operation succeeds.

## Related documents
- [gpresult.exe](gpresult.exe.md)
- [gpupdate.exe](gpupdate.exe.md)
- [secedit.exe](secedit.exe.md)
- [mmc.exe](mmc.exe.md)

## Sources and license

Microsoft's [Group Policy overview](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview)
defines the editor's role, while
[Group Policy results guidance](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-modeling-results)
explains effective policy and precedence. A
[Microsoft Q&A thread about the missing editor](https://learn.microsoft.com/answers/questions/4186794/gpedit-msc-missing)
and a [Server Fault precedence question](https://serverfault.com/questions/1003509/will-group-policy-configurations-applied-locally-through-gpedit-override-domai)
identify recurring edition and authority mistakes; they are discovery evidence,
not syntax authority. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the Q&A sources retain their recorded terms.
