<!-- mant:tldr:start -->
# bcdedit

> Inspect and back up Windows Boot Configuration Data before making narrowly scoped boot changes.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/bcdedit.

- List active entries with full identifiers from the current system store:

`bcdedit.exe /enum active /v`

- List operating-system loader entries from the current system store:

`bcdedit.exe /enum osloader /v`

- List UEFI firmware entries when the current machine uses UEFI:

`bcdedit.exe /enum firmware /v`

- Inspect every entry in one explicitly selected offline BCD store:

`bcdedit.exe /store "{{path\to\BCD}}" /enum all /v`

- Export the current system store before an approved change:

`bcdedit.exe /export "{{path\to\bcd-backup}}"`
<!-- mant:tldr:end -->

# bcdedit

## Overview

`bcdedit.exe` enumerates and changes Windows Boot Configuration Data (BCD)
stores. A store contains boot-manager, operating-system loader, resume,
recovery, memory-diagnostic, debugger, and inherited settings. On UEFI systems,
some commands also expose firmware NVRAM entries; those are not simply another
BCD file on every attached disk.

The default target is the running system's system store. `/store path` selects
an explicit offline store for most operations. `/enum active` shows active
entries, `/enum all` broadens scope, and `/v` prints full GUIDs instead of
friendly well-known identifiers. Administrative privileges are required for
modification, and an incorrect change can make Windows unbootable.

## Identifier and store model

Well-known identifiers include `{current}`, `{default}`, `{bootmgr}`,
`{fwbootmgr}`, `{memdiag}`, and several global settings objects. `{current}`
means the loader for the Windows instance currently running; `{default}` means
the loader selected by the current boot manager after its timeout. They need
not identify the same entry.

Use `/enum ... /v` to record full stable GUIDs before a multi-step change.
Always record whether a command targets:

- the current system store because `/store` is absent;
- a named offline BCD file through `/store`;
- UEFI firmware variables through a firmware-related command;
- the active loader, default loader, or another exact GUID.

Multiple disks can each carry a BCD store, while the firmware chooses which
boot path actually starts. Editing the running system store does not update
every BCD file on attached disks.

## Command families

| Goal | Commands | Safety boundary |
| --- | --- | --- |
| Discover | `/?`, `/enum`, `/v` | Enumeration scope and store identity still matter. |
| Back up/restore system store | `/export`, `/import` | `/import` deletes current system-store entries before restoring the backup. |
| Create/copy/delete entries | `/create`, `/copy`, `/delete` | Capture the returned GUID and verify display order and every required element. |
| Change elements | `/set`, `/deletevalue` | Use documented element types; restart is normally required to observe boot behavior. |
| Change boot selection | `/default`, `/displayorder`, `/bootsequence`, `/timeout` | One-time `/bootsequence` differs from persistent order/default changes. |
| Debug/EMS | `/debug`, `/bootdebug`, `/dbgsettings`, `/ems`, `/emssettings` | These are test/recovery facilities with security, networking, and availability effects. |

For complex or nonstandard structured automation, Microsoft recommends the
BCD WMI API rather than parsing BCDEdit's localized display text.

## Common mistakes

### Leaving braces unquoted in PowerShell

PowerShell treats `{...}` as a script block when it is not quoted. Pass BCD
identifiers as one literal native argument, for example
`bcdedit.exe /enum '{current}' /v`. The same applies to a GUID returned by
`/copy`. Avoid routing through `cmd.exe` merely to hide a quoting error, and
avoid `--%` when later arguments need PowerShell variable expansion.

### Editing the wrong BCD store

The absence of `/store` is meaningful: it selects the current system store.
Recovery media and attached offline disks often assign different letters than
the installed OS. Enumerate volumes, verify the BCD file and matching Windows
root, and run `/store path /enum all /v` before any offline edit. A successful
command against the wrong store changes nothing about the boot path in use.

### Confusing `{current}` with `{default}`

The running loader and boot-manager default can differ after dual-boot,
recovery, VHD, upgrade, or one-time boot selection. Resolve both through
enumeration and use the exact GUID when intent is not inherently virtual.

### Using `/set` recipes without the element's contract

Element names and values are typed and application-specific. Options copied
from tuning posts can reduce CPU/memory availability, select a wrong device,
load an alternate kernel/HAL, weaken code-integrity behavior, or enable a
debug transport. Check `bcdedit /? types`, the relevant application help, and
Microsoft's option reference; preserve the original value and rollback path.

### Enabling `testsigning` or `nointegritychecks` as a driver fix

These settings change kernel-code verification posture and can be blocked by
Secure Boot or affected by memory integrity. Use approved driver-signing and
test-lab procedures, not a generic troubleshooting recipe. Record BitLocker
and Secure Boot state before boot changes; do not disable protections casually.

### Importing a backup as a harmless merge

`/import` restores the system store from a prior `/export` and deletes current
entries first. The backup must correspond to the intended system, firmware,
disk layout, and recovery design. Inventory current state and keep bootable
recovery media before importing.

### Treating `/bootsequence` and `/displayorder` as equivalent

`/bootsequence` is a next-boot sequence that reverts afterward.
`/displayorder` changes persistent menu order, while `/default` changes timeout
selection. Verify the selected entry and one-time/persistent intent separately.

### Parsing descriptions to recover a newly created GUID

Descriptions are neither unique nor stable. Capture the exact GUID returned by
`/copy` or `/create`, verify it with `/enum {GUID} /v`, complete every required
element, and only then add it to a display order. Check `$LASTEXITCODE`; do not
assume a localized success sentence is a stable data format.

### Forgetting encryption and recovery dependencies

BCD, firmware, TPM measurements, Secure Boot, BitLocker protectors, recovery
environment, and boot files form one recovery design. Some changes can trigger
BitLocker recovery or fail policy checks. Preserve recovery material and use
the organization's approved suspend/resume procedure where Microsoft and the
device policy require it.

## PowerShell behavior

`bcdedit.exe` is a native text tool. Quote every `{identifier}` and store path,
check `$LASTEXITCODE` immediately, and protect exported stores and diagnostic
output. Do not parse column spacing or translated labels as an API. In a
32-bit PowerShell process on 64-bit Windows, filesystem redirection can hide a
System32-only executable; prefer a 64-bit administrative shell or the supported
`Sysnative` route from a 32-bit process.

## Version and platform differences

This Windows-only command applies to supported Windows client and server
releases. Available object types and settings depend on firmware (UEFI versus
BIOS), architecture, Windows version, Secure Boot, virtualization, debugger
support, and policy. Use the help installed on the target host and current
Microsoft option reference.

## Related documents

- [bcdboot](bcdboot.md)
- [cipher](cipher.md)
- [dism](dism.md)

## Sources and license

This original guide was adapted from Microsoft's official
[BCDEdit command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bcdedit),
[deployment option reference](https://learn.microsoft.com/windows-hardware/manufacture/desktop/bcdedit-command-line-options?view=windows-11),
and [boot-identifier guidance](https://learn.microsoft.com/windows-hardware/drivers/devtest/boot-options-identifiers).
The recurring PowerShell brace-quoting failure was cross-checked against
[practitioner discussion](https://stackoverflow.com/questions/41030701/unable-to-edit-with-bcdedit-filelds-in-powershell-cmd-exe-command-line-fails)
and resolved using PowerShell's native-argument rules. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
