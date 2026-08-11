<!-- mant:tldr:start -->
# comexp.msc

> Open Component Services for a reviewed COM+, DCOM, or Distributed Transaction Coordinator investigation; identify the exact application, AppID, scope, architecture, and effective security before changing anything.
> More information: https://learn.microsoft.com/windows/win32/com/enabling-com-security-using-dcomcnfg.

- Resolve the console file without launching it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\comexp.msc')`

- Open Component Services in the current interactive session:

`Start-Process comexp.msc`

- Preserve relevant DCOM errors before investigating configuration:

`Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-DistributedCOM' } -MaxEvents 20`
<!-- mant:tldr:end -->

# comexp.msc

## Overview

`comexp.msc` opens the Component Services MMC console. It exposes COM+
applications, DCOM configuration, computer-wide COM security, application
identity and activation settings, and Distributed Transaction Coordinator
configuration. Many changes affect process launch, remote access, service
identity, authentication, transactions, or every COM server on the computer.

The console is not a general fix for every DistributedCOM event. Start with the
failing product's supported guidance and exact CLSID/AppID, executable/service,
caller identity, target, operation, and event/error evidence.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `comexp.msc`: Open Component Services for an explicitly identified computer and COM+, DCOM, or DTC object.

No supported parameter interface is documented here. `dcomcnfg.exe` opens the
same administration area through a separate executable entry point; neither is
a stable machine-readable configuration API.

## Change boundaries

Distinguish computer-wide defaults and limits from per-application settings.
Record the display name, AppID/CLSID, executable or service, 32/64-bit view,
identity, launch/activation/access permissions, authentication and impersonation
levels, location, DTC instance/cluster resource, current ACLs, owner, policy or
installer authority, and a tested rollback before a change.

## Common mistakes

- Editing computer-wide COM security to repair one application; Microsoft warns
  that the change affects every server that does not set its own security.
- Granting broad remote launch, activation, or access because one DCOM 10016
  event exists; some events are expected and permissions may be product-owned.
- Confusing launch/activation permission with method access, Windows Firewall,
  RPC endpoint availability, service logon, namespace permission, or DTC policy.
- Changing an application's identity without planning credentials, service
  rights, profile access, network identity, password rotation, and restart.
- Editing the wrong AppID or architecture view because only a friendly display
  name was recorded.
- Disabling DCOM remotely without console recovery; Microsoft notes that remote
  access cannot re-enable it afterward.
- Treating Apply/OK as proof that a client actually used the registry setting;
  COM applications can establish security programmatically.

## PowerShell behavior

`Start-Process comexp.msc` launches an interactive console and returns no COM
configuration objects. Use `Get-WinEvent` for preserved event data and the
product's supported API, deployment mechanism, or narrowly reviewed registry/
security tooling for automation. Do not scrape localized console labels.

## Version and platform differences

`comexp.msc` is Windows-only. Nodes and effective behavior vary by build,
edition, role, application registration, architecture, clustering, policy,
COM/DCOM hardening, and installed components.

## Related documents

- [eventvwr.msc](eventvwr.msc.md)
- [wmimgmt.msc](wmimgmt.msc.md)
- [regedit.exe](regedit.exe.md)
- [mmc.exe](mmc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[DCOM security guidance](https://learn.microsoft.com/windows/win32/com/enabling-com-security-using-dcomcnfg),
[system-wide DCOM warning](https://learn.microsoft.com/windows/win32/com/setting-machine-wide-security-using-dcomcnfg),
and [network DTC guidance](https://learn.microsoft.com/troubleshoot/windows-server/application-management/enable-network-dtc-access).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
