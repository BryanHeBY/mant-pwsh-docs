<!-- mant:tldr:start -->
# rsh

> Identify and replace the retired RSH remote-command client; do not confuse it with PowerShell remoting or SSH.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rsh.

- Check every same-name command without contacting a remote host:

`Get-Command rsh -All -ErrorAction SilentlyContinue | Select-Object CommandType,Name,Source,Version`

- Inspect a resolved executable's publisher signature before attributing it to Windows:

`Get-AuthenticodeSignature -LiteralPath "{{C:\Path\To\rsh.exe}}" | Format-List Status,StatusMessage,SignerCertificate`

- Discover supported encrypted alternatives:

`Get-Command ssh.exe, Enter-PSSession, Invoke-Command, winrs.exe -All -ErrorAction SilentlyContinue`

- Inspect OpenSSH effective configuration without connecting:

`ssh.exe -G "{{host_alias}}"`
<!-- mant:tldr:end -->

# rsh

## Overview

Microsoft's current `rsh` page describes a retired Subsystem for UNIX-based
Applications workflow and mistakenly labels the deprecation warning `rexec`.
It provides no current Windows syntax. Treat the command as legacy and migrate;
do not infer support from the generic applicability banner.

## Common mistakes

### Confusing RSH with SSH

RSH is not encrypted SSH and does not provide modern host-key verification.
Name similarity is not a migration shortcut.

### Confusing it with PowerShell remoting

PowerShell remoting uses WSMan or SSH transports with different authentication,
serialization, endpoint and authorization semantics. `rsh` is unrelated.

### Copying syntax from a Unix implementation

The historical Windows subsystem, third-party ports and Unix clients are not a
single contract. Resolve path/version/help and avoid a remote call; use the
chosen supported replacement's own documentation.

### Trusting host-based files or source address as identity

Legacy RSH trust models are unsafe on modern networks. Do not recreate `.rhosts`
or privileged-source-port exceptions to keep an obsolete workflow alive.

## PowerShell behavior

`rsh` may resolve to an unrelated executable. Use `Get-Command -All` and never
pass remote command text until the implementation and transport are proven.
Prefer structured PowerShell remoting or explicit `ssh.exe` quoting guidance.

## Version and platform differences

The referenced Windows subsystem is retired, and current availability is not
guaranteed. Microsoft's page has an internal `rexec` wording inconsistency;
local evidence outranks its broad applicability banner.

## Related documents

- [rexec](rexec.md)
- OpenSSH: query `mant ssh --source cross-platform-tools`.
- [winrs](winrs.md)
- [winrm](winrm.md)

## Sources and license

This original migration guide was adapted from Microsoft's official
[rsh reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rsh),
including its current deprecation and retired-subsystem caveats.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
