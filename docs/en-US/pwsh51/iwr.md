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
Internet Explorer engine by default, and page script can run during full
parsing. Security updates released for CVE-2025-54100 on 2025-12-09 add a
confirmation prompt before that risky default path. Use `-UseBasicParsing` for
noninteractive automation and untrusted content. Test proxy, TLS,
authentication, and parser assumptions on the target Windows build.

For structured API responses, `Invoke-RestMethod` is often more convenient.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Uri URI`: Set the required request URI; validate constructed or redirected destinations before sending credentials.
- `-Method METHOD`: Select a supported HTTP method.
- `-Headers HEADERS`: Add request headers from a dictionary.
- `-Body BODY`, `-ContentType TYPE`: Supply request content and describe its media type.
- `-Credential CREDENTIAL`, `-UseDefaultCredentials`: Select explicit or current Windows credentials; do not combine them.
- `-WebSession SESSION`, `-SessionVariable NAME`: Reuse or capture cookies and session state; do not combine the parameters.
- `-OutFile PATH`: Write the response body to a file instead of returning a
  response object. An existing writable file is replaced without confirmation;
  preflight the path or generate a unique destination.
- `-PassThru`: With `-OutFile`, also request a pipeline result. Validate both
  outputs because the versioned reference records an empty-file defect on some paths.
- `-UseBasicParsing`: Avoid the Internet Explorer DOM parser and return reduced parsing behavior.
- `-InFile PATH`: Read the request body from a file; set the matching content type.
- `-UserAgent VALUE`: Override the request user-agent header deliberately.
- `-DisableKeepAlive`: Disable persistent HTTP connection reuse for the request.
- `-TransferEncoding VALUE`: Set the request transfer-encoding value; use only
  when the endpoint requires it.
- `-TimeoutSec SECONDS`: Bound the request timeout; DNS resolution can still exceed very small values.
- `-MaximumRedirection COUNT`: Limit automatic redirects.
- `-Proxy URI`, `-ProxyCredential CREDENTIAL`, `-ProxyUseDefaultCredentials`: Configure the proxy and its authentication.
- `-Certificate CERTIFICATE`, `-CertificateThumbprint THUMBPRINT`: Select a client certificate for mutual TLS.

## Version and compatibility

This page is limited to Windows PowerShell 5.1. Its default HTML parser and
parameter surface differ from PowerShell 7. Updated hosts can prompt before
full parsing; `-UseBasicParsing` avoids both the legacy parser and that prompt.

## Common mistakes

### Overwriting an existing `-OutFile`

The cmdlet does not provide a no-clobber switch. Check `Test-Path` before the
request or create a unique temporary destination, then move the verified
artifact deliberately.

### Depending on the Internet Explorer parser

Default parsing can execute page script, fail when Internet Explorer components
are unavailable, or prompt after the CVE-2025-54100 update. Use
`-UseBasicParsing` unless reviewed DOM parsing is explicitly required.

### Assuming `-PassThru` guarantees both outputs

`-PassThru` is valid only with `-OutFile`. The official 5.1 reference records
an empty-file defect, although the tested serviced build wrote both outputs for
a `file:` request. Verify the file exists, is nonempty, and has the expected
integrity before consuming it.

### Expecting converted API objects

`Invoke-WebRequest` returns a web response representation. Use
`Invoke-RestMethod` when supported structured content should be converted.

### Treating a successful transfer as artifact verification

Check the final destination, expected size, signature, or checksum before
opening or executing a downloaded file.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 resolved `iwr` to `Invoke-WebRequest`. A
bounded `file:` URI fixture under a verified GUID temporary directory returned
one `-PassThru` object and wrote a nonempty file. The suite also confirms the
documented options against live metadata and removes the fixture. No network
request was made; HTTP authentication, proxy, redirect, TLS, Internet Explorer
parser, and remote-content behavior remain outstanding.

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
