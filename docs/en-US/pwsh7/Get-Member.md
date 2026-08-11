<!-- mant:tldr:start -->
# Get-Member

> Inspect the properties, methods, and type information of PowerShell 7 objects.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-member?view=powershell-7.6.

- Inspect pipeline object members:

`{{command}} | Get-Member`

- Show only properties:

`{{command}} | Get-Member -MemberType Property`

- Inspect a static .NET type:

`Get-Member -InputObject ([type]::GetType('{{TypeName}}')) -Static`
<!-- mant:tldr:end -->

# Get-Member

## Synopsis

```powershell
Get-Member [[-Name] <string[]>] [-InputObject <psobject>] [-MemberType <PSMemberTypes>]
    [-Static] [-Force] [<CommonParameters>]
```

`Get-Member` reports the members and type names of objects passed through the
pipeline or supplied through `-InputObject`. Use it to learn the object model
before selecting properties, calling methods, or writing a formatting rule.

## Inspect pipeline objects

Pipe a command's unformatted output into `Get-Member`. The result lists the
type names, properties, methods, events, aliases, and other exposed members.

```powershell
Get-Process | Get-Member
Get-ChildItem -File | Get-Member -MemberType Property
```

Place `Get-Member` before `Format-Table`, `Out-String`, or text redirection.
Those formatting operations change the pipeline data into presentation output
and hide the members of the original object.

## Select member types

Use `-MemberType` to focus on a category such as `Property`, `Method`,
`ScriptProperty`, `AliasProperty`, or `NoteProperty`. Use `-Name` to match
specific member names with wildcard patterns.

```powershell
Get-Service | Get-Member -MemberType Property -Name '*Name'
```

Properties return data; methods perform an operation. Prefer cmdlets for
operations that need pipeline behavior, common parameters, error handling, or
PowerShell provider semantics. Calling a .NET method can be appropriate when
its contract is explicit and portable.

## InputObject and collections

`-InputObject` inspects the supplied object as one value. Piping a collection
normally enumerates it and reports the members of each item type. This
distinction matters when inspecting an array itself rather than its elements.

```powershell
$items = Get-ChildItem -File
$items | Get-Member
Get-Member -InputObject $items
```

## Static members

Use `-Static` with a .NET type to inspect static properties and methods.
Static calls bypass an object instance and can be platform-dependent when the
type exposes operating-system APIs.

```powershell
[System.DateTime] | Get-Member -Static
```

## Adapted and hidden members

PowerShell can adapt .NET objects, add extended type-system members, and hide
some intrinsic members by default. `-Force` includes hidden and intrinsic
members. Use it for debugging type behavior, not as a signal to depend on
internal implementation details.

## Examples

Inspect JSON after conversion rather than before:

```powershell
'{"name":"Ada","active":true}' |
    ConvertFrom-Json |
    Get-Member
```

Discover the property names required for a report:

```powershell
Get-Process |
    Get-Member -MemberType Property |
    Select-Object -ExpandProperty Name
```

## Platform and version differences

The cmdlet works across PowerShell 7 platforms, but object types and members
depend on installed modules, .NET runtime behavior, provider implementations,
and operating system. Inspect objects on every target platform when writing
portable property or method access.

## Related documents

- [Get-Command](Get-Command.md)
- [Get-Help](Get-Help.md)
- [about_Pipelines](about_Pipelines.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-Member reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-member?view=powershell-7.6).
It emphasizes object inspection before formatting or automation. Exact
upstream revision and path are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
