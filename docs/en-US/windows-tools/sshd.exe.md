<!-- mant:tldr:start -->
# sshd.exe

> Validate and diagnose the Windows OpenSSH Server daemon from PowerShell.
> More information: https://man.openbsd.org/sshd.8.

- Validate the default server configuration and host keys without starting a listener:

`sshd.exe -t`

- Print the effective server configuration after validation:

`sshd.exe -T`

- Evaluate `Match` rules for one simulated connection:

`sshd.exe -T -C "user={{user}},host={{host}},addr={{client-ip}}"`

- Inspect the Windows service and every TCP listener owned by it:

`$service = Get-CimInstance Win32_Service -Filter "Name='sshd'"; Get-Service sshd; Get-NetTCPConnection -OwningProcess $service.ProcessId -State Listen`

- Read recent Windows OpenSSH operational events:

`Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents {{20}}`
<!-- mant:tldr:end -->

# sshd.exe

## Overview

`sshd.exe` is the OpenSSH server process. The Windows optional capability
normally installs it below `%WINDIR%\System32\OpenSSH` and registers the
`sshd` Windows service. The service accepts SSH connections, authenticates a
Windows account, and starts the configured shell, command, or SFTP subsystem
in that account's context.

Treat command-line test modes, Windows service state, the effective
`sshd_config`, TCP listeners, firewall policy, and successful authentication
as separate evidence. A running service alone does not prove that a client can
reach or log in to the server.

## Syntax

```text
sshd.exe [-46DdeGiqTtV] [-C CONNECTION_SPEC] [-c HOST_CERTIFICATE_FILE]
         [-E LOG_FILE] [-f CONFIG_FILE] [-g LOGIN_GRACE_TIME]
         [-h HOST_KEY_FILE] [-o OPTION] [-p PORT] [-u LENGTH]
```

## Important options

<!-- mant:entries role=option case=sensitive -->
- `-4`: Listen using IPv4 only.
- `-6`: Listen using IPv6 only.
- `-C CONNECTION_SPEC`: Supply simulated connection attributes for `-T`, such as `user`, `host`, `addr`, `laddr`, or `lport`, so matching configuration can be evaluated without accepting a connection.
- `-c HOST_CERTIFICATE_FILE`: Select a host certificate that corresponds to a configured host key.
- `-D`: Remain in the foreground instead of detaching; use an isolated diagnostic session rather than competing with the service listener.
- `-d`: Enable single-connection debug mode and remain in the foreground; repeat up to three times for greater detail.
- `-E LOG_FILE`: Append debug output to an explicit file instead of the normal logging destination; protect the file and containing directory.
- `-e`: Write debug output to standard error.
- `-f CONFIG_FILE`: Read an explicit configuration file instead of the Windows default `%ProgramData%\ssh\sshd_config`.
- `-G`: Validate, print the effective configuration, and exit; behavior depends on the installed OpenSSH version.
- `-g LOGIN_GRACE_TIME`: Override the time allowed for authentication.
- `-h HOST_KEY_FILE`: Select an explicit host private key; protect its ACL and never expose its contents.
- `-i`: Run in inetd-compatible mode; this is not the ordinary Windows service workflow.
- `-o OPTION`: Set one `sshd_config` directive on the command line; repeat for multiple overrides.
- `-p PORT`: Override listening port unless a `ListenAddress` directive supplies a port that takes precedence.
- `-q`: Suppress ordinary logging.
- `-T`: Perform the extended configuration test, print effective configuration, and exit; combine with `-C` to apply connection-specific `Match` rules.
- `-t`: Check configuration syntax and host-key sanity without starting a listener.
- `-u LENGTH`: Set the remote-host field length used by implementations with `utmp`; it has limited relevance to ordinary Windows service operation.
- `-V`: Print the OpenSSH version and exit.

## PowerShell behavior

Resolve the exact executable before diagnosing a machine that also has Git,
MSYS, Cygwin, or a separately installed Win32-OpenSSH package:

```powershell
Get-Command sshd.exe -All -ErrorAction SilentlyContinue |
    Select-Object Name, Source, Version
```

Validate the configuration before restarting the service. Successful `-t`
usually produces no output, so retain the native exit code:

```powershell
$sshd = "$env:WINDIR\System32\OpenSSH\sshd.exe"
& $sshd -t
if ($LASTEXITCODE -ne 0) {
    throw "sshd configuration validation failed: $LASTEXITCODE"
}
```

