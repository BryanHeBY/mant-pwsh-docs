<!-- mant:tldr:start -->
# pwlauncher.exe

> Recognize the Windows To Go USB-first startup switch; inspect firmware and removable media before any boot-policy change.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pwlauncher.

- Confirm whether the executable exists and read its installed syntax:

`Get-Command pwlauncher.exe -ErrorAction SilentlyContinue; pwlauncher.exe /?`

- Inventory firmware mode without changing startup behavior:

`Get-ComputerInfo -Property BiosFirmwareType, BiosManufacturer, BiosVersion`

- Inventory currently attached USB disks before evaluating USB-first boot risk:

`Get-Disk | Where-Object BusType -EQ USB | Select-Object Number, FriendlyName, SerialNumber, PartitionStyle, OperationalStatus`

- Disable Windows To Go automatic USB-first startup after an approved change decision:

`pwlauncher.exe /disable; $pwlauncherExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# pwlauncher.exe

## Overview

`pwlauncher.exe` enables or disables Windows To Go Startup Options. When
enabled, compatible firmware attempts to boot an inserted USB device before
the internal Windows installation. Windows To Go stopped development in
Windows 10 version 1903 and does not support feature updates, so this command
primarily explains or retires legacy boot behavior rather than establishing a
new deployment design.

## Syntax

<!-- mant:entries role=command case=insensitive -->
- `pwlauncher.exe`: Query, enable, or disable the legacy Windows To Go startup option.

State changes affect firmware startup behavior and normally require a restart.

<!-- mant:entries role=option case=insensitive -->
- `/query`: Display the current Windows To Go startup-option state.
- `/enable`: Enable the startup option for compatible USB workspaces.
- `/disable`: Disable that startup option without blocking all USB boot paths.
- `/?`: Display installed syntax.

```text
pwlauncher /enable
pwlauncher /disable
```

Both forms are administrative mutations. The tool has no documented query
form; command presence or help output does not reveal the effective firmware
boot order or prove that a particular USB device will boot.

## Common mistakes

### Enabling it to boot one trusted USB device

The setting attempts USB boot generally, not by a cryptographically pinned
device identity. A malicious or unintended USB disk can be selected, and
multiple devices can create conflicts. Review Secure Boot, firmware policy,
physical access, removable-media controls, and recovery first.

### Treating `/disable` as complete USB-boot prevention

Microsoft describes it as disabling the Windows To Go startup option; firmware
can still be configured manually to boot USB. Verify effective firmware and
organizational endpoint policy separately.

### Using Windows To Go as a current portable-workspace strategy

The feature is no longer developed and cannot remain current through feature
updates. Use a supported deployment, recovery, VDI, or managed-device design
matched to the requirement.

### Rebooting before recording recovery access

Boot-policy changes can expose encryption recovery, unexpected media, or an
unbootable sequence. Preserve BitLocker recovery, current boot configuration,
firmware access, and a tested rollback before restart.

## PowerShell boundaries

PwLauncher is a native command with no documented state-query output. Capture
`$LASTEXITCODE`, but verify the next boot in a controlled window. Typed disk
inventory is a snapshot and must not be used to change or wipe the device.

## Version and platform differences

This is Windows-only legacy lifecycle tooling. Executable presence, firmware
USB support, UEFI/Secure Boot behavior, Windows To Go media, and policy vary by
hardware and build; Microsoft catalog applicability does not revive the
retired workspace feature.

## Related documents

- [bcdedit.exe](bcdedit.exe.md)
- [bcdboot.exe](bcdboot.exe.md)
- [manage-bde.exe](manage-bde.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[PwLauncher reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pwlauncher)
and Windows feature lifecycle guidance. Exact provenance is recorded in
`upstream/windows-tools.json`. Microsoft documentation and this adaptation are licensed
under CC BY 4.0.
