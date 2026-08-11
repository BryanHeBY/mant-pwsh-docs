<!-- mant:tldr:start -->
# Sort-Object

> Sort PowerShell 7 objects by one or more properties or calculated values.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.6.

- Sort by one property:

`Get-Process | Sort-Object CPU`

- Sort descending and take the largest results:

`Get-ChildItem -File | Sort-Object Length -Descending | Select-Object -First {{count}}`

- Sort by a calculated value:

`{{command}} | Sort-Object @{Expression={ {{expression}} }; Descending=$true}`
<!-- mant:tldr:end -->

# Sort-Object

## Synopsis

```powershell
Sort-Object [[-Property] <object[]>] [-Descending] [-Unique] [-Stable]
    [-Top <int>] [-Bottom <int>] [<CommonParameters>]
```

`Sort-Object` orders pipeline objects by one or more properties or calculated
expressions. It buffers input to determine the order, so apply source-side
filtering and selection first when input can be large.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Property PROPERTY`: Sort by one or more named or calculated keys; per-key hashtables can specify direction.
- `-Ascending`: Sort in ascending order; this is the default when no direction is supplied.
- `-Descending`: Reverse the selected sort direction.
- `-Unique`: Return one object for each distinct comparison key after sorting.
- `-Stable`: Preserve original input order when comparison keys are equal.
- `-Top COUNT`: Return only the highest-ranked requested number of objects.
- `-Bottom COUNT`: Return only the lowest-ranked requested number of objects.
- `-CaseSensitive`: Use case-sensitive string comparison.
- `-Culture CULTURE`: Use the named culture for string comparison.
- `-InputObject OBJECT`: Treat the supplied value as one object; pipeline input is the normal form for collections.

## Sorting by properties

Specify one or more property names. The first property is the primary key;
later properties break ties. Use `-Descending` to reverse the selected order.

```powershell
Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 10 ProcessName, Id, CPU
```

Inspect the input with `Get-Member` before choosing a property. A formatted
column does not prove that the original object has a property with that name.

## Calculated properties

Use a hashtable expression for derived sort keys or for per-property sort
direction. Keep the expression deterministic and inexpensive because it runs
for every input object.

```powershell
Get-ChildItem -File |
    Sort-Object @{
        Expression = { $_.Extension }
        Ascending = $true
    }, @{
        Expression = { $_.Length }
        Descending = $true
    }
```

Use `Select-Object` with the same calculation when callers need to see or
export the derived value as part of the result.

## Unique, stable, top, and bottom

`-Unique` removes adjacent duplicate output values after sorting. `-Stable`
preserves original input order for items with equal keys. `-Top` and `-Bottom`
return a bounded number of sorted objects. Apply filters before sorting and
bound output deliberately when reporting on large collections.

```powershell
Get-ChildItem -File |
    Sort-Object Length -Bottom 5 |
    Select-Object Name, Length
```

## Culture and comparison

String ordering can depend on culture and case sensitivity. Use explicit
culture and case options when an automated result must be stable across hosts.
For machine identifiers, prefer invariant, normalized values over localized
display names when defining a sort contract.

## Examples

Sort services by display name and select a report shape:

```powershell
Get-Service |
    Sort-Object DisplayName |
    Select-Object Name, DisplayName, Status
```

Find the ten largest files in a bounded directory tree:

```powershell
Get-ChildItem -LiteralPath ./logs -File -Recurse |
    Sort-Object Length -Descending |
    Select-Object -First 10 FullName, Length
```

## Common mistakes

### Sorting an unbounded stream

Sorting requires enough buffering to compare the input. Filter near the
source and bound the scope before sorting large filesystem, remote, or API
results.

### Treating `-Unique` as arbitrary deduplication

Uniqueness follows the selected comparison keys and sort semantics. Select a
normalized key deliberately when case, culture, or object string conversion
would otherwise change the result.

### Assuming ties keep input order

Use `-Stable` when equal keys must retain source order and require a PowerShell
version that provides it.

## Platform and version differences

`Sort-Object` is cross-platform, but input objects and string comparison can
depend on locale, provider, module, and operating system. Record culture or
case assumptions where ordering affects automation output.

## Related documents

- [Get-ChildItem](Get-ChildItem.md)
- [Where-Object](Where-Object.md)
- [Select-Object](Select-Object.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Sort-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.6).
It emphasizes bounded, reproducible sorting and object-first pipeline design.
Exact upstream revision and path are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
