<!-- mant:tldr:start -->
# winrm.cmd

> Identify WS-Management endpoints and inventory local WinRM client/service, listener, authentication, plugin, and shell state before changing service, firewall, trust, or remoting configuration.
> More information: https://learn.microsoft.com/windows/win32/winrm/installation-and-configuration-for-windows-remote-management.

- Display the installed command families and target-host syntax:

`winrm.cmd help`

- Ask one exact endpoint to identify its WS-Management product/protocol identity:

`winrm.cmd identify -r:"{{server}}"`

- Inventory local client configuration, including authentication and TrustedHosts:

`winrm.cmd get winrm/config/client`

- Inventory local WinRM service configuration and enabled authentication methods:

`winrm.cmd get winrm/config/service`

- Enumerate local HTTP/HTTPS listener address, port, hostname, and certificate binding:

`winrm.cmd enumerate winrm/config/listener`

- Enumerate registered management/remoting plugins and their security/configuration surfaces:

`winrm.cmd enumerate winrm/config/plugin`

- Inventory active command shells; protect user, command, and shell identifiers in the output:

`winrm.cmd enumerate shell/cmd`
<!-- mant:tldr:end -->

# winrm.cmd

## Overview

`winrm.cmd` is the Windows Remote Management command-line entry point for
WS-Management. The wrapper invokes `winrm.vbs` through `cscript.exe`; Windows
does not ship a `winrm.exe`. It can identify endpoints, get/enumerate configuration/resources,
create/set/delete configuration, invoke methods, manage listeners/plugins/
shells, and run `quickconfig`. Those write surfaces can enable remote access,
start services, open firewall rules, weaken authentication, expose credentials,
or break management; the TLDR is intentionally inventory-only.

WinRM is a transport/management service, not synonymous with PowerShell
Remoting. PowerShell over WSMan additionally selects a PowerShell session
configuration/plugin, language mode, startup process, authorization descriptor,
serialization model, quotas, and PowerShell edition. `winrs.exe` creates a
remote command shell with its own semantics.

## Commands and common parameters

<!-- mant:entries role=command case=insensitive -->
- `winrm.cmd`, `winrm`: Inspect or administer WS-Management resources and WinRM configuration.
- `identify`: Ask one endpoint to return its WS-Management identity.
- `get`: Retrieve one configuration or resource instance.
- `enumerate`: Enumerate instances of one configuration/resource URI.
- `create`: Create one resource/configuration instance.
- `set`: Change one resource/configuration instance.
- `delete`: Delete one resource/configuration instance.
- `invoke`: Invoke one WS-Management action/method on a resource.
- `quickconfig`: Start/configure WinRM service, listener, and firewall as a change bundle.
- `help`: Display command/resource-specific installed help.

Aliases, resource URIs, selectors, and values are parsed by WinRM rather than
PowerShell. Common connection parameters still need an exact command context.

<!-- mant:entries role=option case=insensitive -->
- `-r`: Select the remote WS-Management endpoint URI/host.
- `-u`: Select an alternate username.
- `-p`: Supply its password on the command line, exposing the secret.
- `-a`: Select an authentication mechanism supported by client and service.
- `-encoding`: Select request encoding where the command supports it.
- `-format`: Select output formatting such as pretty XML.
- `-file`: Read input XML from a reviewed file.
- `-skipcachecheck`: Skip certificate-cache validation under a narrowly reviewed need.
- `-skipcncheck`: Skip TLS certificate name validation and weaken endpoint identity.
- `-skiprevocationcheck`: Skip certificate revocation validation.
- `-transport`: Select HTTP or HTTPS where the command form supports it.
- `-quiet`: Suppress selected prompts/output without changing operation impact.
- `-?`: Display installed syntax.

`winrm.cmd help` and `winrm.cmd -?` returned byte-identical localized help on
the recorded build. The 33-byte wrapper invokes `winrm.vbs` through CScript, so
capture can require the console OEM code page rather than PowerShell's current
text encoding; mojibake is not a remote-protocol result.

## Layers to inventory

