<!-- mant:tldr:start -->
# about_Pipelines

> Send PowerShell objects from one command to the next with `|`.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.6.

- Filter process objects:

`Get-Process | Where-Object CPU -GT {{seconds}}`

- Select properties before exporting:

`Get-ChildItem | Select-Object Name, Length | Export-Csv {{items.csv}} -NoClobber`

- Inspect accepted pipeline input:

`Get-Help {{command}} -Full`
<!-- mant:tldr:end -->

# about_Pipelines

## Short description

The pipeline operator `|` sends output from one command to the next. PowerShell
cmdlets normally exchange .NET objects, not formatted display text. Native
commands are a separate boundary: a PowerShell consumer receives decoded
strings, while PowerShell 7.4+ can preserve bytes when the consumer is another
native command or a file redirection.

## Using pipelines

Use a pipeline when each command has one focused responsibility: produce
objects, filter them, transform properties, sort them, and finally format or
persist the result.

The pipeline does not make its endpoint read-only. Export, content, web,
process, and item commands retain their normal side effects; use a new target
or a supported no-clobber option and validate the final path before persisting.

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

## Uncaptured expression results are output

PowerShell sends every uncaptured expression result to the success output
stream, not only values written with `Write-Output` or `return`. This includes
.NET method return values and cmdlet output used only for a side effect. A
boolean from `Task.WaitAll()`, an index from a collection `.Add()`, or an object
from `New-Item` can therefore contaminate JSON, CSV, evidence counts, function
results, or text captured from a native command.

Capture a value when later logic needs it; otherwise discard only the specific
known success result:

```powershell
[void][System.Threading.Tasks.Task]::WaitAll($tasks, 5000)
$null = $items.Add($value)
New-Item -ItemType Directory -Path $path | Out-Null
```

`New-Item` has `-Path`, not `-LiteralPath`, in PowerShell 7. Validate the
intended parent, item type, and exact path string before creating it; use a
cmdlet that actually supports `-LiteralPath` when inspecting or removing the
result. Parameter names are runtime metadata, so syntactically valid examples
still require command-metadata validation.

`[void]`, assignment to `$null`, and `Out-Null` suppress success output; they do
not make an operation safe and must not hide error, warning, verbose, debug, or
information evidence indiscriminately. Prefer precise suppression at the
expression that produces auxiliary output. When collecting native evidence,
store stdout, stderr, exit status, timeout/start state, and harness return values
in separate variables before emitting one deliberate result object.

## Compound statements on the left of a pipeline

A compound language statement such as `foreach`, `if`, or `switch` is not by
itself a pipeline element. This form fails during parsing with
`EmptyPipeElement` before the loop runs:

```text
# Invalid: the foreach statement is not a pipeline element.
foreach ($number in 1..3) { $number } | Measure-Object
```

Wrap the statement when its success output must feed another command. An
array subexpression runs the statement to completion and always produces an
array, which is useful when a stable zero/one/many collection is needed:

```powershell
$numbers = @(foreach ($number in 1..3) { $number })
$numbers | Measure-Object
```

For streaming behavior, invoke a script block as the left pipeline command:

```powershell
& { foreach ($number in 1..3) { $number } } |
    Measure-Object
```

`$(...)` can also expose statement output as an expression, but its scalar or
array shape depends on the number of results. Both `$()` and `@()` collect the
enclosed output before the following pipeline runs; `& {}` can stream but runs
the script block in a child scope. Choose deliberately for memory, result-shape,
and scope requirements.

### Counting an optional value without inventing a null item

The array subexpression preserves a scalar `$null` as one array element:
`@($null).Count` is 1, even though `$null.Count` is 0. Consequently, this can
falsely report one diagnostic when an optional property is absent:

```text
# Unsafe for an optional property: a missing value becomes one null element.
@($result.diagnostics).Count
```

Check the property and value before wrapping a legitimate zero/one/many result:

```powershell
$diagnosticsProperty = $result.PSObject.Properties['diagnostics']
$diagnosticCount = if (
    $null -eq $diagnosticsProperty -or
    $null -eq $diagnosticsProperty.Value
) { 0 } else { @($diagnosticsProperty.Value).Count }
```

This distinction matters for JSON/MCP responses whose optional fields are
omitted on success. Also fail before counting when the entire read or parse
failed; a syntactically valid count is not proof of valid input.

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
program and passes converted command-line arguments. If native stdout flows to
a PowerShell command, PowerShell decodes it into .NET strings. Beginning in
PowerShell 7.4, raw bytes are preserved when native stdout is redirected to a
file or piped to the stdin of another native command. Merging native stderr
into stdout disables this byte-stream path and treats the combined data as
strings. The native program still owns its input, encoding, and exit-code
conventions.

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
handling across releases. Record a minimum PowerShell version when scripts
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

## Version and platform differences

This page targets PowerShell 7.6. PowerShell object-pipeline semantics are
cross-platform, while native byte streams, available commands, and formatting
can differ by host and operating system.

## Runtime evidence

PowerShell 7.6.4 on Windows confirmed object-preserving filesystem pipelines,
direct-array versus enumerated pipeline binding, streaming phases, bounded
parallel input, statement-to-pipeline parsing, optional-null counting, and
no-clobber output. A byte fixture confirmed exact native stdout preservation
through `>`. The earlier Linux pass covered selected object and native
boundaries; macOS and remaining external-command contracts are outstanding.

### Do not truncate a native producer before collecting its status

`Select-Object -First` can stop upstream processing after it has enough
objects. For a native process, that can close the output pipe while the process
is still writing and change its eventual exit result. A local probe that piped
`tasklist.exe /apps /fo csv` directly to `Select-Object -First 3` displayed
three valid CSV lines but left `$LASTEXITCODE` as `-1`; a bounded concurrent
full capture of the same native producer returned `0`.

When exit status is evidence, let the bounded native command finish while
draining stdout and stderr, record its exit code, and only then select or
summarize the captured output. Do not infer success from plausible leading
rows.

## Related documents

- [about_Redirection](about_Redirection.md)
- [about_Parsing](about_Parsing.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Pipelines reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.6).
The grouping, subexpression, array-subexpression, and call-operator boundaries
also follow the official
[about_Operators reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.6).
The null-element counting boundary follows Microsoft's
[PowerShell null guidance](https://learn.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-null?view=powershell-7.6).
The `New-Item` parameter boundary follows the official
[New-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.6).
This page emphasizes object flow, parameter binding, native boundaries, and
safe automation. Exact upstream revisions and paths are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
