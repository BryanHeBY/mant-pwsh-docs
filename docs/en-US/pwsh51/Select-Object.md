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

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Property PROPERTY`: Select named, wildcard, or calculated properties in output order.
- `-ExcludeProperty PROPERTY`: Remove matching properties from a wildcard property selection.
- `-ExpandProperty PROPERTY`: Emit one property's value instead of a selected wrapper object.
- `-First COUNT`: Return the first requested number of objects.
- `-Last COUNT`: Return the last requested number of objects.
- `-Skip COUNT`: Omit the first requested number of objects.
- `-Index INDEX`: Return objects at zero-based input indexes.
- `-Unique`: Remove duplicate selected values according to the cmdlet's comparison behavior.
- `-Wait`: Continue consuming upstream input after the selected result is known so upstream side effects can complete.
- `-InputObject OBJECT`: Treat the supplied value as one object; pipeline input is the normal form for collections.

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

## Common mistakes

### Expanding away needed context

`-ExpandProperty` emits only the selected value. Keep a selected object when a
later stage still needs sibling properties.

### Using `-First` before defining order

Filter and sort before selecting a bounded subset when “first” has operational
meaning.

### Copying newer selection parameters

PowerShell 7 documentation can include parameters such as `-SkipLast` or
`-SkipIndex` that Windows PowerShell 5.1 does not provide. Check 5.1 syntax.

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
