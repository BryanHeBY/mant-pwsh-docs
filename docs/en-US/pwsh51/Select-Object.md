<!-- mant:tldr:start -->
# Select-Object

> Choose object properties, create calculated properties, or take a bounded subset of Windows PowerShell 5.1 pipeline output.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/select-object?view=powershell-5.1.

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
property, or limits pipeline output. Shape data before display, export, or a
downstream command that needs a smaller contract.

## Properties and calculations

Specify property names in order. The result is a selected object, not the
original type with every member. Use `Get-Member` to inspect actual names.

```powershell
Get-Process | Select-Object ProcessName, Id, CPU
```

A hashtable with `Name` and `Expression` creates a calculated property. Keep
the expression deterministic and inexpensive because it runs once per object:

```powershell
Get-ChildItem -File |
    Select-Object Name, Extension, @{
        Name = 'SizeKiB'
        Expression = { [math]::Round($_.Length / 1KB, 1) }
    }
```

## Expansion and bounding

`-ExpandProperty` emits one property's value rather than a selected wrapper
object. Use it only when the downstream command needs that value itself:

```powershell
Get-ChildItem -File | Select-Object -ExpandProperty FullName
```

`-First`, `-Last`, `-Skip`, `-Unique`, and `-Index` can bound or choose output.
Apply filters and sorting before selecting values when ordering determines what
is retained.

```powershell
Get-ChildItem -File |
    Sort-Object Length -Descending |
    Select-Object -First 10 Name, Length
```

## Examples and compatibility

Export a stable CSV shape rather than formatted display text:

```powershell
Get-Service |
    Select-Object Name, DisplayName, Status |
    Export-Csv -LiteralPath .\services.csv -NoTypeInformation
```

Input property types depend on the source cmdlet, module, provider, Windows
version, and architecture. Verify calculated properties on target systems.

## Related documents

- [Where-Object](Where-Object.md)
- [ForEach-Object](ForEach-Object.md)
- [Get-Member](Get-Member.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Select-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/select-object?view=powershell-5.1).
It is organized around preserving object shape before formatting or exporting.
Exact upstream revision and path are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
