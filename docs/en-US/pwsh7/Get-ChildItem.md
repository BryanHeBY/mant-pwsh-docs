<!-- mant:tldr:start -->
# Get-ChildItem

> List items from a filesystem path or another PowerShell provider.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-7.6.

- List files in the current location:

`Get-ChildItem -File`

- List files recursively with a filter:

`Get-ChildItem -Path {{path}} -Filter '{{pattern}}' -File -Recurse`

- Treat wildcard characters in a path literally:

`Get-ChildItem -LiteralPath {{path-with-[brackets]}}`
<!-- mant:tldr:end -->

# Get-ChildItem

## Synopsis

```powershell
Get-ChildItem [[-Path] <string[]>] [[-Filter] <string>] [-File] [-Directory]
    [-Recurse] [-Depth <uint>] [-Force] [<CommonParameters>]
```

`Get-ChildItem` lists child items in a filesystem directory or another
PowerShell provider. Its common aliases include `gci`, `dir`, and `ls`, but
automation should prefer the full cmdlet name to avoid shell-specific habits.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Path PATH`: Enumerate one or more provider paths and expand wildcard characters.
- `-LiteralPath PATH`: Enumerate an exact provider path without wildcard expansion.
- `-Filter FILTER`: Ask the provider to filter near the source; syntax and support are provider-specific.
- `-Include PATTERN`: Include matching child names after path/provider selection; test the path form because provider behavior differs.
- `-Exclude PATTERN`: Exclude matching child names after path/provider selection.
- `-Recurse`: Descend through child containers rather than listing only immediate children.
- `-Depth COUNT`: Bound recursive descent to the requested number of levels.
- `-File`: Return filesystem files only; this is a FileSystem-provider dynamic parameter.
- `-Directory`: Return filesystem directories only; this is a FileSystem-provider dynamic parameter.
- `-Attributes EXPRESSION`: Select filesystem items by attribute expression, including combined and negated attributes.
- `-Force`: Include hidden or otherwise normally omitted items where the provider supports it; it does not bypass security checks.
- `-Name`: Return relative name strings instead of provider item objects.
- `-FollowSymlink`: Follow symbolic-link directories during recursion in PowerShell versions/providers that expose this dynamic parameter.

## Paths and providers

`-Path` accepts one or more provider paths and supports wildcards. Use
`-LiteralPath` when the path is data that can contain wildcard characters such
as `[` or `*`. A filesystem path and a provider path such as `Env:` or
`Function:` expose different item types and parameters.

```powershell
Get-ChildItem -Path ./logs
Get-ChildItem -LiteralPath './data[2026]'
Get-ChildItem Env:
```

Do not pass an untrusted string to `-Path` when wildcard expansion would select
more items than intended. Use `-LiteralPath` and validate location scope for
automation that will act on results.

## Filtering and recursion

Use `-Filter` when the provider can apply a simple filter near the source. It
is usually more efficient than retrieving every item and filtering later.
`-Include` and `-Exclude` are path-pattern controls with provider-specific
behavior; use them only after testing the exact path form.

`-Recurse` descends into child containers. `-Depth` limits recursion in
providers that support it. Use `-File` or `-Directory` to select one item kind
and `-Force` to include hidden or otherwise omitted items where supported.

```powershell
Get-ChildItem -Path ./src -Filter '*.ps1' -File -Recurse
Get-ChildItem -Path ./archive -Directory -Depth 2
```

Large recursive enumeration can be expensive and can cross mount points,
network shares, or protected directories. Bound the path and filter before
using the result in a modifying command.

## Output objects

Filesystem enumeration emits `FileInfo` and `DirectoryInfo` objects with
properties such as `FullName`, `Name`, `Length`, `Extension`, and timestamps.
Other providers emit provider-specific objects. Use `Get-Member` to inspect
the actual type before writing a portable property expression.

```powershell
Get-ChildItem -File | Get-Member
Get-ChildItem -File | Select-Object FullName, Length, LastWriteTime
```

## Examples

Find recent log files without displaying every property:

```powershell
Get-ChildItem -Path ./logs -Filter '*.log' -File -Recurse |
    Where-Object LastWriteTime -GT (Get-Date).AddDays(-7) |
    Select-Object FullName, Length, LastWriteTime
```

Safely review files before a separate destructive action:

```powershell
Get-ChildItem -LiteralPath ./staging -File -Recurse |
    Select-Object FullName, Length
```

## Common mistakes

### Using wildcard paths for literal input

A path containing `[` or `*` is interpreted by `-Path`. Use `-LiteralPath`
when a path is data, especially before piping results into a modifying command.

### Expecting provider parameters everywhere

`-File`, `-Directory`, `-Attributes`, and `-FollowSymlink` are supplied by the
FileSystem provider. They are not a portable contract for `Registry:`, `Env:`,
or third-party providers.

### Starting unbounded recursion

`-Recurse` can cross large trees, links, mounts, network shares, and protected
locations. Anchor an exact root, apply provider-side filtering, and use
`-Depth` when the task has a natural bound.

## Platform and version differences

The cmdlet is cross-platform, but provider availability, filesystem casing,
permissions, hidden-item rules, links, mounts, and path syntax vary by
operating system. Test recursive and provider-specific behavior on every
target platform.

## Related documents

- [Where-Object](Where-Object.md)
- [Sort-Object](Sort-Object.md)
- [Select-Object](Select-Object.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-ChildItem reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-7.6).
It emphasizes provider boundaries, literal paths, and bounded recursive
enumeration. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
