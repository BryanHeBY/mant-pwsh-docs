<!-- mant:tldr:start -->
# convert.exe

> Recognize the Windows FAT/FAT32-to-NTFS conversion front end, verify the exact volume and backup first, and never confuse it with DiskPart conversion.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/autoconv.

- Confirm that the resolved executable is Windows' System32 File System Conversion Utility:

`Get-Command convert.exe -All | Select-Object Name, CommandType, Source, Version`

- Inventory one intended volume by durable identity without converting it:

`Get-Volume -DriveLetter {{D}} | Format-List DriveLetter, Path, UniqueId, FileSystem, FileSystemLabel, HealthStatus, Size, SizeRemaining`

- Display installed conversion syntax without naming a volume:

`convert.exe /?`

- Check the exact volume in read-only mode before a separately approved conversion:

`chkdsk.exe "{{D:}}"`
<!-- mant:tldr:end -->

# convert.exe

## Overview

Windows `convert.exe` is the supported front end for converting an existing FAT
or FAT32 volume to NTFS while retaining its files and directories. The change
is not an in-place route back to FAT/FAT32. If the volume cannot be locked, the
front end can arrange startup conversion through the internal `autoconv.exe`
worker after Autochk.

This is a filesystem mutation, not a health query, repair, backup, format,
partition-style conversion, or general file converter. A failed or interrupted
conversion, wrong volume identity, marginal device, insufficient working space,
or incompatible consumer can cause loss or downtime. Use only with a verified
restorable backup, stable power/storage, an approved maintenance and restart
plan, and post-conversion verification.

## Syntax and options

Installed Windows build `10.0.26200` reports this shape:

```text
CONVERT volume /FS:NTFS [/V] [/CvtArea:filename] [/NoSecurity] [/X]
```

The volume operand can be a drive letter, mount point, or volume name. Resolve
it against current disk/partition/volume identity immediately before a change;
do not select by a mutable label or remembered drive letter alone.

<!-- mant:entries role=command case=insensitive -->
- `convert.exe`: Convert one explicitly identified FAT/FAT32 volume to NTFS in
  place or schedule the supported startup worker when an immediate lock is not
  possible.

Every option below belongs to this executable's filesystem-conversion syntax,
not to the DiskPart interpreter.

<!-- mant:entries role=option case=insensitive -->
- `/fs:ntfs`: Select NTFS as the conversion target; this is required and is not
  a query or preview switch.
- `/v`: Request verbose native conversion output, which can reveal paths and
  volume/storage details.
- `/cvtarea`: Use the following contiguous root-directory file as the reserved
  location for NTFS system files in a preplanned conversion workflow.
- `/nosecurity`: Set converted files and directories so all users have access;
  this deliberately weakens the normal security outcome.
- `/x`: Force the volume to dismount before conversion; all open handles become
  invalid.
- `/?`: Display the installed executable's syntax without selecting a volume.

## Operation boundaries

| Form or state | Meaning | Boundary |
| --- | --- | --- |
| `convert.exe /?` | Installed help | Read-only on the recorded build; returned 0 and selected no volume. |
| `volume /FS:NTFS` | FAT/FAT32-to-NTFS conversion | Mutates filesystem metadata and is not reversible to FAT/FAT32 in place. |
| locked/in-use target | Startup scheduling may be offered | A schedule is pending work, not conversion success; verify after restart. |
| `/X` | Forced dismount before conversion | Invalidates workload handles and can interrupt applications. |
| `/NoSecurity` | Broad post-conversion access | Security-policy choice, not a compatibility convenience. |
| `/CvtArea:file` | Planned NTFS metadata placement | Requires a suitable exact root file and target-specific design; do not improvise. |

## Common mistakes

### Confusing `convert.exe` with DiskPart `convert`

Inside `DISKPART>`, `convert gpt`, `convert mbr`, `convert basic`, and
`convert dynamic` change a selected disk's partition or disk model. Windows
`convert.exe volume /FS:NTFS` changes one FAT/FAT32 filesystem to NTFS. The
contexts, focus rules, prerequisites, and failure consequences are unrelated.

