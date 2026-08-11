<!-- mant:tldr:start -->
# about_Redirection

> Redirect PowerShell 7 output, errors, and informational streams.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.6.

- Save success output to a file:

`Get-Process > {{processes.txt}}`

- Merge errors into success output:

`{{command}} 2>&1`

- Save every redirectable stream:

`{{command}} *> {{all-output.txt}}`
<!-- mant:tldr:end -->

# about_Redirection

## Short description

PowerShell has one success-output stream and numbered error, warning, verbose, debug, and information streams. Redirection operators send a selected stream to a file, to another stream, or to `$null`.

## Redirectable streams

| Number | Name | Typical writer |
| --- | --- | --- |
| `1` | Success | `Write-Output` and normal command output |
| `2` | Error | `Write-Error` and cmdlet errors |
| `3` | Warning | `Write-Warning` |
| `4` | Verbose | `Write-Verbose` |
| `5` | Debug | `Write-Debug` |
| `6` | Information | `Write-Information` and `Write-Host` |

Some host UI behavior is outside normal stream redirection. A command intended for automation should write structured results to success output and messages to the appropriate diagnostic stream instead of relying on terminal rendering.

## Common operators

- `> FILE`: Send success output to a file, replacing its previous contents.
- `>> FILE`: Append success output to a file.
- `N> FILE`: Send stream `N` to a file, replacing its previous contents.
- `N>> FILE`: Append stream `N` to a file.
- `N>&1`: Merge stream `N` into the success-output stream.
- `*> FILE`: Send all redirectable streams to one file.
- `*> $null`: Suppress all redirectable streams.

Redirection does not make errors successful. Merging `2>&1` makes error records visible as success output to a later command, but a caller still needs an explicit error and exit-status policy.

## Files and encoding

Use `Out-File`, `Set-Content`, or `Add-Content` when you need explicit encoding, width, append behavior, or provider-aware path handling. The `>` and `>>` operators are concise for simple output capture, but their output is formatted text. Do not redirect objects to a text file when a later process needs object properties; use `Export-Csv`, `ConvertTo-Json`, or a custom serialization format.

```powershell
Get-Process |
    Select-Object Name, Id, CPU |
    ConvertTo-Json |
    Set-Content -LiteralPath ./processes.json -Encoding utf8
```

## Errors and action preferences

Redirection changes where stream content goes, not whether a cmdlet produces a terminating error. `-ErrorAction Stop` and `$ErrorActionPreference` control how non-terminating errors are treated. Use `try` and `catch` for an explicit failure boundary rather than discarding errors with `2>$null`.

```powershell
try {
    Get-Item -LiteralPath ./required.json -ErrorAction Stop | Out-Null
} catch {
    throw "Required input is unavailable: $_"
}
```

## Native commands

Native programs have standard output and standard error, not PowerShell's full set of streams. PowerShell maps their output into its redirection model, but encoding and byte-stream behavior vary by PowerShell release and target program. Check `$LASTEXITCODE` after a native command even when its output was redirected.

```powershell
tool build *> ./build.log
if ($LASTEXITCODE -ne 0) {
    throw "Build failed with exit code $LASTEXITCODE"
}
```

## Operator ambiguity

`>` is redirection in command context, but it can be confused with comparison syntax in other language contexts. Prefer the named comparison operators such as `-gt`, `-lt`, and `-eq` in PowerShell expressions. Keep redirection next to the command whose streams it controls.

## Version and platform differences

This page follows PowerShell 7.6. Redirection of native standard output changed
across PowerShell 7 releases, and filesystem encoding expectations vary among
native tools; label scripts that depend on byte-preserving behavior.

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Parsing](about_Parsing.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official [about_Redirection reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.6). It is reorganized around stream choice, data formats, error handling, and native-command exit status. Exact upstream revision and path are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is licensed under CC BY 4.0.
