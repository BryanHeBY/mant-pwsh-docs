<!-- mant:tldr:start -->
# vol

> Display one drive's filesystem label and volume serial number through `cmd.exe`; neither value is a globally unique device identity.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/vol.

- Display the current Cmd drive's label and volume serial number:

`cmd.exe /d /c vol`

- Display the label and volume serial number for one explicit drive:

`cmd.exe /d /c 'vol {{X:}}'`

- Obtain typed label, filesystem, path, and unique-volume information for automation:

`Get-Volume -DriveLetter {{X}} | Select-Object DriveLetter, FileSystemLabel, FileSystem, UniqueId, Path, Size`

- Correlate the drive with its partition and physical disk before an identity-sensitive action:

`Get-Partition -DriveLetter {{X}} | Get-Disk | Select-Object Number, FriendlyName, SerialNumber, UniqueId, Size`

<!-- mant:tldr:end -->

# vol

## Overview

`vol` is a Cmd command that displays a drive's filesystem volume label and
volume serial number. With no drive it uses Cmd's current drive. It is read-only,
small, and human-oriented; its localized text is not a strong automation schema.

The displayed filesystem serial is not the same as a disk hardware serial,
GPT partition GUID, volume GUID path, filesystem object ID, BitLocker identity,
or cloud/virtual-storage identifier. Labels are mutable and non-unique.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `vol`: Display a selected drive's filesystem volume label and volume serial
  as localized Cmd text; it does not identify the physical disk globally.

## Common mistakes

### Running bare `vol` in PowerShell

Cmd builtins are not PowerShell commands. Invoke `cmd.exe /d /c vol` and make
the target drive explicit. `/D` disables Command Processor AutoRun commands,
which otherwise can modify output, directory, environment, or security context.

### Treating the volume serial as globally unique

Formatting, cloning, imaging, filesystem tools, or collisions can change or
duplicate identity values. Use the storage layer's durable identifiers and
correlate multiple fields immediately before destructive or security actions.

### Selecting by label alone

Several volumes can have the same label, and a label can be empty or changed.
Combine drive/access path, volume GUID, partition/disk identity, size,
filesystem, and expected ownership. Never choose the first label match.

### Parsing localized text when typed APIs exist

The label text, “Volume Serial Number” wording, spacing, and errors can vary by
locale. Prefer `Get-Volume`, CIM, or storage APIs for automation; retain VOL for
interactive compatibility and cross-checking.

### Confusing current PowerShell location with Cmd's current drive

PowerShell providers, per-drive locations, UNC paths, and a child Cmd process
have different current-location models. Pass `X:` explicitly instead of relying
on inherited state.

## PowerShell boundaries

Use a single quoted command string only for the simple, fixed Cmd builtin call;
do not concatenate untrusted input. Validate a drive letter against an allowlist,
capture raw output and `$LASTEXITCODE`, and prefer typed PowerShell objects for
logic.

## Version and platform differences

This Cmd builtin is Windows-only and documented on supported Windows client and
server releases. Output language, filesystem support, provider paths, mounted
volumes, recovery environments, and storage virtualization affect results.

## Related documents

- [label](label.md)
- [mountvol](mountvol.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's official
[VOL reference](https://learn.microsoft.com/windows-server/administration/windows-commands/vol).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
