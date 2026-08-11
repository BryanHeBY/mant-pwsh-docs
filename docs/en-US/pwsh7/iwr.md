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

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Uri URI`: Set the required request URI; validate constructed or redirected destinations before sending secrets.
- `-Method METHOD`, `-CustomMethod METHOD`: Select a standard HTTP method or supply a custom method token.
- `-Headers HEADERS`: Add request headers from a dictionary.
- `-Body BODY`, `-Form FORM`, `-ContentType TYPE`: Supply request content and describe its media type; `-Form` builds multipart data.
- `-Authentication TYPE`, `-Token TOKEN`, `-Credential CREDENTIAL`: Configure supported authentication over a trusted TLS connection.
- `-WebSession SESSION`, `-SessionVariable NAME`: Reuse or capture cookies and session state; do not combine the parameters.
- `-OutFile PATH`: Write the response body to a file instead of returning the response object.
- `-PassThru`: Return results when `-OutFile` would otherwise suppress pipeline output.
- `-Resume`: Resume a partial file transfer where the server and local file state permit it.
- `-MaximumRedirection COUNT`: Limit automatic redirects.
- `-SkipHttpErrorCheck`: Return non-success HTTP responses for explicit status handling.
- `-ResponseHeadersVariable NAME`, `-StatusCodeVariable NAME`: Capture response metadata without scraping formatted output.
- `-ConnectionTimeoutSeconds SECONDS`, `-OperationTimeoutSeconds SECONDS`: Bound connection and subsequent operation waits.
- `-SkipCertificateCheck`: Disable certificate validation; reserve it for isolated diagnostics.

## Version and platform differences

This page targets PowerShell 7.6. Unlike Windows PowerShell 5.1,
`Invoke-WebRequest` does not depend on Internet Explorer for HTML parsing.

## Common mistakes

### Expecting API objects from the response

`Invoke-WebRequest` returns a web response object. Use `Invoke-RestMethod` when
automatic conversion of supported JSON or XML is the intended contract.

### Assuming a completed download is trusted

Validate the destination, final URI, size, signature, or expected checksum
before opening or executing an artifact.

### Hiding status or TLS failures

Do not reach first for `-SkipHttpErrorCheck` or `-SkipCertificateCheck`.
Capture status explicitly and repair certificate trust rather than silently
removing the boundary.

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
