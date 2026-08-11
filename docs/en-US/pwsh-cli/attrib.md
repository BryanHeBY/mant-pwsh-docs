<!-- mant:tldr:start -->
# attrib

> Inspect or change Windows file and directory attributes.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/attrib.

- Inspect one path before changing it:

`attrib.exe "{{C:\path\item}}"`

- Inspect matching files and directories recursively without following symbolic links for attribute changes:

`attrib.exe "{{C:\path\*}}" /s /d /l`

- Clear the read-only attribute on one verified file:

`attrib.exe -r "{{C:\path\file}}"`
<!-- mant:tldr:end -->

# attrib

## Overview

`attrib.exe` displays, sets, or clears filesystem attributes. Common flags are
read-only (`r`), archive (`a`), system (`s`), hidden (`h`), offline (`o`), not
content-indexed (`i`), pinned (`p`), and unpinned (`u`). Prefix an attribute
with `+` to set it or `-` to clear it.

## Scope options

- `/s`: Apply to matching files below the path recursively.
- `/d`: Include directories as well as files.
- `/l`: Act on a symbolic link itself rather than its target.

## Common mistakes

### Changing a recursive wildcard before inspecting it

First run the same path and scope without any `+` or `-` change. Resolve the
absolute path, include directories deliberately, and identify links/reparse
points before modification.

### Treating read-only as an access-control boundary

Attributes are not ACLs. Clearing `r` does not grant permission, and setting it
does not protect content from a principal allowed to modify attributes/files.

### Forgetting system and hidden ordering

Microsoft documents that system/hidden attributes must be cleared before some
other attribute changes. Apply narrowly and verify the resulting attribute set.

### Confusing a link with its target

Use `/l` when the link object is intended. Without a link-aware scope, an
operation can affect the target rather than the visible link entry.

## Version and platform differences

This command is Windows-only. Supported attributes depend on filesystem,
storage tier, cloud provider, and Windows version.

## Related documents

- [dir](dir.md)
- [xcopy](xcopy.md)
- [mklink](mklink.md)

## Sources and license

This original guide was adapted from Microsoft's official
[attrib reference](https://learn.microsoft.com/windows-server/administration/windows-commands/attrib).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
