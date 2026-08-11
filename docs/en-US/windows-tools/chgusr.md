<!-- mant:tldr:start -->
# chgusr

> Legacy lookup name replaced by `change user`; query RDS application mapping mode and always restore execute mode after an approved install.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chgusr.

- Resolve both names without changing mode:

`Get-Command chgusr.exe, change.exe -All -ErrorAction SilentlyContinue`

- Query current mode through the supported replacement:

`change.exe user /query`

- Read the full family guide:

`mant change --source windows-tools`
<!-- mant:tldr:end -->

# chgusr

## Overview

Microsoft replaced `chgusr` with `change user`. The replacement exposes
`/query`, `/install`, and `/execute` for RD Session Host legacy `.ini` and
registry mapping during application installation.

## Command identities and options

<!-- mant:entries role=command case=insensitive -->
- `chgusr`, `change user`: Inspect or change RD Session Host legacy application-install mapping mode.

Use exactly one of the following mode operations.

<!-- mant:entries role=option case=insensitive -->
- `/query`: Report whether execute or install mode is active.
- `/install`: Enter installation mode for an approved legacy multi-user application procedure.
- `/execute`: Return to normal application execution mode after the installation procedure.

## PowerShell boundaries

Call `change.exe user` explicitly, check `$LASTEXITCODE`, and always place the
mode transition in a procedure that restores execute mode on failure.

## Version and availability

This behavior is specific to supported RD Session Host application-
compatibility scenarios. It is not required merely because an administrator
uses RDP, and modern application deployment can have different requirements.

## Common mistakes

Do not apply install mode to ordinary administrative RDP, leave the host in
install mode after an installer fails, or assume the mode makes an unsupported
application multi-user safe. Follow [change](change.md) for full role,
installer, first-run, rollback and nonadmin-user verification guidance.

## Related documents

- [change](change.md)
- [query](query.md)
- [schtasks](schtasks.md)

## Sources and license

This lookup page was adapted from Microsoft's official
[chgusr replacement notice](https://learn.microsoft.com/windows-server/administration/windows-commands/chgusr).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
