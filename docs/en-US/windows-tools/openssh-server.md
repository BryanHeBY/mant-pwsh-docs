<!-- mant:tldr:start -->
# openssh-server

> Install, enable, expose, authenticate, and verify Microsoft OpenSSH Server for Windows remote development.
> More information: https://learn.microsoft.com/windows-server/administration/openssh/openssh_install_firstuse.

- Inventory the in-box client and server capabilities:

`Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH.*' | Select-Object Name, State`

- Install the server capability from an elevated PowerShell session:

`Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0'`

- Start the server and configure automatic startup:

`Start-Service sshd; Set-Service -Name sshd -StartupType Automatic`

- Validate configuration and inspect service-owned listeners:

`sshd.exe -t; $service = Get-CimInstance Win32_Service -Filter "Name='sshd'"; Get-NetTCPConnection -OwningProcess $service.ProcessId -State Listen`

- Test the final address and port from the client before opening VS Code:

`ssh -p {{port}} {{user}}@{{host}}`
<!-- mant:tldr:end -->

# OpenSSH Server on Windows

## Overview

This workflow prepares a Windows computer as an SSH host for terminals, file
transfer, automation, and Visual Studio Code Remote-SSH. Complete each layer
in order: capability, service, configuration, listener, firewall and network
profile, authentication, client SSH, then VS Code. Keep the client and server
evidence separate so a failure is assigned to the correct layer.

## 1. Inventory and install

Run the inventory first:

```powershell
Get-WindowsCapability -Online |
    Where-Object Name -Like 'OpenSSH.*' |
    Select-Object Name, State
```

If `OpenSSH.Server~~~~0.0.1.0` is `NotPresent`, install it from an elevated
PowerShell session:

```powershell
Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0'
```

DISM exposes the same Windows capability family when cmdlets are unavailable:

```powershell
dism.exe /Online /Get-CapabilityInfo /CapabilityName:OpenSSH.Server~~~~0.0.1.0
dism.exe /Online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0
```

Retain `RestartNeeded` or the DISM exit code and complete a deliberate restart
when Windows servicing requests it.

## 2. Enable and inspect the service

The installation normally registers `sshd` and creates a port-22 firewall
rule. Configure the service from an elevated session:

```powershell
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic

Get-Service sshd | Select-Object Name, Status, StartType
Get-CimInstance Win32_Service -Filter "Name='sshd'" |
    Select-Object Name, State, StartMode, ProcessId, PathName
```

Do not recreate the service manually when the supported Windows capability
installer can repair or reinstall it.

## 3. Validate configuration and listeners

The default server file is `%ProgramData%\ssh\sshd_config`. Validate before a
restart and inspect the effective values afterward:

```powershell
$sshd = "$env:WINDIR\System32\OpenSSH\sshd.exe"
& $sshd -t
if ($LASTEXITCODE -ne 0) {
    throw 'sshd configuration validation failed.'
}

& $sshd -T |
    Select-String '^(port|listenaddress|authorizedkeysfile|pubkeyauthentication|passwordauthentication)\b'
```

The actual socket is decisive:

```powershell
$service = Get-CimInstance Win32_Service -Filter "Name='sshd'"
Get-NetTCPConnection -OwningProcess $service.ProcessId -State Listen |
    Select-Object LocalAddress, LocalPort, OwningProcess
```

## 4. Align firewall and network profile

Inspect the current layers without changing them:

```powershell
Get-NetConnectionProfile |
    Select-Object InterfaceAlias, Name, NetworkCategory, IPv4Connectivity

$port = '{{ssh-port}}'
$allRules = @(Get-NetFirewallRule -PolicyStore ActiveStore)
$namedRules = @($allRules | Where-Object {
    $_.Name -match '(?i)ssh' -or $_.DisplayName -match '(?i)ssh'
})
$portRules = @(Get-NetFirewallPortFilter -PolicyStore ActiveStore |
    Where-Object { $port -in @($_.LocalPort) } |
    Get-NetFirewallRule)
$candidateRules = @($namedRules + $portRules |
    Sort-Object InstanceID -Unique)

$candidateRules |
    Select-Object Name, DisplayName, Enabled, Profile, Direction, Action,
        PrimaryStatus, EnforcementStatus, PolicyStoreSource

$candidateRules | Get-NetFirewallPortFilter
```

