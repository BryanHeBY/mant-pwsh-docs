<!-- mant:tldr:start -->
# about_Redirection

> Redirect PowerShell 7 output, errors, and informational streams.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.6.

- Save success output to a file, replacing an existing file:

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

Beginning in PowerShell 7.2, error records redirected from a native command by
`2>&1` are not added to `$Error` and are not affected by
`$ErrorActionPreference`. On PowerShell 7.6 with
`$PSNativeCommandUseErrorActionPreference` false, a native command that writes
stderr and returns 7 therefore completes the assignment: the merged collection
can contain an `ErrorRecord`, while `$LASTEXITCODE` remains 7. This differs
from Windows PowerShell 5.1, where `Stop` can terminate on the stderr record
before the assignment completes.

`$PSNativeCommandUseErrorActionPreference` is a separate modern control for
turning nonzero native exit codes into PowerShell errors. Do not infer success
from whether stderr is present. Capture `$LASTEXITCODE` immediately and keep
streams separate when type, chronology, or bytes matter.

## Files and encoding

Use `Out-File`, `Set-Content`, or `Add-Content` when you need explicit encoding,
width, append behavior, or provider-aware path handling. For PowerShell object
output, `>` and `>>` are concise forms of `Out-File`: they produce formatted
text and PowerShell 7 writes UTF-8 without a byte-order mark by default. Do not
redirect objects to a text file when a later process needs object properties;
use `Export-Csv`, `ConvertTo-Json`, or a custom serialization format.

```powershell
Get-Process |
    Select-Object Name, Id, CPU |
    ConvertTo-Json |
    Set-Content -LiteralPath ./processes.json -Encoding utf8
```

`Set-Content` replaces an existing file just as `>` does. Use this example
only with a resolved new or intentionally replaceable path.

PowerShell 7 also reads BOM-less text as UTF-8 by default. That differs from
Windows PowerShell 5.1, where `Get-Content` and the script engine assume the
active legacy ANSI code page when no BOM identifies the encoding. Specify
`-Encoding utf8` explicitly when a script must make this data contract clear
across editions.

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

Native programs have standard output and standard error, not PowerShell's full
set of streams. Beginning in PowerShell 7.4, redirecting a native program's
stdout directly to a file with `>` or `>>` preserves its bytes without
PowerShell text decoding or formatting. This permits binary stdout capture.

That byte-preserving path does not apply after stderr is merged into stdout;
combined native streams are treated as string data. Keep stdout separate when
exact bytes matter, and check `$LASTEXITCODE` even when output was redirected.

```powershell
tool build *> ./build.log
if ($LASTEXITCODE -ne 0) {
    throw "Build failed with exit code $LASTEXITCODE"
}
```

## Operator ambiguity

`>` is redirection in command context, but it can be confused with comparison syntax in other language contexts. Prefer the named comparison operators such as `-gt`, `-lt`, and `-eq` in PowerShell expressions. Keep redirection next to the command whose streams it controls.

## Common mistakes

### Expecting redirection to refuse overwrite

`>`, `N>`, `*>`, `Out-File`, and `Set-Content` replace an existing writable
target without an interactive confirmation. `>>` and `Add-Content` append but
do not provide atomicity or concurrency protection. Resolve the final path,
reject an existing target by default, and prefer a command's `-NoClobber`
option or an application-specific atomic write when replacement is not
intended.

## Version and platform differences

This page follows PowerShell 7.6. Native stdout redirection became
byte-preserving in PowerShell 7.4; earlier PowerShell 7 releases converted it
through the text pipeline. Filesystem encoding expectations still vary among
native tools, so label scripts that depend on the 7.4-or-later behavior.

## Runtime evidence

PowerShell 7.6.4 on Windows wrote ordinary text redirection and
`Set-Content -Encoding utf8` without a BOM, read BOM-less UTF-8 correctly, and
preserved the exact native byte sequence `00 0A 0D 7F 80 FF` through `>`.
With the native error preference disabled, a bounded stderr probe completed
without `catch`, produced one merged `ErrorRecord`, and retained exit code `7`.
macOS, remaining Linux cases, other encodings, and other native programs remain
outstanding.

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Parsing](about_Parsing.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official [about_Redirection reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.6), [about_Character_Encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.6), and [about_Preference_Variables](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.6). It is reorganized around stream choice, data formats, error handling, and native-command exit status. Exact upstream revisions and paths are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is licensed under CC BY 4.0.