| Layer | Evidence | Typical failure boundary |
| --- | --- | --- |
| Target identity/name | DNS, SPN, certificate/SAN, `identify` | Alias/IP/workgroup choice changes mutual authentication. |
| Client policy | `winrm/config/client` | Authentication, proxy, timeouts, TrustedHosts, certificate selection. |
| Service policy | `winrm/config/service` | Authentication, encryption requirements, remote access, quotas. |
| Listener | `winrm/config/listener` | HTTP/HTTPS, address filter, port, hostname, certificate thumbprint. |
| Network | profile, route, firewall, port ownership | A listener can exist but remain unreachable or overexposed. |
| Plugin/endpoint | `winrm/config/plugin`, PowerShell session configurations | ACL, architecture/edition, startup, language, resource limits. |
| Shell/operation | `shell/cmd`, events, client/native status | Quotas, idle/lifetime, command, stream, cancellation, audit. |

Diagnose the failing layer before changing any of them. “WinRM cannot complete
the operation” is not authorization to run quick configuration, wildcard trust,
or broad firewall commands.

## `quickconfig` is a change bundle

`winrm quickconfig`/`qc` starts and changes the WinRM service startup behavior,
creates a listener, and enables firewall exceptions. HTTPS quick configuration
also depends on an appropriate local-computer Server Authentication certificate.
Microsoft notes firewall behavior is tied to network profile/configuration.

Before an approved use, export service/listener/firewall/auth/plugin state,
record management sources and policy ownership, choose HTTP versus HTTPS and
name/certificate strategy, define least-privilege endpoint ACLs, and test an
out-of-band recovery path. Prefer centrally reviewed Group Policy/management
configuration for fleets rather than host-by-host `qc` drift.

## Authentication, encryption, and identity

Do not reduce transport security to port numbers. After authentication,
Kerberos/NTLM/CredSSP can provide message-level protection over HTTP; HTTPS adds
TLS endpoint/transport protection. Basic authentication does not supply WinRM
message encryption, and `winrs /unencrypted` explicitly disables message
encryption. Evaluate the exact authentication negotiation, channel, certificate,
service settings, and threat model.

Kerberos normally needs a domain trust and a service name/SPN that matches how
the endpoint is addressed. IP literals, aliases, workgroups, and untrusted
domains can fall back or fail and need a deliberate HTTPS/NTLM/certificate/
credential design. Do not “fix” an SPN/name problem with wildcard trust.

## Common mistakes

### Treating TrustedHosts as a server-side allowlist

TrustedHosts is client configuration used when mutual server authentication
cannot be established. Microsoft explicitly warns that listed computers are not
authenticated and the client might send credential information to them. It
does not decide which clients the remote server authorizes. Keep entries exact
and minimal; never use `*` as a generic remoting fix, and preserve/merge approved
existing values rather than blindly replacing the list.

### Running `quickconfig` before inventory

It changes service, listener, and firewall state. On a workstation, public
network, internet-facing host, hardened server, or centrally managed fleet this
can create exposure or policy drift. Identify intended management sources,
profiles, address filters, authentication, certificate, endpoint ACL, logging,
and rollback first.

### Assuming HTTP means plaintext or HTTPS solves authorization

The negotiated authentication can protect messages over HTTP, while HTTPS does
not grant authorization, correct SPNs/names, safe plugins, or least privilege.
Conversely, Basic or an unencrypted option can remove expected protection.
Capture actual transport/authentication and validate with supported security
guidance instead of inferring from `5985`/`5986` alone.

### Binding HTTPS to the wrong certificate

The certificate must be in the local-computer context, valid, trusted as
required, have Server Authentication usage, match the endpoint hostname through
subject/SAN, and correspond to the listener thumbprint. Renewal can leave an old
binding. Verify chain/revocation/time/private-key access and listener thumbprint;
do not disable certificate checks or use a self-signed certificate by default.

### Changing client configuration on the server by mistake

`winrm/config/client` controls outbound behavior of the machine where it is set;
`winrm/config/service`, listeners, and plugins control inbound behavior there.
Applying TrustedHosts to the remote host does not restrict clients connecting
to it—a recurring practitioner error. Record which host and direction each
configuration belongs to.

### Granting broad endpoint/plugin access

