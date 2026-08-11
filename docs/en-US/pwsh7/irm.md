<!-- mant:tldr:start -->
# irm

> Alias for `Invoke-RestMethod`, which sends HTTP requests and converts supported response content.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6.

- Request a JSON endpoint:

`irm -Uri {{https://api.example.test/items}}`

- Send a JSON request body:

`irm -Method Post -Uri {{https://api.example.test/items}} -ContentType application/json -Body '{{json-body}}'`

- Use the full cmdlet name in shared automation:

`Invoke-RestMethod -Uri {{https://api.example.test/items}}`
<!-- mant:tldr:end -->

# irm

## Meaning

`irm` is a built-in alias for `Invoke-RestMethod`. The cmdlet sends HTTP or
HTTPS requests and converts supported response content, commonly JSON, into
PowerShell objects. Use the full cmdlet name in scripts intended for readers
who may not know the alias.

## Availability

`irm` is available by default in the tested PowerShell 7.6 Linux session.
Alias availability can still be changed by profiles, constrained endpoints, or
user configuration. Verify it with `Get-Alias irm` or `Get-Command irm -All`
on each target environment.

## Common use

Use `-Uri` for the endpoint, `-Method` for the HTTP verb, `-Headers` for
explicit headers, and `-Body` for the request body. Set `-ContentType` when
sending structured data. Keep tokens and credentials out of source code and
command history.

```powershell
$items = Invoke-RestMethod -Uri 'https://api.example.test/items'
$items | Select-Object id, name
```

Treat remote data as untrusted input. Validate expected properties and error
responses before using values in a filesystem, command, or deployment action.

## Do not pipe into Invoke-Expression

Do not use `irm URL | iex` or similar patterns. It downloads remote text and
immediately parses it as PowerShell code, giving the remote response the same
authority as the current session. Download a reviewed artifact, verify its
integrity and provenance, and execute it only through an explicit process.

## Full command

See [Invoke-RestMethod](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6)
for complete parameter, authentication, pagination, and response details.

## Related documents

- [iwr](iwr.md)
- [iex](iex.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original alias page was adapted from the official
[Invoke-RestMethod reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.6).
It adds explicit safe-use guidance for remote content. Exact upstream revision
and paths are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
