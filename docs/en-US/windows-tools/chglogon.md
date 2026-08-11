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

## Common mistakes

Do not confuse drain with ending sessions, disable the only remote recovery
path, or treat administrative RDP as proof of the RD Session Host role. Query
the exact host/listeners/sessions and follow [change](change.md) for the full
maintenance and rollback boundaries.

## Sources and license

This lookup page was adapted from Microsoft's official
[chglogon replacement notice](https://learn.microsoft.com/windows-server/administration/windows-commands/chglogon).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
