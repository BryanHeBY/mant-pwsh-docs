<!-- mant:tldr:start -->
# msdt

> Identify and migrate deprecated Microsoft Support Diagnostic Tool workflows; prefer current Settings/Get Help troubleshooters.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/msdt.

- Resolve the legacy executable without starting a pack or requesting a support passkey:

`Get-Command msdt.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Display local legacy syntax without running a diagnostic package:

`msdt.exe /?`

- Open the current Troubleshoot settings entry for an attended user:

`Start-Process 'ms-settings:troubleshoot'`

- Check whether the current Get Help app is present before reusing an old package name:

`Get-AppxPackage -Name Microsoft.GetHelp -ErrorAction SilentlyContinue | Select-Object Name,Version,InstallLocation`
<!-- mant:tldr:end -->

# msdt

## Overview

`msdt.exe` invokes legacy built-in, directory, `.diagpkg`, `.diagcfg`, or CAB
troubleshooting packs. Microsoft deprecated MSDT and redirected many built-in
troubleshooters to Get Help while retiring others. Presence of the executable
or a broad Learn applicability banner is not a commitment that a pack remains.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `msdt.exe`: Run a verified legacy Microsoft Support Diagnostic Tool pack.

The tool and many inbox packs are deprecated; pack selection does not guarantee
that a target build still supports it.

<!-- mant:entries role=option case=insensitive -->
- `/id`: Select a registered troubleshooting-pack ID.
- `/path`: Select a verified troubleshooting-pack directory or package path.
- `/cab`: Select a verified diagnostic Cabinet.
- `/diagcfg`: Select a verified diagnostic configuration file.
- `/param`: Supply noninteractive pack-specific name/value input.
- `/advanced`: Open advanced troubleshooting choices.
- `/custom`: Require confirmation for proposed resolutions, not read-only mode.
- `/moreoptions`: Offer additional troubleshooting choices where supported.
- `/dci`: Pass support-workflow context rather than ordinary pack selection.
- `/?`: Display installed syntax.

## Common mistakes

### Running `msdt.exe` with no package and treating the passkey prompt as a fix path

That route is for Microsoft support workflows. For ordinary problems, start
from Settings > System > Troubleshoot or current Microsoft support guidance;
do not seek or invent a passkey.

### Reusing a memorized `/id` on every Windows build

Package names and availability changed during the Get Help migration. Confirm
the exact active/retired status on the affected build instead of treating an
old blog command as an inbox API.

### Loading an untrusted `.diagpkg`, `.diagcfg`, CAB, or directory

Troubleshooting packs can collect data and apply resolutions. Never run a pack
from email, chat, a download, or an unverified support case. Verify provenance,
signature/hash, expected collectors/fixes, scope and data destination.

### Assuming `/custom` means read-only

It asks the user to confirm each possible resolution; it does not prevent
collection or changes. Capture the proposed action and obtain approval before
accepting it. Noninteractive `/param` input further removes human review.

### Interpreting code 0 as overall system health

MSDT documents `0` as at least one root cause fixed with none left not-fixed;
`1` means something remains, `2` means not found and `-1` means interruption.
These are pack results, not proof of root cause, durability, policy compliance,
or end-to-end service health.

## PowerShell boundaries

Call `msdt.exe` explicitly only for a verified remaining legacy workflow. GUI
execution and diagnostic completion may not align with a simple process wait;
retain pack logs/results rather than inferring success from launch. `Start-Process`
is appropriate for the attended Settings URI and returns before the user flow
finishes.

## Version and platform differences

Windows-only and deprecated. Microsoft planned full MSDT retirement after
moving custom-package support through a feature-on-demand transition. Current
Windows 10/11 troubleshooting inventory, Get Help behavior, and server support
must be checked at use time.

## Related documents

- [ms-settings](ms-settings.md)
- [dxdiag](dxdiag.md)
- [msinfo32](msinfo32.md)
- [eventvwr](eventvwr.md)

## Sources and license

This original migration guide was adapted from Microsoft's official
[MSDT command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/msdt),
[deprecated-feature resources](https://learn.microsoft.com/windows/whats-new/deprecated-features-resources),
and [active/retired troubleshooter inventory](https://learn.microsoft.com/troubleshoot/windows-client/windows-troubleshooters/active-and-retired-troubleshooters-windows-10).
Recent Microsoft Q&A demand around [unexpected passkey prompts](https://learn.microsoft.com/answers/questions/5821467/i-request-a-passkey-for-msdt-exe)
was used as a migration/error signal, not as the command contract.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation, Microsoft Q&A contribution, and this adaptation
are licensed under CC BY 4.0.
