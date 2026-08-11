<!-- mant:tldr:start -->
# iwr

> Alias for `Invoke-WebRequest`, which sends HTTP requests and returns a web response object.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.6.

- Request a web resource:

`iwr -Uri {{https://example.test}}`

- Download a file to an explicit path:

`iwr -Uri {{https://example.test/file.zip}} -OutFile {{./file.zip}}`

- Use the full cmdlet name in shared automation:

`Invoke-WebRequest -Uri {{https://example.test}}`
<!-- mant:tldr:end -->

# iwr

## Meaning

`iwr` is a built-in alias for `Invoke-WebRequest`. The cmdlet sends HTTP or
HTTPS requests and returns a response object. Use `-OutFile` for an explicit
download target rather than relying on terminal output or an implicit current
directory.

## Availability

`iwr` is available by default in the tested PowerShell 7.6 Linux session.
Profiles, constrained endpoints, and user configuration can change aliases,
so use `Get-Alias iwr` or `Get-Command iwr -All` on the target host when an
interactive alias matters.

## Downloads and response handling

Use a literal, reviewed URI and an explicit output path. Verify the result's
status, expected size, signature, or checksum before consuming a downloaded
artifact. A successful HTTP transfer is not proof that the payload is trusted.

```powershell
$destination = Join-Path $PWD 'tool.zip'
Invoke-WebRequest -Uri 'https://example.test/tool.zip' -OutFile $destination
Get-FileHash -LiteralPath $destination -Algorithm SHA256
```

For API responses, `Invoke-RestMethod` is often more convenient because it
converts supported structured content to PowerShell objects.

## Full command

See [Invoke-WebRequest](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.6)
for complete authentication, proxy, session, header, and response details.

## Related documents

- [irm](irm.md)
- [iex](iex.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original alias page was adapted from the official
[Invoke-WebRequest reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.6)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.6).
It adds explicit artifact-verification guidance. Exact upstream revision and
paths are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
