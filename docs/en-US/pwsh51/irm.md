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
Its full parser can execute page script; use `-UseBasicParsing` for untrusted
content and noninteractive automation.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Uri URI`: Set the required request URI; validate constructed or redirected destinations before sending credentials.
- `-Method METHOD`: Select a supported HTTP method.
- `-Headers HEADERS`: Add request headers from a dictionary.
- `-Body BODY`: Supply request content or form values, depending on the value and content type.
- `-ContentType TYPE`: Set the request media type and any required charset.
- `-Credential CREDENTIAL`, `-UseDefaultCredentials`: Select explicit or current Windows credentials; do not combine them.
- `-WebSession SESSION`, `-SessionVariable NAME`: Reuse or capture cookies and session state; do not combine the parameters.
- `-OutFile PATH`: Write the response body to a file instead of returning
  converted response content. An existing writable file is replaced without
  confirmation; preflight the path or generate a unique destination.
- `-PassThru`: With `-OutFile`, also request a pipeline result. On the tested
  serviced 5.1 build the pipeline result was returned but the file was empty.
- `-UseBasicParsing`: Avoid the legacy full parser and its page-script risk.
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

This page is limited to Windows PowerShell 5.1. Parameters added to modern
PowerShell—such as `-Authentication`, `-Token`, `-Form`,
`-SkipHttpErrorCheck`, and status variables—must not be copied into 5.1
scripts.

## Never pipe it to code execution

Do not use `irm URL | iex`. It downloads remote text and parses it as code with
the authority of the current Windows session. Download a reviewed artifact,
verify its provenance and integrity, and execute only through an explicit,
least-privilege process.

## Common mistakes

### Overwriting an existing `-OutFile`

The cmdlet does not provide a no-clobber switch. Check `Test-Path` before the
request or create a unique temporary destination, then move the verified
artifact deliberately.

### Copying PowerShell 7 parameters into a 5.1 script

Check the installed command with `Get-Command Invoke-RestMethod -Syntax`.
The legacy web stack and parameter surface differ materially from PowerShell 7.

### Treating converted content as trusted or shape-stable

Validate the HTTP outcome and the returned scalar, object, or collection before
using its values in commands, paths, or deployment actions.

### Assuming `-PassThru` safely produces both outputs

Windows PowerShell 5.1 does expose `-PassThru`, but the official reference
records an empty-file defect. The tested 5.1.26100.8875 build reproduced it for
a `file:` request: pipeline data was returned while the destination stayed at
zero bytes. Do not consume either output until both have been validated.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 resolved `irm` to `Invoke-RestMethod`. A
bounded `file:` URI fixture under a verified GUID temporary directory returned
one pipeline result with `-OutFile -PassThru` but left the destination at zero
bytes, reproducing the documented defect. The suite removes the fixture and
made no network request. JSON/XML conversion, authentication, proxy, redirect,
TLS, and remote-content behavior remain outstanding.

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
