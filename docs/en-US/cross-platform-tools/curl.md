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

## Important options

<!-- mant:entries role=option case=sensitive -->
- `-V`, `--version`: Print curl, libcurl, protocol, TLS backend, and compiled feature information.
- `-f`, `--fail`: Fail without returning an HTTP error body for status 400 or later; authentication statuses can still escape detection.
- `--fail-with-body`: Return an HTTP error status as failure while retaining the response body; requires a sufficiently recent curl.
- `-L`, `--location`: Follow redirects; credentials are restricted across hosts unless broader trust is requested explicitly.
- `--max-redirs COUNT`: Cap redirect following; zero rejects redirects and a negative value removes the limit.
- `-o FILE`, `--output FILE`: Write response bytes to an explicit file instead of standard output.
- `-O`, `--remote-name`: Derive the local filename from the URL path; it does not make the server-supplied content trusted.
- `--remove-on-error`: Remove a partial output file when a transfer fails.
- `-X METHOD`, `--request METHOD`: Change the method token sent without changing all related request behavior; prefer method-implying data/upload options when possible.
- `-H HEADER`, `--header HEADER`: Add, replace, or remove a request header; command-line secrets can be exposed to logs and process inspection.
- `-d DATA`, `--data DATA`: Send form-style request data and imply POST unless another method is selected.
- `--data-binary DATA`: Send request bytes without `--data` newline conversion.
- `--json DATA`: Send JSON data and set JSON request/accept headers; availability depends on curl version.
- `-F FORM`, `--form FORM`: Build a multipart form, including file uploads when requested by the value syntax.
- `-T FILE`, `--upload-file FILE`: Upload one local file or standard input when the file is `-`.
- `-u USER:PASS`, `--user USER:PASS`: Supply server credentials; omit the password to prompt where supported instead of exposing it in history.
- `--connect-timeout SECONDS`: Bound only the connection phase.
- `-m SECONDS`, `--max-time SECONDS`: Bound the total operation time.
- `--retry COUNT`: Retry selected transient failures; combine only with deliberate retry timing and idempotency policy.
- `-s`, `--silent`: Hide progress and error text; combine with `--show-error` when errors must remain visible.
- `-S`, `--show-error`: Show an error message when `--silent` is active.
- `-w FORMAT`, `--write-out FORMAT`: Emit selected transfer metadata after completion; keep it separate from response bytes.
- `-k`, `--insecure`: Disable TLS peer verification; avoid it outside isolated diagnostics.

A standalone `--` ends option parsing so remaining tokens are treated as
URLs, including a URL whose first character is `-`.

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

## PowerShell boundaries

Use `Get-Command curl -All` before assuming whether bare `curl` is the native
application. Pass each argument separately, quote URLs containing PowerShell
metacharacters, and check `$LASTEXITCODE`; native response text is not a
PowerShell object until parsed deliberately.

## Version and platform differences

The option list follows the current upstream curl manual and was runtime-
checked with curl 8.21.0 on Linux. Older OS-bundled builds may lack newer
options, protocols, TLS backends, or features. Windows PowerShell 5.1 can
resolve bare `curl` to an alias, so use `curl.exe` when that executable is the
required contract.

On Windows NT `10.0.26200.0`, Windows PowerShell 5.1 resolved bare `curl` first
to its `Invoke-WebRequest` alias and separately found exact System32
`curl.exe` file/tool version `8.21.0`. Explicit `curl.exe --version` returned 0
with four stdout lines; `--help all` returned 0 with 274 nonempty stdout lines.
Every long option indexed by this page appeared in that installed all-help
payload; the check used token boundaries so forms shown after short aliases,
such as `-m, --max-time`, were not falsely classified as absent.
No URL, proxy request, DNS lookup, socket, credential, upload, download, output
file, or network operation ran. Resolve `CommandType Application` or name
`curl.exe` explicitly on Windows when curl semantics are required. A no-profile
PowerShell 7.6.4 session on the same host resolved bare `curl` directly to that
application because PowerShell 7 does not provide the Windows PowerShell
`curl` alias by default.

## Common mistakes

### Using `--location` without a redirect trust policy

Redirects can change host and scheme. Limit their count, inspect the final URL
when it matters, and do not broaden credential forwarding casually.

### Treating HTTP output as success or trusted content

Use an appropriate fail option, check `$LASTEXITCODE`, and independently
verify downloaded artifacts. An HTTP 200 response is not a signature.

### Mixing response bytes with metadata

Use `--output` for the body and a deliberate `--write-out` destination or
format for metadata. Do not parse a progress meter or diagnostic stream as the
payload.

## Runtime evidence

The repeatable Windows cross-platform fixture confirmed that bare `curl` is an
`Invoke-WebRequest` alias in Windows PowerShell 5.1 but an Application in the
no-profile PowerShell 7.6.4 session. It then selected exact System32
`curl.exe` in both collectors: `--version` returned four stdout lines/status
`0`, and `--help all` returned 274 nonempty stdout lines/status `0`. No URL,
proxy, DNS lookup, socket, credential, request, transfer, or output file was
used; macOS and real protocol behavior remain pending.

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
