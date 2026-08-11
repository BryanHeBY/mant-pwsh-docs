<!-- mant:tldr:start -->
# autochk.exe

> Understand the startup-only NTFS checker; configure it with `chkntfs` instead of launching `autochk.exe`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/autochk.

- Query whether an exact volume is dirty without changing startup policy:

`fsutil.exe dirty query {{C:}}`

- Display the current startup-check policy for an exact volume:

`chkntfs.exe {{C:}}`

- Display the Autochk countdown without changing it:

`chkntfs.exe /t`

- Find the later boot-time check record without editing `BootExecute`:

`Get-WinEvent -FilterHashtable @{ LogName = 'Application'; ProviderName = 'Microsoft-Windows-Wininit' } -MaxEvents {{20}}`
<!-- mant:tldr:end -->

# autochk.exe

## Overview

`autochk.exe` is the startup form of CHKDSK. It checks NTFS volumes before
Windows fully starts when a volume is dirty, a boot-volume repair was
scheduled, or CHKDSK could not obtain exclusive access. Microsoft explicitly
states that it cannot be run directly from a command line. Use `chkntfs` to
inspect or configure startup checking and `chkdsk` for an attended scan.

## Invocation boundary

<!-- mant:entries role=command case=insensitive -->
- `autochk.exe`: Internal startup form of CHKDSK; never invoke directly.

Microsoft exposes no supported command-line parameters. Use `chkntfs` to
configure startup checking and `chkdsk` for a supported attended scan.

## Common mistakes

### Running Autochk as if it were CHKDSK

Do not invoke, copy, replace, rename, or wrap `autochk.exe`. Query the dirty bit
and current `chkntfs` policy, then use the supported tool for the intended job.

### Editing BootExecute from an online answer

`HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\BootExecute` is startup
configuration, not an ordinary command history. Incorrect values can suppress
checks or break startup processing. Prefer `chkntfs`; preserve the exact
multi-string value and a recovery route before any exceptional repair.

### Treating `/x` as a repair

`chkntfs /x` excludes volumes and its list is replaced, not accumulated, by a
later `/x`. It can hide a recurring dirty-volume symptom. Diagnose the cause
and schedule supported maintenance instead of permanently suppressing it.

### Assuming the startup screen is the durable result

Collect the Wininit event after boot and correlate it with the volume identity,
dirty state, storage health, and the command that scheduled the check.

## PowerShell boundaries

The useful PowerShell workflow invokes `fsutil.exe`, `chkntfs.exe`, and
`Get-WinEvent`; it does not invoke Autochk. Native output is localized text, so
do not use a translated sentence as the sole automation contract.

## Version and platform differences

This is a Windows-only, NTFS startup component. The Microsoft catalog lists
current Windows client and server releases, but startup, recovery, encryption,
cluster, and storage-stack conditions still affect when a check can run.

## Related documents

- [chkntfs.exe](chkntfs.exe.md)
- [chkdsk.exe](chkdsk.exe.md)
- [fsutil.exe](fsutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Autochk](https://learn.microsoft.com/windows-server/administration/windows-commands/autochk)
and [Chkntfs](https://learn.microsoft.com/windows-server/administration/windows-commands/chkntfs)
references. Recurring reports of missing Autochk and direct `BootExecute` edits
were used only to prioritize the supported-tool warning; unsupported repair
recipes were not adopted. Exact provenance is recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
