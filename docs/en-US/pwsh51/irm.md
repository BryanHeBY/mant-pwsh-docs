<!-- mant:tldr:start -->
# irm

> Alias for `Invoke-RestMethod`, which sends HTTP requests and converts supported response content in Windows PowerShell 5.1.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-5.1.

- Request a JSON endpoint:

`irm -Uri {{https://api.example.test/items}}`

- Send a JSON request body:

`irm -Method Post -Uri {{https://api.example.test/items}} -ContentType application/json -Body '{{json-body}}'`

- Use the full cmdlet name in shared automation:

`Invoke-RestMethod -Uri {{https://api.example.test/items}}`
<!-- mant:tldr:end -->

# irm

## Meaning and availability

`irm` is the built-in alias for `Invoke-RestMethod`. The cmdlet sends HTTP or
HTTPS requests and converts supported responses, commonly JSON, into
PowerShell objects. Use the full cmdlet name in scripts for readers who may not
know the alias. Confirm session state with `Get-Alias irm` or
`Get-Command irm -All`; profiles and constrained endpoints can alter aliases.

## Requests and remote data

Use `-Uri`, `-Method`, explicit `-Headers`, and `-Body`; specify
`-ContentType` when sending structured data. Keep tokens and credentials out
of source and command history.

```powershell
$items = Invoke-RestMethod -Uri 'https://api.example.test/items'
$items | Select-Object id, name
```

Treat remote values as untrusted. Validate properties and error responses
before using them in a filesystem, native command, or deployment operation.
Windows PowerShell 5.1 uses the legacy web-request implementation, so proxy,
authentication, TLS, and response behavior can differ from PowerShell 7.

## Never pipe it to code execution

Do not use `irm URL | iex`. It downloads remote text and parses it as code with
the authority of the current Windows session. Download a reviewed artifact,
verify its provenance and integrity, and execute only through an explicit,
least-privilege process.

## Related documents

- [iwr](iwr.md)
- [iex](iex.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original alias page was adapted from the official
[Invoke-RestMethod reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-5.1)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1).
It adds safe-use guidance for remote content. Exact upstream revision and paths
are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
