<!-- mant:tldr:start -->
# about_Functions

> Define reusable Windows PowerShell 5.1 commands with parameters, pipeline input, and explicit scope.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-5.1.

- Define a simple function:

`function {{Name}} { {{command}} }`

- Define function parameters:

`function {{Name}} { param([string]$Value) {{command}} }`

- Show syntax after defining a function:

`Get-Command {{Name}} -Syntax`
<!-- mant:tldr:end -->

# about_Functions

## Short description

Functions are named Windows PowerShell commands defined with `function`. They
can accept parameters, write .NET objects to the pipeline, use advanced
function features, and be exported by modules. Use a function for reusable
behavior and a script when the behavior needs a file-based entry point.

## Basic functions

The body runs when its name is invoked. Output that is not assigned,
redirected, or suppressed becomes success output:

```powershell
function Get-Greeting {
    'Hello from Windows PowerShell'
}

Get-Greeting
```

Avoid `Write-Host` for a function's primary result. It is intended for
host-oriented information, not a value a caller can filter, assign, serialize,
or test.

## Parameters

Put `param(...)` at the start of the function body. Name types, defaults, and
validation instead of decoding `$args` by hand:

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

Parameter names are case-insensitive and can normally be abbreviated when the
abbreviation is unambiguous. Shared scripts should use complete parameter
names because a later module update can make a short form ambiguous.

## Advanced functions and pipelines

Add `[CmdletBinding()]` before `param(...)` to create an advanced function. It
gains common parameters such as `-Verbose`, `-Debug`, and `-ErrorAction`, plus
cmdlet-style parameter binding. A function can have `begin`, `process`, and
`end` blocks; use `process` to handle input one object at a time:

```powershell
function ConvertTo-Uppercase {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)][string]$Value)

    process { $Value.ToUpperInvariant() }
}

'one', 'two' | ConvertTo-Uppercase
```

Use advanced functions when callers need predictable parameters, streaming
pipeline input, diagnostics, and help. Do not partially imitate cmdlet
semantics while silently ignoring common parameters.

## Scope and output contracts

Functions run in a child scope. They can read parent-scope variables, but an
ordinary assignment normally creates or changes a local value. Return values
through the pipeline or define a clear output contract instead of depending on
hidden mutation of an outer variable.

Dot-sourcing a script with `. .\script.ps1` runs it in the caller's scope and
can add functions or variables there. Use it deliberately for profile or module
bootstrap code; do not use it as an implicit import mechanism for untrusted
scripts.

Use `throw` for a terminating failure and `Write-Error` when a function can
continue safely. Advanced functions should respect `-ErrorAction` and avoid
writing normal data to error, warning, verbose, or host streams.

## Modules and compatibility

Use approved `Verb-Noun` names for reusable functions. Put production
functions in a module and export only supported public commands. A module built
for .NET Framework and Windows PowerShell 5.1 may not load in PowerShell 7,
and the reverse is also possible; test the intended edition explicitly.

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Automatic_Variables](about_Automatic_Variables.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Functions reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-5.1).
It is organized around parameter contracts, streaming pipeline input, scope,
and module design for Windows PowerShell 5.1. Exact upstream revision and path
are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
