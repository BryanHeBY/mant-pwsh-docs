<!-- mant:tldr:start -->
# certutil

> Inspect Windows certificate files, stores, chains, and file hashes without treating display text as a stable API.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/certutil.

- Show the verbs supported by the installed Windows version:

`certutil.exe -?`

- Parse and inspect one certificate or request file without importing it:

`certutil.exe -dump "{{certificate-or-request-file}}"`

- Calculate a SHA-256 file hash for an interactive integrity check:

`certutil.exe -hashfile "{{file}}" SHA256`

- List the current user's Personal certificate store:

`certutil.exe -user -store My`

- Build and verify a certificate chain using current local policy and caches:

`certutil.exe -verify "{{certificate.cer}}"`
<!-- mant:tldr:end -->

# certutil

## Overview

`certutil.exe` is a broad Windows PKI administration and diagnostic tool. It
can inspect certificate/CSR/CRL/ASN.1 content, enumerate stores and key
providers, build and verify chains, calculate hashes, encode/decode data, and
administer Active Directory Certificate Services (AD CS). Many other verbs
modify certificate stores, CA requests, CA configuration, keys, caches, or CA
backup state.

Microsoft explicitly does not recommend `certutil` as a production-code API
and provides no live-site compatibility guarantee. Use it for bounded
interactive administration and diagnosis; prefer supported PowerShell/.NET or
Windows certificate APIs when software needs structured, stable behavior.

## Useful read-only operations

| Goal | Command shape | Important boundary |
| --- | --- | --- |
| Inspect a file | `certutil -dump file` | Decoding content does not establish trust or possession of a private key. |
| Hash a file | `certutil -hashfile file SHA256` | Output is human-oriented; use `Get-FileHash` for structured PowerShell automation. |
| Enumerate stores | `certutil -enumstore` or `-user -enumstore` | Machine and current-user stores are different. |
| Inspect a store | `certutil -store My` or `-user -store My` | Store output can reveal subjects, identities, providers, and topology. |
| Verify a chain | `certutil -verify cert.cer` | Result depends on time, policy, trust stores, caches, and revocation availability. |
| Discover providers | `certutil -csplist` | Availability does not mean a provider/algorithm satisfies current policy. |

Use `certutil.exe {{verb}} -?` before a rare operation. For the full installed
usage inventory, including verbs hidden from ordinary help, Microsoft
documents `certutil.exe -v -uSAGE`; `uSAGE` is case-sensitive. Hidden or
version-specific presence is not an endorsement for routine automation.

## Certificate-store scope

Without `-user`, store operations normally address the local-machine context;
`-user` selects the current user's stores. `-enterprise`, `-GroupPolicy`, and
`-service` select other locations with different ownership and policy. Common
logical names include `My` (Personal), `Root`, and `CA`.

A `CertId` can be a thumbprint/hash, serial number, index, subject name, DNS
name, template, provider/container, OID, or several other tokens. Many forms
can match more than one certificate. Enumerate first, prefer the full exact
thumbprint for a subsequent operation, state the store/context explicitly,
and re-query after any approved change.

## Common mistakes

### Parsing the second line of `-hashfile`

The command writes headings, spaced hexadecimal text, and a completion or
error line intended for people; localization and errors make line-number and
`find` filters brittle. In PowerShell automation use
`(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash`, then handle
exceptions. Also avoid MD5/SHA-1 for security-sensitive integrity decisions
unless a legacy protocol explicitly requires them.

### Assuming `-dump`, `-decode`, or `-encode` validates data

Parsing ASN.1 or converting Base64 only changes or displays representation.
It does not prove issuer trust, hostname/application policy, current validity,
revocation status, or private-key possession. Use an appropriate `-verify`
workflow and then validate the consuming application's actual policy.

### Inspecting or changing the wrong store

An elevated shell does not make `-user` mean the interactive desktop user; it
still selects the account running the process. Conversely, omitting `-user`
can target the machine store. Record account, elevation, store name, host, and
full thumbprint before using `-addstore`, `-delstore`, `-importPFX`, or
`-repairstore`.

### Using a subject or numeric index as a destructive identifier

Subject names are not unique, and indexes can change between queries. Because
`CertId` tries many match forms, a familiar-looking token may match more than
expected. Use the exact full thumbprint in the exact store and context, confirm
the result count, back up required certificates/keys, and verify after change.

### Putting a PFX password on the command line

The `-p` option can expose a secret through history, process inspection, logs,
remote tooling, and transcripts. Prefer a supported import API with secure
secret handling. Never use `-privatekey`, verbose dumps, or exported files in
unprotected support bundles; a PFX contains private-key material.

### Treating `-repairstore` as key recovery

`-repairstore` repairs an association or properties/security descriptor when
the matching key material already exists and is usable in the intended
context. It cannot reconstruct a missing key or bypass DPAPI/provider/HSM
protection. Diagnose certificate public key, provider/container, account,
machine, backup, and ACL state before attempting repair.

### Adding a root certificate as a generic fix

`-addstore Root` changes what the host trusts and can affect every process
using that trust store. Do not import a leaf or unknown CA merely to silence a
chain error. Establish the authorized trust anchor and distribution method,
inspect basic constraints and thumbprints out of band, and prefer managed
policy for fleet-wide trust.

### Misreading online revocation failures

`-urlfetch` allows network retrieval of AIA certificates and CRLs and can be
slow, proxied, blocked, cached, or privacy-sensitive. Record test time, URL
reachability, timeout, user/machine context, and cache state. Distinguish
offline/unknown revocation from revoked, expired, untrusted, or wrong-policy
certificates; do not flush caches as the first diagnostic step.

### Running CA-management verbs without a recovery plan

Verbs such as `-setreg`, `-delreg`, `-backup`, `-restore`, `-deny`,
`-resubmit`, and key-recovery operations can change or expose critical AD CS
state. Use an approved CA runbook, explicit `-config`, known backups, change
control, protected output, and service-restart/replication awareness.

## PowerShell behavior

`certutil.exe` emits human-oriented native text. Quote paths, do not infer
success from matching output text, and check `$LASTEXITCODE` immediately.
Prefer the `Cert:` provider and certificate cmdlets for structured store
inventory, and `Get-FileHash` for hashes. If you retain diagnostic output,
protect it as security metadata and record the exact command and host version.

## Version and platform differences

This Windows-only tool ships on supported Windows client and server releases,
but Microsoft notes that not every version implements every documented verb
or option. AD CS-specific operations require the appropriate server role or
management tools and permissions. Algorithms, providers, trust policy, store
contents, and revocation behavior vary by host and organization.

## Related documents

- [certreq](certreq.md)
- [cipher](cipher.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[certutil reference](https://learn.microsoft.com/windows-server/administration/windows-commands/certutil).
The recurring request to parse `-hashfile` display text was cross-checked
against
[practitioner discussion](https://stackoverflow.com/questions/38771114/saving-result-of-certutil-hashfile-to-a-variable-and-remove-spaces-of-the-hash)
and used as evidence for recommending a structured PowerShell alternative.
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
