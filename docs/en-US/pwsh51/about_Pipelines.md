<!-- mant:tldr:start -->
# about_Pipelines

> Send Windows PowerShell 5.1 objects from one command to the next with `|`.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-5.1.

- Filter process objects:

`Get-Process | Where-Object CPU -GT {{seconds}}`

- Select properties before exporting:

`Get-ChildItem | Select-Object Name, Length | Export-Csv {{items.csv}} -NoClobber`

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

The pipeline does not make its endpoint read-only. Export, content, web,
process, and item commands retain their normal side effects; use a new target
or a supported no-clobber option and validate the final path before persisting.

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

`New-Item` has `-Path`, not `-LiteralPath`, in Windows PowerShell 5.1. Validate
the intended parent, item type, and exact path string before creating it; use a
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

## Version and availability

This page targets Windows PowerShell 5.1. Object-pipeline behavior is part of
the language, while installed commands, native encodings, and remoting object
types depend on the Windows host.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 confirmed object-preserving filesystem
pipelines, direct-array versus enumerated pipeline binding, streaming
begin/process/end phases, statement-to-pipeline parsing, bounded no-clobber
output, and the optional-null counting trap used in ManT result aggregation.
Native checks confirm exit-code and mixed-stream object behavior, not every
native encoding or external command contract.

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
- [native-commands](native-commands.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Pipelines reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-5.1).
The grouping, subexpression, array-subexpression, and call-operator boundaries
also follow the official
[about_Operators reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-5.1).
The null-element counting boundary follows Microsoft's
[PowerShell null guidance](https://learn.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-null?view=powershell-7.6).
The `New-Item` parameter boundary follows the official
[New-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/new-item?view=powershell-5.1).
This page emphasizes object flow, parameter binding, native boundaries, and
Windows PowerShell 5.1 automation. Exact upstream revisions and paths are
recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
