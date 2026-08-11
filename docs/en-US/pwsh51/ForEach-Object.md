<!-- mant:tldr:start -->
# ForEach-Object

> Run a script block for each object that arrives through a Windows PowerShell 5.1 pipeline.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-5.1.

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
streams input, unlike the `foreach` language statement, which iterates an
in-memory collection.

## Process blocks

The usual form supplies a script block. `$_` and `$PSItem` name the current
object; values emitted by the block become output for the next stage.

```powershell
Get-ChildItem -File |
    ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            SizeKiB = [math]::Round($_.Length / 1KB, 1)
        }
    }
```

Use `-Begin`, `-Process`, and `-End` when initialization and finalization run
once while process work handles each input item.

## Member shortcut and actions

The member form invokes one property or method per object. It is concise for a
simple read, but a script block is clearer once validation, error handling,
multiple statements, or null behavior matters:

```powershell
Get-Process | ForEach-Object ProcessName
Get-Date | ForEach-Object ToUniversalTime
```

Actions over many objects need an explicit failure policy. Use `-WhatIf` when
the target cmdlet supports it and `-ErrorAction Stop` when a failure should stop
the pipeline. Keep objects in the pipeline until final display or serialization.

Windows PowerShell 5.1 has no `ForEach-Object -Parallel`. Use jobs, remoting,
or a deliberate concurrency design only when ordered sequential processing has
first been verified.

## Related documents

- [Where-Object](Where-Object.md)
- [Select-Object](Select-Object.md)
- [about_Functions](about_Functions.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[ForEach-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-5.1).
It emphasizes streaming transformations, action safety, and the 5.1 concurrency
boundary. Exact upstream revision and path are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
