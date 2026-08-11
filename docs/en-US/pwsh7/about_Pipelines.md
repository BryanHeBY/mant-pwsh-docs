<!-- mant:tldr:start -->
# about_Pipelines

> Send PowerShell objects from one command to the next with `|`.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.6.

- Filter process objects:

`Get-Process | Where-Object CPU -GT {{seconds}}`

- Select properties before exporting:

`Get-ChildItem | Select-Object Name, Length | Export-Csv {{items.csv}}`

- Inspect accepted pipeline input:

`Get-Help {{command}} -Full`
<!-- mant:tldr:end -->

# about_Pipelines

## Short description

The pipeline operator `|` sends output from one command to the next. PowerShell
cmdlets normally exchange .NET objects, not formatted display text. Native
commands are a separate boundary with text or byte-stream behavior.

## Using pipelines

Use a pipeline when each command has one focused responsibility: produce
objects, filter them, transform properties, sort them, and finally format or
persist the result.

```powershell
Get-ChildItem -File |
    Where-Object Length -GT 1MB |
    Sort-Object Length -Descending |
    Select-Object -First 10 Name, Length
```

Do not put `Format-Table` or another formatting command in the middle of a
data pipeline. Formatting cmdlets produce formatting instructions for display,
not the original file, process, or custom objects. Format at the endpoint or
select properties before exporting structured data.

## How object flow works

PowerShell sends output one object at a time in the usual case. A receiving
cmdlet can accept input by value, by property name, or through an explicit
script block. The parameter metadata and `Get-Help COMMAND -Full` identify
which parameters accept pipeline input.

```powershell
Get-Service |
    Where-Object Status -EQ Running |
    Select-Object Name, DisplayName, Status
```

Collections are normally enumerated as they enter the pipeline. Use unary
comma, `Write-Output -NoEnumerate`, or a command-specific option when one
collection object must remain a single pipeline item.

## Parameter binding

Pipeline binding first tries to match the complete incoming object to a
parameter that accepts input by value. It can then match object properties to
parameters that accept input by property name. Binding is convenient, but it
is not magic: inspect the command's parameter metadata and write an explicit
`ForEach-Object` block when the relationship is unclear.

```powershell
Get-Process |
    ForEach-Object {
        "{0}: {1:N2}" -f $_.Name, $_.CPU
    }
```

`$_` and `$PSItem` name the current pipeline object inside a script block.

## Native commands in pipelines

Native programs do not receive PowerShell objects. PowerShell starts the
program, passes converted command-line arguments, and receives native output
as text or, in supported PowerShell 7 scenarios, a byte stream. The native
program then applies its own parsing, encoding, and exit-code conventions.

Do not assume that `|` makes an object pipeline portable across native tools.
Prefer a documented machine-readable format such as JSON, verify
`$LASTEXITCODE`, and convert data explicitly:

```powershell
$json = tool list --output json
if ($LASTEXITCODE -ne 0) {
    throw "tool failed with exit code $LASTEXITCODE"
}
$items = $json | ConvertFrom-Json
```

PowerShell 7 has changed details of native argument passing and byte-stream
redirection across releases. Record a minimum PowerShell version when scripts
depend on exact native pipe behavior.

## Pipeline errors

Non-terminating errors do not necessarily stop a pipeline. Use
`-ErrorAction Stop` for cmdlet calls that must enter `catch`, and distinguish
PowerShell errors from native nonzero exit codes. `$?` summarizes the latest
PowerShell operation; `$LASTEXITCODE` holds the latest native process code.

```powershell
$ErrorActionPreference = 'Stop'
try {
    Get-ChildItem -LiteralPath ./required | ForEach-Object { $_.FullName }
} catch {
    throw "Pipeline failed: $_"
}
```

## Line continuation

A pipeline can continue after a pipe at the end of a line or with a pipe at
the start of the next line. These natural continuation points are safer than
a trailing backtick, whose meaning is easily changed by trailing whitespace.

## Related documents

- [about_Redirection](about_Redirection.md)
- [about_Parsing](about_Parsing.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Pipelines reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.6).
It emphasizes object flow, parameter binding, native boundaries, and safe
automation. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
