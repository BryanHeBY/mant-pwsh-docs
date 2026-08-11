<!-- mant:tldr:start -->
# rmdir

> Exact cmd synonym for `rd`; `/s` permanently removes an entire directory tree.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rd.

- Open the complete safety guide:

`mant rd --source windows-tools`

- Inspect a tree before removal:

`cmd.exe /d /c 'dir /s /b /a "{{C:\path\directory}}"'`

- Remove one verified empty directory:

`cmd.exe /d /c 'rmdir "{{C:\path\empty-directory}}"'`
<!-- mant:tldr:end -->

# rmdir

## Meaning

In `cmd.exe`, `rmdir` is identical to `rd`. In PowerShell, bare `rmdir`
normally aliases `Remove-Item`, so `/s` and `/q` do not mean the cmd switches.
Use [rd](rd.md) for the complete syntax, recursive-deletion safety, reparse
points, current-directory limits, and diagnostics.

## Command identity and options

<!-- mant:entries role=command case=insensitive -->
- `rmdir`, `rd`: Remove directories through the same cmd builtin.

The following switches belong to cmd recursive deletion.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Remove the selected directory tree including files and subdirectories.
- `/q`: With `/s`, suppress confirmation for recursive deletion.

## PowerShell boundaries

PowerShell normally resolves `rmdir` to `Remove-Item`, where `/s` and `/q` are
path arguments rather than cmd switches. Use the full command appropriate to
the intended parser and preview the exact target and reparse boundaries.

## Version and availability

Cmd `rmdir`/`rd` is Windows-only. Current-directory ownership, ACLs, attributes,
open handles, reparse points, and filesystem behavior affect removal.

Cmd removal does not use the Recycle Bin and has no rollback transaction.
Protect required data before an approved recursive deletion.

## Common mistakes

- Copying cmd `/s /q` syntax directly into PowerShell.
- Adding recursive quiet deletion merely to suppress a nonempty error.
- Assuming a different spelling changes scope or recoverability.

## Related documents

- [rd](rd.md)
- [cmd.exe](cmd.exe.md)
- [erase](erase.md)

## Sources and license

This original alias guide is based on Microsoft's official
[rd/rmdir reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rd).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