Use `-T` for the values that the installed server actually resolved. Add a
connection specification when `Match` blocks can alter authentication or key
paths:

```powershell
& $sshd -T -C 'user=builduser,host=devhost,addr=192.0.2.25' |
    Select-String '^(port|listenaddress|authorizedkeysfile|pubkeyauthentication|passwordauthentication)\b'
```

Do not infer a listening port from the firewall rule or configuration text.
Bind the service to its process and inspect the sockets it owns:

```powershell
$service = Get-CimInstance Win32_Service -Filter "Name='sshd'"
Get-Service sshd | Select-Object Name, Status, StartType
Get-NetTCPConnection -OwningProcess $service.ProcessId -State Listen |
    Select-Object LocalAddress, LocalPort, OwningProcess
```

## Windows service and logging

The ordinary in-box deployment runs `sshd.exe` as the `sshd` service. Query it
with `Get-Service`, CIM, or `sc.exe`; change it only from an elevated session:

```powershell
Get-Service sshd
Get-CimInstance Win32_Service -Filter "Name='sshd'" |
    Select-Object Name, State, StartMode, ProcessId, PathName
```

With the normal Windows logging facility, operational messages are available
through Event Tracing for Windows:

```powershell
Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 20 |
    Select-Object TimeCreated, Id, LevelDisplayName, Message
```

Setting `SyslogFacility LOCAL0` redirects server logging below
`%ProgramData%\ssh\logs`. That directory and its files become protected
server resources; incorrect ACLs can prevent useful diagnostics or break
sessions. Prefer the operational event log for routine inspection.

## Common mistakes

### Using `-?` as help

The recorded Windows build treated `-?` as an unknown option, printed usage to
standard error, and returned `1`. Use `-V`, the installed usage text, this
page, and the authoritative manual; do not classify the usage text as a
successful help result.

### Restarting before validation

A bad configuration can remove remote access. Run `sshd.exe -t`, retain a
local or alternative management path, then restart the service and verify its
new listener.

### Assuming the service port is 22

`Port`, port-bearing `ListenAddress` directives, and command-line overrides
can select another port. Compare `sshd.exe -T`, the service-owned socket, and
the firewall port filter.

### Starting a second debug listener beside the service

Foreground debug mode can collide with an existing listener and runs under a
different token from the LocalSystem service. Stop the service only during a
planned diagnostic window with a recovery path, and do not generalize a
successful interactive debug run to service identity or ACL behavior.

## Version and platform differences

This page targets Microsoft OpenSSH for supported Windows client and server
releases. In-box OpenSSH is serviced with Windows and normally resides under
System32; a GitHub/MSI build can use another location and version. Options and
configuration directives follow the installed OpenSSH build, while service,
event-log, registry, account, and ACL integration are Windows-specific.

## Runtime evidence

On Windows NT `10.0.26200.0`, the in-box executable resolved to
`C:\Windows\System32\OpenSSH\sshd.exe`, fixed file/product version `9.5.6.1`,
and identified itself as `OpenSSH_for_Windows_9.5p2, LibreSSL 3.8.2` with
`-V` on stderr/status `0`. `-?` produced five usage lines on stderr/status `1`.

On the same host, `-t` returned `0` without output and `-T` returned effective
configuration/status `0`. The registered service was running with Automatic
start and owned matching IPv4 and IPv6 listeners on a nondefault port. Exact
local listener and authentication-policy values are intentionally not retained
in the public guide. The inspection did not change configuration, service
state, firewall policy, authorized keys, host keys, registry state, or network
profile, and it did not establish successful remote authentication.

## Related documents

- [sshd_config](sshd_config.md)
- [OpenSSH Server on Windows](openssh-server.md)
- [sc.exe](sc.exe.md)
- [services.msc](services.msc.md)
- [netsh.exe](netsh.exe.md)
- For the client, query `mant ssh --source cross-platform-tools`.

## Sources and license

This original guide was independently adapted from the
[OpenBSD sshd manual](https://man.openbsd.org/sshd.8), Microsoft's
[OpenSSH Server configuration for Windows](https://learn.microsoft.com/windows-server/administration/openssh/openssh-server-configuration),
and Microsoft's
[OpenSSH Server installation guide](https://learn.microsoft.com/windows-server/administration/openssh/openssh_install_firstuse).
The OpenBSD material uses its cited BSD-style license; Microsoft Learn content
is licensed under CC BY 4.0. The adaptation adds Windows and ManT-specific
structure, PowerShell examples, and bounded runtime evidence.
