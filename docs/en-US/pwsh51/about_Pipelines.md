<!-- mant:tldr:start -->
# about_Pipelines

> Send Windows PowerShell 5.1 objects from one command to the next with `|`.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-5.1.

- Filter process objects:

`Get-Process | Where-Object CPU -GT {{seconds}}`

- Select properties before exporting:

`Get-ChildItem | Select-Object Name, Length | Export-Csv {{items.csv}}`

- Inspect accepted pipeline input:

`Get-Help {{command}} -Full`
<!-- mant:tldr:end -->

# about_Pipelines

## Short description

The pipeline operator `|` sends output from one command to the next. Windows
PowerShell cmdlets normally exchange .NET Framework objects, not formatted
display text. Native Windows executables are a separate text-stream boundary.

## Use object pipelines

Use a pipeline when each command has one focused responsibility: produce
objects, filter them, select or transform their properties, sort them, and
finally format or persist the result.

```powershell
Get-ChildItem -File |
    Where-Object Length -GT 1MB |
    Sort-Object Length -Descending |
    Select-Object -First 10 Name, Length
```

Do not put `Format-Table`, `Format-List`, or another formatting command in the
middle of a data pipeline. Formatting cmdlets produce formatting instructions
for display rather than the original file, process, or custom objects. Format
only at an interactive endpoint; select properties before structured export.

## Object enumeration and parameter binding

Windows PowerShell normally sends objects one at a time. A receiving cmdlet can
accept input by value, by property name, or through an explicit script block.
Use `Get-Help COMMAND -Full` to identify parameters that accept pipeline
input. Write an explicit `ForEach-Object` block when the binding relationship
is not obvious:

```powershell
Get-Process |
    ForEach-Object {
        '{0}: {1:N2}' -f $_.Name, $_.CPU
    }
```

`$_` and `$PSItem` name the current input object in a pipeline script block.
Collections are generally enumerated before entering the pipeline. Use unary
comma or an applicable `-NoEnumerate` option only when one collection must
remain a single pipeline item.

## Native commands

Windows executables do not receive PowerShell objects. Windows PowerShell
starts the program, converts its arguments to a Windows command line, and
receives standard output as decoded text. The target program owns its input
format, output encoding, error stream, and exit-code conventions.

Do not assume that `|` creates a portable object pipeline across a native
boundary. Prefer a documented machine-readable format, check `$LASTEXITCODE`,
and convert text explicitly:

```powershell
$json = tool.exe list --output json
if ($LASTEXITCODE -ne 0) {
    throw "tool failed with exit code $LASTEXITCODE"
}
$items = $json | ConvertFrom-Json
```

Windows PowerShell 5.1's native stream and encoding behavior differs from
newer PowerShell releases. Record the edition and test the actual executable,
Windows version, code page, and non-ASCII data when those details matter.

## Errors in pipelines

Non-terminating cmdlet errors do not necessarily stop a pipeline. Use
`-ErrorAction Stop` for operations that must enter `catch`, and distinguish
PowerShell errors from native nonzero exit codes. `$?` summarizes the latest
PowerShell operation; `$LASTEXITCODE` holds the latest native-process code.

```powershell
try {
    Get-ChildItem -LiteralPath .\required -ErrorAction Stop |
        ForEach-Object { $_.FullName }
} catch {
    throw "Pipeline failed: $_"
}
```

## Continuation

A line can naturally continue after a pipe, comma, opening delimiter, or
operator. Prefer these forms to a trailing backtick, whose meaning changes if
whitespace follows it.

## Related documents

- [about_Redirection](about_Redirection.md)
- [about_Parsing](about_Parsing.md)
- [native-commands](native-commands.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Pipelines reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-5.1).
It emphasizes object flow, parameter binding, native boundaries, and Windows
PowerShell 5.1 automation. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
