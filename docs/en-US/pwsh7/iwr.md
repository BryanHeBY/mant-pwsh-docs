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

PowerShell 7 defines `iwr` as the built-in alias for `Invoke-WebRequest` on all
platforms. Profiles, constrained endpoints, and user configuration can remove
or replace aliases in a particular session, so use `Get-Alias iwr` or
`Get-Command iwr -All` when an interactive alias matters.

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
- `-Authentication TYPE`, `-Token TOKEN`, `-Credential CREDENTIAL`,
  `-UseDefaultCredentials`: Configure supported authentication over a trusted
  TLS connection, and do not combine incompatible modes.
- `-Certificate CERTIFICATE`, `-CertificateThumbprint THUMBPRINT`: Select a
  client certificate for mutual TLS where the platform supports the chosen form.
- `-AllowUnencryptedAuthentication`: Permit credentials or secrets over a
  non-HTTPS connection; avoid this unsafe override.
- `-WebSession SESSION`, `-SessionVariable NAME`: Reuse or capture cookies and session state; do not combine the parameters.
- `-OutFile PATH`: Write the response body to a file instead of returning the
  response object. An existing writable file is replaced without confirmation;
  preflight the path or generate a unique destination.
- `-PassThru`: Return results when `-OutFile` would otherwise suppress pipeline output.
- `-Resume`: Make a size-only best effort to continue an `-OutFile` download;
  it does not prove that local and remote content are the same artifact.
- `-MaximumRedirection COUNT`: Limit automatic redirects.
- `-AllowInsecureRedirect`: Permit an HTTPS-to-HTTP redirect; avoid this
  plaintext downgrade outside an isolated diagnostic.
- `-PreserveAuthorizationOnRedirect`: Keep the authorization header across a
  redirect; use only when every destination is trusted to receive the secret.
- `-PreserveHttpMethodOnRedirect`: Retain the original HTTP method instead of
  changing a redirected request to GET.
- `-MaximumRetryCount COUNT`, `-RetryIntervalSec SECONDS`: Retry selected HTTP
  failures with a bounded interval; ensure repeating the method is safe.
- `-SkipHttpErrorCheck`: Return non-success HTTP responses for explicit status handling.
- `-ConnectionTimeoutSeconds SECONDS`, `-OperationTimeoutSeconds SECONDS`: Bound connection and subsequent operation waits.
- `-SkipCertificateCheck`: Disable certificate validation; reserve it for isolated diagnostics.
- `-Proxy URI`, `-ProxyCredential CREDENTIAL`,
  `-ProxyUseDefaultCredentials`: Select a proxy and one authentication mode.
- `-NoProxy`: Bypass proxy use for this request; it belongs to separate
  no-proxy parameter sets.
- `-HttpVersion VERSION`, `-SslProtocol PROTOCOL`: Select the requested HTTP
  version and constrain permitted TLS protocols; actual support is platform dependent.
- `-UserAgent VALUE`, `-DisableKeepAlive`: Override the user-agent header or
  disable persistent connection reuse.
- `-InFile PATH`, `-TransferEncoding VALUE`: Read the request body from a file
  or set its transfer encoding; use the content type required by the endpoint.
- `-SkipHeaderValidation`: Permit header values that bypass normal validation;
  send only reviewed protocol values.
- `-UnixSocket ENDPOINT`: Connect through a Unix-domain socket where the
  operating system supports it.
- `-UseBasicParsing`: Retained for Windows PowerShell compatibility; it has no
  effect because PowerShell 6 and later always use basic parsing.

## Version and platform differences

This page targets PowerShell 7.6. Unlike Windows PowerShell 5.1,
`Invoke-WebRequest` does not depend on Internet Explorer for HTML parsing.

## Common mistakes

### Overwriting an existing `-OutFile`

The cmdlet does not provide a no-clobber switch. Check `Test-Path` before the
request or create a unique temporary destination, then move the verified
artifact deliberately.

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

### Copying `Invoke-RestMethod` metadata parameters

PowerShell 7.6 `Invoke-WebRequest` has no `-ResponseHeadersVariable` or
`-StatusCodeVariable` parameters; those belong to `Invoke-RestMethod`. Keep the
response object and read its `Headers` and `StatusCode` properties. Use
`-SkipHttpErrorCheck` only when the script deliberately handles non-success
responses.

## Full command

See [Invoke-WebRequest](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.6)
for complete authentication, proxy, session, header, and response details.

## Runtime evidence

PowerShell 7.6.4 on Windows and 7.6.3 on Linux confirmed that `iwr` resolves to
`Invoke-WebRequest`; the Windows suite also confirms every documented alias
option against live metadata. No remote request was made in this check. macOS,
HTTP status, authentication, proxy, session, redirect, TLS, and downloaded
artifact behavior remain outstanding.

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
