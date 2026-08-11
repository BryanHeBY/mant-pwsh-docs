<!-- mant:tldr:start -->
# curl

> Transfer data with the native curl executable from PowerShell.
> More information: https://curl.se/docs/manpage.html.

- Show the selected executable and its supported features:

`curl.exe --version`

- Download to an explicit file path:

`curl.exe --fail --location --output {{file}} {{https://example.test/file}}`

- Send JSON with an explicit request method:

`curl.exe --request Post --header 'Content-Type: application/json' --data '{{json}}' {{https://api.example.test/items}}`
<!-- mant:tldr:end -->

# curl

## Meaning in PowerShell

Native curl is a data-transfer executable. In Windows PowerShell 5.1, bare
`curl` normally resolves to the `Invoke-WebRequest` alias, not curl. Use
`curl.exe` when the executable is required, and use `Get-Command curl -All` to
diagnose the current session. On macOS and Linux, still check the installed
curl path and version because features are build-dependent.

## Make failure visible

HTTP error responses can otherwise produce a successful curl process. Use
`--fail` (or the precise variant supported by the installed curl) when a
non-success HTTP response must be treated as failure. `--location` follows
redirects only when that behavior is intended, and `--output` makes the target
file explicit:

```powershell
curl.exe --fail --location --output .\tool.zip https://example.test/tool.zip
if ($LASTEXITCODE -ne 0) {
    throw "curl failed with exit code $LASTEXITCODE"
}
```

Verify checksums, signatures, expected size, and publisher before running or
installing a downloaded artifact. TLS transport success is not package trust.

## Requests and secrets

Set request methods, headers, and body formats explicitly. Do not place bearer
tokens, passwords, or client secrets directly on a command line: they can be
visible in process listings, logs, history, or diagnostics. Use a secure
credential mechanism appropriate to the platform and service.

Curl options and supported protocols depend on the installed version and its
TLS, proxy, HTTP/2/3, and authentication builds. Record `curl --version` in a
reproducible automation report rather than assuming a feature is universal.

## Related documents

- [Cross-platform tools for PowerShell](cross-platform-tools.md)
- On Windows, query `mant where --source windows-tools` for executable lookup
  and `mant winget --source windows-tools` for package management.

## Sources and license

This original ManT-oriented guide was adapted from the official
[curl manpage](https://curl.se/docs/manpage.html). It emphasizes PowerShell
alias resolution, explicit failure handling, and artifact verification. Exact
upstream revision and path are recorded in `upstream/cross-platform-tools.json`.

The cited documentation is licensed under the curl license. This adaptation
is licensed under CC BY 4.0.
