<!-- mant:tldr:start -->
# telnet.exe

> Inspect the optional Telnet Client without opening a plaintext session; use
> SSH or a protocol-aware TLS client for authenticated administration.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/telnet.

- Check whether the optional Telnet Client feature is enabled:

`Get-WindowsOptionalFeature -Online -FeatureName TelnetClient | Format-List FeatureName, State`

- Resolve the client without enabling it:

`Get-Command telnet.exe -All -ErrorAction SilentlyContinue | Format-List Source, Version`

- Display target-local syntax without connecting:

`telnet.exe /?`

- Test only TCP reachability to an approved host/port without Telnet negotiation or credentials:

`Test-NetConnection -ComputerName "{{host}}" -Port {{port}} -InformationLevel Detailed`

<!-- mant:tldr:end -->

# telnet.exe

## Overview

`telnet.exe` is the optional Windows Telnet Client. With no parameters it opens
the `Microsoft telnet>` client context. It can connect to a host/port, select a
terminal type, choose an escape character, attempt username logon and write a
client-side transcript.

Telnet does not provide the authenticated encryption expected for modern remote
administration. Do not send passwords, tokens, commands or sensitive output
over an untrusted network. Use SSH or the application's documented TLS protocol.
Keep Telnet only for an approved legacy device inside a segmented network.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `telnet.exe`: Start the optional Microsoft Telnet client or connect to one endpoint.

Without a host, the executable enters its interactive client context; supplied
ports still use Telnet rather than becoming protocol-neutral probes.

<!-- mant:entries role=option case=insensitive -->
- `/a`: Attempt logon with the current Windows username.
- `/e`: Select the character that enters the local Telnet prompt.
- `/f`: Write a client-side transcript to the named file.
- `/l`: Supply the username sent during Telnet logon.
- `/t`: Select terminal emulation: `vt100`, `vt52`, `ansi`, or `vtnt`.
- `/?`: Display installed syntax.

## Common mistakes

### Installing Telnet Client just to check a TCP port

Use `Test-NetConnection` or approved network telemetry for TCP reachability.
That result proves only a TCP handshake, not application protocol, banner,
authentication, TLS, authorization or health. Feature installation is a separate
servicing/security decision and must not be hidden inside diagnostics.

### Using Telnet against HTTP, SMTP, database, or TLS ports as a neutral probe

Telnet can send negotiation bytes and interactive keystrokes; protocol servers
may interpret them as malformed or state-changing input. For TLS it cannot
validate a certificate or encrypted exchange. Use a protocol-aware read-only
health check with bounded input/output and an explicit target.

### Sending credentials because `/a` or `/l` exists

`/a` supplies the current username and `/l` supplies a username; neither adds
encryption or trustworthy server identity. Avoid all secrets. Never weaken
authentication or expose a Telnet server to make the client useful.

### Logging a session with `/f` without a data review

Transcripts can contain credentials, commands, banners, personal data and
device configuration. Use a protected new path, restrictive ACLs, retention and
redaction rules; do not collect secrets merely for evidence.

### Losing control of the interactive session

The escape character returns to the client prompt and can collide with protocol
input. Define it deliberately, know the disconnect/quit path, set an external
timeout, and do not run Telnet in unattended pipelines that can block forever.

### Treating terminal type as server capability

`vt100`, `vt52`, `ansi`, and `vtnt` affect terminal negotiation/presentation.
They do not add encoding correctness, binary safety, authentication or shell
compatibility. Unexpected control sequences and banners are untrusted display
data.

## PowerShell boundaries

Invoke `telnet.exe` explicitly. It is interactive and not a structured PowerShell
pipeline producer. Use `Test-NetConnection` for a bounded TCP handshake and
`ssh.exe` for approved encrypted remote shells. Capture transcripts only under
the relevant security/data policy.

## Version and platform differences

Telnet Client is an optional Windows feature. Availability, feature servicing,
terminal behavior, console host, encoding and server negotiation vary by build
and endpoint. Microsoft documents TCP 23 as the default but any supplied port
still speaks through a Telnet client, not a generic TLS client.
Exact System32 discovery on the recorded Windows NT `10.0.26200.0` Home China
client found no `telnet.exe`; do not substitute a PATH match or enable the
optional feature merely for documentation evidence.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found telnet.exe absent; no PATH substitute, feature enablement,
negotiation, input, credential, or transcript ran. Optional-feature/help and
approved TCP reachability remain pending where already installed.

## Related documents
- OpenSSH: query `mant ssh --source cross-platform-tools`.
- [winrs.exe](winrs.exe.md)
- [winrm.cmd](winrm.cmd.md)
- [pktmon.exe](pktmon.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Telnet reference](https://learn.microsoft.com/windows-server/administration/windows-commands/telnet)
and its optional-client installation boundary. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
