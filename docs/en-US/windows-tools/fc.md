<!-- mant:tldr:start -->
# fc

> Compare two files; use `fc.exe` because PowerShell's `fc` alias is `Format-Custom`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/fc.

- Compare text with line numbers:

`fc.exe /l /n "{{old.txt}}" "{{new.txt}}"`

- Compare every byte of two files:

`fc.exe /b "{{old.bin}}" "{{new.bin}}"`

- Inspect the comparison result in PowerShell (0 identical, 1 different, 2 error):

`fc.exe "{{old.txt}}" "{{new.txt}}"; $LASTEXITCODE`
<!-- mant:tldr:end -->

# fc

## Overview

`fc.exe` compares two files or matched sets and reports differences. In
PowerShell, bare `fc` aliases `Format-Custom`; always include `.exe` for the
native comparator.

## Important modes and status

- `/l`: Line-oriented text comparison.
- `/b`: Byte-for-byte comparison.
- `/u`: Treat inputs as Unicode text under this tool's contract.
- `/n`: Show text line numbers.
- `/c`: Ignore text case.
- `/w`: Compress whitespace for comparison.

Exit 0 means identical, 1 means different, and 2 means an error. Difference is
a normal comparison outcome, not necessarily a failed automation step.

## Common mistakes

### Invoking `Format-Custom` by accident

Use `Get-Command fc -All` to see the conflict and call `fc.exe` explicitly.

### Using text mode for binary identity

Text options can normalize case, tabs, or whitespace and resynchronize after
differences. Use `/b` when every byte matters, and use hashes/signatures when
the workflow needs artifact identity or authenticity.

### Treating exit 1 as an operational error

Branch separately for identical, different, and comparison error. Read
`$LASTEXITCODE` before another native command overwrites it.

### Assuming wildcard comparisons form obvious pairs

Wildcard mapping can compare sets in surprising ways. Enumerate intended
pairs first when names are not identical and explicit.

## Version and platform differences

`fc.exe` is Windows-only. Encoding labels and text resynchronization are its
legacy rules, not a general Unicode diff contract.

## Related documents

- [find](find.md)
- [type](type.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's official
[fc reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fc).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
