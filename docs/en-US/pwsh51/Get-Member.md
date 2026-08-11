<!-- mant:tldr:start -->
# Get-Member

> Inspect the properties, methods, and type information of Windows PowerShell 5.1 objects.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-member?view=powershell-5.1.

- Inspect pipeline object members:

`{{command}} | Get-Member`

- Show only properties:

`{{command}} | Get-Member -MemberType Property`

- Inspect a static .NET type:

`[System.DateTime] | Get-Member -Static`
<!-- mant:tldr:end -->

# Get-Member

## Synopsis

```powershell
Get-Member [[-Name] <string[]>] [-InputObject <psobject>]
    [-MemberType <PSMemberTypes>] [-Static] [-Force] [<CommonParameters>]
```

`Get-Member` reports the members and type names of objects passed through the
pipeline or given to `-InputObject`. Use it to understand the object model
before selecting properties, calling methods, or constructing formatting rules.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-InputObject OBJECT`: Inspect the supplied value as one object instead of enumerating it through the pipeline.
- `-Name NAME`: Select member names; wildcard patterns are accepted.
- `-MemberType TYPE`: Restrict results to properties, methods, events, or other member categories.
- `-Static`: Inspect static members on a supplied .NET Framework type.
- `-Force`: Include intrinsic, adapted, and otherwise hidden members.
- `-View VIEW`: Select the adapted, extended, or base member view.

## Inspect pipeline objects

Pipe unformatted output to `Get-Member`. The result lists type names,
properties, methods, events, aliases, and extended members.

```powershell
Get-Process | Get-Member
Get-ChildItem -File | Get-Member -MemberType Property
```

Put `Get-Member` before `Format-Table`, `Out-String`, or text redirection.
Those operations change objects into presentation data and hide their original
members.

## Member categories and collections

Use `-MemberType` to focus on categories such as `Property`, `Method`,
`ScriptProperty`, `AliasProperty`, or `NoteProperty`. `-Name` accepts wildcard
patterns for particular member names.

`-InputObject` examines the supplied value as one object. Piping a collection
normally enumerates it, which is different when inspecting an array itself:

```powershell
$items = Get-ChildItem -File
$items | Get-Member
Get-Member -InputObject $items
```

Properties expose data; methods perform operations. Prefer cmdlets for work
that needs providers, pipeline semantics, common parameters, or PowerShell
error handling.

## Static, adapted, and hidden members

Use `-Static` with a .NET Framework type to inspect its static members:

```powershell
[System.DateTime] | Get-Member -Static
```

Windows PowerShell can adapt .NET objects and add extended type-system
members. `-Force` includes hidden and intrinsic members. Use it for debugging
type behavior, not as a contract to depend on internal implementation details.

Object types and members vary by Windows version, installed modules, provider,
.NET Framework behavior, and architecture. Inspect objects on the target host
before shipping property or method access in a shared script.

## Common mistakes

### Inspecting after formatting

Formatting cmdlets replace the original domain objects with presentation data.
Pipe to `Get-Member` before `Format-Table`, `Out-String`, or text redirection.

### Confusing the collection and element types

Pipeline input enumerates a collection, whereas `-InputObject $items` inspects
the collection object. Choose the form deliberately.

### Depending on a display-only column

Formatting definitions can show calculated labels that are not real object
properties. Verify the member before using it in a script.

## Version and availability

This page describes Windows PowerShell 5.1. Members depend on the runtime type,
loaded type data, remoting serialization, and installed .NET Framework rather
than only on the spelling of the originating command.

## Related documents

- [Get-Command](Get-Command.md)
- [Get-Help](Get-Help.md)
- [about_Pipelines](about_Pipelines.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-Member reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-member?view=powershell-5.1).
It emphasizes object inspection before formatting or Windows automation.
Exact upstream revision and path are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
