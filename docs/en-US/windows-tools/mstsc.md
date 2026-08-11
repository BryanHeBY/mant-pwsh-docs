<!-- mant:tldr:start -->
# mstsc

> Start Remote Desktop only for an explicitly verified FQDN and approved user/host; inspect `.rdp` redirections, validate the server identity/certificate, and never assume `/admin` grants administrative rights.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mstsc.

- Show the installed Remote Desktop Connection options:

`mstsc.exe /?`

- List local monitor IDs without connecting to a remote computer:

`mstsc.exe /l`

- Prompt before authenticating to an explicitly verified target:

`mstsc.exe /v:{{host.example.com}} /prompt`

- Inspect an RDP file as text before opening it:

`Get-Content -LiteralPath '.\connection.rdp'`
<!-- mant:tldr:end -->

# mstsc

## Overview

`mstsc.exe` is the classic Remote Desktop Connection client. It can open or
edit `.rdp` files, connect through a gateway, select display modes, use
credential-protection modes, or shadow an existing session. A connection spans
identity, certificate, authentication, device/resource redirection and remote
session policy; it is not just a hostname and password.

## Important options

```text
mstsc [RDP_FILE]
      [/v:SERVER[:PORT]] [/g:GATEWAY] [/prompt]
      [/admin] [/restrictedAdmin] [/remoteGuard]
      [/f] [/w:WIDTH /h:HEIGHT] [/multimon] [/l] [/public]
      [/edit RDP_FILE]
      [/shadow:SESSION_ID [/control] [/noConsentPrompt]]
```

Availability and permission for credential modes, gateway use and shadowing
depend on both endpoints and policy. `/public` changes caching for that launch;
it is not a complete cleanup or privacy guarantee.

## Common mistakes

- Believing `/admin` elevates the account. It selects a server administration
  session mode; the remote token and rights still come from the authenticated
  identity and remote policy.
- Treating `/restrictedAdmin` and `/remoteGuard` as synonyms or privilege
  switches. They have different credential delegation and second-hop behavior,
  prerequisites and compatibility tradeoffs.
- Accepting an unexpected certificate/name warning, especially after connecting
  by IP, short name or an untrusted `.rdp` file. Resolve the intended FQDN,
  gateway and certificate before credentials are entered.
- Opening a downloaded `.rdp` file without reviewing drive, clipboard, device,
  smart-card, audio, authentication, gateway, server and remote-program settings.
- Assuming `/public` erases previously cached credentials, history or artifacts.
- Using `/shadow`, `/control` or `/noConsentPrompt` without exact fresh session
  identity, authorization, informed consent, privacy policy and a stop path.
- Saving passwords in scripts or command lines. `mstsc` has no safe password
  switch; use approved credential and Remote Desktop management mechanisms.
- Treating a visible desktop as proof that DNS, certificate, gateway, NLA,
  licensing, profile, redirection and audit requirements are healthy.

## PowerShell behavior

Use `Start-Process mstsc.exe -ArgumentList ...` for interactive launch, but do
not expect structured session results or a reliable remote-workload exit code.
PowerShell must quote `.rdp` paths and each native argument. Inventory/query RDS
sessions with dedicated tools; do not automate the localized GUI or infer remote
state from the client process alone.

## Version and platform differences

`mstsc.exe` is Windows-only. Client capabilities, `/admin` semantics,
credential-protection modes, display/redirection settings, RDS licensing,
shadow consent and policy vary by client/server build, edition and deployment.

## Related documents

- [query](query.md)
- [shadow](shadow.md)
- [tscon](tscon.md)
- [cmdkey](cmdkey.md)

## Sources and license

Microsoft's official [mstsc reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mstsc)
defines current syntax and mode descriptions. A highly viewed
[Super User `/admin` question](https://superuser.com/questions/237626/what-is-the-significance-of-the-admin-switch-in-mstsc-exe)
records the persistent privilege misconception; current Microsoft documentation
remains authoritative. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
