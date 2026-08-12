<!-- mant:tldr:start -->
# certreq.exe

> Create, submit, retrieve, and accept Windows certificate requests with explicit identity and CA scope.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/certreq_1.

- Show the locally installed syntax for creating a request:

`certreq.exe -new -?`

- Create a machine-context request and keep the request file for inspection:

`certreq.exe -new -machine "{{request.inf}}" "{{request.req}}"`

- Inspect the encoded subject, SANs, public key, and usages before submission:

`certutil.exe -dump "{{request.req}}"`

- Submit an inspected request to one exact certification authority and save the issued certificate:

`certreq.exe -submit -config "{{ca-host\ca-name}}" "{{request.req}}" "{{issued.cer}}"`

- Retrieve an approved pending request by its recorded request ID:

`certreq.exe -retrieve -config "{{ca-host\ca-name}}" "{{request-id}}" "{{issued.cer}}"`

- Accept an issued machine certificate on the computer that owns the matching private key:

`certreq.exe -accept -machine "{{issued.cer}}"`
<!-- mant:tldr:end -->

# certreq.exe

## Overview

`certreq.exe` drives Windows certificate enrollment. It can create a request
and private key from an INF policy file, submit the request to a certification
authority (CA), retrieve a previously pending response, and accept the issued
certificate into the Windows certificate store. Advanced verbs also enroll or
renew from templates and construct or sign cross-certification requests.

A typical controlled flow is `-new`, inspect the resulting request, `-submit`,
record the CA and request ID, then `-accept` on the same identity and machine
that owns the pending private key. Each stage changes or discloses security-
relevant state even when it only writes a request or certificate file.

## Commands and common parameters

<!-- mant:entries role=command case=insensitive -->
- `certreq.exe`: Drive a Windows certificate request and enrollment lifecycle.

The leading dash verb selects the operation; subsequent options change store,
identity, CA, encoding, overwrite, and request-policy behavior.

<!-- mant:entries role=option case=insensitive -->
- `-new`: Create a private key and certificate request from an INF policy file.
- `-submit`: Submit a request to an explicitly selected certification authority.
- `-retrieve`: Retrieve a disposition/certificate by recorded CA request ID.
- `-accept`: Install and link an issued response to its pending private key.
- `-policy`: Create a policy request from an existing request and policy INF.
- `-sign`: Sign a cross-certificate or qualified-subordination request.
- `-enroll`: Enroll or renew from an enterprise certificate template.
- `-enrollaik`: Enroll an Attestation Identity Key certificate on installed
  builds that expose this specialized TPM-attestation workflow.
- `-enrollcredguardcert`: Enroll a machine Credential Guard certificate from
  the following template and optional extension INF on installed builds.
- `-enrolllogon`: Enroll a Windows Hello for Business logon certificate through
  ADFS on installed builds that expose this specialized workflow.
- `-post`: Send an HTTP request to the explicitly configured URL on installed
  builds; treat the endpoint, payload, authentication, response, and logs as a
  network/security operation rather than local file formatting.
- `-machine`: Use the local-machine key/store context.
- `-user`: Use the current-user key/store context.
- `-config`: Select an exact `CAHost\CAName` configuration.
- `-policyserver`: Select the following enrollment-policy server URL or ID;
  `*` can open interactive selection and is unsuitable for deterministic automation.
- `-attrib`: Supply reviewed request attributes such as an enterprise template.
- `-binary`: Use binary request/response handling where the selected verb supports it.
- `-any`: Let the submission interface determine the request encoding type.
- `-cert`: Select the following signing or renewal certificate identity; resolve
  the exact certificate and private-key context before use.
- `-anonymous`: Select anonymous authentication for a supported policy/enrollment
  endpoint; this is not a general permission bypass.
- `-kerberos`: Select Kerberos authentication for a supported endpoint.
- `-clientcertificate`: Select the following client-certificate identity for a
  supported connection; protect its private-key context.
- `-username`: Supply the following enrollment-service username.
- `-p`: Supply the following password for a supported service connection;
  command-line use can expose the secret in arguments, history, transcripts, and logs.
