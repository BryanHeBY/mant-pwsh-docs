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

## Command identities

<!-- mant:entries role=command case=insensitive -->
- `rename`, `ren`: In cmd, rename selected files or directories in place through the same builtin.
- `Rename-Item`: In PowerShell, rename provider items; `ren` is its built-in alias and collides with cmd spelling.

## PowerShell boundaries

Bare `rename` is not the standard PowerShell alias, while `ren` normally is.
Use `Rename-Item -LiteralPath -NewName -WhatIf` for reviewed object operations
and `cmd.exe /d /c rename ...` only for exact cmd wildcard semantics.

## Version and availability

Cmd `rename`/`ren` is Windows-only and cannot move an item to another path.
PowerShell providers, profiles, platform commands, collisions, and permissions
can change the meaning or outcome.

Neither cmd nor PowerShell rename is a transactional bulk operation. Build and
review the complete old-to-new mapping, detect collisions and case-only changes,
then verify every result before removing a rollback copy.

## Common mistakes

- Assuming the longer spelling has the same meaning in cmd and PowerShell.
- Supplying a new path even though rename operations are in-place.
- Applying a wildcard transformation without first reviewing old-to-new pairs.

## Related documents

- [ren](ren.md)
- [cmd](cmd.md)
- [move](move.md)

## Sources and license

This original alias guide is based on Microsoft's official
[ren/rename reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ren)
and [Rename-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/rename-item).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
