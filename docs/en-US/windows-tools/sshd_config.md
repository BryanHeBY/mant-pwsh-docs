<!-- mant:tldr:start -->
# sshd_config

> Configure Microsoft OpenSSH Server authentication, listeners, sessions, and subsystems on Windows.
> More information: https://learn.microsoft.com/windows-server/administration/openssh/openssh-server-configuration.

- Locate the default Windows server configuration:

`$config = "$env:ProgramData\ssh\sshd_config"; Get-Item -LiteralPath $config`

- Validate the selected file before restarting `sshd`:

`sshd.exe -t -f "$env:ProgramData\ssh\sshd_config"`

- Print effective settings for a simulated user and client address:

`sshd.exe -T -C "user={{user}},host={{host}},addr={{client-ip}}"`

- Read the normalized heading node for the authorized-key directive:

`mant sshd_config --source windows-tools --node=authorizedkeysfile`

- Restart the service only after validation, then inspect its listeners:

`Restart-Service sshd; $service = Get-CimInstance Win32_Service -Filter "Name='sshd'"; Get-NetTCPConnection -OwningProcess $service.ProcessId -State Listen`
<!-- mant:tldr:end -->

# sshd_config

## Overview

On Windows, Microsoft OpenSSH Server reads
`%ProgramData%\ssh\sshd_config` when the `sshd` service starts. Relative paths
are interpreted by OpenSSH in the applicable account or program-data context,
not relative to the caller's current PowerShell directory. A service restart
is required after a file change.

Treat the file as privileged configuration. Back it up, edit from a local or
recoverable session, validate it with `sshd.exe -t`, inspect connection-specific
results with `sshd.exe -T -C`, restart, and then verify the actual listener and
authentication path.

## Important directives

ManT 0.7.1 cannot represent prefixless configuration keywords as option-role
entries. Each directive is therefore a heading node with a normalized
lower-case ID, so queries such as `--node=authorizedkeysfile` remain available
without falsely classifying the keyword as a command.

### Port

`Port PORT` selects a listening port. It is repeatable where supported, but a
port specified in `ListenAddress` can further specialize or override listener
construction.

### ListenAddress

`ListenAddress ADDRESS` binds one local address, optionally with a port. Repeat
it for multiple listeners.

### AddressFamily

`AddressFamily FAMILY` restricts listeners to `any`, `inet`, or `inet6`.

### HostKey

`HostKey FILE` selects a protected server host private key.

### PubkeyAuthentication

`PubkeyAuthentication yes|no` enables or disables public-key authentication.

### PasswordAuthentication

`PasswordAuthentication yes|no` enables or disables password authentication.
Confirm a working key path before disabling the last fallback.

### AuthenticationMethods

`AuthenticationMethods METHODS` requires supported authentication method
combinations. Windows OpenSSH has a narrower authentication surface than
portable Unix deployments.

### AuthorizedKeysFile

`AuthorizedKeysFile FILE` selects one or more public-key authorization files,
normally relative to the authenticating user's profile unless an absolute or
program-data path is used.

### AllowUsers

`AllowUsers PATTERNS` allows only matching user names or `USER@HOST` patterns
after deny processing.

### AllowGroups

`AllowGroups PATTERNS` allows only members of matching lower-case group
patterns after user rules.

### DenyUsers

`DenyUsers PATTERNS` denies matching users before allow-user and group
processing.

### DenyGroups

`DenyGroups PATTERNS` denies members of matching groups before allow-group
processing.

### Match

`Match CONDITIONS` begins a conditional block whose following supported
directives apply only to matching connections.

### Subsystem

`Subsystem NAME COMMAND` defines a subsystem such as SFTP. The in-box Windows
configuration normally points `sftp` to `sftp-server.exe`.

### ForceCommand

`ForceCommand COMMAND` forces a command or internal subsystem for matching
sessions. Test its effect on interactive shells, file transfer, and VS Code
Remote-SSH.

### ChrootDirectory

`ChrootDirectory DIRECTORY` constrains supported SFTP workflows. Windows does
not apply it as a general interactive-shell filesystem jail.

### SyslogFacility

`SyslogFacility FACILITY` selects the Windows event-log path for ordinary
facilities or file logging with `LOCAL0`.

### LogLevel

`LogLevel LEVEL` selects server log verbosity. Debug levels can expose account,
path, and connection metadata.

### MaxSessions

`MaxSessions COUNT` limits open shell, login, or subsystem sessions per network
connection.

### MaxStartups

`MaxStartups START:RATE:FULL` limits concurrent unauthenticated connections.

## Safe change workflow

Run the workflow from an elevated PowerShell session with local console access
or another recovery path:

```powershell
$config = "$env:ProgramData\ssh\sshd_config"
$backup = "$config.bak"
$sshd = "$env:WINDIR\System32\OpenSSH\sshd.exe"

Copy-Item -LiteralPath $config -Destination $backup
notepad.exe $config

& $sshd -t -f $config
if ($LASTEXITCODE -ne 0) {
    throw 'Do not restart sshd: configuration validation failed.'
}

Restart-Service sshd
Get-Service sshd
```

Validation does not prove reachability. Inspect the service-owned listener and
test from the intended client network after every listener or firewall change.

## Authorized keys on Windows

For an ordinary effective `AuthorizedKeysFile .ssh/authorized_keys`, OpenSSH
looks below the authenticating user's profile, for example
`C:\Users\builduser\.ssh\authorized_keys`.

