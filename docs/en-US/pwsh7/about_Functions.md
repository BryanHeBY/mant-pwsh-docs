<!-- mant:tldr:start -->
# about_Functions

> Define reusable PowerShell 7 commands with parameters, pipeline input, and explicit scope.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-7.6.

- Define a simple function:

`function {{Name}} { {{command}} }`

- Define parameters for a function:

`function {{Name}} { param([string]$Value) {{command}} }`

- Show command syntax after defining it:

`Get-Command {{Name}} -Syntax`
<!-- mant:tldr:end -->

# about_Functions

## Short description

Functions are named PowerShell commands defined with `function`. They can
accept parameters, write objects to the pipeline, use advanced-function
features, and be exported by modules. Use a function for reusable behavior;
use a script when the behavior needs a file-based entry point.

## Basic functions

The function body runs when its name is invoked. Output not assigned,
redirected, or suppressed becomes success output:

```powershell
function Get-Greeting {
    'Hello from PowerShell'
}

Get-Greeting
```

Avoid `Write-Host` for a function's primary result. It writes host-oriented
information rather than an object a caller can filter, assign, serialize, or
test.

## Parameters

Put a `param(...)` block at the beginning of a function body. Name parameter
types, defaults, and validation rather than manually decoding `$args`:

```powershell
function Get-Greeting {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [switch]$Uppercase
    )

    $message = "Hello, $Name"
    if ($Uppercase) { $message.ToUpperInvariant() } else { $message }
}
```

Parameter names are case-insensitive and can usually be abbreviated when the
abbreviation is unambiguous. Scripts and automation should prefer complete
names because a later parameter can make an earlier abbreviation ambiguous.

## Advanced functions

Add `[CmdletBinding()]` before `param(...)` to create an advanced function.
It receives cmdlet-like common parameters such as `-Verbose`, `-Debug`, and
`-ErrorAction`, along with richer parameter binding behavior.

```powershell
function Get-FileName {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$File
    )

    process {
        Write-Verbose "Reading $($File.FullName)"
        $File.Name
    }
}
```

Use advanced functions when callers benefit from predictable parameters,
pipeline input, diagnostics, and help. A function should not imitate cmdlet
semantics partially while silently ignoring common parameters.

## Pipeline blocks

Functions can have `begin`, `process`, and `end` blocks. `begin` runs once,
`process` runs for each pipeline item, and `end` runs once after input is
complete. Use `process` for streaming work so large input does not need to be
stored in memory first.

```powershell
function ConvertTo-Uppercase {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)][string]$Value)

    process { $Value.ToUpperInvariant() }
}

'one', 'two' | ConvertTo-Uppercase
```

## Scope and state

Functions run in a child scope. They can read parent-scope variables, but an
ordinary assignment creates or changes a local value. Return values through
the pipeline or define an explicit output contract instead of depending on
hidden outer-scope mutation.

Dot-sourcing a script runs it in the caller's scope and can add functions or
variables there. Use it intentionally for profile or module bootstrap code;
do not use it as an implicit import mechanism for untrusted scripts.

## Errors and output

Use `throw` for a terminating failure and `Write-Error` for a non-terminating
error when the function can continue safely. Advanced functions should honor
`-ErrorAction` and avoid writing normal data to error, warning, verbose, or
host streams.

Return one clear object type where practical. Avoid wrapping normal output in
`Write-Output` unless its enumeration behavior is required; simply emitting an
object is usually clearer.

## Modules and naming

Use approved `Verb-Noun` names for functions intended for reuse. Place
production functions in a module, export only the supported public commands,
and call them with a module-qualified name when command precedence matters.
Do not define short aliases in a shared module unless the alias is explicitly
part of its supported interface.

## Version and platform differences

This page follows PowerShell 7.6 on Windows, macOS, and Linux. Function syntax
is largely portable, but commands called by a function, parameter types,
providers, and modules can be platform- or version-specific.

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Automatic_Variables](about_Automatic_Variables.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Functions reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-7.6).
It is reorganized around parameter contracts, streaming pipeline input, scope,
and reusable module design. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
