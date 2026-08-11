<!-- mant:tldr:start -->
# Select-Object

> Choose object properties, create calculated properties, or take a bounded subset of pipeline output.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.6.

- Select two properties:

`Get-Process | Select-Object ProcessName, Id`

- Create a calculated property:

`Get-ChildItem | Select-Object Name, @{Name='SizeKiB'; Expression={ [math]::Round($_.Length / 1KB, 1) }}`

- Take the first matching objects:

`Get-ChildItem | Select-Object -First {{count}}`
<!-- mant:tldr:end -->

# Select-Object

## Synopsis

```powershell
Select-Object [[-Property] <object[]>] [-First <int>] [-Last <int>]
    [-Unique] [-ExpandProperty <string>] [<CommonParameters>]
```

`Select-Object` creates output objects with selected properties, expands one
property, or limits pipeline output. Use it to shape data before display,
export, or a downstream command that needs a smaller contract.

## Selecting properties

Specify property names in order. The output is a selected object that contains
only those properties, not the original object type with every member.

```powershell
Get-Process |
    Select-Object ProcessName, Id, CPU
```

Use `Get-Member` to inspect real property names. A formatted table column is
not necessarily a source property.

## Calculated properties

A hashtable with `Name` and `Expression` creates a calculated property. Keep
expressions deterministic and inexpensive because they run for every input
object.

```powershell
Get-ChildItem -File |
    Select-Object Name, Extension, @{
        Name = 'SizeKiB'
        Expression = { [math]::Round($_.Length / 1KB, 1) }
    }
```

Calculated properties are preferable to formatting text early because the
result remains an object that can be sorted, exported, or converted to JSON.

## Expanding properties

`-ExpandProperty` emits the value of one property rather than a selected
wrapper object. Use it when the next pipeline stage needs the property value
itself, but remember that type and null behavior now come from that value.

```powershell
Get-Process | Select-Object -ExpandProperty ProcessName
```

Do not combine an expanded property with assumptions about the original
object's other properties; preserve those properties in a selected object when
the downstream step still needs them.

## First, last, unique, skip, and index

`-First` and `-Last` bound results. `-Unique` removes consecutive duplicate
output values according to the command's comparison behavior. Other options
can skip or select indexed positions. Apply filtering and sorting before these
options when ordering determines which values are retained.

```powershell
Get-ChildItem -File |
    Sort-Object Length -Descending |
    Select-Object -First 10 Name, Length
```

## Examples

Export a stable CSV shape:

```powershell
Get-Service |
    Select-Object Name, DisplayName, Status |
    Export-Csv -LiteralPath ./services.csv -NoTypeInformation
```

Return file paths as strings for a native command:

```powershell
Get-ChildItem -File |
    Select-Object -ExpandProperty FullName
```

## Platform and version differences

`Select-Object` is available across PowerShell 7 platforms. Input object
properties depend on the source cmdlet, module, provider, and operating
system. Verify calculated-property examples on every target where source
objects may differ.

## Related documents

- [Where-Object](Where-Object.md)
- [ForEach-Object](ForEach-Object.md)
- [Get-Member](Get-Member.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Select-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.6).
It is organized around preserving object shape before formatting or exporting.
Exact upstream revision and path are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
