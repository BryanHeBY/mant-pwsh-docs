<!-- mant:tldr:start -->
# attrib.exe

> Inspect or change Windows file and directory attributes.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/attrib.

- Inspect one path before changing it:

`attrib.exe "{{C:\path\item}}"`

- Inspect matching files and directories recursively without following symbolic links for attribute changes:

`attrib.exe "{{C:\path\*}}" /s /d /l`

- Clear the read-only attribute on one verified file:

`attrib.exe -r "{{C:\path\file}}"`
<!-- mant:tldr:end -->

# attrib.exe

## Overview

`attrib.exe` displays, sets, or clears filesystem attributes. Common flags are
read-only (`r`), archive (`a`), system (`s`), hidden (`h`), offline (`o`), not
content-indexed (`i`), pinned (`p`), and unpinned (`u`). Prefix an attribute
with `+` to set it or `-` to clear it.

## Attributes and scope options

<!-- mant:entries role=command case=insensitive -->
- `attrib.exe`: Display attributes, or set/clear selected attributes on
  matching Windows filesystem entries.

Each listed `-LETTER` form clears an attribute; replace `-` with `+` to set
the same attribute. A path without an attribute modifier is read-only display.

<!-- mant:entries role=option case=insensitive -->
- `-r`: Clear read-only; the paired `+r` form sets read-only.
- `-a`: Clear archive; the paired `+a` form sets archive.
- `-s`: Clear system; the paired `+s` form sets system.
- `-h`: Clear hidden; the paired `+h` form sets hidden.
- `-o`: Clear offline; the paired `+o` form sets offline.
- `-i`: Clear not-content-indexed; the paired `+i` form sets it.
- `-x`: Clear no-scrub-data; the paired `+x` form sets it where supported.
- `-p`: Clear pinned; the paired `+p` form pins provider-backed content where
  the filesystem/provider implements that attribute.
- `-u`: Clear unpinned; the paired `+u` form marks content unpinned where
  supported.
- `-b`: Clear the SMR blob attribute; the paired `+b` form sets it on storage
  configurations that implement the attribute.
- `/s`: Apply to matching files below the path recursively.
- `/d`: Include matching directories as well as files; use with `/s` for a
  recursive directory scope.
- `/l`: Act on a symbolic link itself rather than its target.
- `/?`: Display installed command help.

## PowerShell boundaries

Use `attrib.exe` explicitly. PowerShell's `Get-Item`/`Get-ChildItem` expose
typed filesystem attributes but provider and link behavior still require
care. Native output is localized text; after a change check `$LASTEXITCODE`
and re-query the exact literal path and link/target identity.

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
- [xcopy.exe](xcopy.exe.md)
- [mklink](mklink.md)

## Sources and license

This original guide was adapted from Microsoft's official
[attrib reference](https://learn.microsoft.com/windows-server/administration/windows-commands/attrib).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
