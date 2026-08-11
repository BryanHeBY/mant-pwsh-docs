<!-- mant:tldr:start -->
# ren

> Rename files or directories in place with cmd.exe; it cannot move them to another path.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ren.

- Rename one exact file; the new value is a name, not a path:

`cmd.exe /d /c 'ren "{{C:\work\old.txt}}" "{{new.txt}}"'`

- Preview files before a simple extension-only batch rename:

`cmd.exe /d /c 'dir /b /a:-d "{{C:\work\*.txt}}"'`

- Change one extension pattern after reviewing the preview:

`cmd.exe /d /c 'cd /d "{{C:\work}}" && ren "*.txt" "*.log"'`

- Preview a more flexible PowerShell rename without applying it:

`Get-ChildItem -LiteralPath '{{C:\work}}' -Filter '*.txt' | Rename-Item -NewName { $_.BaseName + '.log' } -WhatIf`
<!-- mant:tldr:end -->

# ren

## Overview

`ren` renames files or directories without changing their containing
directory; `rename` is identical cmd syntax. PowerShell includes `ren` as an
alias for `Rename-Item`, whose parameters and wildcard behavior differ.
`rename` is not a built-in PowerShell alias and can resolve differently by
platform or session.

## Syntax

```text
ren [DRIVE:][PATH]OLD_NAME NEW_NAME
rename [DRIVE:][PATH]OLD_NAME NEW_NAME
```

`OLD_NAME` may contain `*` or `?`. `NEW_NAME` may also use wildcards, but
matched characters are carried according to cmd's positional filename-mask
rules, not regular-expression capture groups.

## Command forms

<!-- mant:entries role=command case=insensitive -->
- `ren`, `rename`: Rename selected files or one directory in place through
  equivalent Cmd builtin names; the new operand cannot name another directory.

## PowerShell boundaries

Bare `ren` normally aliases `Rename-Item`, while `rename` can resolve
differently by session/platform. Prefer `Rename-Item -LiteralPath -NewName`
with `-WhatIf` for PowerShell transformations. Use `cmd.exe /d /c` only when
Cmd's positional wildcard-mask behavior is intended; check its exit code and
verify a precomputed old-to-new mapping because multi-item renames can be partial.

## Common mistakes

### Putting a directory path in the new name

The second argument must be a new name in the source directory. Cmd `ren`
cannot move across directories or drives. Use `move` when location changes.

### Treating destination wildcards as regex replacement groups

Patterns such as `ren *.jpg *-thumb.jpg` can produce surprising names because
cmd maps wildcard positions rather than appending to a captured stem. Preview
the exact file set and test transformations on copies. For nontrivial changes,
use object names and `Rename-Item -WhatIf`.

### Running PowerShell's aliases with cmd syntax

Use `Get-Command ren, rename -All`. In PowerShell scripts, prefer
`Rename-Item -LiteralPath ... -NewName ...`; invoke `cmd.exe /d /c` only when
cmd mask semantics are intended. Do not assume `rename` is another PowerShell
alias merely because cmd accepts that spelling.

### Renaming many files without collision analysis

The target name must be unique. Case-only changes, existing names, multiple
dots, short names, and transformations that collapse distinct inputs can
produce errors or partial completion. Compute and review old-to-new pairs
before applying a batch.

### Assuming a batch rename is transactional

Some entries can be renamed before a later collision fails. Keep a mapping or
backup, inspect exit status, and verify the final inventory.

## PowerShell-native alternative

`Rename-Item` supports `-LiteralPath`, pipeline input, `-WhatIf`, and script
blocks for computed names. Its `-NewName` also cannot be a different location;
use `Move-Item` to move and rename.

## Version and platform differences

The cmd builtin is Windows-only and follows Windows filename/filesystem rules.
`Rename-Item` is cross-platform and provider-aware; case sensitivity,
collisions, and allowed names depend on the provider and filesystem.

## Related documents

- [rename](rename.md)
- [move](move.md)
- [dir](dir.md)
- [for](for.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's official
[ren reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ren)
and [Rename-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/rename-item).
The recurring destination-wildcard surprise is evidenced by
[Renaming files in cmd using wildcards](https://stackoverflow.com/questions/8780097/renaming-files-in-cmd-using-wildcards).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
