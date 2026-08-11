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

## Paths and providers

`-Path` accepts provider paths and wildcard patterns. Use `-LiteralPath` when
the path is data that can contain `[` or `*`. A filesystem path and a provider
path such as `Env:`, `HKLM:`, `HKCU:`, `Certificate:`, or `Function:` expose
different item types and parameters.

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

Use `-Filter` when the provider supports source-side filtering. `-Include` and
`-Exclude` have provider-specific path rules. `-Recurse` descends into child
containers; `-Depth` bounds traversal; `-File` and `-Directory` choose a kind;
and `-Force` can include hidden items.

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

## Windows-specific behavior

Filesystem permissions, hidden attributes, providers, registry views, UNC
paths, and junction handling depend on Windows version and process
architecture. Native programs do not accept arbitrary provider paths; convert
to a filesystem path before passing one to an `.exe`.

## Related documents

- [Where-Object](Where-Object.md)
- [Sort-Object](Sort-Object.md)
- [Select-Object](Select-Object.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-ChildItem reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-5.1).
It emphasizes Windows providers, literal paths, and bounded recursive
enumeration. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
