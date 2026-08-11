<!-- mant:tldr:start -->
# md

> Create a directory tree with the cmd.exe builtin; `mkdir` is identical in cmd.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/md.

- Create a directory and any missing parents with normal command extensions:

`cmd.exe /d /c 'md "{{C:\work\logs\2026}}"'`

- Create a directory explicitly with PowerShell and return its object:

`New-Item -ItemType Directory -Path '{{C:\work\logs\2026}}' -Force`

- Check what the short names mean in the current PowerShell session:

`Get-Command md, mkdir -All`
<!-- mant:tldr:end -->

# md

## Overview

`md` creates a directory or subdirectory in `cmd.exe`; `mkdir` is identical.
With command extensions enabled, as they are by default, one invocation also
creates missing intermediate directories.

In Windows PowerShell and PowerShell on Windows, `mkdir` is normally a
convenience function over `New-Item -ItemType Directory`, and `md` resolves
through that PowerShell command. On another platform, `mkdir` can instead be a
native executable. Do not assume a contract from the spelling alone.

## Syntax

```text
md [DRIVE:]PATH
mkdir [DRIVE:]PATH
```

Cmd offers no force, owner, ACL, or mode switch here. Creation still depends
on permissions, the filesystem, and whether an item already occupies a path
component.

## Command forms

<!-- mant:entries role=command case=insensitive -->
- `md`, `mkdir`: Create the named directory through equivalent Cmd builtin
  names; with extensions enabled, create missing intermediate directories.

## PowerShell boundaries

PowerShell commonly resolves `md`/`mkdir` to its own convenience commands,
not Cmd. Prefer `New-Item -ItemType Directory -LiteralPath` (or a deliberately
chosen `-Path`) and inspect the returned item. Invoke `cmd.exe /d /c md ...`
only for the builtin contract; check its exit code and verify the resolved
absolute path and resulting item type.

## Common mistakes

### Assuming `md` always invokes cmd

PowerShell resolves aliases and functions before cmd builtins, which are not
directly visible to it. Use `Get-Command md, mkdir -All`, prefer `New-Item` in
PowerShell scripts, or invoke `cmd.exe /d /c md ...` intentionally.

### Depending silently on command extensions

Intermediate-directory creation is an extension behavior. Normal supported
cmd sessions enable extensions, but a caller can use `/e:off`. Scripts that
require the behavior should control their cmd launch or create each level.

### Treating `-Force` as an ownership or permission override

PowerShell's `New-Item -Force` can make existing-container workflows
idempotent, but it does not bypass ACLs or convert an existing file into a
directory. Confirm the resulting item type with `Get-Item`.

### Hiding a path bug by creating parents automatically

Resolve and log the absolute target before creating deep paths. A typo in a
drive, environment variable, or working directory can otherwise produce a
valid tree in the wrong location.

## Version and platform differences

The cmd builtin is Windows-only. PowerShell's `New-Item` is cross-platform and
provider-aware, but the commands named `md` and `mkdir` vary by platform and
session. Inspect resolution and provider semantics on the target edition.

## Related documents

- [mkdir](mkdir.md)
- [cd](cd.md)
- [rd](rd.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's official
[md reference](https://learn.microsoft.com/windows-server/administration/windows-commands/md)
and [New-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/new-item).
The common PowerShell function-versus-cmdlet confusion is evidenced by
[mkdir vs New-Item, is it the same cmdlet?](https://stackoverflow.com/questions/50832054/mkdir-vs-new-item-is-it-the-same-cmdlets).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
