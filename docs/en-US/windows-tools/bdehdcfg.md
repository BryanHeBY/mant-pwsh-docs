<!-- mant:tldr:start -->
# bdehdcfg

> Inspect legacy BitLocker system-partition prerequisites without shrinking, merging, activating, lettering, or restarting a disk.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/bdehdcfg.

- Confirm that the legacy preparation tool exists on this exact Windows installation:

`Get-Command bdehdcfg.exe -ErrorAction Stop`

- Display installed syntax before relying on an online platform banner:

`bdehdcfg.exe /?`

- Query the partitions BdeHdCfg considers valid on one exact drive:

`bdehdcfg.exe -driveinfo {{C:}}`

- Inventory disk number, partition style, boot/system roles, sizes, and offsets with structured PowerShell data:

`Get-Disk | Get-Partition | Format-Table DiskNumber, PartitionNumber, DriveLetter, Type, IsSystem, IsBoot, IsActive, Offset, Size`

- Preserve BitLocker conversion, protection, lock, and protector state before any partition plan:

`manage-bde.exe -status`

- Preserve active BCD entries and full identifiers before changing boot layout:

`bcdedit.exe /enum active /v`
<!-- mant:tldr:end -->

# bdehdcfg

## Overview

`bdehdcfg.exe` is a legacy elevated BitLocker Drive Preparation tool. It can
inspect partitions, create a system partition from default/unallocated/shrunk
space, merge an existing partition into the system role, assign a letter, and
restart after preparation. Microsoft's page says most Windows 7 installations
already let BitLocker setup repartition as needed; modern preinstalled and
deployed systems normally have an appropriate UEFI/GPT or BIOS/MBR layout.

Use this tool only when a target-host and deployment-specific BitLocker
procedure explicitly calls for it. A partition called “system” in Windows
boot terminology contains boot files; the currently running Windows volume is
often called “boot.” Those names are not interchangeable with a disk's label
or with the EFI System Partition.

## Operation map

| Form | Purpose | Boundary |
| --- | --- | --- |
| `-driveinfo drive:` | Display valid partition characteristics, total size, and maximum free space | Does not show all unallocated space in every four-partition layout; corroborate with Storage cmdlets. |
| `-target default` | Let the tool choose preparation space | Delegates a boot-critical layout decision; unsuitable without an exact approved design. |
| `-target unallocated` | Build the system drive from available unallocated space | Must identify disk, partition table, firmware mode, and required size/filesystem first. |
| `-target drive: shrink` | Shrink an existing volume and create a system drive | Moves layout boundaries and can fail on immovable data, filesystem, snapshots, or policy. |
| `-target drive: merge` | Use an existing drive as the system drive | Copies boot files and changes the active/system role; wrong identity can make Windows unbootable. |
| `-newdriveletter` | Assign a letter to the new system drive | Exposes a normally hidden boot partition and changes path assumptions. |
| `-size MB` | Set new system-partition size | Do not reuse historical sizes for current firmware, recovery, servicing, or deployment requirements. |
| `-quiet` | Suppress display and answer Yes to later prompts | Suppresses actions and errors as well as confirmation; it is not a safety flag. |
| `-restart` | Restart after preparation | Causes availability impact; the family syntax line and linked parameter set should be checked against local help. |

## Common mistakes

### Running it because BitLocker reports “not ready”

TPM ownership/attestation, Secure Boot, firmware mode, PCR policy, recovery
escrow, edition, Group Policy, encryption state, filesystem, and partition
layout are separate prerequisites. Diagnose the exact BitLocker event/error
and compare the existing layout with current deployment guidance before
repartitioning.

### Copying a Windows 7 MBR recipe onto a UEFI/GPT machine

Marking an arbitrary partition active is a BIOS/MBR action; UEFI normally boots
from a correctly typed FAT32 EFI System Partition with firmware entries.
Current systems may also have MSR and Windows Recovery partitions. Use the
target firmware/partition style and current Windows deployment design, not an
old `active` or 100-MB recipe.

### Confusing boot, system, OS, recovery, and encrypted volumes

Community recovery cases show that changing the active/system role can lead to
`BOOTMGR is missing`. Match disk unique ID, model/serial, partition GUID/type,
offset/size, filesystem, BCD store, firmware entry, current boot/system flags,
and BitLocker state. A drive letter alone is not durable identity.

### Using `default`, `shrink`, or `merge` as discovery

These are mutating target modes, not previews. `shrink` changes boundaries;
`merge` copies boot files and assigns a boot role; `default` lets the tool make
the choice. Preserve a tested backup, recovery key, BCD export, recovery media,
disk layout, and rollback procedure before an approved mutation.

### Enabling `-quiet` for automation first

Microsoft documents that `-quiet` hides all actions and errors and answers Yes
to subsequent prompts. It can turn a misunderstood layout into an unattended
boot outage. Establish a deterministic target, collect visible output in a
disposable representative lab, and independently verify partition and boot
state before considering unattended execution.

### Ignoring the fixed-drive write-denial Group Policy conflict

Microsoft documents a known conflict with “Deny write access to fixed drives
not protected by BitLocker.” Depending on target mode, the tool can leave a
RAW partition, fail formatting, or fail to copy boot files. Sequence partition
creation and policy application through the organization's approved deployment
process; do not disable security policy ad hoc on a production host.

### Assigning and keeping a drive letter on the boot partition

A temporary letter may assist an explicit recovery procedure, but permanent
exposure invites accidental writes and applications/indexers may treat it as
ordinary storage. Record the pre-state and remove only the approved access path
after verifying boot files, BCD/firmware, and restart behavior.

### Restarting before checking the new boot path

`-restart` reduces the chance to inspect partial state. Before restart, verify
the intended partition type/flags/filesystem, boot files, BCD store, firmware
entry, BitLocker state and recovery material. Maintain console access and known
bootable recovery media; a successful process exit is not a successful boot.

## PowerShell behavior

Call `bdehdcfg.exe` explicitly and pass a scalar drive string. Preserve native
stdout/stderr and `$LASTEXITCODE`, but independently query disks, partitions,
volumes, BCD/firmware, and BitLocker because native text is human-oriented and
localized. Never generate `-target`, `-size`, `-quiet`, or `-restart` from
untrusted inventory text.

## Version and platform differences

This is Windows-only legacy tooling. Microsoft's current command banner lists
supported Windows client/server releases, while the page's rationale and
layout model are rooted in older BitLocker deployment. Executable presence,
Core/WinPE environment, firmware, MBR/GPT, edition, policy, recovery layout,
and current deployment guidance determine applicability. Prefer modern setup,
Storage cmdlets, BCDBoot, and supported deployment workflows where applicable.

## Related documents

- [manage-bde](manage-bde.md)
- [bcdboot](bcdboot.md)
- [bcdedit](bcdedit.md)
- [diskpart](diskpart.md)

## Sources and license

This original guide was adapted from Microsoft's official
[BdeHdCfg family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bdehdcfg)
and its linked drive-info, target, drive-letter, size, quiet, and restart
references. The recurring boot/system/active-partition confusion was cross-
checked against
[a practitioner recovery question](https://superuser.com/questions/255772/system-reserved-partition-no-longer-marked-as-system),
then resolved using Microsoft's current boot and BitLocker boundaries. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Super User contributions are licensed under CC BY-SA 4.0.
