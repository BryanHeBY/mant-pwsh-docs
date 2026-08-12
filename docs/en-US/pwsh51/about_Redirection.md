<!-- mant:tldr:start -->
# about_Redirection

> Redirect Windows PowerShell 5.1 output, errors, and informational streams.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1.

- Save success output to a file, replacing an existing file:

`Get-Process > {{processes.txt}}`

- Merge errors into success output:

`{{command}} 2>&1`

- Save every redirectable stream:

`{{command}} *> {{all-output.txt}}`
<!-- mant:tldr:end -->

# about_Redirection

## Short description

Windows PowerShell 5.1 has one success-output stream and numbered error,
warning, verbose, debug, and information streams. Redirection operators send
a selected stream to a file, another stream, or `$null`.

## Redirectable streams

| Number | Name | Typical writer |
| --- | --- | --- |
| `1` | Success | `Write-Output` and normal command output |
| `2` | Error | `Write-Error` and cmdlet errors |
| `3` | Warning | `Write-Warning` |
| `4` | Verbose | `Write-Verbose` |
| `5` | Debug | `Write-Debug` |
| `6` | Information | `Write-Information` and `Write-Host` |

Host display behavior is not always normal redirectable output. Commands used
by automation should put results on success output and messages on the
appropriate diagnostic stream instead of relying on console rendering.

## Operators

- `> FILE`: Send success output to a file, replacing its prior contents.
- `>> FILE`: Append success output to a file.
- `N> FILE`: Send stream `N` to a file, replacing its prior contents.
- `N>> FILE`: Append stream `N` to a file.
- `N>&1`: Merge stream `N` into success output.
- `*> FILE`: Send all redirectable streams to one file.
- `*> $null`: Suppress all redirectable streams.

Merging `2>&1` makes error records available as success output to a later
command; it does not make an error successful. Define an explicit error and
exit-status policy before combining streams that a downstream parser consumes.

Windows PowerShell 5.1 materializes native stderr lines as PowerShell error
records. Consequently, a surrounding `$ErrorActionPreference = 'Stop'` can
turn a native stderr line into a terminating `NativeCommandError` even when
`2>&1` appears inside an assignment; the assignment may never complete. This
is separate from the native exit code, which still belongs to the program.
Do not rely on `$LASTEXITCODE` inside that early `catch`: stderr can terminate
the PowerShell statement before native completion has been observed, leaving a
stale or timing-dependent value. Let the native process complete inside a
narrow compatibility boundary, then capture its code immediately:

```powershell
$oldPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    $merged = @(& $tool @arguments 2>&1)
    $toolExitCode = $LASTEXITCODE
} finally {
    $ErrorActionPreference = $oldPreference
}
```

Use this scoped compatibility boundary only when deliberately collecting a
mixed stdout/stderr sequence. Elements can include strings and `ErrorRecord`
objects. Keep streams separate when chronology, bytes, or parsing matters, and
interpret `$toolExitCode` by the target program's contract.

## Text files and encoding

`>` and `>>` are concise for simple capture, but they produce formatted text.
In Windows PowerShell 5.1, redirection and `Out-File` default to UTF-16LE
(`Unicode`) output. Specify an encoding with `Out-File`, `Set-Content`, or
`Add-Content` when another program expects a particular byte representation.

Do not redirect objects to text when a later process needs their properties.
Use `Export-Csv`, `ConvertTo-Json`, or another explicit serialization format:

```powershell
Get-Process |
    Select-Object Name, Id, CPU |
    ConvertTo-Json |
    Set-Content -LiteralPath .\processes.json -Encoding UTF8
```

`Set-Content` replaces an existing file just as `>` does. Use this example
only with a resolved new or intentionally replaceable path.

In Windows PowerShell 5.1, `-Encoding UTF8` writes a UTF-8 byte-order mark
(`EF BB BF`); PowerShell 7's `utf8` default is UTF-8 without a BOM. State the
required consumer and verify the produced bytes when an external tool or
protocol is involved.

Reading has a separate compatibility trap. When a text file has no BOM,
Windows PowerShell 5.1 `Get-Content` and the script engine assume the active
legacy ANSI code page. Modern editors and PowerShell 7 commonly create UTF-8
without a BOM, so non-ASCII text can be misdecoded even though the bytes are
valid. Specify the known encoding when reading data:

```powershell
$text = Get-Content -LiteralPath .\document.md -Raw -Encoding UTF8
```

For 5.1 script files containing non-ASCII characters, use an encoding the
engine can identify, normally UTF-8 with a BOM. Do not add or remove a BOM
blindly when Unix tools or another protocol owns the file format.

## Errors and action preferences

Redirection changes where stream data goes, not whether a cmdlet emits a
terminating error. `-ErrorAction Stop` and `$ErrorActionPreference` control how
non-terminating errors are treated. Use `try` and `catch` for required input
instead of silently discarding diagnostic data with `2>$null`:

```powershell
try {
    Get-Item -LiteralPath .\required.json -ErrorAction Stop | Out-Null
} catch {
    throw "Required input is unavailable: $_"
}
```

## Native commands

Native Windows programs have standard output and standard error, not all six
PowerShell streams. Windows PowerShell maps those streams into its model, but
code pages, decoding, and redirection behavior can depend on the executable
and console host. Check `$LASTEXITCODE` after every native command whose result
matters, even when output was redirected.

```powershell
tool.exe build *> .\build.log
if ($LASTEXITCODE -ne 0) {
    throw "Build failed with exit code $LASTEXITCODE"
}
```

## Common mistakes

### Expecting redirection to refuse overwrite

`>`, `N>`, `*>`, `Out-File`, and `Set-Content` replace an existing writable
target without an interactive confirmation. `>>` and `Add-Content` append but
do not provide atomicity or concurrency protection. Resolve the final path,
reject an existing target by default, and prefer a command's `-NoClobber`
option or an application-specific atomic write when replacement is not
intended.

## Version and availability

This page targets Windows PowerShell 5.1. Its text-based native redirection and
default encodings differ from newer PowerShell releases; do not assume that a
redirected binary stream is preserved byte for byte.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 wrote `>` output with a UTF-16LE BOM and
`Set-Content -Encoding UTF8` with a UTF-8 BOM; default reading misdecoded a
BOM-less UTF-8 em dash. A bounded native stderr probe confirmed the legacy
`NativeCommandError` behavior under stopping policy and one merged
`ErrorRecord` plus exit code `7` under scoped `Continue`. Temporary files were
confined to the verified suite root and removed. Other encodings, providers,
and native programs remain outstanding.

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Parsing](about_Parsing.md)
- [native-commands](native-commands.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Redirection reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1).
Encoding guidance also follows
[about_Character_Encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.6).
Native error-action behavior was cross-checked against
[about_Preference_Variables](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-5.1).
The page is organized around stream selection, 5.1 text encoding, error
handling, and native-program exit status. Exact upstream revisions and paths are
recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
