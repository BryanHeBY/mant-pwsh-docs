<!-- mant:tldr:start -->
# sort

> Sort text lines with sort.exe; bare `sort` in PowerShell means `Sort-Object`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/sort.

- Sort a file into a distinct output file:

`sort.exe "{{input.txt}}" /o "{{output.txt}}"`

- Reverse the line order and keep unique results:

`sort.exe /r /unique "{{input.txt}}"`

- Sort PowerShell objects by a property instead of their displayed text:

`{{objects}} | Sort-Object -Property {{property}}`
<!-- mant:tldr:end -->

# sort

## Overview

`sort.exe` sorts text records using Windows locale/collation rules and writes
text. PowerShell's bare `sort` aliases `Sort-Object`, which compares objects
and properties rather than feeding their display rendering to `sort.exe`.

## Useful options

- `/r`: Reverse the result.
- `/unique`: Return unique lines.
- `/+N`: Start comparison at one-based character position N.
- `/l LOCALE`: Select supported collation; `C` is the documented alternative.
- `/rec N`: Set maximum record length, up to 65,535 characters.
- `/o FILE`: Write to an output file.

## Common mistakes

### Running the PowerShell alias unintentionally

Use `Get-Command sort -All`; call `sort.exe` for its text contract and
`Sort-Object` for object-aware sorting.

### Expecting invariant or numeric ordering

Default collation follows system locale/code-page settings and is
case-insensitive. It is not numeric sorting. Use typed PowerShell properties
or an invariant application contract when reproducibility matters.

### Writing output over the input

Use a distinct `/o` file and replace the original only after validation.
In-place redirection can truncate data before sorting reads it.

### Forgetting `/+N` is one-based and character-oriented

Short records sort before longer ones at that position. It is not a parsed
column/key selector.

## Version and platform differences

This executable is Windows-only and host locale affects order. Other
platforms' native `sort` utilities have unrelated options and collation rules.

## Related documents

- [find](find.md)
- [findstr](findstr.md)
- [type](type.md)

## Sources and license

This original guide was adapted from Microsoft's official
[sort reference](https://learn.microsoft.com/windows-server/administration/windows-commands/sort).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
