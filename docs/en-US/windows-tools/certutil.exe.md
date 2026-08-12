<!-- mant:tldr:start -->
# certutil.exe

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

# certutil.exe

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

<!-- mant:entries role=command case=insensitive -->
- `certutil.exe`: Inspect or administer Windows certificate, trust, key, store, Active Directory, and AD CS state through an explicitly selected verb.

## Common verbs

<!-- mant:entries role=option case=insensitive -->
- `-dump`: Parse and display a certificate, request, CRL, or supported ASN.1 file without establishing trust.
- `-hashfile`: Calculate a selected file hash for interactive diagnostics; prefer `Get-FileHash` for typed automation.
- `-encode`, `-decode`: Convert between binary and Base64 representation without validating trust or content safety.
- `-encodehex`, `-decodehex`: Convert supported binary/hexadecimal forms according to installed help.
- `-enumstore`: Enumerate logical certificate stores in the selected machine/user/service/policy scope.
- `-store`: Inspect certificates in one exact logical store and selected scope.
- `-verify`: Build and verify a certificate chain under current time, trust, policy, cache, and revocation conditions.
- `-verifyCTL`: Verify a certificate trust list under the selected policy.
- `-URL`: Open the URL retrieval/verification UI for a certificate or CRL in an interactive session.
- `-URLCache`: Inspect or change URL cache entries; deletion changes diagnostic state.
- `-csplist`: Enumerate cryptographic providers visible on the host.
- `-key`: Inspect key containers for a selected provider/context; output is sensitive security metadata.
- `-addstore`, `-delstore`: Add or remove an exact certificate in an exact store and scope.
- `-importPFX`: Import a PFX and private-key material using a protected credential workflow.
- `-repairstore`: Repair an existing certificate-to-key association or properties; it cannot recover a missing key.
- `-setreg`, `-delreg`: Change AD CS/cryptographic registry state only through an approved product runbook.
- `-backup`, `-restore`: Back up or restore AD CS state with protected key material and tested recovery procedures.
- `-?`: Display the installed top-level verb list or exact-verb help; prefer this to bare CertUtil invocation.

## Complete verb-family index

The entries below make the union of Microsoft's current reference and the
recorded installed top-level help addressable to ManT. Presence is not a safety
or availability guarantee: exact-verb help, role installation, privilege,
target identity, output paths, secrets, and rollback remain mandatory gates.

### File, ASN.1, PFX, and representation operations

<!-- mant:entries role=option case=insensitive -->
- `-dumpPFX`: Display PFX structure; protect passwords, certificate identities, key-provider metadata, and any resulting transcript.
- `-asn`: Parse supported ASN.1 input without establishing certificate trust or semantic safety.
- `-ConvertEPF`: Convert a PFX file to EPF on installed builds that expose this verb; treat both input and output as private-key material.
- `-mergePFX`: Merge PFX files into a new protected private-key artifact.

### CA request, certificate, and CRL lifecycle

<!-- mant:entries role=option case=insensitive -->
- `-deny`, `-resubmit`: Change the disposition of one exact pending AD CS request.
- `-setattributes`, `-setextension`: Change request attributes or extensions before issuance; resolve request ID, OID, flags, type, and exact value first.
- `-revoke`: Revoke or unrevoke exact certificate serial numbers with an explicit reason and CA configuration.
- `-isvalid`: Query the disposition of one current CA certificate identifier; it is not a complete relying-party validation.
- `-GetCRL`: Retrieve the selected CA CRL to a protected new output file.
- `-CRL`: Publish or republish base/delta CRLs; this changes revocation infrastructure state.
- `-shutdown`: Stop Active Directory Certificate Services on the selected CA.
- `-installCert`, `-renewCert`: Install or renew the selected CA certificate through an approved CA lifecycle runbook.

#### Dot-bearing CA retrieval verbs

ManT 0.6.1's dash-option grammar stops before a dot, while command-role names
cannot begin with `-`. The semantic selectors therefore omit only the leading
hyphen; the exact CertUtil invocation verbs remain `-ca.cert` and `-ca.chain`.
Do not invoke the selector spelling as a CertUtil argument.

<!-- mant:entries role=command case=insensitive -->
- `ca.cert`: Index the exact CertUtil verb `-ca.cert`, which retrieves the selected CA certificate to a protected new output file.
- `ca.chain`: Index the exact CertUtil verb `-ca.chain`, which retrieves the selected CA chain to a protected new output file.

### CA discovery, database, and row operations

