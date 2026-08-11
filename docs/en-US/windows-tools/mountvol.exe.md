<!-- mant:tldr:start -->
# mountvol.exe

> Map Windows volume GUID identities to drive letters and NTFS directory mount points before changing access paths.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mountvol.

- List local volume GUID paths and their current mount points:

`mountvol.exe`

- Show the volume GUID mounted at one exact drive letter or directory path:

`mountvol.exe "{{C:\mount-point}}" /L`

- Attach one exact volume GUID to an existing reviewed NTFS directory:

`mountvol.exe "{{C:\mount-point}}" "{{\\?\Volume{volume-guid}\}}"`

- Verify that mount point resolves to the intended volume GUID:

`mountvol.exe "{{C:\mount-point}}" /L`

- Remove only that access path without taking the volume offline:

`mountvol.exe "{{C:\mount-point}}" /D`
<!-- mant:tldr:end -->

# mountvol.exe

## Overview

`mountvol.exe` lists volume GUID names and current mount points, creates or
deletes a drive-letter/directory mount point, controls automatic mounting of
new basic volumes, cleans stale mount-point records, takes a basic volume
offline, and temporarily mounts the EFI System Partition.

A volume, its data, and its access paths are separate. One volume can have
multiple mount points; removing `/d` from one path does not delete the volume
or necessarily remove its other paths. The stable native identity has the
form `\\?\Volume{GUID}\` including the final backslash.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `mountvol.exe`: List Windows volumes or manage their drive-letter and NTFS
  directory access paths.

Creating a mount point uses `path volume-guid` with no switch. The target
directory must already exist on NTFS and should be empty and dedicated.

<!-- mant:entries role=option case=insensitive -->
- `/l`: Resolve one named mount point to its volume GUID path.
- `/d`: Remove only the named mount point.
- `/p`: Remove the named path, dismount the basic volume, and take it offline.
- `/n`: Disable automatic mounting of newly discovered basic volumes globally.
- `/e`: Re-enable automatic mounting of newly discovered basic volumes.
- `/r`: Remove stale mount-point directories and registry mappings for absent volumes.
- `/s`: Mount the EFI System Partition at the named drive letter.
- `/?`: Display syntax supported by the installed executable.

## Operation boundaries

| Form | Effect | Risk |
| --- | --- | --- |
| no arguments | Lists volume GUIDs and mount points | Output reveals storage topology but is read-only. |
| `path /l` | Resolves one mount point to a volume GUID | Confirm the path exists and is the expected access point. |
| `path volume-guid` | Creates an access path | The directory must already exist on NTFS; verify it is the intended empty mount directory. |
| `path /d` | Deletes that mount point | Other paths/data remain, but applications using this path lose access. |
| `path /p` | Deletes path, dismounts, and takes a basic volume offline | Closes open handles and is not a stronger synonym for `/d`. |
| `/n`, `/e` | Disables/enables automatic mounting of new basic volumes | Machine-wide policy affects later storage arrivals. |
| `/r` | Removes stale directories/registry settings for absent volumes | Can prevent a returning volume from regaining former paths. |
| `drive: /s` | Mounts the EFI System Partition | Exposes boot files; use a temporary known-free letter and remove it afterward. |

## Common mistakes

### Passing a PowerShell object instead of its volume GUID string

Native tools receive stringified text, not an object's `DeviceID` property.
Resolve a single volume, select its exact `Path`/`DeviceID` string, confirm the
value, and pass that property. Do not rely on default object formatting.

### Omitting the trailing backslash from a volume name

The documented identity is `\\?\Volume{GUID}\`; braces and the final slash are
part of the syntax. Quote the complete string in PowerShell so braces remain
literal and verify it against fresh inventory rather than transcribing a GUID.

### Mounting over a directory that already contains application data

While mounted, the directory exposes the target volume and hides access to the
underlying directory contents through that path. Use a dedicated existing
empty NTFS directory, confirm ACLs/ownership, links, backups, and application
configuration, and verify both before and after mounting.

### Using `/p` when `/d` was intended

`/p` removes the mount point, invalidates open handles, dismounts the basic
volume, and takes it offline. `/d` only removes the named mount point. Stop
workloads and use storage-owner procedures before any offline operation.

### Assuming one drive letter is the volume's identity

Letters can change across boots, recovery environments, SAN presentation, and
device arrival. Record volume GUID, disk/partition identifiers, filesystem,
label, size, serial/storage path, and every current mount point.

### Running `/r` as routine cleanup

`/r` deletes stale mount directories and registry mappings for volumes that
are currently absent. Removable, SAN, backup, or temporarily detached volumes
may be expected to return. Inventory ownership and desired remount behavior.

### Disabling automount and forgetting the global state

`/n` affects new basic volumes machine-wide and can surprise deployment,
backup, removable-media, clustering, or recovery workflows. Record the prior
state, intended duration, and explicit `/e` rollback; verify actual new-volume
behavior in an approved lab.

### Leaving the EFI System Partition exposed

`drive: /s` makes critical boot content directly reachable. Use an exact free
letter for a bounded boot-maintenance task, protect it from unrelated tools,
and remove the mount afterward. Mounting the ESP does not authorize edits.

### Assuming mount success proves application readiness

Verify the returned GUID, filesystem health, BitLocker lock state, permissions,
free space, application service identity, and expected path behavior. Mounting
cannot unlock BitLocker or make an unsupported filesystem/workload valid.

## PowerShell boundaries

Mountvol is a native text tool. Quote both paths, pass the scalar volume GUID
property rather than a storage object, and check `$LASTEXITCODE`. PowerShell
braces are safe inside a quoted GUID string but syntactic when unquoted. Prefer
structured Storage cmdlets for discovery while retaining Mountvol's exact
native identity during verification.

## Version and platform differences

This Windows-only administrative command applies to supported Windows client
and server releases. Directory mount points require NTFS. Basic/dynamic/
clustered/virtual/SAN storage ownership, automount policy, EFI availability,
BitLocker, filesystem state, and user privileges constrain operations.

## Related documents

- [manage-bde.exe](manage-bde.exe.md)
- [subst.exe](subst.exe.md)
- [bcdboot.exe](bcdboot.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Mountvol reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mountvol).
The recurring PowerShell object-versus-`DeviceID` failure was cross-checked
against
[practitioner discussion](https://stackoverflow.com/questions/11547239/mount-point-in-powershell)
and resolved by requiring an exact scalar volume GUID. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
