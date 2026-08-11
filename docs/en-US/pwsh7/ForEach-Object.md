<!-- mant:tldr:start -->
# ForEach-Object

> Run a script block for each object that arrives through the pipeline.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-7.6.

- Select a property from every object:

`Get-Process | ForEach-Object { $_.Name }`

- Run an action for each path:

`Get-ChildItem -File | ForEach-Object { {{command}} $_.FullName }`

- Use the property shortcut:

`Get-Process | ForEach-Object ProcessName`
<!-- mant:tldr:end -->

# ForEach-Object

## Synopsis

```powershell
ForEach-Object [-Process] <scriptblock[]> [-Begin <scriptblock>] [-End <scriptblock>]
ForEach-Object [-MemberName] <string> [-ArgumentList <object[]>]
```

`ForEach-Object` runs a command or script block for every pipeline object. It
is the streaming counterpart to the `foreach` language statement, which
iterates an in-memory collection.

## Process blocks

The common form supplies a script block. `$_` and `$PSItem` name the current
object. Any value emitted by the block becomes output for the next pipeline
stage.

```powershell
Get-ChildItem -File |
    ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            SizeKiB = [math]::Round($_.Length / 1KB, 1)
        }
    }
```

Use `begin`, `process`, and `end` blocks when initialization and finalization
must happen once while `process` handles each incoming object.

## Member shortcut

The member form invokes one property or method name for each object. It is
concise for a simple property read, but a script block is clearer once there
is validation, error handling, multiple statements, or null behavior to
consider.

```powershell
Get-Process | ForEach-Object ProcessName
Get-Date | ForEach-Object ToUniversalTime
```

Use `Get-Member` before invoking a member that depends on a particular object
type.

## Side effects and errors

`ForEach-Object` is commonly used to perform actions, but an action over many
objects needs an explicit failure policy. Use `-WhatIf` when the target cmdlet
supports it, `-ErrorAction Stop` when a failure must stop the pipeline, and
clear logging or output for results that must be audited.

```powershell
Get-ChildItem -File |
    ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination ./backup -ErrorAction Stop
    }
```

Avoid using this cmdlet merely to format text. Keep objects in the pipeline
until a final display or serialization step.

## Parallel processing

PowerShell 7 supports `-Parallel` for independent work in separate runspaces.
It has overhead, changes variable and object-sharing behavior, and can make
ordering and external resource limits harder to reason about. Use it only
after a sequential pipeline is correct, and record the minimum PowerShell
version required by automation that depends on it.

## Examples

Create a report from process objects:

```powershell
Get-Process |
    Where-Object CPU -GT 10 |
    ForEach-Object { "$($_.ProcessName): $([math]::Round($_.CPU, 2))" }
```

Validate each JSON file before processing it:

```powershell
Get-ChildItem ./input -Filter '*.json' -File |
    ForEach-Object {
        Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json | Out-Null
        $_.FullName
    }
```

## Platform and version differences

The core process and member forms are portable across PowerShell 7 platforms.
The input objects, target actions, and `-Parallel` behavior can depend on
operating system, module, PowerShell version, and external resource limits.

## Related documents

- [Where-Object](Where-Object.md)
- [Select-Object](Select-Object.md)
- [about_Functions](about_Functions.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[ForEach-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-7.6).
It emphasizes streaming object transformations, action safety, and the
trade-offs of parallel execution. Exact upstream revision and path are
recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