### Trusting the bare name without checking resolution

Third-party tools, functions, scripts, aliases, or PATH order can own the word
`convert`. Resolve `convert.exe -All`, verify the expected signed System32 File
System Conversion Utility, and invoke the exact reviewed application. On the
recorded host both `convert` and `convert.exe` resolve only to
`C:\Windows\System32\convert.exe`, version `10.0.26100.7623`; that observation
is not portable to another host.

### Treating retained files as a backup guarantee

Conversion is designed to retain the tree, but it changes core filesystem
metadata in place. It cannot protect against wrong-target selection, device or
power failure, pre-existing corruption, application incompatibility, or a
mistaken security option. Test restore before the maintenance window and keep
the backup independent of the target volume.

### Assuming every FAT-family filesystem is supported

Installed help says FAT, and Microsoft's startup-worker reference names FAT and
FAT32. Do not infer exFAT, ReFS, network shares, optical media, or arbitrary
foreign filesystems. Inventory the exact current filesystem and stop on any
unsupported or ambiguous state.

### Using `/NoSecurity` to avoid permission planning

The switch makes converted content accessible to all users according to the
installed help. That can expose sensitive data and violates least privilege.
Design and test the intended ownership/DACL inheritance instead; if broad
access is explicitly required, record approval and verify the resulting ACLs.

### Forcing `/X` on a live workload

`/X` invalidates open handles. Stop and verify applications, shares, databases,
backup/VSS activity, encryption, clustering, and storage ownership through
their supported maintenance procedures. It is not a generic way to bypass a
lock error.

### Reporting a startup schedule as completed conversion

An in-use volume can require startup processing by AutoConv. Preserve the
prompt/result and `$LASTEXITCODE`, verify the approved schedule and downtime,
then after restart requery the filesystem, health, events, ACLs, applications,
and expected NTFS capabilities. A scheduled request is neither success nor a
safe reason to retry blindly.

## PowerShell boundaries

Use typed `Get-Disk`, `Get-Partition`, and `Get-Volume` inventory to validate a
single target, but pass only the exact scalar volume string to the native tool.
Capture localized output and `$LASTEXITCODE` immediately. Do not pipe a storage
object, interpolate an untrusted drive letter/path, answer prompts from
locale-specific text, or let native nonzero handling erase the distinction
between access, lock, scheduling, filesystem, space, and I/O failures.

## Version and platform differences

This Windows-only executable and the startup AutoConv path are present on the
recorded supported Windows build, but filesystem, boot/recovery environment,
edition, architecture, removable/virtual/cluster storage, encryption, filter
drivers, free space, and privilege affect availability and behavior. Microsoft's
current `/convert` web page documents the separate DiskPart command, so the
installed `convert.exe /?` output and AutoConv reference are required to identify
this executable's actual interface.

## Runtime evidence

On the recorded Windows host, both exact `convert` and `convert.exe` discovery
resolved only to `C:\Windows\System32\convert.exe`, version
`10.0.26100.7623`. Explicit `/?` printed 16 lines of FAT-to-NTFS syntax and
returned 0 without a volume operand. This establishes the installed Microsoft
binary and its help parser, not conversion success. No conversion, dismount,
schedule, AutoConv, filesystem, ACL, partition, volume, or reboot mutation is
permitted merely for verification; behavior requires a disposable recoverable
volume fixture.

## Related documents
- [autoconv.exe](autoconv.exe.md)
- [chkdsk.exe](chkdsk.exe.md)
- [diskpart.exe](diskpart.exe.md)
- [format.com](format.com.md)

## Sources and license

This original guide uses the installed Windows executable's help and identity,
plus Microsoft's official
[AutoConv reference](https://learn.microsoft.com/windows-server/administration/windows-commands/autoconv),
which identifies `convert.exe` as the supported scheduler and states that the
FAT/FAT32-to-NTFS change cannot be reversed in place. Exact provenance and the
remaining runtime requirements are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
