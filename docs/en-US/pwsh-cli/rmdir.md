<!-- mant:tldr:start -->
# rmdir

> Exact cmd synonym for `rd`; `/s` permanently removes an entire directory tree.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rd.

- Open the complete safety guide:

`mant rd --source pwsh-cli`

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

## Common mistakes

- Copying cmd `/s /q` syntax directly into PowerShell.
- Adding recursive quiet deletion merely to suppress a nonempty error.
- Assuming a different spelling changes scope or recoverability.

## Sources and license

This original alias guide is based on Microsoft's official
[rd/rmdir reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rd).
Exact locked provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
