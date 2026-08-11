<!-- mant:tldr:start -->
# edit

> Identify a dependency on the legacy full-screen MS-DOS Editor and migrate it to a supported text editor.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/edit.

- Check whether this host actually provides `edit.exe`:

`Get-Command edit.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Inspect a text file safely without relying on the legacy interactive editor:

`Get-Content -LiteralPath "{{C:\Legacy\AUTOEXEC.BAT}}" -Raw`

- Open a plain-text file in modern Notepad on an interactive Windows host:

`Start-Process notepad.exe -ArgumentList "{{C:\Legacy\notes.txt}}"`

- Detect encoding and binary content before converting a legacy file:

`Format-Hex -LiteralPath "{{C:\Legacy\notes.txt}}" | Select-Object -First 8`
<!-- mant:tldr:end -->

# edit

## Overview

`edit.exe` starts the interactive MS-DOS Editor for ASCII text. Its legacy
syntax accepts one or more files plus `/b` monochrome, `/h` maximum-height,
`/r` read-only, `/s` short-filename, and `/<nnn>` binary wrapping modes.

Use this page to recognize and migrate old instructions. A modern editor,
PowerShell text cmdlets, or a reviewed encoding-aware library is a better fit
for current automation.

## Common mistakes

### Assuming the Microsoft Learn banner guarantees `edit.exe`

The page describes DOS-era behavior while carrying a generated modern Windows
banner. Verify `Get-Command edit.exe`; do not install an unknown binary just to
make an old runbook work.

### Calling every text file ASCII

Legacy OEM/ANSI code pages, UTF encodings, CRLF conventions, control bytes, and
binary data are different. Preserve a copy, inspect bytes, choose an explicit
encoding, and verify round-trip content before conversion.

### Automating a full-screen editor

`edit.exe` is interactive. Keystroke automation is fragile and can overwrite
the wrong file. Use `Get-Content`, `Set-Content`, or a structured editor only
after defining encoding, newline, backup, and atomic-write behavior.

## PowerShell behavior

PowerShell does not supply an `edit` command. Command discovery may find a
third-party function or executable with that name, so resolve `edit.exe`
explicitly. `Get-Content -Raw` is useful for inspection; writing requires an
explicit encoding and a protected backup.

## Version and platform differences

The MS-DOS Editor is legacy Windows tooling and is commonly absent on 64-bit
and current systems. Its display and file interpretation depend on console and
OEM code-page behavior. Verify on the exact historical environment when
reproducing a legacy workflow.

## Related documents

- [type](type.md)
- [more](more.md)
- [chcp](chcp.md)

## Sources and license

Adapted as an original migration guide from Microsoft's
[edit reference](https://learn.microsoft.com/windows-server/administration/windows-commands/edit).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
