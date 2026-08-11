<!-- mant:tldr:start -->
# verify

> Inspect a legacy Cmd write-verification setting; do not confuse it with file
> hashes, byte comparison, signatures, filesystem health, or Driver Verifier.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/verify.

- Display the current setting without changing it:

`cmd.exe /d /c verify`

- Calculate a SHA-256 content hash for an exact file:

`Get-FileHash -LiteralPath "{{path}}" -Algorithm SHA256`

- Inspect an exact file's Authenticode signature and signer:

`Get-AuthenticodeSignature -LiteralPath "{{path}}" | Format-List Status, StatusMessage, SignerCertificate, TimeStamperCertificate`

- Compare two exact files byte-for-byte and capture FC's result immediately:

`fc.exe /B "{{expected-file}}" "{{actual-file}}"; $fcExitCode = $LASTEXITCODE`

<!-- mant:tldr:end -->

# verify

## Overview

`verify [on|off]` is a legacy `cmd.exe` session setting described by Microsoft
as telling Cmd whether to verify that files are written correctly to disk. With
no argument it only displays that setting. The command accepts no file path and
produces no content digest or trustworthy end-to-end verification record.

Choose a mechanism that matches the claim you need: compare bytes for equality,
hash content for later comparison, validate an Authenticode signature and trust
policy, inspect filesystem/device health, or test an application artifact after
a controlled write. None of those claims follows from `verify on`.

## Common mistakes

### Passing a filename to `verify`

There is no filename parameter. Use `Get-FileHash`, `fc.exe /B`, an application-
specific verifier, or a documented storage diagnostic according to the goal.

### Treating a matching hash as authenticity

A hash proves equality only against a trusted expected value obtained through a
trusted channel. It does not identify the publisher or establish policy. For a
signed artifact, inspect the signature, certificate chain, timestamp, expected
publisher, and revocation/policy requirements separately.

### Treating byte comparison as durable storage proof

A successful immediate read does not by itself prove cache flush, future media
health, atomicity, backup recoverability, or application consistency. Define the
actual durability and recovery contract and test at that layer.

### Confusing `verify` with similarly named tools

Driver Verifier (`verifier.exe`), System File Checker, CHKDSK, package signature
validation, TLS certificate validation, and PowerShell's `-WhatIf` are unrelated
systems with different risk. Resolve the exact executable or Cmd builtin first.

### Changing an inherited setting without evidence

The setting is scoped to Cmd process state and can be inherited by child Cmd
sessions. Do not toggle it globally in shared batch logic based only on its
promising name. If compatibility requires it, isolate the child shell and
validate behavior on the exact supported Windows builds.

## PowerShell behavior

Bare `verify` is not a PowerShell cmdlet. Use `cmd.exe /d /c verify` to query a
clean child Cmd. Prefer PowerShell's typed file, hash, and signature cmdlets for
their specific purposes, and capture native `$LASTEXITCODE` before another
native command overwrites it.

## Version and platform differences

This is a Windows Cmd compatibility setting on supported Windows client and
server releases. Microsoft documents its narrow switch surface but not an
end-to-end durability guarantee. Runtime proof is required before relying on it
for any legacy application's compatibility behavior.

## Related documents

- [fc](fc.md)
- [verifier](verifier.md)
- [sfc](sfc.md)
- [chkdsk](chkdsk.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Verify reference](https://learn.microsoft.com/windows-server/administration/windows-commands/verify).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
