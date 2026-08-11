<!-- mant:tldr:start -->
# fc.exe

> Compare two files; use `fc.exe` because PowerShell's `fc` alias is `Format-Custom`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/fc.

- Compare text with line numbers:

`fc.exe /l /n "{{old.txt}}" "{{new.txt}}"`

- Compare every byte of two files:

`fc.exe /b "{{old.bin}}" "{{new.bin}}"`

- Inspect the comparison result in PowerShell (0 identical, 1 different, 2 error):

`fc.exe "{{old.txt}}" "{{new.txt}}"; $LASTEXITCODE`
<!-- mant:tldr:end -->

# fc.exe

## Overview

`fc.exe` compares two files or matched sets and reports differences. In
PowerShell, bare `fc` aliases `Format-Custom`; always include `.exe` for the
native comparator.

## Options and status

<!-- mant:entries role=command case=insensitive -->
- `fc.exe`: Compare two files or two wildcard-matched file sets and report
  differences using the selected text or binary contract.

The following switches select comparison/display behavior. Source operands
remain path strings and wildcard pairing should be reviewed separately.

<!-- mant:entries role=option case=insensitive -->
- `/a`: For each group of text differences, display only the first and last
  line instead of every differing line.
- `/b`: Compare every byte; this is the appropriate built-in mode for binary
  equality.
- `/c`: Ignore letter case during text comparison.
- `/l`: Compare files as ASCII/text; this is the default except for documented
  binary filename extensions.
- `/lb`: Set the maximum number of consecutive mismatching lines retained for
  the text comparison's resynchronization buffer.
- `/n`: Prefix displayed text lines with line numbers.
- `/off`: Include files that have the offline attribute set; `/offline` is the
  documented full spelling.
- `/t`: Do not expand tab characters to spaces during text comparison.
- `/u`: Compare files as Unicode text under this legacy tool's contract.
- `/w`: Compress tabs and spaces for comparison and ignore leading/trailing
  whitespace.
- `/nnnn`: Set how many consecutive matching lines are required to
  resynchronize after a mismatch; replace `nnnn` with an integer.
- `/?`: Display installed command help.

Exit 0 means identical, 1 means different, and 2 means an error. Difference is
a normal comparison outcome, not necessarily a failed automation step.

## PowerShell boundaries

Call `fc.exe` explicitly because bare `fc` normally resolves to
`Format-Custom`. Capture `$LASTEXITCODE` immediately and branch on 0
(identical), 1 (different), and 2 (error). Native difference output is text;
use byte hashes or `Compare-Object`/another parser when typed results are needed.

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

- [find.exe](find.exe.md)
- [type](type.md)
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[fc reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fc).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
