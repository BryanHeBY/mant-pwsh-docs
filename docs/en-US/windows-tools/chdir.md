<!-- mant:tldr:start -->
# chdir

> Exact cmd synonym for `cd`; in PowerShell it normally aliases `Set-Location`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cd.

- Open the complete cmd navigation guide:

`mant cd --source windows-tools`

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

## Command identities and option

<!-- mant:entries role=command case=insensitive -->
- `chdir`, `cd`: In `cmd.exe`, display or change cmd's current directory using the same builtin implementation.
- `Set-Location`: Change PowerShell's current provider location using cmdlet parameter binding.

The following switch belongs only to the cmd builtin grammar.

<!-- mant:entries role=option case=insensitive -->
- `/d`: In cmd, change both the current drive and directory instead of only that drive's stored directory.

## PowerShell boundaries

PowerShell normally resolves `chdir` to `Set-Location`; cmd's `/d` is not a
PowerShell parameter. A child `cmd.exe /c` can change only its own location,
so combine navigation and dependent cmd operations inside that child command.

## Version and availability

The cmd builtin is available on supported Windows releases. PowerShell alias
availability can be changed by profiles or constrained sessions; inspect with
`Get-Command chdir -All`.

## Common mistakes

- Assuming the longer spelling bypasses PowerShell command resolution.
- Omitting `/d` when a cmd operation must also switch drives.
- Expecting a child `cmd.exe /c chdir ...` to change its parent shell.

## Runtime evidence

Exact cmd.exe 10.0.26100.1 `help CHDIR` printed the same 21-line location help,
no PowerShell error records, and returned 1 without changing location.
Protected synonym verification remains tied to the canonical CD fixture.

## Related documents
- [cd](cd.md)
- [cmd.exe](cmd.exe.md)
- [pushd](pushd.md)
- [popd](popd.md)

## Sources and license

This original alias guide is based on Microsoft's official
[cd/chdir reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cd)
and [Set-Location reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/set-location).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
