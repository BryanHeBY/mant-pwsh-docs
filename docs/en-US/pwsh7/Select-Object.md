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
    [-Unique] [-CaseInsensitive] [-ExpandProperty <string>] [<CommonParameters>]
```

`Select-Object` creates output objects with selected properties, expands one
property, or limits pipeline output. Use it to shape data before display,
export, or a downstream command that needs a smaller contract.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Property PROPERTY`: Select named, wildcard, or calculated properties in output order.
- `-ExcludeProperty PROPERTY`: Remove matching properties from a wildcard property selection.
- `-ExpandProperty PROPERTY`: Emit one property's value instead of a selected wrapper object.
- `-First COUNT`: Return the first requested number of objects.
- `-Last COUNT`: Return the last requested number of objects.
- `-Skip COUNT`: Omit the first requested number of objects.
- `-SkipLast COUNT`: Omit the requested number of objects from the end; availability depends on the PowerShell 7 version.
- `-Index INDEX`: Return objects at zero-based input indexes.
- `-SkipIndex INDEX`: Exclude objects at zero-based input indexes; availability depends on the PowerShell 7 version.
- `-Unique`: Remove duplicate values after the other selection parameters are applied; comparisons are case-sensitive by default.
- `-CaseInsensitive`: Make unique-value string comparisons case-insensitive; added in PowerShell 7.4.
- `-Wait`: Continue consuming upstream input after enough objects have been selected so upstream side effects can complete.
- `-InputObject OBJECT`: Treat the supplied value as one object; pipeline input is the normal form for collections.

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

When `-Property` and `-ExpandProperty` are combined, `Select-Object` attempts
to add the selected properties as `NoteProperty` members to each expanded
object. That can alter referenced input objects and can fail on a name
collision. Construct a new object explicitly when mutation is unacceptable.

## First, last, unique, skip, and index

`-First` and `-Last` can be combined to return both ends of the input. When
`-Skip` is also present, it skips from the beginning before those selections:
`1..20 | Select-Object -First 3 -Last 3 -Skip 4` returns `5, 6, 7, 18,
19, 20`. `-SkipLast` belongs to a different parameter set and cannot be
combined with `-First` or `-Last` in the same invocation. Use `-Skip` with
`-SkipLast` to trim both ends, then pipe to a second `Select-Object` if another
first/last selection is required.

`-Unique` removes duplicates from the subset remaining after other selection
parameters; it is case-sensitive unless `-CaseInsensitive` is used. Other
options can select or exclude indexed positions. Apply filtering and sorting
before these options when ordering determines which values are retained.

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
    Export-Csv -LiteralPath ./services.csv -NoTypeInformation -NoClobber
```

`-NoClobber` makes an existing destination an error; still resolve the final
path and choose a protected parent before exporting sensitive service data.

Return file paths as strings for a native command:

```powershell
Get-ChildItem -File |
    Select-Object -ExpandProperty FullName
```

## Common mistakes

### Expanding a property too early

`-ExpandProperty` normally emits the property's values rather than a wrapper
with the original object's context. Combining it with `-Property` instead adds
selected note properties to expanded objects and can mutate referenced input.
Construct the intended output object explicitly when either behavior is
surprising.

### Assuming `-Unique` is case-insensitive or only compares neighbors

The comparison is case-sensitive by default and applies after other selection
parameters to the whole selected subset. Use `-CaseInsensitive` on PowerShell
7.4 or later when casing should not distinguish strings.

### Taking `-First` before defining order

The first objects are whatever the upstream command emitted. Filter and sort
explicitly when the retained subset has semantic meaning.

### Combining incompatible skip parameters

`-First`, `-Last`, and `-Skip` share one parameter set, while `-SkipLast`
shares the separate skip-only set. A command such as
`Select-Object -First 3 -Last 3 -SkipLast 4` fails parameter binding; split
the required stages into separate pipeline commands and verify which end each
stage trims.

### Expecting selection to be display-only

`Select-Object -Property` creates selected wrapper objects. Use formatting
cmdlets only at the presentation boundary, and preserve original objects when
their methods or type identity are still required.

## Platform and version differences

`Select-Object` is available across PowerShell 7 platforms. Input object
properties depend on the source cmdlet, module, provider, and operating
system. `-CaseInsensitive` requires PowerShell 7.4 or later. Verify calculated
property and expansion behavior on every target where source objects may
differ.

## Runtime evidence

PowerShell 7.6.4 on Windows confirmed all documented option metadata, default
`-Unique` output `a,A`, 7.4+ case-insensitive output `a`, and combined
`-First 3 -Last 3 -Skip 4` output `5,6,7,18,19,20`. Adding `-SkipLast` raised
`AmbiguousParameterSet`. The in-memory fixtures do not cover provider-specific
objects, large-stream resource limits, macOS, Linux, or every calculated
property expression.

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
