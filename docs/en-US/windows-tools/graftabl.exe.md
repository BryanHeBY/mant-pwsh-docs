<!-- mant:tldr:start -->
# graftabl.exe

> Diagnose a legacy graphics-character-set dependency; use `chcp` for the console code page on modern Windows.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/graftabl.

- Check whether the legacy executable exists:

`Get-Command graftabl.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Display the graphics code page on a compatible legacy system:

`graftabl.exe /status`

- Display the active console code page instead:

`chcp.com`

- Inspect PowerShell's input and output encodings separately:

`[pscustomobject]@{ Input = [Console]::InputEncoding.WebName; Output = [Console]::OutputEncoding.WebName; NativePipe = $OutputEncoding.WebName }`
<!-- mant:tldr:end -->

# graftabl.exe

## Overview

`graftabl.exe` loads an extended graphics character set for a DOS-style display
and reports its previous/current graphics code page. Microsoft marks it legacy
and normally not installed on modern Windows. Its documented code pages are
437, 850, 852, 855, 857, 860, 861, 863, 865, 866, and 869.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `graftabl.exe`: Load or report a DOS-display extended graphics code page.

The positional code-page number changes display glyph mapping, not input or
file encoding.

<!-- mant:entries role=option case=insensitive -->
- `/status`: Display the graphics code page previously and currently selected.
- `/?`: Display installed legacy syntax.

## Common mistakes

### Using Graftabl to change console input or file encoding

Microsoft explicitly says it affects only the displayed graphics character set.
It does not change the actual console input code page. Use `chcp`/`mode` for the
legacy console code page, and configure PowerShell/.NET/file encodings at their
own boundaries.

### Assuming a code-page number identifies a file encoding

Display glyphs, input decoding, native-process pipe encoding, and bytes stored
in a file can differ. Capture all relevant settings and inspect the original
bytes before translating text.

### Treating an exit code as proof that text is correct

Documented status codes distinguish success, bad parameter, and file error;
they cannot prove that a font has the required glyphs or an application decoded
bytes correctly. Verify representative text visually and byte-for-byte.

## PowerShell boundaries

PowerShell exposes several distinct encoding layers. `$OutputEncoding` affects
data sent from PowerShell to native commands, while console input/output and
file cmdlet encodings have their own settings and differ by PowerShell edition.
Changing them merely to test this page is unnecessary.

## Version and platform differences

This command is legacy and normally absent from modern Windows. PowerShell 7
and Windows PowerShell 5.1 also have different default file/native-pipe encoding
histories. Verify the shell edition, host, code page, font, and target program.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`graftabl.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains resolution, /status and encoding reads
only; no graphics/input/output/file/native-pipe code-page or font mutation is
permitted merely for evidence.

## Related documents
- [chcp.com](chcp.com.md)
- [mode.com](mode.com.md)

## Sources and license

Adapted as an original diagnostic guide from Microsoft's
[graftabl reference](https://learn.microsoft.com/windows-server/administration/windows-commands/graftabl).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
