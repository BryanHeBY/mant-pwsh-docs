<!-- mant:tldr:start -->
# Where-Object

> Filter pipeline objects by property values or a predicate script block.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/where-object?view=powershell-7.6.

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

`Where-Object` passes through only pipeline objects that match a condition.
Use it to filter objects before sorting, selecting properties, exporting, or
performing an action.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-FilterScript SCRIPTBLOCK`: Evaluate a predicate for every pipeline object; `$_` and `$PSItem` refer to the current object.
- `-Property NAME`: Select the input property used by the comparison parameter set.
- `-Value VALUE`: Supply the comparison value when the chosen operator requires one.
- `-EQ`, `-IEQ`, `-CEQ`: Test equality using default, explicitly case-insensitive, or case-sensitive comparison.
- `-NE`, `-INE`, `-CNE`: Test inequality with the corresponding case policy.
- `-GT`, `-GE`, `-LT`, `-LE`: Perform ordered greater-than or less-than comparisons.
- `-Like`, `-NotLike`: Match or reject wildcard patterns.
- `-Match`, `-NotMatch`: Match or reject regular expressions.
- `-Contains`, `-NotContains`: Test whether the property collection contains a value.
- `-In`, `-NotIn`: Test whether the property value occurs in a supplied collection.
- `-Is`, `-IsNot`: Test the runtime type of the property value.

## Property comparison syntax

The concise form names a property, a comparison operator, and a value. It is
well suited to simple filtering and is easier to scan than a script block:

```powershell
Get-Process | Where-Object ProcessName -Like 'pwsh*'
Get-ChildItem -File | Where-Object Length -GT 1MB
```

Common operators include `-EQ`, `-NE`, `-GT`, `-GE`, `-LT`, `-LE`, `-Like`,
`-NotLike`, `-Match`, `-NotMatch`, `-In`, `-NotIn`, `-Contains`, and
`-NotContains`. Choose the operator according to the property type and the
intended comparison; do not use a wildcard when an exact name is required.

## Filter script syntax

Use `-FilterScript` or its positional script block form for multiple
conditions, method calls, null handling, or computed comparisons. `$_` and
`$PSItem` name the current pipeline object:

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 1MB -and $_.Extension -in '.log', '.json'
    }
```

Keep predicates side-effect free. A filter that creates, deletes, writes, or
mutates data is difficult to reason about and should normally be an explicit
action in a later pipeline stage.

## Null and missing properties

A property can be absent or null. Compare `$null` on the left when testing
values that might be collections, and guard optional properties explicitly:

```powershell
$items | Where-Object {
    $null -ne $_.Owner -and $_.Owner.Name -eq 'Ada'
}
```

Use `Get-Member` to inspect actual object properties rather than assuming a
display column is a property name.

## Performance and scope

`Where-Object` processes input as it arrives, so it composes well with large
pipelines. When the original provider or cmdlet has a filtering parameter,
prefer it for remote, filesystem, or API queries because filtering closer to
the data source can reduce work and transfer.

## Examples

Select currently running services whose name begins with `Win`:

```powershell
Get-Service |
    Where-Object Status -EQ Running |
    Where-Object Name -Like 'Win*'
```

Filter structured JSON data after conversion:

```powershell
Get-Content -Raw ./items.json |
    ConvertFrom-Json |
    Where-Object Enabled
```

## Common mistakes

### Filtering on a formatted column

A display label is not necessarily an object property. Place `Get-Member`
before formatting and use the actual property name.

### Putting side effects in a predicate

A filter should decide whether an object passes. Move writes, deletion, or
state changes to an explicit later stage so retries and failures remain clear.

### Retrieving everything before filtering

When a provider, remote command, or API exposes a server-side filter, prefer
that parameter to reduce work and transfer; use `Where-Object` for conditions
that cannot be expressed at the source.

## Platform and version differences

`Where-Object` is available across PowerShell 7 platforms. The input object's
properties and the availability of source commands vary by operating system,
module, provider, and runtime version. Verify the source command's object type
on every supported target.

## Related documents

- [ForEach-Object](ForEach-Object.md)
- [Select-Object](Select-Object.md)
- [Get-Member](Get-Member.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Where-Object reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/where-object?view=powershell-7.6).
It is organized around safe predicates, object inspection, and source-side
filtering. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
