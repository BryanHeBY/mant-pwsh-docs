<!-- mant:tldr:start -->
# chcp.com

> Inspect or change one console session's active code page; this does not convert files and is only one part of PowerShell/native text encoding.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chcp.

- Display the active console code page without changing it:

`chcp.com`

- Inspect the three PowerShell/native-pipeline encodings that can differ from the active console code page:

`[pscustomobject]@{ Input = [Console]::InputEncoding; Output = [Console]::OutputEncoding; NativePipe = $OutputEncoding }`

- Resolve the actual Windows executable instead of assuming a shell builtin or function:

`Get-Command chcp.com -All`

- Scope UTF-8 code page 65001 to one new `cmd.exe` process and commands it starts:

`cmd.exe /d /c 'chcp 65001>nul & {{command}}'`

<!-- mant:tldr:end -->

# chcp.com

## Overview

`chcp.com` displays or changes the active console code page. With no number it
is read-only. A change affects programs started afterward in that console;
programs already running, other terminals, file bytes, PowerShell's parser,
and every API's encoding are separate concerns.

Code page 65001 identifies UTF-8, but `chcp 65001` alone does not guarantee an
end-to-end UTF-8 pipeline. The producer, pipe encoding, native program, console
input/output encodings, font/rendering stack, file reader/writer, BOM policy,
and PowerShell edition all have independent behavior.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `chcp.com`: Display the active console code page, or select the following
  numeric code page for programs started afterward in that console.

The number is an operand. A successful change is not file conversion or an
end-to-end native-pipeline encoding contract.

## Common mistakes

### Treating code-page selection as file conversion

CHCP changes console interpretation for a session. It does not rewrite an
existing file or attach reliable encoding metadata. Decode the source with its
known encoding and write a new verified file explicitly when conversion is the
goal; never infer encoding only from displayed text.

### Changing only CHCP inside PowerShell

PowerShell sends text to native stdin using `$OutputEncoding`, while
`[Console]::InputEncoding` and `OutputEncoding` affect console I/O. Their
defaults and caching differ between Windows PowerShell 5.1 and PowerShell 7.
Inspect all relevant values and test the exact native program with non-ASCII,
invalid-byte, newline, and BOM fixtures.

### Setting code page 65001 globally through Command Processor AutoRun

An AutoRun registry value affects every inheriting `cmd.exe`, including scripts,
installers, and recovery tools, and combines dangerously with existing AutoRun
content. Prefer a child `cmd.exe /d /c` with a scoped code-page change. If a
persistent policy is required, inventory both user/machine values and test all
legacy dependencies with rollback.

### Assuming all programs notice a mid-session change

Microsoft notes that programs already started, except Cmd.exe, continue using
their original code page. Restart the program in the intended environment and
record its own encoding switches; do not use the new `chcp` display as proof.

### Confusing display glyphs with correct bytes

A TrueType/raster font, console host, terminal, shaping support, and fallback
font can make correct bytes look wrong or wrong decoding look plausible.
Verify round-trip bytes and Unicode code points separately from appearance.

### Forgetting that code-page output is localized text

Do not parse “Active code page:” by language. If automation must obtain the
value, constrain the environment or use an API whose numeric result is stable,
and preserve target build/locale evidence.

## PowerShell boundaries

Use `chcp.com` explicitly. A change made directly in the current terminal is
session state and can affect later native commands, so save the original number
and restore it in `finally`, or isolate the entire operation in a child process.
Do not assume a PowerShell pipeline of objects remains objects after entering a
native tool: it is encoded text.

## Version and platform differences

This Windows-only utility is documented on supported Windows client and server
releases. Available code pages, OEM/ANSI defaults, UTF-8 behavior, console host,
fonts, system-locale settings, and PowerShell encoding defaults vary by build,
locale, edition, and host.

## Related documents

- [cmd.exe](cmd.exe.md)
- [type](type.md)
- [more.com](more.com.md)

## Sources and license

This original guide was adapted from Microsoft's official
[CHCP reference](https://learn.microsoft.com/windows-server/administration/windows-commands/chcp).
High-demand PowerShell/UTF-8 confusion was cross-checked against a detailed
[practitioner question and answers](https://stackoverflow.com/questions/57131654/using-utf-8-encoding-chcp-65001-in-command-prompt-windows-powershell-window);
Microsoft documentation and target-runtime evidence govern supported behavior.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
