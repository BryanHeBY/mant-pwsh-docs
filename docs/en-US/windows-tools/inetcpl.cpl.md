<!-- mant:tldr:start -->
# inetcpl.cpl

> Open Internet Properties for interactive WinINet/legacy Internet Options inspection; do not assume its proxy, zone, TLS, certificate, privacy, or browser settings govern every Windows application.
> More information: https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names.

- Resolve the module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\inetcpl.cpl')`

- Open Internet Properties interactively:

`Start-Process inetcpl.cpl`

- Inspect the separate WinHTTP proxy configuration:

`netsh.exe winhttp show proxy`
<!-- mant:tldr:end -->

# inetcpl.cpl

## Overview

`inetcpl.cpl` opens the classic Internet Properties Control Panel module. It
contains legacy general, security-zone, privacy, content/certificate,
connections/LAN, programs, and advanced Internet Options where supported.

Many settings primarily affect WinINet, Internet Explorer compatibility, or
components that explicitly consume them. WinHTTP, browsers, PowerShell/.NET
versions, services, system accounts, and managed applications can use different
proxy, TLS, trust, authentication, cache, and policy paths.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `inetcpl.cpl`: Open Internet Properties in the current interactive user's context.
- `control.exe /name Microsoft.InternetOptions`: Open the canonical Internet Options Control Panel item where supported.

Use the owning application's documented interface or policy for automation.
Opening a tab is not evidence that a process reads or accepted its settings.

## Scope and consumer identity

Record user/service identity, process architecture, API stack (WinINet, WinHTTP,
.NET, browser, custom), proxy source/PAC/bypass, security zone and policy,
certificate stores, TLS protocol/cipher ownership, authentication, enterprise
management, current sessions, and exact test endpoint before a change.

Validate from the real consuming process/account; interactive-user success does
not prove a service or system component uses the same configuration.

## Common mistakes

- Changing LAN proxy settings and expecting WinHTTP services or every browser/
  runtime to follow them.
- Clearing/resetting broad settings before preserving proxy, zones, certificates,
  trusted sites, privacy, authentication, policy, and application evidence.
- Weakening TLS/security-zone settings globally to fix one endpoint instead of
  correcting certificate, clock, hostname, protocol, proxy, or server policy.
- Confusing Current User certificate content with Local Computer trust.
- Using numeric tab selectors as a durable automation API across versions.
- Treating a GUI check box as effective when domain/MDM policy owns the setting.
- Scraping localized dialogs instead of querying the actual consumer/API.

## PowerShell behavior

`Start-Process inetcpl.cpl` launches the GUI and returns no network settings.
PowerShell 7 and Windows PowerShell 5.1 can use different HTTP implementations
and defaults; neither should be assumed from Internet Properties alone.

Call `netsh.exe winhttp` explicitly for WinHTTP compatibility queries and check
`$LASTEXITCODE`. Use application/runtime diagnostics for the exact request path.

## Version and platform differences

`inetcpl.cpl` is Windows-only. Pages, Internet Explorer compatibility, TLS,
proxy behavior, Settings migration, policies, and consuming applications vary by
Windows build, edition, identity, runtime, architecture, and enterprise policy.

## Related documents

- [netsh.exe](netsh.exe.md)
- [certmgr.msc](certmgr.msc.md)
- [certlm.msc](certlm.msc.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Control Panel canonical names](https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names),
[Control Panel execution guidance](https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items),
and [WinINet overview](https://learn.microsoft.com/windows/win32/wininet/about-wininet).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