Do not stop at the installer-created rule name. Administrators, WSL tooling,
VPN products, or prior automation can create differently named multi-port
rules that already cover the listener. Querying only
`OpenSSH-Server-In-TCP` can therefore produce a false firewall diagnosis.
Use `ActiveStore` for effective policy and inspect `PersistentStore` or group
policy sources separately when provenance matters.

For a trusted LAN, classify the intended interface Private and align the
existing rule with the effective SSH port:

```powershell
Set-NetConnectionProfile -InterfaceAlias '{{interface}}' -NetworkCategory Private

Set-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' `
    -Enabled True -Profile Private -Protocol TCP -LocalPort {{port}}
```

If the interface must remain Public, create a separate narrow rule for the
required client subnet instead of changing every Public-network policy:

```powershell
New-NetFirewallRule `
    -Name 'OpenSSH-Server-LAN' `
    -DisplayName 'OpenSSH Server - approved LAN' `
    -Enabled True `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort {{port}} `
    -RemoteAddress '{{client-subnet}}' `
    -Profile Public `
    -Action Allow
```

Changing to a nonstandard port reduces background scanning noise but is not an
authentication control. Avoid direct Internet port forwarding for routine
development; prefer an approved VPN or private overlay network.

## 5. Configure public-key authentication

Generate a client key on the computer running VS Code:

```powershell
ssh-keygen -t ed25519
Get-Content "$HOME\.ssh\id_ed25519.pub"
```

Copy only the complete public-key line to the server. For an effective
user-relative key path, append it without overwriting existing keys:

```powershell
$publicKey = '{{complete ssh-ed25519 public-key line}}'
$authorizedKeys = "$HOME\.ssh\authorized_keys"

New-Item -ItemType Directory -Force (Split-Path $authorizedKeys) |
    Out-Null

if (!(Test-Path $authorizedKeys) -or
    $publicKey -notin (Get-Content $authorizedKeys)) {
    Add-Content -LiteralPath $authorizedKeys -Value $publicKey
}
```

If the effective path is `%ProgramData%\ssh\administrators_authorized_keys`,
use that file and Microsoft's required ACL instead. Do not select a path based
only on group membership; confirm it for the intended user:

```powershell
sshd.exe -T -C 'user={{user}},host={{host}},addr={{client-ip}}' |
    Select-String '^authorizedkeysfile\b'
```

Keep password authentication available only as deliberately required. Before
disabling it, verify a fresh SSH session using the actual client key.

## 6. Verify from the client

Test the network and SSH separately from the computer that will run VS Code:

```powershell
Test-NetConnection {{host}} -Port {{port}}
ssh -vv -p {{port}} {{user}}@{{host}}
```

The first connection requires an explicit host-key trust decision. Verify the
fingerprint through a separate trusted channel; do not automatically suppress
a changed host key.

For a repeatable connection, add a client-side SSH config entry:

```sshconfig
Host windows-dev
    HostName 192.0.2.10
    User builduser
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

Confirm the resolved client configuration without connecting:

```powershell
ssh -G windows-dev |
    Select-String '^(hostname|user|port|identityfile) '
```

## 7. Connect Visual Studio Code

Install Visual Studio Code and the Remote-SSH extension on the client. The
Windows host does not need an existing VS Code desktop installation. First
prove that `ssh windows-dev` works, then run `Remote-SSH: Connect to Host...`
and select the same alias.

If platform detection fails, map the alias to Windows in client settings:

```json
{
  "remote.SSH.remotePlatform": {
    "windows-dev": "windows"
  }
}
```

VS Code installs and manages its remote server component after SSH succeeds.
Initial installation or extension downloads can require outbound HTTPS. Use
the Remote-SSH output channel to distinguish transport/authentication failures
from VS Code Server download or startup failures.

## Optional PowerShell default shell

Windows OpenSSH selects the default interactive shell from the `DefaultShell`
string value below `HKLM\SOFTWARE\OpenSSH`. PowerShell 7 can be selected from
an elevated session:

```powershell
New-ItemProperty `
    -Path 'HKLM:\SOFTWARE\OpenSSH' `
    -Name DefaultShell `
    -Value 'C:\Program Files\PowerShell\7\pwsh.exe' `
    -PropertyType String `
    -Force
```

