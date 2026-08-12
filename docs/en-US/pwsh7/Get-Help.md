<!-- mant:tldr:start -->
# Get-Help

> Read installed PowerShell 7 command and concept documentation.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-help?view=powershell-7.6.

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
    [-Parameter <string>] [-Path <string>] [<CommonParameters>]
```

`Get-Help` displays installed help for commands and `about_*` concepts. Help
content comes from the command's module, local help files, or fallback
information when full help has not been installed.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Name NAME`: Select a command or conceptual help topic; wildcard patterns are accepted.
- `-Full`: Show every available section, including detailed parameters, inputs, outputs, notes, and examples.
- `-Detailed`: Show descriptions and examples without every field from the full view.
- `-Examples`: Show only the examples section.
- `-Parameter NAME`: Show help for matching parameter names; wildcard patterns are accepted.
- `-Online`: Open the command's configured online help URI in an interactive browser.
- `-ShowWindow`: Display help in a searchable window on supported Windows hosts.
- `-Category CATEGORY`: Restrict results to command or help categories such as cmdlets, functions, aliases, or provider help.
- `-Component COMPONENT`: Filter help by the component metadata supplied by help authors.
- `-Role ROLE`, `-Functionality FUNCTIONALITY`: Filter help using role or functionality metadata when a help topic supplies it.
- `-Path PATH`: Show provider-customized help for how a cmdlet behaves at the
  specified PowerShell provider path.

## Help views

The default view gives a short description and syntax. `-Detailed` adds
parameter descriptions and examples. `-Full` adds all available metadata,
including input and output types. `-Examples` focuses on examples, and
`-Parameter` describes a particular parameter.

```powershell
Get-Help Get-ChildItem -Examples
Get-Help Get-ChildItem -Parameter LiteralPath
Get-Help Get-ChildItem -Path Cert:\
Get-Help about_Quoting_Rules
```

Use `Get-Command NAME -Syntax` for a compact parameter-set view when the
full help page is more detail than an interactive troubleshooting session
needs.

## Online and updatable help

`-Online` opens the command's online help URI in the configured browser when
the command supplies one. It requires a suitable interactive environment and
network access. It is not appropriate for unattended automation.

Many modules support `Update-Help`, which downloads current help content from
their configured source. Updating help can require elevation, network access,
or a saved-help workflow in restricted environments. Do not make scripts rely
on a help update occurring at runtime.

## Searching help

Help names can use wildcards. Use the `about_*` prefix to discover conceptual
topics and `Get-Command` to discover command names before asking for detailed
help.

```powershell
Get-Help about_*
Get-Command *-Service
Get-Help Get-Service -Full
```

The installed help version can differ from the online documentation version.
Record the PowerShell and module versions when documentation behavior affects
an operational decision.

## Examples

Inspect pipeline support before composing commands:

```powershell
Get-Help Select-Object -Full
```

Read one concept page in a terminal-friendly form:

```powershell
Get-Help about_Profiles
```

Find the required parameter details for a command:

```powershell
Get-Help Invoke-Command -Parameter ComputerName
```

## Common mistakes

### Treating missing local prose as a missing command

Fallback help can show syntax while detailed help files are absent. Confirm
the command with `Get-Command`, then use `Update-Help` or the version-matched
online reference instead of concluding that the command is unavailable.

### Assuming installed and online help describe the same version

Module help can lag the installed binary, while `-Online` can open a newer
documentation version. Record PowerShell and module versions when exact
parameter behavior matters.

### Using GUI help in unattended automation

`-Online` and `-ShowWindow` require an interactive environment. Use terminal
or generated metadata views for CI, remoting, and service sessions.

## Platform and version differences

PowerShell's help system is available on all supported PowerShell 7 platforms,
but installed modules, downloadable help sources, browser integration, and
permission requirements can differ. Help for Windows-only modules may not be
available in a Linux or macOS session.

## Runtime evidence

PowerShell 7.6.4 on Windows was tested in a clean `-NoProfile` process.
`Get-Help Get-Command -Parameter Name` returned a named, nonempty parameter
view. A temporary in-memory function with no comment-based or external help
still returned its name and nonempty syntax, confirming that syntax fallback
does not prove detailed help is installed. The probe did not update help, open
a browser or window, contact the network, or inspect user profile content.
The provider fixture additionally confirmed that
`Get-Help Get-ChildItem -Path Cert:\` returns named help with a nonempty
provider-customized synopsis. It enumerated no certificate. Downloadable
module help, GUI views, third-party providers, macOS, and Linux remain
outstanding.

## Related documents

- [Get-Command](Get-Command.md)
- [Get-Member](Get-Member.md)
- [PowerShell 7 documentation](powershell-7-docs.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-Help reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-help?view=powershell-7.6).
Provider concepts are cross-checked against the official
[about_Providers](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_providers?view=powershell-7.6)
reference. It is organized around interactive help views, source freshness,
and safe use in automated environments. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
