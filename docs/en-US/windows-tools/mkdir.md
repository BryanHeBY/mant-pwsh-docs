<!-- mant:tldr:start -->
# mkdir

> Exact cmd synonym for `md`; PowerShell command resolution varies by platform.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/md.

- Open the complete command-resolution and directory-creation guide:

`mant md --source windows-tools`

- Create a directory tree explicitly through cmd:

`cmd.exe /d /c 'mkdir "{{C:\work\logs\2026}}"'`

- Use the explicit PowerShell operation:

`New-Item -ItemType Directory -Path '{{C:\work\logs\2026}}' -Force`
<!-- mant:tldr:end -->

# mkdir

## Meaning

In `cmd.exe`, `mkdir` is identical to `md`. In PowerShell on Windows, `mkdir`
normally resolves to a convenience function that calls `New-Item -ItemType
Directory`, so cmd switches and parsing do not apply. On another platform it
can resolve to a native executable instead. Use [md](md.md) for command
extensions, path verification, PowerShell resolution, and full diagnostics.

## Command identities

<!-- mant:entries role=command case=insensitive -->
- `mkdir`, `md`: In cmd, create one or more directories using the same builtin implementation.
- `New-Item`: In PowerShell, create a directory explicitly with `-ItemType Directory`.

Cmd has no separate `mkdir` option set. With command extensions enabled it
creates intermediate directories in the specified path; verify the final path
and type rather than treating no visible error as proof.

## PowerShell boundaries

On Windows PowerShell, `mkdir` is commonly a convenience function rather than
the cmd builtin. Its `-Force` follows `New-Item` behavior and does not override
ACLs. Resolve the name before using cross-platform automation.

## Version and availability

The cmd builtin is Windows-only. A PowerShell function or native `mkdir`
executable can own the same spelling on other hosts and has a different option
contract.

## Common mistakes

- Assuming a familiar cross-shell name has one portable option contract.
- Treating PowerShell `-Force` as a permission bypass.
- Creating a deep relative path without first verifying the current location.

## Related documents

- [md](md.md)
- [cmd.exe](cmd.exe.md)
- [rmdir](rmdir.md)

## Sources and license

This original alias guide is based on Microsoft's official
[md/mkdir reference](https://learn.microsoft.com/windows-server/administration/windows-commands/md)
and [New-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/new-item).
The Windows PowerShell convenience-function distinction is illustrated by
[mkdir vs New-Item, is it the same cmdlet?](https://stackoverflow.com/questions/50832054/mkdir-vs-new-item-is-it-the-same-cmdlets).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