This change affects SSH users broadly and is optional for VS Code Remote-SSH.
Validate ordinary commands, interactive sessions, SFTP, and VS Code after the
change; shell startup output can break machine-oriented protocols.

## Troubleshooting map

| Symptom | Inspect first | Typical mismatch |
| --- | --- | --- |
| Connection timed out | Client route, server listener, firewall profile and remote-address scope | Client cannot reach the interface or policy drops the port |
| Connection refused | Service-owned listeners and effective port | `sshd` is stopped or not bound to the requested address/port |
| `Permission denied (publickey)` | `sshd.exe -T -C`, offered client key, key-file ACL, event log | Wrong authorized-key path, unmatched key, or rejected ACL |
| Service runs but remote connection fails | Listener port versus firewall port and profile | Service state was mistaken for reachability |
| VS Code fails after shell SSH succeeds | Remote-SSH output and outbound HTTPS | VS Code Server download, platform detection, proxy, or startup problem |

Read recent server diagnostics with:

```powershell
Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 30 |
    Select-Object TimeCreated, Id, LevelDisplayName, Message
```

## Version and platform differences

OpenSSH Server is a Windows optional capability on supported Windows client
and server releases. Capability availability, in-box OpenSSH version, restart
requirements, directives, and firewall defaults vary with Windows servicing.
VS Code Remote-SSH support and download requirements also evolve; check the
current official Remote-SSH page when deployment behavior changes.

## Runtime evidence

On Windows NT `10.0.26200.0`, both in-box OpenSSH capabilities were installed.
The System32 `sshd.exe` was OpenSSH for Windows `9.5p2`; its configuration
passed `-t`, its service was running with Automatic start, and it owned matching
IPv4 and IPv6 listeners on a nondefault port.

An initial rule-name-only inspection found that the installer-created
`OpenSSH-Server-In-TCP` rule did not match the active listener and network
profile. That result was real but incomplete: a subsequent port-based
`ActiveStore` inventory found a differently named enabled local rule that
covered the listener port and reported primary status `OK` plus an `Enforced`
status. Another matching custom rule was disabled. Therefore the listener was
already admitted by effective policy; the default-rule mismatch was not a
connection blocker.

Two running WSL2 distributions then completed `ssh-keyscan` probes against the
Windows listener with status `0`, confirming TCP reachability without retaining
the local address, port, distribution names, host keys, or authentication
policy. No matching retained firewall-change event identified when the custom
rules were created or disabled. No capability, service, configuration, key,
ACL, firewall, registry, network-profile, or WSL state was changed for this
evidence.

## Related documents

- [sshd.exe](sshd.exe.md)
- [sshd_config](sshd_config.md)
- [dism.exe](dism.exe.md)
- [sc.exe](sc.exe.md)
- [services.msc](services.msc.md)
- [netsh.exe](netsh.exe.md)
- For the client, query `mant ssh --source cross-platform-tools`.

## Sources and license

This original workflow was independently adapted from Microsoft's
[OpenSSH Server installation guide](https://learn.microsoft.com/windows-server/administration/openssh/openssh_install_firstuse),
[Windows server configuration guide](https://learn.microsoft.com/windows-server/administration/openssh/openssh-server-configuration),
[key-management guide](https://learn.microsoft.com/windows-server/administration/openssh/openssh_keymanagement),
and Visual Studio Code's
[Remote Development using SSH](https://code.visualstudio.com/docs/remote/ssh).
Microsoft Learn material is licensed under CC BY 4.0. Visual Studio Code and
Remote-SSH are subject to Microsoft's applicable product and extension
licenses. This adaptation adds a cross-layer Windows verification sequence,
ManT quick reference, and bounded local runtime evidence.
