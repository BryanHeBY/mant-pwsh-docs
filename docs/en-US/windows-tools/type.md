<!-- mant:tldr:start -->
# type

> Display text files with cmd.exe; bare `type` in PowerShell means `Get-Content`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/type.

- Display one text file explicitly through cmd:

`cmd.exe /d /c 'type "{{C:\path\file.txt}}"'`

- Read a text file with explicit PowerShell encoding:

`Get-Content -LiteralPath '{{C:\path\file.txt}}' -Encoding utf8`

- Read a whole text file as one PowerShell string:

`Get-Content -LiteralPath '{{C:\path\file.txt}}' -Raw`
<!-- mant:tldr:end -->

# type

## Overview

Cmd's `type` builtin writes one or more text files to standard output without
modifying them. PowerShell's `type` alias calls `Get-Content`, with different
parameters, encoding behavior, output objects, and wildcard semantics.

## Syntax

```text
type [DRIVE:][PATH]FILENAME [FILENAME ...]
```

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `type`: Write one or more named files to standard output through the
  `cmd.exe` builtin; it is not a standalone `type.exe`.

The builtin has no encoding selector, binary-safe mode, or stdin operand. Its
filenames are parsed by the child Cmd shell.

## PowerShell boundaries

Bare `type` normally resolves to `Get-Content`. Prefer the full cmdlet name
with `-LiteralPath`, `-Raw`, and explicit `-Encoding`. Invoke the builtin only
through `cmd.exe /d /c` when its exact byte-to-console text path is required;
check the child exit code and never display untrusted binary/control content.

## Common mistakes

### Using cmd syntax with PowerShell's alias

Check `Get-Command type -All`. Prefer `Get-Content -LiteralPath` in PowerShell,
or invoke the builtin through `cmd.exe /d /c`.

### Displaying binary or untrusted control data

`type` is a text display/filter, not a safe binary viewer. Binary bytes and
terminal escape/control sequences can produce misleading output or terminal
effects. Inspect unknown files with a hex-aware tool.

### Assuming encoding is detected reliably

Cmd output depends on file bytes, console/code-page behavior, redirection, and
the consumer. For deterministic PowerShell text, specify `-Encoding`; for
byte preservation, use byte-oriented APIs rather than either display command.

### Concatenating into an input file

Redirecting multiple `type` inputs to an output that is also selected as input
can corrupt or duplicate content. Use a distinct output and verify it.

## Version and platform differences

The cmd builtin is Windows-only. `Get-Content` is cross-platform, but defaults
and available encoding names differ between Windows PowerShell 5.1 and
PowerShell 7.

## Related documents

- [find.exe](find.exe.md)
- [findstr.exe](findstr.exe.md)
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[type reference](https://learn.microsoft.com/windows-server/administration/windows-commands/type).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
