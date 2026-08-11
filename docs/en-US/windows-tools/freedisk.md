<!-- mant:tldr:start -->
# freedisk

> Gate a batch step on an explicit free-space threshold; exit code `0` means enough space and `1` means insufficient space.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/freedisk.

- Check whether the current drive has at least an explicit amount free:

`freedisk.exe {{5GB}}; $hasSpace = ($LASTEXITCODE -eq 0)`

- Check an explicit local drive and preserve the result code immediately:

`freedisk.exe /d {{D:}} {{20GB}}; $freediskExitCode = $LASTEXITCODE`

- Query typed local volume capacity when a human-readable inventory is needed:

`Get-Volume -DriveLetter {{D}} | Select-Object DriveLetter, Size, SizeRemaining`

- Check an approved remote computer without putting a password on the command line:

`freedisk.exe /s {{server01}} /d {{D:}} {{20GB}}; $freediskExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# freedisk

## Overview

`freedisk.exe` tests whether a drive has at least a requested amount of free
space, mainly as an installation-script gate. Values can use byte through YB
suffixes. `/s` selects a remote computer without leading backslashes, and a
drive is required remotely. Its binary result is intentionally simpler than a
capacity report: `0` means enough space and `1` means not enough.

## Common mistakes

### Treating any nonzero value as an ordinary process crash

Code `1` is the documented negative answer. Capture it immediately and branch
deliberately; preserve output for other operational failures rather than
assuming every nonzero result only means insufficient space.

### Omitting the unit

Make units explicit (`MB`, `GB`, and so on). Do not depend on a reader or agent
remembering a default unit, and keep a margin for temporary files, rollback,
logs, growth, filesystem reserve, quotas, and concurrent workloads.

### Passing a password with `/p`

Command-line secrets can appear in process listings, logs, histories, and task
definitions. Prefer the current security context or an approved remoting/job
mechanism. Do not embed passwords in scripts.

### Confusing free space with usable installation capacity

Free bytes do not validate permissions, quotas, filesystem support, path
length, compression, cluster/shared-volume ownership, or future peak usage.
Run the product's supported prerequisite checks as well.

## PowerShell behavior

`Get-Volume` is better for typed local inventory; FreeDisk remains useful where
its exit contract is required. Capture `$LASTEXITCODE` before another native
command overwrites it. The native message is localized and should not be the
automation contract.

## Version and platform differences

This Windows-only command is cataloged for current Windows client and server
releases. Remote access, drive naming, authentication, quotas, cluster storage,
and the command's installed presence vary by environment.

## Related documents

- [fsutil](fsutil.md)
- [dir](dir.md)

## Sources and license

This original guide was adapted from Microsoft's official
[FreeDisk reference](https://learn.microsoft.com/windows-server/administration/windows-commands/freedisk).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
