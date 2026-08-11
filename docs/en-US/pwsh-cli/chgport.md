<!-- mant:tldr:start -->
# chgport

> Legacy lookup name replaced by `change port`; mappings are current-session compatibility state, not persistent hardware configuration.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chgport.

- Resolve both names without changing mappings:

`Get-Command chgport.exe, change.exe -All -ErrorAction SilentlyContinue`

- Query current-session mappings through the supported replacement:

`change.exe port /query`

- Read the full family guide:

`mant change --source pwsh-cli`
<!-- mant:tldr:end -->

# chgport

## Overview

Microsoft replaced `chgport` with `change port`. The replacement lists, creates,
or deletes COM mappings for legacy MS-DOS applications. Mappings belong to the
current session and are lost at logoff.

## Common mistakes

Do not confuse a redirected COM endpoint with a local physical port, reverse
`portX=portY`, assume persistence, or let multiple sessions/applications own the
same device. Query first and follow [change](change.md) for the complete port,
session, framing and ownership boundary.

## Sources and license

This lookup page was adapted from Microsoft's official
[chgport replacement notice](https://learn.microsoft.com/windows-server/administration/windows-commands/chgport).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
