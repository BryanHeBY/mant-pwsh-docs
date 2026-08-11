<!-- mant:tldr:start -->
# chdir

> Exact cmd synonym for `cd`; in PowerShell it normally aliases `Set-Location`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cd.

- Open the complete cmd navigation guide:

`mant cd --source pwsh-cli`

- Run one cmd command after changing drive and directory:

`cmd.exe /d /c 'chdir /d "{{D:\work\project}}" && {{command}}'`

- Use the unambiguous PowerShell operation:

`Set-Location -LiteralPath '{{D:\work\project}}'`
<!-- mant:tldr:end -->

# chdir

## Meaning

In `cmd.exe`, `chdir` and `cd` have identical syntax and behavior. In
PowerShell, `chdir` normally aliases `Set-Location`; it is not an invocation of
the cmd builtin. Use [cd](cd.md) for the drive-specific current-directory
model, `/d`, child-process limits, and full diagnostics.

## Common mistakes

- Assuming the longer spelling bypasses PowerShell command resolution.
- Omitting `/d` when a cmd operation must also switch drives.
- Expecting a child `cmd.exe /c chdir ...` to change its parent shell.

## Sources and license

This original alias guide is based on Microsoft's official
[cd/chdir reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cd)
and [Set-Location reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/set-location).
Exact locked provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
