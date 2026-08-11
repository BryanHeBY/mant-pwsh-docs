<!-- mant:tldr:start -->
# subst.exe

> Associate a local path with a drive letter in the current Windows logon context.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/subst.

- List current substituted drives:

`subst.exe`

- Associate an unused drive letter with an existing local path:

`subst.exe {{X:}} "{{C:\long\path}}"`

- Remove one verified substituted drive without deleting its target directory:

`subst.exe {{X:}} /d`
<!-- mant:tldr:end -->

# subst.exe

## Overview

`subst.exe` creates a virtual drive-letter view of a path. With no arguments it
lists current substitutions; `DRIVE: /d` removes a substitution. This changes
name resolution, not the underlying files, partition, volume, or mount layout.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `subst.exe`: List substitutions, associate an unused drive letter with one
  local path, or remove exactly one substitution.

The drive-letter and target path are operands. Removal changes only the name
mapping and never deletes target content.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Delete the substitution for the preceding exact drive letter.
- `/?`: Display installed command help.

## PowerShell boundaries

Call `subst.exe` explicitly and remember that the mapping belongs to the
current user/logon/elevation context, not a PowerShell drive provider. Check
`$LASTEXITCODE`, run `subst.exe` again in the consuming context, and never pass
the substituted letter to volume-management tools as if it identified a volume.

## Common mistakes

### Assuming the mapping is persistent

`subst` has no persistence option. A logon/startup mechanism must recreate a
desired mapping, and that mechanism needs an explicit lifecycle and collision
policy.

### Expecting ordinary and elevated sessions to share it

UAC can place mappings in separate logon contexts. Query `subst` from the exact
process context that consumes the drive; do not infer visibility from Explorer
or a differently elevated shell.

### Treating the virtual drive as a real volume

Microsoft explicitly excludes volume/disk tools such as `chkdsk`, `format`,
and `label`. Apply volume operations to the real volume, not the substitution.

### Reusing an occupied drive letter

Inventory existing local volumes, network mappings, and substitutions first.
Removing a substitution exposes the underlying meaning of that letter if one
exists; it does not remove target content.

## Version and platform differences

This executable is Windows-only. Visibility varies by user, logon session,
elevation, service context, and remote-session setup.

## Related documents

- [cd](cd.md)
- [pushd](pushd.md)
- [reg.exe](reg.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[subst reference](https://learn.microsoft.com/windows-server/administration/windows-commands/subst)
and Microsoft's explanation of
[mapped drives in elevated prompts](https://learn.microsoft.com/troubleshoot/windows-client/networking/mapped-drives-not-available-from-elevated-command).
The same context boundary for substituted drives is illustrated by
[Batch file working differently in administrator mode](https://stackoverflow.com/questions/37182329/batch-file-working-differently-if-ran-in-administrator-mode).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
