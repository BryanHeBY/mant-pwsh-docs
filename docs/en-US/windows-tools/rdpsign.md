<!-- mant:tldr:start -->
# rdpsign

> Test and apply a publisher signature to an exact Remote Desktop connection file.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rdpsign.

- Display the installed build's supported hash selectors and options:

`rdpsign.exe /?`

- Inventory candidate certificates with private keys in the current user's personal store:

`Get-ChildItem Cert:\CurrentUser\My | Where-Object HasPrivateKey | Select-Object Subject,Thumbprint,NotAfter,EnhancedKeyUsageList`

- Test signing one exact RDP file without replacing it (Windows Server 2016 and newer):

`rdpsign.exe /sha256 "{{SHA256_certificate_thumbprint_without_spaces}}" /l /v "{{C:\RDP\connection.rdp}}"`

- Preserve the source, sign a deliberately named copy, and check the native result:

`& { $source = "{{C:\RDP\connection.rdp}}"; $copy = "{{C:\RDP\connection.signed.rdp}}"; if (Test-Path -LiteralPath $copy) { throw "Destination already exists: $copy" }; Copy-Item -LiteralPath $source -Destination $copy -ErrorAction Stop; rdpsign.exe /sha256 "{{SHA256_certificate_thumbprint_without_spaces}}" /v $copy; $LASTEXITCODE }`
<!-- mant:tldr:end -->

# rdpsign

## Overview

`rdpsign.exe` digitally signs one or more `.rdp` connection files with a
certificate available to the signing computer. `/l` performs a trial without
replacing input; a normal successful run overwrites every readable/writable
input file with its signed form. Wildcards are not accepted.

The signature identifies the file publisher and detects changes to settings in
the signed scope. It does not encrypt the file, authenticate the remote server,
or prove that every requested redirection and connection target is safe.

## Common mistakes

### Confusing the certificate's signature algorithm with its thumbprint

`/sha1` and `/sha256` select the certificate fingerprint used to find the
signing identity; they do not describe the algorithm displayed as the
certificate issuer's signature algorithm. Obtain the exact fingerprint form
required by the local Windows build and remove whitespace or invisible copy
characters. Do not guess by converting PowerShell's usual `Thumbprint` field.

### Skipping `/l` before an in-place signature

The normal operation overwrites its input. First hash and preserve the source,
then use `/l /v` with one exact file. For publication, sign an explicitly named
copy and compare its target, gateway, RemoteApp command, credential behavior,
and device/drive/clipboard redirection settings before distribution.

### Treating a valid signature as a trusted publisher

Cryptographic validity and client trust are separate. Managed clients suppress
or block warnings according to RDP-file Group Policy and the configured trusted
publisher thumbprints. A certificate chain that is valid for another TLS use
does not automatically make this publisher trusted for `.rdp` files.

### Confusing file signing with RDP server TLS identity

`rdpsign` signs a connection file. The RDP endpoint, RD Gateway, Web Access,
and publishing roles use certificates for different identities and channels.
A signed file can still point to an unexpected or improperly authenticated
server; validate the destination and server certificate independently.

### Editing a signed RDP file afterward

Changing a setting in the signed scope breaks the publisher signature. Generate
the final reviewed file first, sign last, and redistribute the signed artifact.
Never teach users to ignore a new warning after an untracked edit.

### Assuming a multi-file invocation is atomic

Microsoft documents that the tool continues after a file cannot be read or
written. Check the exit/output and each artifact individually; do not infer that
all files were signed because one succeeded.

## PowerShell behavior

Call `rdpsign.exe` explicitly. Use full literal paths because wildcard input is
unsupported and because PowerShell glob expansion would weaken artifact
identity. The guarded TLDR copy refuses an existing destination and stops on a
copy error; production automation should also test `$LASTEXITCODE` immediately
after the native process and verify the resulting artifact.

## Version and platform differences

This command is Windows-only. Microsoft documents `/sha1` for Windows Server
2012 R2 and older and `/sha256` as its replacement on Windows Server 2016 and
newer. Client trusted-publisher policy gained SHA-2 support with the July 2026
security update; SHA-1 remains only for backward compatibility and is planned
for removal from that policy. Patch level and local `rdpsign.exe /?` therefore
belong in deployment evidence.

## Related documents

- [mstsc](mstsc.md)
- [certutil](certutil.md)
- [certreq](certreq.md)
- [gpresult](gpresult.md)

## Sources and license

This original guide was adapted from Microsoft's official
[rdpsign reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rdpsign)
and current [RDP file security Group Policy guidance](https://learn.microsoft.com/windows-server/remote/remote-desktop-services/remotepc/manage-rdp-file-security-settings-with-group-policy).
Certificate-selector and trust confusion was cross-checked against a
[practitioner troubleshooting example](https://serverfault.com/questions/865292/rdpsign-failing-with-error-0x80092004).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