<!-- mant:entries role=option case=insensitive -->
- `-getconfig`, `-getconfig2`, `-getconfig3`: Discover CA configuration through different installed COM interfaces; gate the latter forms on exact help.
- `-ping`, `-pingadmin`: Contact the AD CS request or administration interface; this is network/authentication activity, not ICMP.
- `-CAInfo`, `-CAPropInfo`: Display selected CA properties or property-type information.
- `-schema`, `-view`, `-db`: Display CA database schema, filtered views, or raw database information; output can contain sensitive request and identity data.
- `-deleterow`: Permanently delete selected CA database rows; date parsing is documented in `MM/DD/YYYY` form regardless of local display convention.
- `-dynamicfilelist`, `-databaselocations`: Display CA dynamic files or database/log locations.

### CA backup, PFX export, and archived-key recovery

<!-- mant:entries role=option case=insensitive -->
- `-backupDB`, `-backupKey`: Back up the CA database or CA certificate/private key to an explicit protected destination.
- `-restoreDB`, `-restoreKey`: Restore CA database or CA certificate/private-key state from an approved backup.
- `-exportPFX`: Export selected certificates and private keys to a new PFX with explicit encryption, chain, root, and property policy.
- `-ImportKMS`, `-ImportCert`: Import key-archival material or a certificate into the selected CA database.
- `-GetKey`, `-RecoverKey`: Retrieve or recover an archived private key under the organization's key-recovery-agent procedure.

### Certificate stores, keys, providers, and crypto configuration

<!-- mant:entries role=option case=insensitive -->
- `-verifystore`: Verify selected certificates in an exact store and user/machine/service/policy context.
- `-viewstore`: Display a certificate store through the CertUtil UI/view path; do not use it as a headless data API.
- `-viewdelstore`: Select and delete a certificate through interactive store UI; it is a mutation despite the `view` prefix.
- `-UI`, `-getcert`: Open installed CertUtil certificate-selection or general UI; interactive identity must still be recorded.
- `-TPMInfo`: Display TPM-related certificate/key information on versions that expose this verb.
- `-attest`: Process or verify key-attestation material according to exact verb help and enrollment policy.
- `-delkey`: Delete an exact key container; certificate deletion and key-container deletion are different irreversible scopes.
- `-verifykeys`: Verify a public/private key pair without proving certificate trust or application usability.
- `-csptest`: Exercise installed cryptographic providers; it can invoke provider operations and is not mere enumeration.
- `-CNGConfig`: Display installed CNG configuration where supported.
- `-addEccCurve`, `-deleteEccCurve`: Add or delete registered elliptic-curve configuration.
- `-displayEccCurve`: Display one installed elliptic-curve definition.
- `-sign`: Re-sign a CRL or certificate using explicitly authorized issuer/key material.

### Active Directory publication, templates, enrollment, and policy

<!-- mant:entries role=option case=insensitive -->
- `-ds`, `-dsCert`, `-dsCRL`, `-dsDeltaCRL`, `-dsTemplate`: Display selected directory-service DNs, certificates, CRLs, delta CRLs, or template attributes where supported.
- `-dsDel`: Delete selected directory-service distinguished-name data.
- `-dsPublish`: Publish a certificate or CRL to an exact Active Directory object.
- `-dsAddTemplate`: Add selected certificate-template data to Active Directory.
- `-ADTemplate`, `-Template`, `-TemplateCAs`, `-CATemplates`: Display AD/enrollment templates or the CAs related to them.
- `-SetCATemplates`: Change the templates that the selected CA can issue.
- `-SetCASites`: Set, verify, or delete CA site names.
- `-enrollmentServerURL`: Display, add, or delete enrollment-server URLs associated with a CA.
- `-ADCA`, `-CA`, `-Policy`: Display Active Directory CAs, enrollment-policy CAs, or enrollment policy.
- `-PolicyCache`: Display or delete enrollment-policy cache entries.
- `-CredStore`: Display, add, or delete credential-store entries.
- `-InstallDefaultTemplates`: Install default certificate templates; this is an Active Directory configuration change.
- `-MachineInfo`, `-DCInfo`, `-EntInfo`, `-TCAInfo`: Display selected AD machine, domain-controller, enterprise-CA, or CA information.

### Trust retrieval, smart cards, Hello, and caches