Microsoft's default Windows configuration commonly adds a conditional block
for administrators that redirects the key file to
`%ProgramData%\ssh\administrators_authorized_keys`. A customized file can
remove or override that block, so membership in Administrators is not enough
to predict the path. Ask the installed parser:

```powershell
sshd.exe -T -C 'user=builduser,host=devhost,addr=192.0.2.25' |
    Select-String '^authorizedkeysfile\b'
```

The administrator-wide file must be protected so that only `SYSTEM` and the
built-in Administrators group have the intended access. Microsoft's example
uses `icacls.exe`; localized Windows group names can differ, so inspect the
resulting owner and access entries rather than assuming a translated command
succeeded. User-specific public-key files must likewise reject unrelated
writers. Never copy the private half of a client key to the server.

## Authentication and account boundaries

Microsoft documents `password` and `publickey` as the principal Windows
OpenSSH authentication methods. Microsoft Entra identities are not accepted
as a separate OpenSSH authentication method. Domain and local account naming,
group matching, home-directory resolution, and token privileges can differ;
evaluate the exact intended identity with `-T -C` and a real client login.

Before setting `PasswordAuthentication no`, establish and test at least one
public key from the actual client. `authorized_keys` existing is not proof
that the client's offered key matches or that its ACL is accepted.

## Listener and firewall alignment

Changing `Port` or `ListenAddress` does not update Windows Defender Firewall.
After a validated restart, compare all three layers:

```powershell
sshd.exe -T | Select-String '^(port|listenaddress)\b'

$service = Get-CimInstance Win32_Service -Filter "Name='sshd'"
Get-NetTCPConnection -OwningProcess $service.ProcessId -State Listen

Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' |
    Get-NetFirewallPortFilter
```

Also compare the firewall rule's profile with `Get-NetConnectionProfile`.
A rule for port 22 on the Private profile does not admit a server listening on
a different port over an interface currently classified Public.

## Default shell and subsystems

The default interactive Windows SSH shell is selected outside this file by the
`DefaultShell` string value below `HKLM\SOFTWARE\OpenSSH`. Changing it affects
SSH users broadly, requires an elevated process, and is not required for VS
Code Remote-SSH. Use a stable full executable path, refresh `sshd`, validate
new ordinary SSH, interactive, SFTP, and VS Code sessions after a change, and
remember that startup scripts can emit text that breaks machine protocols.
Query `mant openssh-server --source windows-tools
--node=optional-powershell-default-shell` for the PowerShell 7 procedure and
rollback.

The `Subsystem sftp` directive is independent from the interactive shell.
Do not remove or replace it merely to change the shell used by login sessions.

## Common mistakes

### Editing the client configuration

`%UserProfile%\.ssh\config` configures a client. The server reads
`%ProgramData%\ssh\sshd_config`. Similar option names do not make the files
interchangeable.

### Checking only global output when `Match` is present

Plain `sshd.exe -T` cannot model every connection. Supply `user`, `host`, and
`addr` with `-C` when conditional key paths or access rules matter.

### Reusing Unix-only recipes unchanged

Paths, account lookup, ACLs, service control, logging, default shell selection,
and the set of supported directives differ on Windows. Confirm each directive
with the installed build and Microsoft's Windows-specific page.

### Publishing a custom port without matching policy

A high port does not replace authentication or firewall scoping. Align the
listener, firewall port, firewall profile, client `Port`, and any NAT or VPN
policy, then test from the actual client network.

## Version and platform differences

The portable OpenSSH manual defines the broad directive grammar. Microsoft's
in-box Windows build does not implement every portable directive and adds
Windows-specific paths, account behavior, service integration, registry shell
selection, ETW logging, and ACL requirements. Windows Update can change the
installed OpenSSH version; validate the current file after servicing.

## Runtime evidence

On Windows NT `10.0.26200.0` with in-box OpenSSH for Windows `9.5p2`, the
default-path configuration passed `sshd.exe -t`. `sshd.exe -T` returned
matching IPv4 and IPv6 listeners on a nondefault port, and the running service
owned corresponding TCP sockets. Exact local authentication settings, key
paths, addresses, and port values are intentionally not retained in the public
guide.

This was a read-only inspection of selected effective values. It did not print
keys, change ACLs, edit configuration, restart the service, mutate firewall or
network profiles, or prove that any particular remote client's key is
authorized.

## Related documents

- [sshd.exe](sshd.exe.md)
- [OpenSSH Server on Windows](openssh-server.md)
- [services.msc](services.msc.md)
- [sc.exe](sc.exe.md)
- For the client, query `mant ssh --source cross-platform-tools`.

## Sources and license

This original guide was independently adapted from Microsoft's
[OpenSSH Server configuration for Windows](https://learn.microsoft.com/windows-server/administration/openssh/openssh-server-configuration),
[key-based authentication guide](https://learn.microsoft.com/windows-server/administration/openssh/openssh_keymanagement),
and the [OpenBSD sshd_config manual](https://man.openbsd.org/sshd_config.5).
Microsoft Learn content is licensed under CC BY 4.0. The OpenBSD manual uses
its cited BSD-style license. The adaptation adds Windows PowerShell workflow,
ManT semantic entries, cross-layer diagnostics, and bounded runtime evidence.
