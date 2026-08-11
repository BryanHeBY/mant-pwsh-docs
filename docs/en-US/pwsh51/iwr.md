<!-- mant:tldr:start -->
# iwr

> Alias for `Invoke-WebRequest`, which sends HTTP requests and returns a web response object in Windows PowerShell 5.1.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1.

- Request a web resource:

`iwr -Uri {{https://example.test}}`

- Download a file to an explicit path:

`iwr -Uri {{https://example.test/file.zip}} -OutFile {{./file.zip}}`

- Use the full cmdlet name in shared automation:

`Invoke-WebRequest -Uri {{https://example.test}}`
<!-- mant:tldr:end -->

# iwr

## Meaning and availability

`iwr` is the built-in alias for `Invoke-WebRequest`. The cmdlet sends HTTP or
HTTPS requests and returns a response object. Use `-OutFile` with an explicit
destination rather than relying on terminal output or an implicit location.
Verify the alias with `Get-Alias iwr` or `Get-Command iwr -All` when profile or
endpoint configuration could change it.

## Downloads and response handling

Use a reviewed URI and explicit output path. Verify status, expected size,
signature, or checksum before consuming a downloaded artifact; a successful
HTTP transfer is not proof the payload is trusted.

```powershell
$destination = Join-Path $PWD 'tool.zip'
Invoke-WebRequest -Uri 'https://example.test/tool.zip' -OutFile $destination
Get-FileHash -LiteralPath $destination -Algorithm SHA256
```

In Windows PowerShell 5.1, `Invoke-WebRequest` parses HTML using the legacy
Internet Explorer engine by default. On systems where this is unavailable or
undesirable, use `-UseBasicParsing` when its reduced response behavior meets
the task. Test proxy, TLS, authentication, and parser assumptions on the
target Windows host.

For structured API responses, `Invoke-RestMethod` is often more convenient.

## Related documents

- [irm](irm.md)
- [iex](iex.md)
- [curl](curl.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original alias page was adapted from the official
[Invoke-WebRequest reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1).
It adds download verification and 5.1 parser guidance. Exact upstream revision
and paths are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
