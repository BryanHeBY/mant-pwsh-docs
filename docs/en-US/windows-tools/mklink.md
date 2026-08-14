<!-- mant:tldr:start -->
# mklink

> Create a Windows symbolic link, hard link, or directory junction.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mklink.

- Inspect the intended target and parent before creating a link:

`Get-Item -LiteralPath '{{target}}', '{{link-parent}}'`

- Create a file symbolic link explicitly through cmd:

`cmd.exe /d /c 'mklink "{{link}}" "{{target}}"'`

- Create a directory symbolic link (use `/h` for a file hard link or `/j` for a junction):

`cmd.exe /d /c 'mklink /d "{{link}}" "{{target}}"'`

- Create a hard link to one file on the same volume:

`cmd.exe /d /c 'mklink /h "{{link}}" "{{target}}"'`
<!-- mant:tldr:end -->

# mklink

## Overview

`mklink` is a cmd builtin. With no type switch it creates a file symbolic link;
`/d` creates a directory symbolic link, `/h` a file hard link, and `/j` a
directory junction. The first path is the new link and the second is its target.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `mklink`: Create one Windows link through the `cmd.exe` builtin, with the new
  link path first and the existing/intended target path second.

Without a type switch the builtin creates a file symbolic link.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Create a directory symbolic link.
- `/h`: Create a hard link to a file on the same volume.
- `/j`: Create a directory junction.
- `/?`: Display installed builtin help through `cmd.exe`.

## PowerShell boundaries

There is no standalone `mklink.exe`; invoke the builtin through an explicit
`cmd.exe /d /c` string or use `New-Item -ItemType SymbolicLink/HardLink/Junction`
where the target PowerShell/filesystem supports it. Verify argument order,
link type, reparse target, `$LASTEXITCODE`, and privilege/policy result before
any recursive operation touches the new entry.

## Common mistakes

### Reversing link and target

Read the command as “create LINK pointing to TARGET.” Ensure the link path does
not exist, verify the target and link parent, then inspect the result as a
reparse point/link before using it.

### Treating all link types as interchangeable

Hard links reference the same file record and are restricted to a volume;
directory junctions and symbolic links have different target, privilege,
filesystem, and remote-path behavior. Choose the type from actual requirements.

### Recursively copying or deleting through a link unknowingly

Different tools copy the link, skip it, or traverse its target. Inventory links
and test the exact tool/options before recursive mutation. Removing the link
entry should not be confused with deleting the target tree.

### Assuming creation privilege is universal

Symbolic-link creation depends on privileges, Developer Mode/policy, filesystem,
and process context. Do not silently replace the requested type with a junction.

## Version and platform differences

This cmd builtin is Windows-only. Relative-target resolution and allowed link
types depend on filesystem, Windows configuration, and target location.

## Runtime evidence

The protected fixture created one empty task-owned target directory and ran
`mklink /J LINK TARGET` below the same verified temporary root. Under both
PowerShell collectors, the first path existed afterward as a reparse point and
the child returned `0`; cleanup removed the task root. Symbolic-link privilege,
hard links, remote targets, traversal, deletion through links, and caller-owned
paths remain outside this junction-only evidence.

## Related documents

- [attrib.exe](attrib.exe.md)
- [dir](dir.md)
- [rd](rd.md)
- [xcopy.exe](xcopy.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[mklink reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mklink).
Practical distinctions between Windows link types are reflected in
[What is the difference between a symbolic link and a hard link?](https://stackoverflow.com/questions/185899/what-is-the-difference-between-a-symbolic-link-and-a-hard-link/185903).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
