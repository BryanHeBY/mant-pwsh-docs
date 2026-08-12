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
    [-SkipLast <int>] [-Unique] [-ExpandProperty <string>]
    [<CommonParameters>]
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
- `-SkipLast COUNT`: Omit the requested number of objects from the end of the input.
- `-Index INDEX`: Return objects at zero-based input indexes.
- `-Unique`: Remove duplicate values after the other selection parameters are applied; comparisons are case-sensitive.
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

When `-Property` is combined with `-ExpandProperty`, selected properties are
added as `NoteProperty` members to expanded objects. This can mutate referenced
input objects or fail on a property-name collision; construct a new object
explicitly when that side effect is unacceptable.

`-First` and `-Last` can be combined. When `-Skip` is also present, it skips
from the beginning before both selections: `1..20 | Select-Object -First 3
-Last 3 -Skip 4` returns `5, 6, 7, 18, 19, 20`. `-SkipLast` belongs to a
different parameter set and cannot be combined with `-First` or `-Last` in the
same invocation. Trim with `-Skip` and `-SkipLast` first, then use a second
pipeline stage when a further first/last selection is required.

`-Unique` removes duplicates from the selected subset and is case-sensitive.
`-Index` chooses zero-based positions. Apply filters and sorting before
selecting values when ordering determines what is retained.

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
    Export-Csv -LiteralPath .\services.csv -NoTypeInformation -NoClobber
```

`-NoClobber` makes an existing destination an error; still resolve the final
path and choose a protected parent before exporting sensitive service data.

Input property types depend on the source cmdlet, module, provider, Windows
version, and architecture. Verify calculated properties on target systems.

## Common mistakes

### Expanding away needed context

`-ExpandProperty` normally emits the selected value. When combined with
`-Property`, it can instead add note properties to the expanded object and
mutate a referenced input object. Build a new output object when a later stage
needs sibling context without mutation.

### Assuming unique comparison is case-insensitive or adjacent-only

`-Unique` compares the whole selected subset and treats strings that differ
only by case as distinct. Windows PowerShell 5.1 has no `-CaseInsensitive`
switch for this cmdlet.

### Using `-First` before defining order

Filter and sort before selecting a bounded subset when “first” has operational
meaning.

### Combining incompatible skip parameters

`-First`, `-Last`, and `-Skip` share one parameter set, while `-SkipLast`
shares the separate skip-only set. A command such as
`Select-Object -First 3 -Last 3 -SkipLast 4` fails parameter binding; separate
the stages and verify which end each stage trims.

### Copying newer selection parameters

Windows PowerShell 5.1 supports `-SkipLast`, but not later additions such as
`-SkipIndex` or 7.4's `-CaseInsensitive`. Check the installed 5.1 syntax rather
than grouping similarly named parameters under one assumed version boundary.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 confirmed all documented option metadata,
case-sensitive `-Unique` output `a,A`, `-SkipLast 1` output `1,2`, and combined
`-First 3 -Last 3 -Skip 4` output `5,6,7,18,19,20`. Adding `-SkipLast` to that
combination raised `AmbiguousParameterSet`. The in-memory fixtures do not cover
provider-specific objects, large-stream resource limits, or every calculated
property expression.

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
