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

## Options

<!-- mant:entries role=command case=insensitive -->
- `sort.exe`: Sort text records using the selected Windows collation and write
  the resulting text to standard output or one distinct output file.

Options may precede or follow the input filename in the documented syntax.
Keep input and `/o` output paths distinct.

<!-- mant:entries role=option case=insensitive -->
- `/r`: Reverse the sort order.
- `/unique`: Return one line for records that compare equal under this sort.
- `/l`: Select a supported locale/collation name; `C` is the documented
  alternative to the system locale.
- `/m`: Set the amount of main memory in kilobytes used by the sort operation.
- `/rec`: Set maximum input-record length up to 65,535 characters.
- `/o`: Write sorted text to the following output file instead of stdout.
- `/?`: Display installed command help.

The special positional form `/+N` starts comparison at one-based character
position `N`. It is part of the native syntax but is described outside the
semantic option list because the digits are embedded in the switch name.

## PowerShell boundaries

Bare `sort` normally resolves to `Sort-Object`. Use that cmdlet for properties,
typed numbers, and deliberate comparer logic. Call `sort.exe` for its text
contract, pass `/o` as a separate native argument pair, check `$LASTEXITCODE`,
and do not overwrite the input until the distinct result is validated.

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
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
