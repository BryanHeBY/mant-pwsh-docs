<!-- mant:tldr:start -->
# wusa.exe

> Install or remove one reviewed Windows Update Standalone Installer package.
> More information: https://support.microsoft.com/help/934307.

- Display the interface supported by this Windows build:

`wusa.exe /?`

- Install one local MSU interactively:

`wusa.exe {{C:\Updates\update.msu}}`

- Install without UI or automatic restart during a maintenance window:

`wusa.exe {{C:\Updates\update.msu}} /quiet /norestart`
<!-- mant:tldr:end -->

# wusa.exe

## Overview

Windows Update Standalone Installer (`wusa.exe`) installs or uninstalls an
applicable `.msu` update package through the Windows servicing stack. It is not
a general archive extractor or the normal fleet-update orchestration API.
Package applicability, supersedence, uninstallability, elevation, pending
servicing state, and restart requirements must be checked on the target build.

## Syntax

```text
wusa.exe UPDATE.msu [options]
wusa.exe /uninstall UPDATE.msu [options]
wusa.exe /uninstall /kb:NUMBER [options]
```

## Options

<!-- mant:entries role=option case=insensitive attached=fixed -->
- `/?`: Display the exact switches supported by the installed WUSA version.
- `/quiet`: Run without user interaction; license terms are not displayed and a required restart is allowed unless constrained.
- `/norestart`: Prevent WUSA from restarting automatically; Microsoft documents that this is ignored without `/quiet`.
- `/uninstall`: Request removal of the selected package or KB where that update is uninstallable.
- `/kb:NUMBER`: Select the KB number for `/uninstall`; omit the `KB` prefix from `NUMBER`.
- `/extract:DIRECTORY`: Extract package contents on Windows versions that still expose this legacy switch; prefer supported DISM/package tooling when absent.
- `/warnrestart:SECONDS`: With `/quiet`, warn before a required restart on builds that expose the timed form.
- `/promptrestart`: With `/quiet`, prompt before restarting on builds that expose this form.
- `/forcerestart`: With `/quiet`, forcibly close applications and restart; this can lose unsaved work.

Restart switch availability and parameter forms have changed across Windows
generations. Do not copy an old WUSA command into current automation without
matching it to `wusa.exe /?` on the target.

## Inspect before servicing

Use a trusted local package, record its identity and signature, inspect package
metadata, and check current/pending servicing state:

```powershell
$package = (Resolve-Path 'C:\Updates\windows-update.msu').Path
Get-Item -LiteralPath $package | Select-Object FullName, Length, LastWriteTimeUtc
Get-FileHash -LiteralPath $package -Algorithm SHA256
Get-AuthenticodeSignature -LiteralPath $package |
    Select-Object Status, StatusMessage, SignerCertificate

dism.exe /Online /Get-Packages /Format:Table
if ($LASTEXITCODE -ne 0) { throw 'DISM inventory failed' }
```

Confirm the Microsoft catalog/source, exact KB and architecture, target product
and build, prerequisites, known issues, rollback plan, BitLocker/recovery-key
readiness, maintenance window, and whether the package is superseded.

## Install and interpret the result

```powershell
wusa.exe $package /quiet /norestart
$result = $LASTEXITCODE
if ($result -eq 3010) {
    'Installation succeeded; a controlled restart is required.'
} elseif ($result -ne 0) {
    $hex = '0x{0:X8}' -f ([uint32]$result)
    throw "WUSA returned $result ($hex)"
}
```

WUSA and the Windows Update Agent can return success/status HRESULT values as
well as Win32 codes. Preserve both signed decimal and eight-digit hexadecimal
forms, correlate Windows Setup/Update logs, and verify the installed package
state after any required restart. Do not reduce every nonzero value to the same
generic failure.

## Uninstall boundary

Not every cumulative, servicing-stack, feature, security, or permanent package
is uninstallable. Removing a security update can restore a vulnerability and
can be superseded by pending servicing. Use an approved incident/rollback plan,
verify the exact package identity, prefer a disposable reproduction first, and
confirm servicing health and build state after restart.

## PowerShell considerations

WUSA is a native GUI-capable servicing process. Pass the `.msu` path as one
argument and check `$LASTEXITCODE` immediately. Avoid `Start-Process -Wait`
without also capturing its process exit code; console silence in `/quiet` mode
is not evidence of success.

## Common mistakes

### Downloading and executing an arbitrary MSU in one pipeline

Separate acquisition, provenance/signature/hash inspection, applicability
review, execution approval, and post-restart verification.

### Pairing `/norestart` without `/quiet`

Microsoft documents that WUSA ignores `/norestart` unless `/quiet` is present.
Always control restart through the complete supported servicing workflow.

### Treating a returned process as completed servicing

Package state can be pending and requires reboot. Query servicing state and
logs after the coordinated restart.

## Version and availability

WUSA ships with Windows, but supported switches and package behaviors vary by
release. Microsoft no longer supports some legacy extraction/automation forms
uniformly. The target's `wusa.exe /?`, update catalog article, and servicing
stack guidance are authoritative for one deployment.

## Verification boundary

Current Microsoft Support syntax and servicing boundaries were reviewed. No
package was downloaded, extracted, installed, removed, staged, or queried, and
no restart or servicing-state change ran.

## Related documents

- [dism.exe](dism.exe.md)
- [sfc.exe](sfc.exe.md)
- [shutdown.exe](shutdown.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows Update Standalone Installer description](https://support.microsoft.com/help/934307)
and Windows servicing guidance. Exact page-level provenance is recorded in
`upstream/windows-tools.json`.

The cited Microsoft support content is used as technical reference. This
original adaptation is licensed under CC BY 4.0.
