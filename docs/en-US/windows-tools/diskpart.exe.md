<!-- mant:tldr:start -->
# diskpart.exe

> Inventory, select, and detail Windows storage objects before any focus-dependent DiskPart change.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/diskpart.

- Start the elevated DiskPart interpreter:

`diskpart.exe`

- At the `DISKPART>` prompt, list disks before selecting one:

`list disk`

- Select a disk only after matching size, model, serial, bus, partition style, and online state:

`select disk {{disk-number}}`

- Verify the focused disk and its volumes before any change:

`detail disk`

- List partitions on the focused disk and confirm the focus marker:

`list partition`

- Leave DiskPart without changing storage:

`exit`
<!-- mant:tldr:end -->

# diskpart.exe

## Overview

`diskpart.exe` is an elevated interactive and scriptable interpreter for disks,
partitions, volumes, storage-area-network policy, and VHD/VHDX files. Most
commands act on the object that currently has focus. Focus persists and can
change implicitly: selecting a volume can change the related disk/partition,
and creating a partition focuses the new partition.

Disk numbers and drive letters are observations, not durable identity. Before
every destructive command, repeat `list`, `select`, and `detail`; match several
stable attributes and disconnect unrelated removable/backup disks when the
approved procedure permits it.

## Resolvable commands

<!-- mant:entries role=command case=insensitive -->
- `list`: List disks, partitions, volumes, or virtual disks and mark current focus.
- `select`: Put one exact disk, partition, volume, or virtual disk in focus for later commands.
- `detail`: Display identifiers and state for the focused object before any change.
- `filesystems`: Display filesystems supported for formatting the focused volume.
- `help`: Show installed DiskPart command or command-specific help.
- `assign`, `remove`: Add or remove a drive letter or mount-point association.
- `online`, `offline`: Change whether the focused disk or volume is available to Windows.
- `attributes`: Inspect or change disk/volume attributes such as read-only state.
- `automount`, `san`, `rescan`: Inspect or change storage arrival policy, SAN policy, or refresh visible storage.
- `create`: Create a partition, volume, or virtual disk and normally shift focus to the new object.
- `delete`: Delete the focused partition, volume, or virtual-disk object according to command-specific rules.
- `extend`, `shrink`: Change selected volume or partition size subject to layout and filesystem constraints.
- `active`, `inactive`: Change the MBR partition active marker; misuse can prevent boot.
- `gpt`, `set id`: Change partition attributes or type identifiers under the applicable partition scheme.
- `clean`: Remove partition/volume formatting from the focused disk; `clean all` writes every sector.
- `convert`: Convert the focused disk's partition/disk model according to command-specific preconditions.
- `uniqueid`: Inspect or change the focused disk identifier.
- `format`: Create a filesystem on the focused volume; `quick` is neither preview nor secure erase.
- `attach vdisk`, `detach vdisk`: Attach or detach the focused VHD/VHDX from the host.
- `create vdisk`, `compact vdisk`, `expand vdisk`, `merge vdisk`: Create or change a selected virtual-disk file and parent chain.
- `rem`: Add a comment line to a DiskPart script.
- `exit`: End the DiskPart interpreter.

## Script option

<!-- mant:entries role=option case=insensitive -->
- `/s FILE`: Run a reviewed DiskPart script file containing one command per line.

## Command-family map

| Family | Commands | Purpose and boundary |
| --- | --- | --- |
| Inventory/focus | `list`, `select`, `detail`, `filesystems`, `help` | Query first; the `*` in `list` marks focus, not approval. |
| Access/state | `assign`, `remove`, `online`, `offline`, `attributes`, `automount`, `san`, `rescan` | Changes host access, read-only/offline state, or storage-arrival policy. |
| Partition lifecycle | `create`, `delete`, `extend`, `shrink`, `active`, `inactive`, `gpt`, `set id` | Can change layout/bootability and cause immediate data loss. |
| Disk initialization | `clean`, `convert`, `uniqueid` | `clean` removes layout; `clean all` writes every sector; conversion and IDs affect discovery/boot. |
| Filesystem | `format` | Recreates filesystem metadata; `quick` is not a preview or secure erase. |
| Dynamic disks | `add`, `break`, `import`, `recover`, `repair`, `retain` | Legacy/dynamic-disk topology and redundancy operations need a platform runbook. |
| Virtual disks | `attach vdisk`, `detach vdisk`, `create vdisk`, `select vdisk`, `detail vdisk`, `compact vdisk`, `expand vdisk`, `merge vdisk`, `list vdisk` | The selected file, parent chain, host exposure, read-only state, and consumers matter. |
| Script control | `rem`, `exit`, per-command `noerr` | `noerr` can continue after operational errors and create partial state. |

`convert` is overloaded across Windows tools and DiskPart contexts. Within
DiskPart, consult command-specific help for the focused disk/volume and target
such as GPT/MBR/dynamic; the standalone `convert.exe` performs FAT-to-NTFS
conversion. Do not infer behavior from the word alone.

## Safe script design

