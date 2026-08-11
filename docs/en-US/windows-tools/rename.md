<!-- mant:tldr:start -->
# rename

> Exact cmd synonym for `ren`; unlike `ren`, it is not a built-in PowerShell alias.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ren.

- Open the complete wildcard and collision-safety guide:

`mant ren --source windows-tools`

- Rename one exact file explicitly through cmd without changing its directory:

`cmd.exe /d /c 'rename "{{C:\work\old.txt}}" "{{new.txt}}"'`

- Preview the explicit PowerShell operation:

`Rename-Item -LiteralPath '{{C:\work\old.txt}}' -NewName '{{new.txt}}' -WhatIf`
<!-- mant:tldr:end -->

# rename

## Meaning

In `cmd.exe`, `rename` is identical to `ren`. PowerShell does not provide a
built-in `rename` alias: on Windows it may be unresolved, while another
platform or profile can supply an application, function, or alias with that
name. PowerShell's built-in short alias for `Rename-Item` is `ren`. Use
[ren](ren.md) for in-place limits, wildcard surprises, collision review, and
safe batch rename guidance.

## Common mistakes

- Assuming the longer spelling has the same meaning in cmd and PowerShell.
- Supplying a new path even though rename operations are in-place.
- Applying a wildcard transformation without first reviewing old-to-new pairs.

## Sources and license

This original alias guide is based on Microsoft's official
[ren/rename reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ren)
and [Rename-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/rename-item).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
