<!-- mant:tldr:start -->
# tftp.exe

> Treat TFTP as an unauthenticated, unencrypted legacy provisioning protocol;
> inspect availability and syntax without transferring a file.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tftp.

- Check whether the optional Windows TFTP Client feature is enabled:

`Get-WindowsOptionalFeature -Online -FeatureName TFTP | Format-List FeatureName, State`

- Resolve the exact executable without enabling the feature:

`Get-Command tftp.exe -All -ErrorAction SilentlyContinue | Format-List Source, Version`

- Display target-local syntax without contacting a server:

`tftp.exe /?`

- Hash a separately approved received artifact before any use:

`Get-FileHash -LiteralPath "{{downloaded-file}}" -Algorithm SHA256`

<!-- mant:tldr:end -->

# tftp.exe

## Overview

`tftp.exe [-i] host {get|put} source [destination]` is the optional Windows
Trivial File Transfer Protocol client. TFTP is typically used for tightly
controlled boot, firmware and embedded-device provisioning. Microsoft warns
that it has no authentication or encryption and does not recommend installing
the client on Internet-connected systems; Microsoft no longer supplies a TFTP
server service.

For `get`, the source is remote and the destination is local. For `put`, the
source is local and the destination is remote. `-i` selects binary octet mode;
without it, the default ASCII mode converts end-of-line characters.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `tftp.exe`: Transfer one file through the optional unauthenticated TFTP client.
- `get`: Download one remote source to an explicit local destination.
- `put`: Upload one local source to an explicit remote destination.

TFTP supplies neither directory discovery nor authentication; source and
destination meanings reverse between `get` and `put`.

<!-- mant:entries role=option case=insensitive -->
- `-i`: Select byte-preserving binary/octet mode instead of ASCII conversion.

## Common mistakes

### Enabling the feature merely to test whether a remote port exists

Feature enablement changes attack surface and may require servicing/restart
policy. Inventory the feature first. Use approved network telemetry or a
purpose-built probe from an authorized diagnostic host; a TCP port test does not
test TFTP because TFTP uses UDP and negotiates transfer state beyond the initial
request.

### Omitting `-i` for firmware, images, archives, or configuration bytes

Default ASCII conversion can corrupt binary content. Use octet mode for byte-
exact artifacts and verify size plus a trusted out-of-band SHA-256/signature.
Never flash or boot an artifact merely because TFTP reported success.

### Reversing GET/PUT source and destination

Write down direction, exact host, remote name and isolated local path before the
command. Use a new destination and explicit collision policy. A reversed PUT can
expose local data; a reversed GET can replace or create an unintended local file.

### Treating network reachability as authorization or identity

TFTP has no user login, server authentication or confidentiality. DNS/IP can be
spoofed and any reachable actor may observe or inject traffic. Restrict it to an
isolated provisioning network with ACLs, short exposure, device allowlists,
signed artifacts and independent inventory/change authorization.

### Assuming TFTP supports filesystem discovery and transaction semantics

The protocol/client is not a remote shell or file browser. Do not guess paths by
broad retry, assume atomic writes, resume, locking, durable completion, directory
creation or cleanup. Follow the exact device/server workflow and verify final
state at the consumer.

### Retrying forever across UDP/firewall failures

Packet loss, NAT, stateful firewalls, server transfer ports, block-size options,
MTU and device boot timing can produce timeouts. Bound attempts, capture both
endpoint/packet evidence under privacy policy, and do not weaken broad firewall
rules to make one transfer pass.

## PowerShell boundaries

Invoke `tftp.exe` explicitly and pass host/action/paths as separate arguments.
Capture `$LASTEXITCODE` immediately, but validate the exact resulting artifact.
Do not interpolate untrusted remote filenames into local paths.

## Version and platform differences

TFTP Client is an optional Windows feature; feature name, availability and
servicing behavior vary by edition/build. Server extensions, block size,
timeouts, path rules, overwrite policy and firmware workflow are implementation-
specific. Target-local help and representative isolated testing are required.

## Related documents

- [dism.exe](dism.exe.md)
- [pnputil.exe](pnputil.exe.md)
- [certutil.exe](certutil.exe.md)
- [pktmon.exe](pktmon.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[TFTP reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tftp),
including its explicit authentication, encryption, Internet-installation and
server-removal warnings. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
