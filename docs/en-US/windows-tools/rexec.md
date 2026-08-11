<!-- mant:tldr:start -->
# rexec

> Identify and replace the deprecated plaintext-style Rexec remote-command client; do not use it for new automation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rexec.

- Check whether a legacy executable is present without invoking a remote host:

`Get-Command rexec.exe -All -ErrorAction SilentlyContinue | Select-Object CommandType,Source,Version`

- Inspect the resolved file's publisher signature before attributing it to Windows:

`Get-AuthenticodeSignature -LiteralPath "{{C:\Path\To\rexec.exe}}" | Format-List Status,StatusMessage,SignerCertificate`

- Discover supported encrypted remote-command clients instead:

`Get-Command ssh.exe, winrs.exe, pwsh.exe -All -ErrorAction SilentlyContinue`

- Inspect OpenSSH effective destination configuration without connecting:

`ssh.exe -G "{{host_alias}}"`
<!-- mant:tldr:end -->

# rexec

## Overview

Microsoft documents `rexec` only as a deprecated client that runs a command on
a host offering `rexecd`, and says support is not guaranteed. The current page
publishes no syntax. Treat any found binary as legacy/third-party until its
path, signature, version and local help are verified.

## Common mistakes

### Inventing syntax from Unix or old Windows pages

Same-name implementations differ, and Microsoft's current reference no longer
provides a supported contract. Do not generate credential/command examples from
memory or a different vendor's man page.

### Sending credentials or commands over Rexec

The protocol lacks the host identity, confidentiality and integrity expected
of modern administration. Use SSH, WinRM/PowerShell remoting, or another
approved authenticated encrypted transport.

### Treating a TCP connection as authenticated execution

Reachability does not identify the daemon, remote account, authorization,
command shell, encoding, exit status, working directory or audit trail.

### Enabling a daemon to make the client testable

Do not install or expose `rexecd` for compatibility testing. Migrate the
workflow and remove any firewall/service exception through change control.

## PowerShell behavior

PowerShell may resolve a function, alias or third-party executable named
`rexec`; use `Get-Command -All` and an explicit verified path. Remote command
text would cross local PowerShell parsing and a remote shell parser, making
legacy examples especially unsafe.

## Version and platform differences

Deprecated and not guaranteed on current Windows. Subsystem for UNIX-based
Applications guidance belongs to retired Windows generations. Availability of
an unrelated Unix `rexec` does not make this Microsoft page applicable.

## Related documents

- [rsh](rsh.md)
- OpenSSH: query `mant ssh --source cross-platform-tools`.
- [winrs](winrs.md)
- [winrm](winrm.md)

## Sources and license

This original migration guide was adapted from Microsoft's official
[deprecated rexec notice](https://learn.microsoft.com/windows-server/administration/windows-commands/rexec).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
