<!-- mant:tldr:start -->
# Get-ChildItem

> List items from a Windows filesystem path or another Windows PowerShell provider.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-5.1.

- List files in the current location:

`Get-ChildItem -File`

- List matching files recursively:

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

`Get-ChildItem` lists child items in a filesystem directory or another Windows
PowerShell provider. Common aliases include `gci`, `dir`, and `ls`; use the
full cmdlet name in automation to avoid command-name ambiguity.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Path PATH`: Enumerate provider paths and expand wildcard characters.
- `-LiteralPath PATH`: Enumerate exact provider paths without wildcard expansion.
- `-Filter FILTER`: Ask the provider to filter near the source; syntax and support depend on the provider.
- `-Include PATTERN`: Include matching child names after path/provider selection.
- `-Exclude PATTERN`: Exclude matching child names after path/provider selection.
- `-Recurse`: Descend through child containers.
- `-Depth COUNT`: Bound recursive descent to the requested number of levels.
- `-File`: Return filesystem files only; this is a FileSystem-provider dynamic parameter.
- `-Directory`: Return filesystem directories only; this is a FileSystem-provider dynamic parameter.
- `-Hidden`: Return filesystem items with the hidden attribute.
- `-ReadOnly`: Return filesystem items with the read-only attribute.
- `-System`: Return filesystem items with the system attribute.
- `-Attributes EXPRESSION`: Select filesystem items using an attribute expression.
- `-Force`: Include hidden or otherwise normally omitted items where supported; it does not bypass ACLs.
- `-Name`: Return relative name strings instead of provider item objects.
- `-FollowSymlink`: Follow directory symbolic links during recursion when the serviced Windows PowerShell 5.1 FileSystem provider exposes this dynamic parameter; it is not available on every 5.1 host.

## Paths and providers

`-Path` accepts provider paths and wildcard patterns. Use `-LiteralPath` when
the path is data that can contain `[` or `*`. A filesystem path and a provider
path such as `Env:`, `HKLM:`, `HKCU:`, `Cert:`, or `Function:` expose
different item types and parameters. `Certificate` is the provider name;
`Cert:` is its built-in drive name.

```powershell
Get-ChildItem -Path C:\logs
Get-ChildItem -LiteralPath 'C:\data[2026]'
Get-ChildItem Env:
Get-ChildItem HKLM:\SOFTWARE
```

Do not pass an untrusted path to `-Path` when wildcard expansion might select
more items than intended. Use `-LiteralPath` and validate scope before a later
command modifies any returned item.

## Filtering and recursion

Use `-Filter` when the provider supports source-side filtering. For the
built-in FileSystem provider it accepts one string passed to the enumeration
API, whose wildcard support is limited to `*` and `?`. `-Include` and
`-Exclude` accept string arrays and PowerShell wildcard patterns including
`*`, `?`, and `[]`, but PowerShell applies them after provider enumeration and
their effect depends on the exact path form. `-Recurse` descends into child
containers; `-Depth` bounds traversal; `-File` and `-Directory` choose a kind;
and `-Force` can include hidden items.

In Windows PowerShell 5.1, `-Depth` has no effect when combined with
`-Include`; use the FileSystem provider's `-Filter` when it can express the
match. `-Include` and `-Exclude` also have no effect with `-LiteralPath` in
5.1. These limitations were fixed in later PowerShell releases.

Large recursive scans can cross network shares, junctions, protected folders,
or large user profiles. Bound the root and filter before results feed a
destructive command.

## Output objects

Filesystem enumeration emits `FileInfo` and `DirectoryInfo` objects with
properties such as `FullName`, `Name`, `Length`, `Extension`, and timestamps.
Other providers emit different objects. Inspect the target before relying on a
property:

```powershell
Get-ChildItem -File | Get-Member
Get-ChildItem -File | Select-Object FullName, Length, LastWriteTime
```

## Examples

```powershell
Get-ChildItem -Path C:\logs -Filter '*.log' -File -Recurse |
    Where-Object LastWriteTime -GT (Get-Date).AddDays(-7) |
    Select-Object FullName, Length, LastWriteTime
```

Review a staging tree before an independently approved destructive action:

```powershell
Get-ChildItem -LiteralPath C:\staging -File -Recurse |
    Select-Object FullName, Length
```

## Common mistakes

### Using `-Path` for literal wildcard characters

Use `-LiteralPath` when filenames containing `[` or `*` are data rather than
patterns.

### Assuming filesystem switches work on every provider

Dynamic parameters such as `-File`, `-Directory`, and `-Attributes` are not a
contract for Registry, Certificate, Environment, or third-party providers.

### Starting an unbounded recursive scan

Anchor an exact root and use source filtering and `-Depth`. Junctions, shares,
permissions, and profile trees can make a seemingly small traversal expensive.

### Assuming every Windows PowerShell 5.1 build has the same dynamic parameters

The current official 5.1 reference lists `-FollowSymlink` while also noting
that the parameter was introduced in PowerShell 6. The serviced Windows build
used for this repository exposes it in 5.1, but older 5.1 FileSystem providers
may not. Check `Get-Command Get-ChildItem -Syntax` on the target host before
depending on it.

## Windows-specific behavior

Filesystem permissions, hidden attributes, providers, registry views, UNC
paths, and junction handling depend on Windows version and process
architecture. Native programs do not accept arbitrary provider paths; convert
to a filesystem path before passing one to an `.exe`.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 confirmed all documented option names against
live metadata, including the serviced `-FollowSymlink` parameter, and a
bounded SystemRoot enumeration produced a `FileSystemInfo` object. A separate
`-NoProfile` provider fixture confirmed `DirectoryInfo`, `AliasInfo`,
`DictionaryEntry`, `FunctionInfo`, `PSVariable`, `RegistryKey`, and
`X509StoreLocation` objects from fixed built-in paths without emitting their
values. It also confirmed six selected FileSystem-only dynamic parameters,
none of them on Registry paths, and Certificate-provider `CodeSigningCert`.
In the fresh process, the first `Get-PSProvider` snapshot contained six core
providers but not Certificate; subsequent `Get-PSDrive` discovery loaded
`Microsoft.PowerShell.Security`, exposed `Cert:`, and made the Certificate
provider visible. Provider discovery is session state, so record invocation
order rather than treating snapshots from different load points as a
contradiction.
The fixture does not traverse links, recurse, enumerate environment/registry/
certificate contents, or perform provider mutation; path edge cases,
third-party providers, and recursive behavior remain outstanding.

## Related documents

- [Where-Object](Where-Object.md)
- [Sort-Object](Sort-Object.md)
- [Select-Object](Select-Object.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-ChildItem reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-5.1).
Provider object types and drive semantics are cross-checked against the
official [about_Providers](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_providers?view=powershell-5.1)
and [Get-PSDrive](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-psdrive?view=powershell-5.1)
references. It emphasizes Windows providers, literal paths, and bounded
recursive enumeration. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