Run a reviewed text file with `diskpart.exe /s "script.txt"`. Microsoft
documents one command per line and no empty lines; `rem` starts a comment.
Place inventory and `detail` checks in the same controlled transaction where
practical, but do not attempt to parse a human list and automatically reuse a
disk number without stable-identity validation outside DiskPart.

By default, an operational error stops a DiskPart script. Some commands accept
`noerr`, which continues after errors; syntax errors still stop. Avoid `noerr`
unless every later command is safe under each possible earlier failure, and
verify final state object by object. Microsoft also advises allowing at least
15 seconds between consecutive DiskPart script processes.

## Common mistakes

### Assuming disk 0 is always the OS disk or disk 1 is always USB

Enumeration changes with firmware, controllers, SAN, virtual disks, docking,
recovery media, and arrival order. Match unique ID/serial, model, bus/location,
size, partition/volume layout, boot/system markers, and intended asset. One
matching size is insufficient.

### Forgetting that focus persists or changes implicitly

A later `clean`, `delete`, `format`, or `set id` acts on current focus, not the
object mentioned several lines earlier in a log. Immediately reselect and
`detail` before every destructive phase; terminate on any mismatch.

### Treating `clean` as harmless preparation

`clean` removes partition/volume formatting metadata from the focused disk,
making all its volumes inaccessible and requiring recovery to regain data.
`clean all` additionally zeroes every sector and can take hours. Neither fixes
failing hardware, and neither should precede a verified backup and identity
gate.

### Believing quick format preserves or securely erases data

Quick format creates filesystem structures without a full surface write; it
still destroys the existing filesystem's ordinary accessibility. Full format
and `clean all` are lengthy writes but are not automatically the approved
sanitization method for SSDs, arrays, thin storage, or regulated media.

### Copying BIOS/MBR commands into UEFI/GPT deployment

`active` is an MBR boot concept; UEFI uses a correctly typed EFI System
Partition and firmware entries. Partition type IDs, ESP/MSR/recovery sizes,
filesystems, and attributes must follow the target Windows deployment guide,
not a generic `active` recipe.

### Using `noerr` as error handling

Continuing after a failed select/create/delete can redirect later work to stale
focus or leave a partially initialized disk. Capture DiskPart output and
process result, but also verify every expected disk, partition, filesystem,
letter, attribute, and boot artifact. Text “success” is not enough.

### Assuming sizes use bytes

DiskPart `size=` and offset/alignment units vary by command and are commonly
MB or KB. Read the installed command-specific help, calculate overflow and
rounding explicitly, and validate resulting boundaries/alignment.

### Shrinking or extending without filesystem/application checks

Unmovable data, snapshots, encryption, filesystem support, contiguous free
space, dynamic/thin provisioning, clustering, and workload ownership constrain
resize. Backup and verify at storage, filesystem, and application layers.

### Attaching or merging the wrong VHD chain

Canonicalize the VHD/VHDX path, identify its parent chain and active consumers,
use read-only attachment for inspection where supported, and never merge or
compact a chain used by a running VM or another host. A surfaced disk enters
the same focus/enumeration space as physical disks.

### Changing unique IDs to silence a collision

Duplicate disk signatures/GUIDs can cause offline state, but those IDs may be
referenced by BCD, clustering, backup, replication, or applications. Diagnose
the clone/import workflow and update dependent systems through an approved
procedure rather than assigning an arbitrary value.

### Ignoring SAN, automount, cluster, and ownership policy

Online/offline and automount changes can affect shared storage across boots or
arrivals. Confirm cluster ownership, reservation/fencing, SAN policy,
hypervisor controls, and vendor guidance before changing presentation.

## PowerShell behavior

DiskPart subcommands are not PowerShell commands; they run inside the
`DISKPART>` interpreter or a `/s` file. Do not pipe untrusted interpolated
values into DiskPart. Generate any script from validated scalar values, keep
it as a review artifact without secrets, capture stdout/stderr and
`$LASTEXITCODE`, and independently query final storage state with structured
Storage cmdlets.

## Version and platform differences

This Windows-only administrative family applies to supported Windows client,
server, Windows PE, and recovery environments, but command support varies by
basic/dynamic disk, MBR/GPT, removable media, filesystem, SAN/cluster policy,
VHD version, Windows build, and installed storage stack.

## Related documents

- [mountvol.exe](mountvol.exe.md)
- [bcdboot.exe](bcdboot.exe.md)
- [manage-bde.exe](manage-bde.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DiskPart family reference](https://learn.microsoft.com/windows-server/administration/windows-commands/diskpart)
and [script guidance](https://learn.microsoft.com/windows-server/administration/windows-commands/diskpart-scripts-and-examples).
The recurring question whether `clean` destroys existing data was cross-
checked against
[practitioner discussion](https://superuser.com/questions/1164515/will-diskpart-clean-destroy-existing-data)
and resolved using Microsoft's current focused-disk contract. Exact sources
and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Super User contributions are licensed under CC BY-SA 4.0.
