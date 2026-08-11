<!-- mant:tldr:start -->
# chgport.exe

> Legacy lookup name replaced by `change port`; mappings are current-session compatibility state, not persistent hardware configuration.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chgport.

- Resolve both names without changing mappings:

`Get-Command chgport.exe, change.exe -All -ErrorAction SilentlyContinue`

- Query current-session mappings through the supported replacement:

`change.exe port /query`

- Read the full family guide:

`mant change.exe --source windows-tools`
<!-- mant:tldr:end -->

# chgport.exe

## Overview

Microsoft replaced `chgport` with `change port`. The replacement lists, creates,
or deletes COM mappings for legacy MS-DOS applications. Mappings belong to the
current session and are lost at logoff.

## Command identities and option

<!-- mant:entries role=command case=insensitive -->
- `chgport.exe`, `change.exe port`: Inspect or manage current-session COM-port compatibility mappings for legacy applications.

The read-only switch is separate from the equals-bearing mapping grammar.

<!-- mant:entries role=option case=insensitive -->
- `/query`: List current-session COM mappings without changing them.

The write form uses a documented `PORTX=PORTY` mapping token, while deletion
uses the exact source port with an equals sign and no destination. Preserve the
direction and query after an approved change.

## PowerShell boundaries

Call `change.exe port` explicitly and pass the complete equals-bearing mapping
as one native argument. Capture `$LASTEXITCODE`; do not treat the output as
physical device inventory.

## Version and availability

This compatibility surface is Windows/RD Session Host-specific and relevant
to legacy MS-DOS application port mapping. Session, device redirection, policy,
role, and Windows version affect its utility.

## Common mistakes

Do not confuse a redirected COM endpoint with a local physical port, reverse
`portX=portY`, assume persistence, or let multiple sessions/applications own the
same device. Query first and follow [change.exe](change.exe.md) for the complete port,
session, framing and ownership boundary.

## Related documents

- [change.exe](change.exe.md)
- [mode.com](mode.com.md)
- [query.exe](query.exe.md)

## Sources and license

This lookup page was adapted from Microsoft's official
[chgport replacement notice](https://learn.microsoft.com/windows-server/administration/windows-commands/chgport).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
