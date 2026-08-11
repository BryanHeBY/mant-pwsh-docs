<!-- mant:tldr:start -->
# about_Redirection

> Redirect Windows PowerShell 5.1 output, errors, and informational streams.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1.

- Save success output to a file:

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

Windows PowerShell 5.1's `UTF8` encoding behavior differs from PowerShell 7
for byte-order marks. State the required consumer and verify the produced bytes
when an external tool or protocol is involved.

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

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Parsing](about_Parsing.md)
- [native-commands](native-commands.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Redirection reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1).
It is organized around stream selection, 5.1 text encoding, error handling,
and native-program exit status. Exact upstream revision and path are recorded
in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