Listener reachability is not command authorization. Plugin/session-configuration
security descriptors, local/group membership, UAC token filtering, JEA, language
mode, and OS resource ACLs still apply. Do not grant Administrators or weaken an
SDDL merely to clear Access Denied; design narrowly scoped endpoints and audit.

### Treating CredSSP or delegation as a routine second-hop fix

Default Kerberos/NTLM remoting avoids placing reusable credentials on the remote
host, so access from that host to a third resource can fail. CredSSP/delegation
changes credential exposure and compromise impact. Prefer resource-specific
delegation, JEA/run-as/service identity, or redesign after security review; do
not enable CredSSP fleet-wide from a troubleshooting snippet.

### Editing quotas and timeouts until an operation passes

Envelope, memory, process, concurrent-operation, idle, and shell quotas protect
availability. Increasing them can create denial-of-service/resource pressure
while hiding a runaway command. Correlate events, plugin/shell identity,
payload/runtime, cancellation, and server capacity before a bounded change.

### Parsing configuration text as a stable schema

WinRM output and error messages can be localized and contain URI, selector,
certificate, identity, and policy data. Preserve raw output with host/build/
locale/time and native status. Prefer WSMan cmdlets/APIs for structured work,
but account for PowerShell edition/platform availability.

### Decoding localized output with the wrong code page

The VBScript host can emit localized text in the console OEM code page. If the
PowerShell host advertises a different `[Console]::OutputEncoding`, readable
output can become mojibake before a parser sees it. Inspect `chcp.com`, the
current culture's OEM code page, and the host encoding. For one bounded capture,
temporarily align `[Console]::OutputEncoding` with
`[Text.Encoding]::GetEncoding((Get-Culture).TextInfo.OEMCodePage)` inside
`try`/`finally`, then restore the exact prior encoding. Prefer WSMan APIs for
durable structured automation instead of making localized text a schema.

## PowerShell boundaries

Call `winrm.cmd` explicitly. Its resource URIs, selectors, and `@{key="value"}`
write syntax pass through PowerShell and WinRM parsing layers; examples copied
from cmd can misquote in PowerShell. Do not use `Invoke-Expression`. Capture
stdout/stderr and `$LASTEXITCODE` immediately and protect configuration output.

For PowerShell Remoting, prefer `Test-WSMan`, `Get-WSManInstance`,
`Get-PSSessionConfiguration`, and the documented `Invoke-Command`/PSSession
workflow where supported. A successful `identify` proves a WSMan response, not
that a specific PowerShell endpoint, credential, language, module, or second hop
will work.

## Version and platform differences

`winrm.cmd`, its `winrm.vbs` implementation, and the Windows WinRM service are
Windows-specific. Defaults,
commands/resources, firewall rules, authentication, TLS/certificate behavior,
plugins, quotas, and PowerShell endpoint registration vary by Windows/WMF build,
edition, network profile, domain/workgroup, policy, and PowerShell edition.

## Runtime evidence

The protected local-help fixture found the 33-byte System32 `winrm.cmd`,
verified that it delegates to adjacent `winrm.vbs` through `cscript //nologo`,
and captured `winrm.cmd help` under both installed PowerShell editions. Each
returned status `0`, 30 nonempty stdout lines, and no stderr. It supplied no
resource URI, endpoint, host, credential, listener, plugin, shell, service, or
configuration selector and made no WinRM query or change.

## Related documents

- [winrs.exe](winrs.exe.md)
- [sc.exe](sc.exe.md)
- [whoami.exe](whoami.exe.md)

See the separately installed `pwsh7` and `pwsh51` sources for their shell
manuals and edition-specific remoting boundaries.

## Sources and license

This original guide was adapted from Microsoft's official
[WinRM installation/configuration](https://learn.microsoft.com/windows/win32/winrm/installation-and-configuration-for-windows-remote-management),
[PowerShell remoting security](https://learn.microsoft.com/powershell/scripting/security/remoting/winrm-security),
[remote troubleshooting](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_remote_troubleshooting),
and [WinRM HTTPS configuration](https://learn.microsoft.com/troubleshoot/windows-client/system-management-components/configure-winrm-for-https)
references. The TrustedHosts direction error was cross-checked against a
[practitioner question](https://stackoverflow.com/questions/12110355/powershell-winrm-trusted-hosts-not-working).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
