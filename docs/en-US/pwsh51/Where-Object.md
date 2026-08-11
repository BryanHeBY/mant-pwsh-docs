<!-- mant:tldr:start -->
# Where-Object

> Filter Windows PowerShell 5.1 pipeline objects by property values or a predicate script block.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/where-object?view=powershell-5.1.

- Filter with a comparison shortcut:

`Get-Process | Where-Object CPU -GT {{seconds}}`

- Filter with a predicate script block:

`Get-ChildItem | Where-Object { $_.Length -GT {{bytes}} }`

- Exclude matching objects:

`Get-Service | Where-Object Status -NE Running`
<!-- mant:tldr:end -->

# Where-Object

## Synopsis

```powershell
Where-Object [-Property] <string> [[-Value] <object>] [-EQ | -NE | -GT | -LT | ...]
Where-Object [-FilterScript] <scriptblock>
```

`Where-Object` passes through only pipeline objects matching a condition. Use
it before sorting, selecting properties, exporting, or performing an action.

## Comparison and predicate forms

The concise form names a property, comparison operator, and value. Use it for
one simple, readable condition:

```powershell
Get-Process | Where-Object ProcessName -Like 'powershell*'
Get-ChildItem -File | Where-Object Length -GT 1MB
```

Use a script block for multiple conditions, calculated values, null handling,
or method calls. `$_` and `$PSItem` name the current object:

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 1MB -and $_.Extension -in '.log', '.json'
    }
```

Keep predicates side-effect free. Creating, deleting, or changing items in a
filter makes pipeline behavior hard to review; put an explicit action later.

## Properties, null, and performance

Use `Get-Member` to inspect actual properties rather than assuming a display
column is a property. A property can be missing or null. Compare `$null` on
the left when a value might be a collection:

```powershell
$items | Where-Object {
    $null -ne $_.Owner -and $_.Owner.Name -eq 'Ada'
}
```

`Where-Object` handles input as it arrives. When the source command or provider
has its own filter parameter, use it first for filesystem, registry, remote,
or API queries to reduce work and transfer.

## Related documents

- [ForEach-Object](ForEach-Object.md)
- [Select-Object](Select-Object.md)
- [Get-Member](Get-Member.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Where-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/where-object?view=powershell-5.1).
It is organized around safe predicates, object inspection, and source-side
filtering. Exact upstream revision and path are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
