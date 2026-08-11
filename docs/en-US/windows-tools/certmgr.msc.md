<!-- mant:tldr:start -->
# certmgr.msc

> Open the Current User certificate-store console for interactive inspection; verify store location, certificate identity, chain, purpose, private-key ownership, and trust effect before importing or deleting anything.
> More information: https://learn.microsoft.com/dotnet/framework/wcf/feature-details/how-to-view-certificates-with-the-mmc-snap-in.

- Resolve the console file without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\certmgr.msc')`

- Open the Current User certificate stores:

`Start-Process certmgr.msc`

- Query Current User certificates as objects:

`Get-ChildItem Cert:\CurrentUser -Recurse | Select-Object Subject, Thumbprint, NotAfter, HasPrivateKey`
<!-- mant:tldr:end -->

# certmgr.msc

## Overview

`certmgr.msc` opens the Certificates MMC snap-in scoped to the current user's
certificate stores. It can view, import, export, move, request, renew, or delete
certificates and inspect trust stores when the operation is available.

This inbox `.msc` console is distinct from the .NET SDK command-line tool named
`certmgr.exe`. Resolve the complete filename and path; do not assume that a bare
`certmgr` token identifies the GUI or an inbox executable.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `certmgr.msc`: Open certificate stores for the current interactive user, not the Local Computer store.

The console file exposes no supported parameter interface documented here. Use
the PowerShell Certificate provider, PKI cmdlets, `certutil.exe`, or documented
certificate APIs for reproducible automation.

## Certificate identity and scope

Record store location/name, subject and SANs, issuer, serial number, thumbprint
and hash algorithm, validity, EKUs, basic constraints, key algorithm/size,
provider/KSP, private-key presence and ACL, chain result, revocation context,
template, enrollment source, intended application, and target user SID.

A certificate can appear in multiple stores. A thumbprint should be normalized
and paired with store/location and purpose rather than treated as global identity.

## Common mistakes

- Opening `certmgr.msc` while intending to manage Local Computer trust; use
  `certlm.msc` or explicitly add the Certificates snap-in for Computer account.
- Invoking an SDK `certmgr.exe` found earlier on PATH and assuming it is the
  inbox Current User MMC console.
- Importing a root or intermediate certificate merely to silence a validation
  error without authenticating the certificate and understanding trust scope.
- Exporting a private key to an unprotected path, logging a PFX password, or
  assuming a certificate export always includes its private key and ACL.
- Deleting by subject/display name without unique thumbprint, store, dependent
  service, renewal, rollback, and private-key impact.
- Treating “valid dates” or a clean-looking chain as proof of hostname, EKU,
  revocation, policy, key possession, and application acceptance.

## PowerShell behavior

`Start-Process certmgr.msc` only opens the Current User GUI. The Certificate
provider exposes typed objects under `Cert:\CurrentUser`; enumerate an explicit
store and preserve thumbprints as strings. Certificate cmdlets can be destructive
and may access private keys, so use least privilege and protected output paths.

Do not pipe a formatted table back into certificate-management commands. Preserve
the original certificate object or re-resolve it by exact location and identity.

## Version and platform differences

`certmgr.msc` is Windows-only. Store contents, trust policy, providers, algorithms,
enrollment, revocation, UI actions, and certificate cmdlets vary by Windows build,
edition, domain policy, installed roles/SDKs, user identity, and architecture.

## Related documents

- [certlm.msc](certlm.msc.md)
- [certutil.exe](certutil.exe.md)
- [mmc.exe](mmc.exe.md)
- [where.exe](where.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[MMC certificate viewing guide](https://learn.microsoft.com/dotnet/framework/wcf/feature-details/how-to-view-certificates-with-the-mmc-snap-in),
[certificate-store description](https://learn.microsoft.com/windows-hardware/drivers/install/certificate-stores),
and [SDK Certificate Manager reference](https://learn.microsoft.com/dotnet/framework/tools/certmgr-exe-certificate-manager-tool).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
