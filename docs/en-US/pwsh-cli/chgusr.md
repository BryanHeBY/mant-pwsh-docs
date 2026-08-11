<!-- mant:tldr:start -->
# chgusr

> Legacy lookup name replaced by `change user`; query RDS application mapping mode and always restore execute mode after an approved install.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chgusr.

- Resolve both names without changing mode:

`Get-Command chgusr.exe, change.exe -All -ErrorAction SilentlyContinue`

- Query current mode through the supported replacement:

`change.exe user /query`

- Read the full family guide:

`mant change --source pwsh-cli`
<!-- mant:tldr:end -->

# chgusr

## Overview

Microsoft replaced `chgusr` with `change user`. The replacement exposes
`/query`, `/install`, and `/execute` for RD Session Host legacy `.ini` and
registry mapping during application installation.

## Common mistakes

Do not apply install mode to ordinary administrative RDP, leave the host in
install mode after an installer fails, or assume the mode makes an unsupported
application multi-user safe. Follow [change](change.md) for full role,
installer, first-run, rollback and nonadmin-user verification guidance.

## Sources and license

This lookup page was adapted from Microsoft's official
[chgusr replacement notice](https://learn.microsoft.com/windows-server/administration/windows-commands/chgusr).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
