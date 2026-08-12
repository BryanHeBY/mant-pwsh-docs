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

PowerShell 7 defines `irm` as the built-in alias for `Invoke-RestMethod` on all
platforms. Profiles, constrained endpoints, and user configuration can still
remove or replace aliases in a particular session. Verify it with
`Get-Alias irm` or `Get-Command irm -All` when an interactive alias matters.

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

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Uri URI`: Set the required request URI; validate constructed or redirected destinations before sending secrets.
- `-Method METHOD`, `-CustomMethod METHOD`: Select a standard HTTP method or supply a custom method token.
- `-Headers HEADERS`: Add request headers from a dictionary; do not persist secrets in source or history.
- `-Body BODY`: Supply request content or form values, depending on the value and content type.
- `-Form FORM`: Build a multipart form from a dictionary; available in PowerShell 7, not Windows PowerShell 5.1.
- `-ContentType TYPE`: Set the request content type, including an explicit charset when the server requires one.
- `-Authentication TYPE`, `-Token TOKEN`, `-Credential CREDENTIAL`,
  `-UseDefaultCredentials`: Configure supported authentication; use TLS and
  the least-privileged credential, and do not combine incompatible modes.
- `-Certificate CERTIFICATE`, `-CertificateThumbprint THUMBPRINT`: Select a
  client certificate for mutual TLS where the platform supports the chosen form.
- `-AllowUnencryptedAuthentication`: Permit credentials or secrets over a
  non-HTTPS connection; avoid this unsafe override.
- `-WebSession SESSION`, `-SessionVariable NAME`: Reuse or capture cookies and connection state; do not combine these two parameters.
- `-OutFile PATH`: Write the response body to a file instead of returning the
  converted response body. An existing writable file is replaced without
  confirmation; preflight the path or generate a unique destination.
- `-PassThru`: Return results when `-OutFile` would otherwise suppress pipeline output.
- `-FollowRelLink`, `-MaximumFollowRelLink COUNT`: Follow RFC link relations and cap the number of followed links.
- `-MaximumRedirection COUNT`: Limit automatic HTTP redirects; redirects can cross a trust boundary.
- `-AllowInsecureRedirect`: Permit an HTTPS-to-HTTP redirect; avoid this
  plaintext downgrade outside an isolated diagnostic.
- `-PreserveAuthorizationOnRedirect`: Keep the authorization header across a
  redirect; use only when every destination is trusted to receive the secret.
- `-PreserveHttpMethodOnRedirect`: Retain the original HTTP method instead of
  changing a redirected request to GET.
- `-MaximumRetryCount COUNT`, `-RetryIntervalSec SECONDS`: Retry selected HTTP
  failures with a bounded interval; ensure repeating the method is safe.
- `-SkipHttpErrorCheck`: Return non-success HTTP responses instead of turning them into terminating request errors.
- `-ResponseHeadersVariable NAME`, `-StatusCodeVariable NAME`: Capture response headers or status without parsing display text.
- `-ConnectionTimeoutSeconds SECONDS`, `-OperationTimeoutSeconds SECONDS`: Bound connection establishment and subsequent operation waits.
- `-SkipCertificateCheck`: Disable certificate validation for the request; avoid it outside isolated diagnostics.
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
- `-Resume`: Make a size-only best effort to continue an `-OutFile` download;
  it does not prove that local and remote content are the same artifact.
- `-UseBasicParsing`: Retained for Windows PowerShell compatibility; it has no
  effect because PowerShell 6 and later always use basic parsing.

## Version and platform differences

This page targets PowerShell 7.6. Windows PowerShell 5.1 uses a different web
stack and lacks several parameters listed here; consult the matching 5.1 page
when maintaining legacy scripts.

## Do not pipe into Invoke-Expression

Do not use `irm URL | iex` or similar patterns. It downloads remote text and
immediately parses it as PowerShell code, giving the remote response the same
authority as the current session. Download a reviewed artifact, verify its
integrity and provenance, and execute it only through an explicit process.

## Common mistakes

### Overwriting an existing `-OutFile`

The cmdlet does not provide a no-clobber switch. Check `Test-Path` before the
request or create a unique temporary destination, then move the verified
artifact deliberately.

### Treating converted JSON as a single predictable object

The response can be a scalar, object, or collection. Validate its shape before
property access, and explicitly enumerate an array when a downstream command
must receive each member separately.

### Trusting redirects, certificates, or HTTP status implicitly

Set appropriate redirect and timeout limits, keep certificate checking
enabled, and handle non-success status deliberately. A parsed response is
still untrusted remote input.

### Assuming `-OutFile` also returns the response

`-OutFile` suppresses the normal response output unless the selected parameter
set and version support `-PassThru` and it is requested.

## Full command

See [Invoke-RestMethod](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6)
for complete parameter, authentication, pagination, and response details.

## Runtime evidence

PowerShell 7.6.4 on Windows and 7.6.3 on Linux confirmed that `irm` resolves to
`Invoke-RestMethod`; the Windows suite also confirms every documented alias
option against live metadata. No remote request was made in this check. macOS,
HTTP conversion, pagination, authentication, proxy, redirect, TLS, and
remote-content behavior remain outstanding.

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
