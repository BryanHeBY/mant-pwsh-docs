<!-- mant:tldr:start -->
# certlm.msc

> Open the Local Computer certificate-store console for interactive inspection; require an explicit machine/store/certificate identity and understand system-wide trust and private-key impact before changing it.
> More information: https://learn.microsoft.com/dotnet/framework/wcf/feature-details/how-to-view-certificates-with-the-mmc-snap-in.

- Resolve the console file without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\certlm.msc')`

- Open the Local Computer certificate stores:

`Start-Process certlm.msc`

- Query Local Computer certificates as objects:

`Get-ChildItem Cert:\LocalMachine -Recurse | Select-Object Subject, Thumbprint, NotAfter, HasPrivateKey`
<!-- mant:tldr:end -->

# certlm.msc

## Overview

`certlm.msc` opens the Certificates MMC snap-in scoped to Local Computer stores.
It exposes machine-wide personal, trusted root/intermediate, enterprise, and
other stores available on the target Windows installation.

Machine-store changes can affect services, servers, every user, authentication,
code trust, TLS inspection, and system security. Interactive launch is not proof
that a service identity can read a private key or selected the new certificate.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `certlm.msc`: Open certificate stores for the Local Computer, normally requiring elevation for changes.

The console file has no supported parameter interface documented here. Use the
PowerShell Certificate provider, PKI cmdlets, `certutil.exe`, deployment policy,
or certificate APIs when automation and verification are required.

## Certificate identity and machine impact

Record computer, store location/name, certificate thumbprint/serial, subject and
SANs, issuer/chain, validity, EKUs, key algorithm/provider, private-key location
and ACL, consuming service identity/configuration, enrollment/renewal owner,
policy store, and rollback.

Verify the consumer from its real service/account context. Installing a
certificate does not bind it to IIS, HTTP.sys, RDP, a service, or an application,
and granting broad private-key access is not a safe substitute for diagnosis.

## Common mistakes

- Opening `certlm.msc` while intending to change only the current user's store,
  or opening `certmgr.msc` and concluding a machine certificate is missing.
- Importing an unverified root certificate system-wide to bypass a chain error.
- Matching by subject/friendly name when renewals or duplicate certificates have
  different thumbprints, keys, EKUs, SANs, validity, and bindings.
- Assuming elevation grants the consuming service/private principal access to the
  key, or granting Users/Everyone broad key permissions to make it work.
- Deleting an expired certificate before proving no service, binding, decrypting
  operation, signature validation, archival, or rollback depends on it.
- Exporting machine private keys/secrets to an inherited or world-readable path.
- Treating MMC's chain view as identical to a remote client's chain building,
  revocation access, TLS policy, hostname, and trust store.

## PowerShell behavior

`Start-Process certlm.msc` launches the GUI. Use `Cert:\LocalMachine` for typed
PowerShell inventory, but remember that running PowerShell elevated changes
authorization, not the store location syntax or a service's key ACL.

For native tooling, call `certutil.exe` explicitly and inspect its exit code and
artifacts. Avoid parsing localized display output when certificate objects or
documented structured APIs can preserve identity and binary data.

## Version and platform differences

`certlm.msc` is Windows-only. Stores, providers, algorithms, trust, enrollment,
private-key protection, cmdlets, and UI vary by build, edition, server role,
domain/MDM policy, installed PKI components, architecture, and security product.

## Related documents

- [certmgr.msc](certmgr.msc.md)
- [certutil.exe](certutil.exe.md)
- [services.msc](services.msc.md)
- [mmc.exe](mmc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[MMC certificate viewing guide](https://learn.microsoft.com/dotnet/framework/wcf/feature-details/how-to-view-certificates-with-the-mmc-snap-in),
[certificate-store description](https://learn.microsoft.com/windows-hardware/drivers/install/certificate-stores),
and [certificate viewing guidance](https://learn.microsoft.com/windows-hardware/drivers/install/viewing-test-certificates).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