<!-- mant:entries role=option case=insensitive -->
- `-pulse`: Trigger an autoenrollment event or Windows Hello/NGC task; this is active processing, not a passive status query.
- `-SCInfo`: Display smart-card information; prompts, readers, middleware, and card access can make it interactive.
- `-SCRoots`: Manage smart-card root certificates; exact help determines display versus mutation form.
- `-DeleteHelloContainer`: Delete the Windows Hello container and associated WebAuthn/FIDO credentials; recovery is not implied.
- `-syncWithWU`: Synchronize trust certificates with Windows Update under current network and policy state.
- `-generateSSTFromWU`: Generate a trust-store file from Windows Update into an explicit new destination.
- `-generatePinRulesCTL`: Generate a CTL containing certificate-pinning rules.
- `-downloadOcsp`: Download OCSP responses into an explicit protected directory.
- `-generateHpkpHeader`: Generate an HPKP header from selected certificates; HPKP is obsolete for modern Web deployment decisions.
- `-flushCache`: Flush selected certificate-related caches, potentially in a process such as LSASS; preserve before-state and use an approved runbook.

### Web enrollment applications and local configuration

<!-- mant:entries role=option case=insensitive -->
- `-vroot`, `-vocsproot`: Create or delete certificate/OCSP Web virtual roots and related shares.
- `-addEnrollmentServer`, `-deleteEnrollmentServer`: Add or delete enrollment-server IIS applications and application pools.
- `-addPolicyServer`, `-deletePolicyServer`: Add or delete policy-server IIS applications and application pools.
- `-Class`: Display selected COM registry information where supported.
- `-7f`: Check a certificate for ASN.1 `0x7f` length encodings on builds that expose the verb.
- `-oid`: Display an object identifier or set its display name, depending on exact arguments.
- `-error`: Display message text for an exact error code; message localization is not a stable programmatic mapping.
- `-getsmtpinfo`: Display AD CS SMTP information where supported.
- `-setsmtpinfo`: Change AD CS SMTP information where supported.
- `-getreg`: Display an exact AD CS/cryptographic registry value.

### Certificate Transparency and log-proof operations

<!-- mant:entries role=option case=insensitive -->
- `-add-chain`, `-add-pre-chain`: Add a certificate or precertificate chain to the selected transparency service.
- `-get-sth`, `-get-sth-consistency`: Retrieve a signed tree head or consistency proof/change from a selected transparency service.
- `-get-proof-by-hash`: Retrieve inclusion proof for one exact hash.
- `-get-entries`: Retrieve selected entries from the remote transparency log, not the Windows Event Log.
- `-get-roots`: Retrieve accepted root certificates from the selected transparency service.
- `-get-entry-and-proof`: Retrieve one transparency-log entry and its cryptographic proof.
- `-VerifyCT`: Verify certificate-transparency evidence for a selected certificate and policy context.

## Scope and behavior options

<!-- mant:entries role=option case=insensitive -->
- `-user`: Select the current process user's certificate/key context instead of the default machine context.
- `-enterprise`: Select enterprise registry/store behavior for a supported verb.
- `-GroupPolicy`: Select Group Policy certificate stores where the verb supports them.
- `-service`: Select a named service certificate store/context.
- `-config CA`: Select an exact certification-authority configuration for AD CS operations.
- `-urlfetch`: Permit chain verification to retrieve AIA certificates and CRLs from network locations.
- `-v`: Request verbose diagnostics that can reveal security metadata.
- `-p PASSWORD`: Supply a password to a supported verb; avoid exposing secrets on the command line.
- `-f`: Force a supported operation; it does not make the target, certificate, or trust change safe.
- `-silent`: Suppress supported UI prompts; unattended failure handling still requires explicit checks.

### Full-usage discovery

Microsoft documents the following mixed-case spelling as case-sensitive. It
is a help selector, not an ordinary CertUtil verb.

<!-- mant:entries role=option case=sensitive -->
- `-uSAGE`: With `-v`, display complete installed verb and option help, including entries hidden from ordinary `-?` output.

### Additional installed global options

These option headings appear in the recorded client's complete usage output.
They are not accepted by every verb; exact-verb help remains the applicability
gate.

<!-- mant:entries role=option case=insensitive -->
- `-admin`: Use the ICertAdmin2 administration interface for supported CA-property operations.
- `-Anonymous`: Select anonymous SSL credentials where a supported network verb allows that authentication mode.
- `-Kerberos`: Select Kerberos SSL credentials where a supported network verb allows that authentication mode.
- `-idispatch`: Use COM `IDispatch` rather than the native COM interface for supported operations.
- `-v1`: Use the older version-1 interface for a supported compatibility workflow.
- `-gmt`: Display supported timestamps in GMT rather than local time.
- `-seconds`: Include seconds and milliseconds in supported timestamp output.
- `-mt`: Display machine certificate templates in supported template operations.
- `-ut`: Display user certificate templates in supported template operations.
- `-reverse`: Reverse supported log or queue columns; do not assume it reverses arbitrary output or operation order.
- `-SCDump`: Dump smart-card file information; output can reveal card, reader, certificate, and provider metadata.
- `-nocr`: Encode supported text without carriage-return characters; this changes the generated representation.
- `-nocrlf`: Encode supported text without CR-LF characters; this changes the generated representation.
- `-Unicode`: Write redirected CertUtil text as Unicode where the selected output path supports it.
- `-UnicodeText`: Write supported text output files as Unicode.
- `-split`: Extract embedded ASN.1 elements into separate files; resolve and protect every generated output path.
- `-privatekey`: Include password and private-key data in supported output; never use it in routine logs or support bundles.
- `-protect`: Protect supported key output with a password; use an approved secret-input and storage workflow.
- `-oldpfx`: Use legacy PFX encryption only for an explicitly required compatibility target, not as a default.
- `-nullsign`: Use the data hash as a null signature in supported construction/testing workflows; it does not provide an issuer signature.

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
version-specific presence is not an endorsement for routine automation, and
global-option headings still require exact-verb help before use.

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

