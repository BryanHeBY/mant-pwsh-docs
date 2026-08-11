<!-- mant:tldr:start -->
# chglogon

> Legacy lookup name replaced by `change logon`; query before any RDS logon-admission change.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chglogon.

- Resolve both names without changing session admission:

`Get-Command chglogon.exe, change.exe -All -ErrorAction SilentlyContinue`

- Query current status through the supported replacement:

`change.exe logon /query`

- Read the full family guide:

`mant change --source windows-tools`
<!-- mant:tldr:end -->

# chglogon

## Overview

Microsoft replaced `chglogon` with `change logon`. The replacement supports
`/query`, `/enable`, `/disable`, `/drain`, and `/drainuntilrestart`. Do not infer
a separate modern syntax contract from a leftover executable.

## Command identities and options

<!-- mant:entries role=command case=insensitive -->
- `chglogon`, `change logon`: Use the legacy lookup name or its documented replacement for RD Session Host logon admission.

The following operation switches apply to the replacement command family.

<!-- mant:entries role=option case=insensitive -->
- `/query`: Report current logon-admission state without changing it.
- `/enable`: Enable new user logons to the RD Session Host.
- `/disable`: Refuse new logons while leaving existing sessions running.
- `/drain`: Refuse new user logons while allowing reconnection to existing sessions.
- `/drainuntilrestart`: Drain logons until the host restarts, then return to enabled behavior.

## PowerShell boundaries

Call `change.exe logon` as separate native arguments and check
`$LASTEXITCODE`; neither the legacy name nor output is a PowerShell object.

## Version and availability

This legacy/replacement family applies to supported Remote Desktop Session Host
contexts. Role installation, Windows Server version, permissions, listeners,
and management policy determine availability and authority.

## Common mistakes

Do not confuse drain with ending sessions, disable the only remote recovery
path, or treat administrative RDP as proof of the RD Session Host role. Query
the exact host/listeners/sessions and follow [change](change.md) for the full
maintenance and rollback boundaries.

## Related documents

- [change](change.md)
- [query](query.md)
- [quser](quser.md)

## Sources and license

This lookup page was adapted from Microsoft's official
[chglogon replacement notice](https://learn.microsoft.com/windows-server/administration/windows-commands/chglogon).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
