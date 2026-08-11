<!-- mant:tldr:start -->
# Sort-Object

> Sort Windows PowerShell 5.1 objects by one or more properties or calculated values.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-5.1.

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
Sort-Object [[-Property] <object[]>] [-Descending] [-Unique]
    [-Culture <string>] [-CaseSensitive] [<CommonParameters>]
```

`Sort-Object` orders pipeline objects by properties or calculated expressions.
It buffers input to determine the order, so filter at the source and bound the
result before sorting large Windows directory trees or service inventories.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Property PROPERTY`: Sort by one or more named or calculated keys.
- `-Ascending`: Sort in ascending order; this is the default.
- `-Descending`: Reverse the selected sort direction.
- `-Unique`: Return one object for each distinct comparison key after sorting.
- `-CaseSensitive`: Use case-sensitive string comparison.
- `-Culture CULTURE`: Use the named culture for string comparison.
- `-InputObject OBJECT`: Treat the supplied value as one object; pipeline input is the normal form for collections.

## Properties and calculated keys

Specify one or more properties. The first is the primary key; later properties
break ties. `-Descending` reverses the selected order.

```powershell
Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 10 ProcessName, Id, CPU
```

Use a hashtable expression for a derived key or per-property order:

```powershell
Get-ChildItem -File |
    Sort-Object @{ Expression = { $_.Extension }; Ascending = $true },
                @{ Expression = { $_.Length }; Descending = $true }
```

Use `Select-Object` with the same calculation if callers need to see or export
the derived value.

## Unique and comparison rules

`-Unique` removes duplicate output after sorting according to PowerShell's
comparison behavior. Windows PowerShell 5.1 does not provide the PowerShell 7
`-Stable`, `-Top`, or `-Bottom` parameters. Use `Select-Object -First` after a
sort when you need a bounded report; do not assume equal-key ordering is stable.

String ordering can depend on culture and case. Use `-Culture` and
`-CaseSensitive` only when the required ordering is explicit; prefer normalized
machine identifiers over localized display names in automated output.

## Examples

```powershell
Get-Service |
    Sort-Object DisplayName |
    Select-Object Name, DisplayName, Status

Get-ChildItem -LiteralPath C:\logs -File -Recurse |
    Sort-Object Length -Descending |
    Select-Object -First 10 FullName, Length
```

Input objects and display names depend on providers, modules, Windows version,
and locale. Record culture assumptions if sorting affects a saved result.

## Common mistakes

### Copying PowerShell 7-only switches

Windows PowerShell 5.1 has no `-Stable`, `-Top`, or `-Bottom`. Sort and then
use `Select-Object -First` when that behavior is adequate, without claiming
that equal-key order is stable.

### Sorting an unbounded input set

Sorting buffers input. Filter and bound expensive filesystem, remote, or API
queries as near to the source as possible.

### Assuming culture-independent uniqueness

`-Unique` follows the chosen comparison keys and string rules. Normalize keys
and specify culture/case requirements when output must be reproducible.

## Version and availability

This page targets Windows PowerShell 5.1. Do not use PowerShell 7 parameters
such as `-Stable`, `-Top`, or `-Bottom` in a 5.1 script; implement and test the
required ordering explicitly.

## Related documents

- [Get-ChildItem](Get-ChildItem.md)
- [Where-Object](Where-Object.md)
- [Select-Object](Select-Object.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Sort-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-5.1).
It emphasizes bounded sorting, culture, and the Windows PowerShell 5.1
parameter set. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
