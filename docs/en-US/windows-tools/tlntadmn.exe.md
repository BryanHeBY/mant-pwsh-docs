<!-- mant:tldr:start -->
# tlntadmn.exe

> Inventory a legacy Windows Telnet Server configuration and sessions without enabling or reconfiguring it.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tlntadmn.

- Resolve the optional legacy administration tool without installing anything:

`Get-Command tlntadmn.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Display current local Telnet Server settings without changing them:

`tlntadmn.exe`

- Display settings on one exact legacy server using the current authorized identity:

`tlntadmn.exe "{{TELNET01}}"`

- List active Telnet sessions on that exact server without ending them:

`tlntadmn.exe "{{TELNET01}}" -s all`
<!-- mant:tldr:end -->

# tlntadmn.exe

## Overview

`tlntadmn.exe` administers the legacy Windows Telnet Server Service. No
arguments displays settings. It can start/stop/pause the service, list/end/
message sessions, and change domain, timeout, connection, port, authentication
and console/stream settings. Telnet does not provide modern transport security.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `tlntadmn.exe`: Inspect or administer a legacy local or remote Telnet Server.
- `start`: Start the Telnet Server service and accept configured connections.
- `stop`: Stop the Telnet Server service.
- `pause`: Stop accepting new Telnet connections until `continue` resumes them.
- `continue`: Resume a paused Telnet Server service.
- `config`: Change legacy domain, timeout, connection, port, auth, or mode settings.

Equals-bearing config fields such as `timeout=` and `port=` remain in prose
because ManT cannot yet index that native token shape.

<!-- mant:entries role=option case=insensitive -->
- `-u`: Select an alternate remote administrative username.
- `-p`: Supply its password inline and expose the secret to process/log inspection.
- `-s`: Display one or all active Telnet sessions.
- `-k`: End one or all Telnet sessions.
- `-m`: Send a message to one or all Telnet sessions.
- `-?`: Display installed syntax.

## Common mistakes

### Enabling password authentication over plaintext Telnet

`config sec +passwd` does not encrypt credentials or session content. Do not
expose Telnet to untrusted networks; migrate administration to SSH or WinRM.

### Using start/config as a feature-discovery test

Resolve the binary, feature/service state and current settings without starting
the server or opening firewall access. A missing/disabled service is not a
reason to enable it merely for documentation validation.

### Using `-k all` or `-m all` casually

They terminate or message every session. Bind one current session ID to user,
client, start time and change owner; preserve evidence and warn affected users.

### Omitting the remote computer

The default target is local. Always record exact server identity for remote
inventory and verify that the current token has only the required rights.

### Passing `-p` inline

Administrative passwords can leak in process listings, transcripts and logs.
Use the current authorized identity; do not copy plaintext-shaped official
syntax into automation.

### Treating NTLM as transport encryption

Authentication method and channel confidentiality are separate. Even if NTLM
authenticates, Telnet session bytes lack SSH/TLS-style protection.

## PowerShell boundaries

Call `tlntadmn.exe` explicitly, quote messages/identities and check
`$LASTEXITCODE`. Output is text. `+`/`-` authentication flags must reach the
native tool as intended; do not construct them from untrusted input.

## Version and platform differences

Windows-only and legacy-feature dependent. Broad Microsoft Learn applicability
does not prove Telnet Server availability on a current image. Feature, service,
authentication and firewall policy vary by edition/build.

## Related documents

- [telnet.exe](telnet.exe.md)
- OpenSSH: query `mant ssh --source cross-platform-tools`.
- [winrm.exe](winrm.exe.md)
- [winrs.exe](winrs.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tlntadmn reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tlntadmn).
Operational demand to distinguish an installed client from insecure Telnet use
was cross-checked against practitioner questions about
[installed-client risk](https://serverfault.com/questions/916875/is-there-a-security-risk-to-just-having-the-telnet-client-installed-on-windows)
and [listing and ending Windows Telnet sessions](https://serverfault.com/questions/610794/show-users-connected-to-windows-telnet-server).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
