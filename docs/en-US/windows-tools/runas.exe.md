<!-- mant:tldr:start -->
# runas.exe

> Start a program using credentials for another Windows account.
> More information: https://learn.microsoft.com/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc771525(v=ws.11).

- Run a program as a local account and enter its password at the prompt:

`runas.exe /user:{{computer\user}} "{{program.exe arguments}}"`

- Use credentials only for remote resource access:

`runas.exe /netonly /user:{{domain\user}} "{{program.exe arguments}}"`

- List supported trust levels without launching a program:

`runas.exe /showtrustlevels`

- Run without loading the target user's profile when the application contract permits it:

`runas.exe /noprofile /user:{{domain\user}} "{{program.exe arguments}}"`

- Preserve the caller's environment variables while changing the security principal:

`runas.exe /env /user:{{domain\user}} "{{program.exe arguments}}"`

- Open a Command Prompt as another account and enter its password interactively:

`runas.exe /user:{{domain\user}} "cmd.exe /d"`
<!-- mant:tldr:end -->

# runas.exe

## Overview

`runas.exe` creates a process using another Windows account or alternate
network credentials. It does not automatically elevate through UAC: an
administrator account can still receive a filtered token, and policy can deny
the requested logon. Use Sudo for Windows or an elevation-aware launcher when
the requirement is elevation rather than identity.

## Syntax

```text
runas.exe [/profile | /noprofile] [/env]
          [/netonly | /savecred] [/smartcard]
          [/showtrustlevels] [/trustlevel:LEVEL]
          /user:ACCOUNT "PROGRAM [arguments]"
```

## Options

<!-- mant:entries role=option case=insensitive -->
- `/user:ACCOUNT`: Use `USER@DOMAIN`, `DOMAIN\USER`, or `COMPUTER\USER` as the target identity.
- `/profile`: Load the target user's profile; this is the default and may make startup slower.
- `/noprofile`: Do not load the target profile; applications that depend on its registry hive or environment can fail.
- `/env`: Use the current network environment rather than the target user's environment.
- `/netonly`: Keep the current local identity and use supplied credentials only for remote access; valid only with `/user`.
- `/savecred`: Reuse credentials previously saved for the account where supported; this expands credential-abuse risk.
- `/smartcard`: Obtain target credentials from a smart card.
- `/showtrustlevels`: List trust levels available to `/trustlevel`.
- `/trustlevel:LEVEL`: Start the program at the selected authorization trust level.
- `/?`: Display the help installed with this Windows build.

The password is requested interactively. `runas.exe` intentionally has no
password command-line switch; do not pipe or embed a password.

## Identity and elevation

Confirm the requirement before choosing the tool:

- another local/domain user: `runas.exe /user:...`;
- current user with administrator elevation: `sudo.exe` on supported Windows
  11 or an elevation-aware `Start-Process -Verb RunAs` workflow;
- current local token plus alternate remote credentials: `/netonly`.

`/netonly` does not make local file, registry, or process access run as the
named account. Verify both local and remote identity in the target workload.

## PowerShell usage

`PROGRAM` is one command-line string interpreted again when the child starts.
Nested quoting is fragile; a reviewed script file is safer than dynamic text:

```powershell
$account = "$env:COMPUTERNAME\maintenance"
$command = 'powershell.exe -NoLogo -NoProfile -File C:\Ops\Inspect-Service.ps1'
runas.exe /user:$account $command
if ($LASTEXITCODE -ne 0) { throw "runas failed to launch: $LASTEXITCODE" }
```

The launcher can return after process creation, so its exit result does not
prove the child workload succeeded. Arrange application logging or a separately
protected result channel. For typed credentials inside PowerShell, review
`Start-Process -Credential`; it is still not the same as UAC elevation.

## Common mistakes

### Using runas as an elevation switch

Alternate credentials and elevation are different token operations. Verify the
child token and integrity level rather than assuming an administrator username
means an elevated process.

### Supplying passwords in arguments or scripts

There is no supported password option. Command lines and scripts are observable;
allow the secure prompt or use an approved managed-credential mechanism.

### Using `/savecred` in automation

Any process able to invoke compatible targets may exploit the saved credential.
Avoid it on shared or high-trust systems and use narrowly scoped managed identity.

### Misreading `/netonly`

It changes outbound authentication, not local process identity. It can also
defer bad-password discovery until the first remote connection.

## Version and availability

Stable switches have existed across supported Windows generations, but trust
levels, smart-card behavior, `/savecred` availability, authentication policy,
and installed help vary by build and edition. Treat `runas.exe /?` on the
target as the exact local interface.

## Verification boundary

Published Microsoft syntax and the current Sudo comparison were reviewed. No
credential prompt, alternate logon, profile load, saved credential, smart card,
remote authentication, or child process ran.

## Related documents

- [sudo.exe](sudo.exe.md)
- PowerShell `Start-Process`
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[runas command reference](https://learn.microsoft.com/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc771525(v=ws.11))
and the current [Sudo for Windows comparison](https://learn.microsoft.com/windows/advanced-settings/sudo/#how-is-sudo-for-windows-different-from-the-existing-runas-command).
Exact page-level provenance is recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
