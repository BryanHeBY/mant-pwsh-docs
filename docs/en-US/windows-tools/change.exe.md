<!-- mant:tldr:start -->
# change.exe

> Query and control RD Session Host logon admission, per-session legacy COM mappings, and application install/execute mode.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/change.

- Resolve the exact Windows executable and confirm the RD Session Host role:

`Get-Command change.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}; Get-WindowsFeature -Name RDS-RD-Server -ErrorAction SilentlyContinue`

- Query whether new RDS client logons are enabled, disabled, or draining:

`change.exe logon /query`

- Query current-session legacy COM port mappings:

`change.exe port /query`

- Query whether the RD Session Host is in application install or execute mode:

`change.exe user /query`
<!-- mant:tldr:end -->

# change.exe

## Overview

`change.exe` is an RD Session Host command family. `change logon` controls new
client-session admission, `change port` manages current-session COM mappings
for MS-DOS applications, and `change user` controls legacy application install
versus execute mode and `.ini`/registry shadowing.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `change.exe`: Query or change RD Session Host logon, COM-port, or application mode.
- `logon`: Query or change admission of new/reconnecting client sessions.
- `port`: Query, create, or delete current-session legacy COM mappings.
- `user`: Query or change application install/execute mode.

Slash options apply only to the family that documents them; similarly named
state changes have materially different session behavior.

<!-- mant:entries role=option case=insensitive -->
- `/query`: Display current state for `logon`, `port`, or `user`.
- `/enable`: Permit new client logons in the `logon` family.
- `/disable`: Block later client logons without ending current sessions.
- `/drain`: Block new sessions while allowing reconnects.
- `/drainuntilrestart`: Drain until the next computer restart.
- `/d`: Delete one current-session COM-port mapping.
- `/install`: Enter legacy application installation/shadowing mode.
- `/execute`: Return to normal application execution mode.
- `/?`: Display installed family help.

## Logon admission

`change logon /query` is read-only. The mutation choices differ materially:

- `/enable` accepts new client logons.
- `/disable` blocks later client logons but not console logon and does not end
  current sessions.
- `/drain` blocks new sessions while permitting reconnects to existing ones.
- `/drainuntilrestart` drains until the next computer restart.

Inventory current/listener/session state with `query.exe`, warn users and keep
console or out-of-band recovery before a maintenance change. Re-query after the
change; a broker/load balancer and other hosts determine farm-wide admission.

## COM port mappings

`change port /query` (or no extra parameters) lists mappings. The mutation forms
are `change port <portX>=<portY>` and `change port /d <portX>`. They exist for
legacy applications limited to COM1-COM4 and affect only the current session;
they disappear at logoff. Confirm the physical/redirected endpoint, framing,
ownership and application direction before mapping.

## Application install mode

`change user /install` disables home-directory `.ini` mapping while an
application is installed and shadows relevant registry/configuration state for
later users. `change user /execute` restores normal execution mapping and is
the default. `change user /query` reports the current mode.

Use a `try`/`finally`-style operational procedure: verify the RDSH role and no
other installation, enter install mode immediately before the reviewed installer,
wait for it, complete required first-run configuration, always restore execute
mode, then test with a disposable nonadmin RDS user. Installer success alone
does not prove per-user behavior.

## Common mistakes

### Using install mode on a server configured only for remote administration

RDP access does not mean the RD Session Host role is installed. Install mode
does not apply to ordinary administrative RDP. Confirm `RDS-RD-Server` and the
application/vendor deployment requirements before changing mode.

### Leaving the server in `/install` after failure

An exception, reboot request or abandoned shell can leave subsequent activity
in the wrong mapping mode. Record the starting mode and guarantee `/execute`
restoration in the maintenance rollback, then query it explicitly.

### Treating `/disable`, `/drain`, and `/drainuntilrestart` as synonyms

Drain permits reconnection; disable blocks subsequent client logons; the
until-restart variant changes automatically at restart. Choose the intended
session lifecycle and verify existing users instead of assuming the command
logs them off.

### Disabling logons from the only remote administration session

If you sign out before re-enabling, ordinary client reconnection can be blocked.
Require console/OOB access, a second authorized administrator, an expiry/restore
step and external monitoring before changing admission.

### Assuming a COM mapping is machine-wide or persistent

It is session-local and ends at logoff. Do not place a mapping in every user's
startup blindly; verify redirected-device policy, session ID, port availability,
application exclusivity and disconnect/reconnect behavior.

### Using obsolete `chglogon`, `chgport`, or `chgusr` syntax as a separate contract

Microsoft replaced those commands with `change logon`, `change port`, and
`change user`. Keep shorthand lookup pages for discovery, but build new
automation against the replacement and installed help.

## PowerShell boundaries

Call `change.exe` explicitly and capture `$LASTEXITCODE`. `change` can be
shadowed by another command in mixed toolchains. Native `/` options are not
PowerShell parameters. The port expression contains `=` and should be passed as
one reviewed literal argument.

## Version and platform differences

Windows-only and primarily useful on servers with RD Session Host. Broad Learn
applicability does not make install mode or logon admission meaningful on a
client/ordinary RDP server. Legacy application mapping behavior can differ with
modern MSIX, virtualization, FSLogix and vendor packaging.

## Related documents

- [query.exe](query.exe.md)
- [quser.exe](quser.exe.md)
- [flattemp.exe](flattemp.exe.md)
- [msiexec.exe](msiexec.exe.md)

## Sources and license

This original family guide was adapted from Microsoft's official
[change](https://learn.microsoft.com/windows-server/administration/windows-commands/change),
[change logon](https://learn.microsoft.com/windows-server/administration/windows-commands/change-logon),
[change port](https://learn.microsoft.com/windows-server/administration/windows-commands/change-port),
and [change user](https://learn.microsoft.com/windows-server/administration/windows-commands/change-user)
references. Role/mode confusion and real deployment practice were cross-checked
against Server Fault questions about [install mode on a remote-administration server](https://serverfault.com/questions/1178262/cannot-put-rds-server-into-install-mode-install-mode-does-not-apply-to-a-remot)
and [RDS application deployment](https://serverfault.com/questions/327330/net-application-deployment-under-terminal-services-win-svr-2008-r2).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