- `-pin`: Supply the following key or smart-card PIN; avoid command-line secret exposure.
- `-crl`: Include certificate-revocation-list handling for supported operations.
- `-rpc`: Force RPC enrollment transport where documented.
- `-adminforcemachine`: Submit using the key-service local-system context; this
  is an administrative identity boundary, not an ordinary machine-store synonym.
- `-renewonbehalfof`: Submit renewal on behalf of the subject identified by the
  signing certificate under an approved enrollment-agent policy.
- `-nochallenge`: Skip processing the key-proof challenge where the installed
  workflow supports it; do not weaken attestation without authoritative policy.
- `-xchg`: Supply the following CA exchange-certificate file for private-key archival.
- `-noeku`: Disable enhanced-key-usage filtering when selecting a signing certificate.
- `-alternatesignaturealgorithm`: Request the alternate signature algorithm where supported.
- `-hashalgorithm`: Select the following hash algorithm under current CA and organization policy.
- `-unicode`: Write redirected console output as Unicode on installed builds.
- `-unicodetext`: Write output files as Unicode text where the selected verb supports it.
- `-f`: Permit replacement of an existing output artifact.
- `-q`: Reduce console output without changing the operation.
- `-v`: Emit verbose diagnostic output.
- `-?`: Display verb-specific installed help.

## Request lifecycle

| Stage | Primary artifact or state | Verification before continuing |
| --- | --- | --- |
| `-new` | Private key plus `.req` request | Confirm subject, SANs, key algorithm/length, usages, template, and user/machine context. |
| `-submit` | CA request row and request ID; possibly an issued `.cer` | Confirm exact CA configuration and disposition; retain the request ID. |
| `-retrieve` | Issued certificate/chain for a prior request | Match the CA, request ID, public key, names, usages, validity, and issuer. |
| `-accept` | Certificate linked to its pending private key in a store | Confirm the intended store/context and that the certificate reports an accessible private key. |

Use `certutil.exe -dump "{{request.req}}"` to inspect a generated request before
submission. After acceptance, inspect the exact thumbprint through the
PowerShell certificate provider or `certutil -store`; then test the intended
application identity, not merely whether the import command succeeded.

## INF policy essentials

`[NewRequest]` defines key creation and request properties. `[Extensions]`
can encode SANs and other X.509 extensions, while `[RequestAttributes]` can
send CA-specific attributes such as an enterprise template name. Review at
least:

- `Subject` and SAN extension `2.5.29.17` against the actual DNS/IP/user names;
- `MachineKeySet` and the matching `-machine` or `-user` execution context;
- `KeyAlgorithm`, `KeyLength`, `HashAlgorithm`, provider/KSP, `KeyUsage`, and
  enhanced key usages against current organization policy;
- `Exportable` and key-protection settings, defaulting to non-exportable unless
  an approved deployment design requires export;
- request type, template, enrollment-on-behalf-of identity, and renewal key
  reuse against CA policy.

Treat the INF as executable security policy. Keep it under review, but do not
store real private-key passwords, sensitive subject data, or reusable
enrollment secrets in source control.

## Common mistakes

### Copying the SHA-1 defaults from the reference page

Microsoft warns that parts of the official reference describe historical
Windows Server defaults, including SHA-1. Do not turn those defaults into a
recommendation. Select algorithms, key sizes, providers, usages, and validity
from current CA and organization policy, then verify what the issued
certificate actually contains.

### Losing track of the private key after `-new`

The `.req` contains the public request, not a portable private key. Windows
keeps the pending private key in the request creator's user or machine
context. Record the host, account, store context, provider/container, and
request file; accept the response there. Copying only the `.req` to another
computer does not copy the private key.

### Mixing user and machine context

For a machine certificate, the INF `MachineKeySet` value, template context,
`-machine` option, elevation, and later acceptance must agree. A request made
under an administrator's user context can leave a service or computer unable
to access its key. Do not compensate by broadly weakening private-key ACLs.

