<!-- mant:tldr:start -->
# Get-Help

> Read installed Windows PowerShell 5.1 command and concept documentation.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-help?view=powershell-5.1.

- Show concise command help:

`Get-Help {{command}}`

- Show parameters, examples, inputs, and outputs:

`Get-Help {{command}} -Full`

- Open official online help:

`Get-Help {{command}} -Online`
<!-- mant:tldr:end -->

# Get-Help

## Synopsis

```powershell
Get-Help [[-Name] <string>] [-Full] [-Detailed] [-Examples] [-Online]
    [-Parameter <string>] [<CommonParameters>]
```

`Get-Help` displays installed help for commands and `about_*` concepts. The
content can come from a module, local help files, or fallback information when
full help has not been downloaded.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Name NAME`: Select a command or conceptual topic; wildcard patterns are accepted.
- `-Full`: Show all available parameter, input, output, note, and example information.
- `-Detailed`: Show descriptions and examples without every full-view field.
- `-Examples`: Show the examples section.
- `-Parameter NAME`: Show help for matching parameter names.
- `-Online`: Open the configured online help URI in an interactive browser.
- `-ShowWindow`: Display help in a searchable Windows help window.
- `-Category CATEGORY`: Restrict results to categories such as cmdlets, functions, aliases, or provider help.
- `-Component COMPONENT`: Filter help by component metadata.
- `-Role ROLE`, `-Functionality FUNCTIONALITY`: Filter help when topics supply role or functionality metadata.

## Help views

The default view gives a summary and syntax. `-Detailed` adds parameter
descriptions and examples; `-Full` adds all available metadata, including
inputs and outputs. `-Examples` focuses on examples, while `-Parameter`
describes one parameter.

```powershell
Get-Help Get-ChildItem -Examples
Get-Help Get-ChildItem -Parameter LiteralPath
Get-Help about_Quoting_Rules
```

Use `Get-Command NAME -Syntax` when a compact parameter-set view is enough.

## Online and updatable help

`-Online` opens a command's online help URI when the command supplies one. It
needs an interactive browser-capable environment and network access, so it is
not for unattended automation.

Many Windows PowerShell modules support `Update-Help`, which can need elevation
and internet access. Older inbox modules may have stopped publishing new help
or may use a different update mechanism. Do not make operational scripts depend
on a help update succeeding at runtime.

## Searching and freshness

Help names accept wildcards. Use the `about_*` prefix for concepts and
`Get-Command` for command discovery before requesting detailed help:

```powershell
Get-Help about_*
Get-Command *-Service
Get-Help Get-Service -Full
```

Installed help can be older than online documentation. Record the Windows
release, Windows PowerShell version, and module version when help behavior
affects a support or operational decision.

## Common mistakes

### Treating fallback help as the complete reference

When detailed help files are absent, syntax fallback can still appear. Confirm
the command with `Get-Command`, then obtain version-appropriate help through a
reviewed update or online workflow.

### Assuming the online page matches the inbox module

Windows PowerShell 5.1 inbox modules are serviced with Windows and may not
match the latest default Learn view. Preserve the `view=powershell-5.1`
selection and record the module/Windows build.

### Opening help windows from unattended sessions

`-Online` and `-ShowWindow` require an interactive desktop. Use terminal or
metadata output for remoting, scheduled tasks, and services.

## Version and availability

This page targets Windows PowerShell 5.1. Installed help can be older than the
operating system or module, and online links can lead to a newer documentation
version; verify the version selector before adopting an example.

## Related documents

- [Get-Command](Get-Command.md)
- [Get-Member](Get-Member.md)
- [Windows PowerShell 5.1 documentation](windows-powershell-5.1-docs.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-Help reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-help?view=powershell-5.1).
It is organized around interactive help views, source freshness, and safe use
in Windows automation. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