### Using bare CertUtil as help

Microsoft documents context-dependent bare behavior: on a CA it displays the
current CA configuration, while on a non-CA it defaults toward `-dump`.
Neither is a portable help request and both can expose host PKI metadata. Use
explicit `-?`, then `verb -?`, and record role/elevation before proceeding.

### Treating every verb as installed or safe because it is indexed

The complete index intentionally covers the union of Microsoft's current
reference and recorded installed help. Microsoft warns that versions differ;
some official verbs are hidden or absent locally, and installed `-ConvertEPF`
is absent from the current online reference. Exact target help is the
availability gate. A verb whose description says display can still contact AD,
a CA, Windows Update, a smart card, or a transparency service; a UI verb can
still delete state.

### Reusing an output path with `-f`

Encoding, decoding, CA retrieval, export, backup, OCSP, trust-store, and key
recovery verbs write files or directories. `-f` can authorize replacement but
does not provide a dry run, atomicity, secret protection, or rollback. Resolve
the final path, reject existing content by default, secure the parent, check
free space, capture status, and verify the artifact without exposing keys.

## PowerShell behavior

`certutil.exe` emits human-oriented native text. Quote paths, do not infer
success from matching output text, and check `$LASTEXITCODE` immediately.
Prefer the `Cert:` provider and certificate cmdlets for structured store
inventory, and `Get-FileHash` for hashes. If you retain diagnostic output,
protect it as security metadata and record the exact command and host version.

Native text encoding is build/locale dependent. On the recorded Simplified
Chinese client, `-?` wrote 5,376 OEM code-page 936 bytes to stdout, nothing to
stderr, and returned 0. Capture paths that assume UTF-8 produced mojibake.
Preserve raw bytes or decode with the recorded console/OEM code page; do not
change global encoding speculatively or parse translated descriptions as API.

## Version and platform differences

This Windows-only tool ships on supported Windows client and server releases,
but Microsoft notes that not every version implements every documented verb
or option. Microsoft's current source exposes 133 verb headings. On Windows NT
`10.0.26200.0`, installed file version `10.0.26100.8115` top-level help exposed
109 verbs; 25 current official verbs were absent from that ordinary list and
installed `-ConvertEPF` was absent from the official page. The 134-verb union
is indexed here. The documented `-v -uSAGE` form returned 1,600 lines and 162
unique headings: the same 134 verbs plus 28 installed global-option headings,
all of which are indexed here. Exact verb help remains authoritative for
applicability and availability. AD CS-specific operations require the
appropriate server role or management tools and permissions. Algorithms,
providers, trust policy, store contents, encoding, and revocation behavior
vary by host and organization.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8115 ordinary -?
returned 0, 5376 CP936 stdout bytes, no stderr, and 109 top-level verbs.
Microsoft's current source exposes 133 verb headings; the case-insensitive
union is 134 because the installed -ConvertEPF verb is absent online. The
help-only -v -uSAGE form returned 0, 1600 lines, no stderr, and 162 unique
headings: the same 134 verbs plus 28 global options. The page indexes every
heading and records ManT 0.6.1's inability to preserve leading-hyphen
dot-bearing selectors such as -ca.cert; ca.cert and ca.chain are explicit
index-only fallbacks.

## Related documents
- [certreq.exe](certreq.exe.md)
- [cipher.exe](cipher.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[certutil reference](https://learn.microsoft.com/windows-server/administration/windows-commands/certutil).
The recurring request to parse `-hashfile` display text was cross-checked
against
[practitioner discussion](https://stackoverflow.com/questions/38771114/saving-result-of-certutil-hashfile-to-a-variable-and-remove-spaces-of-the-hash)
and used as evidence for recommending a structured PowerShell alternative.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