### Treating a common name as a complete server identity

Modern clients normally match the subject alternative name extension. Add
only authorized DNS/IP identities, inspect the encoded request, and verify the
issued SANs. A CA can reject, remove, or replace requested extensions according
to template and policy; successful submission is not proof of correct names.

### Omitting the verb, file, or CA configuration

Some incomplete forms open a file picker or CA-selection UI, and omission of
an explicit verb defaults toward submission. That is unsuitable for repeatable
automation. Specify the verb, quoted input/output paths, and exact
`host\CAName`; capture the request ID and `$LASTEXITCODE`.

### Assuming `-accept` establishes trust or proves usability

Acceptance links an issued certificate to a matching pending key and installs
it in a store. It does not establish that peers trust the issuer, that chain
and revocation retrieval work, that the application uses this store, or that
the service identity can access the key. Verify all four separately.

### Reusing a key during renewal without policy review

Renewal and `reusekeys` can preserve compromised, undersized, nonexportable,
or wrong-provider key material. Confirm whether policy requires key rotation,
whether the old certificate is still valid, and how overlapping deployment and
rollback will work before renewing.

### Treating enrollment-on-behalf-of as ordinary enrollment

`RequesterName`, signing certificates, and enrollment-agent permissions
change who is represented and require CA support. Record requester and agent
identities, constrain templates, protect signing keys, and audit the issued
certificate rather than adding attributes until the CA accepts them.

### Treating specialized installed verbs as ordinary certificate requests

`-EnrollAIK`, `-EnrollCredGuardCert`, `-EnrollLogon`, and `-Post` appear in the
recorded installed complete help but are absent from the current general
Microsoft CertReq syntax page. They cross TPM attestation, Credential Guard,
ADFS/Hello, or HTTP endpoint boundaries. Feature-test exact help, use the owning
product's approved workflow, and do not infer required identity, transport,
template, payload, or success semantics from the verb name.

### Exposing enrollment credentials and PINs

Installed help accepts `-p Password` and `-pin Pin`. Native arguments can be
visible to process inventory, logging, command history, transcripts, monitoring,
and Agents. Prefer a supported protected prompt or managed identity mechanism;
never print, serialize, commit, or paste a real password or PIN.

## PowerShell boundaries

`certreq.exe` is a native program: it emits text rather than certificate
objects. Quote every path and CA configuration, preserve stdout/stderr for the
change record, and check `$LASTEXITCODE` immediately. Use `Get-ChildItem` on
`Cert:\CurrentUser` or `Cert:\LocalMachine` to perform structured follow-up
queries, but select the store and thumbprint explicitly.

## Version and platform differences

This Windows-only command is available on supported Windows client and server
releases, but verbs, options, providers, algorithms, templates, and enrollment
services vary. Run `certreq.exe -v -?` and verb-specific help on the target
host. Enterprise CA, CEP/CES, Key Attestation, offline CA, and third-party CA
workflows have additional constraints. On Windows NT 10.0.26200.0, installed
file version 10.0.26100.8115 complete help exposes the specialized verbs and
options indexed above; the current general Microsoft page documents only the
portable core, so exact target help remains authoritative for availability.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8115 -v -?
returned 0 and exposed 40 option/verb entries plus the executable. Four
specialized installed verbs and 18 security-relevant common options missing
from the current general Microsoft page are indexed with build, secret,
identity, network, attestation, and no-inference boundaries. No key, request,
CA, template, policy server, credential, PIN, HTTP endpoint, file, store, TPM,
ADFS, Hello, or Credential Guard operation ran.

## Related documents
- [certutil.exe](certutil.exe.md)
- [cipher.exe](cipher.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[certreq reference](https://learn.microsoft.com/windows-server/administration/windows-commands/certreq_1).
The recurring question about where a `certreq -new` private key goes was
cross-checked against
[practitioner discussion](https://serverfault.com/questions/717178/where-is-the-private-key-after-using-certreq-for-csr-generation-on-windows-10)
and resolved using Microsoft's documented user/machine request context and
`-accept` behavior. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
