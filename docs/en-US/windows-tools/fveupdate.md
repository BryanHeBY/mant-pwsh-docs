<!-- mant:tldr:start -->
# fveupdate

> Recognize the Windows Setup-owned BitLocker metadata updater; do not run it independently.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/fveupdate.

- Inspect BitLocker state through the supported management command:

`manage-bde.exe -status {{C:}}`

- Inspect protector identities without changing them:

`manage-bde.exe -protectors -get {{C:}}`

- Query Windows Setup events when an upgrade reports an FVE update failure:

`Get-WinEvent -FilterHashtable @{ LogName = 'System' } -MaxEvents {{200}} | Where-Object Message -Match 'FVE|BitLocker'`

- Confirm the installed file only for diagnostics; do not execute it:

`Get-Item "$env:SystemRoot\System32\FveUpdate.exe" -ErrorAction SilentlyContinue | Select-Object FullName, Length, VersionInfo`
<!-- mant:tldr:end -->

# fveupdate

## Overview

`FveUpdate.exe` is an internal tool used by Windows Setup during an operating
system upgrade to update BitLocker metadata. Microsoft explicitly states that
it cannot be run independently. Its catalog entry is useful for recognizing a
setup component, not as a supported BitLocker repair command.

## Invocation boundary

<!-- mant:entries role=command case=insensitive -->
- `fveupdate.exe`: Internal BitLocker metadata-update worker used by Windows Setup.

Microsoft exposes no supported direct syntax. Do not invoke it to repair or
upgrade a volume outside its owning Setup workflow.

## Common mistakes

### Executing the internal tool after a search result names it

Do not infer a public syntax, copy arguments from setup logs, or run the binary
manually. Use supported Setup recovery and BitLocker management procedures.

### Changing protectors before preserving recovery access

For an upgrade failure, first record encryption state, protector identity,
recovery-key escrow/access, setup phase, logs, and rollback state. Protector,
suspend/resume, decrypt, and metadata operations require a separately approved
plan; FveUpdate is not the shortcut.

### Treating file presence as proof that Setup completed the update

Binary presence and version do not prove the intended volume metadata changed.
Verify the supported upgrade outcome and BitLocker state, and keep the relevant
Setup and BitLocker event evidence.

## PowerShell boundaries

PowerShell is appropriate for read-only inventory and log collection, not for
calling this internal executable. Message filtering is exploratory and
localized; narrow final evidence by provider, event ID, time, and volume.

## Version and platform differences

This Windows-only component is owned by Windows Setup. Its behavior is an
implementation detail that can change by build, upgrade path, device encryption
policy, hardware security, and volume state.

## Related documents

- [manage-bde](manage-bde.md)
- [bdehdcfg](bdehdcfg.md)

## Sources and license

This original guide was adapted from Microsoft's official
[FveUpdate reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fveupdate).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
