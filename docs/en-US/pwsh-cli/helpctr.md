<!-- mant:tldr:start -->
# helpctr

> Recognize the deprecated Windows Server 2003 Help and Support Center launcher; use current local or Microsoft Learn help instead.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/helpctr.

- Confirm whether a legacy image contains the executable without launching it:

`Get-Command helpctr.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Query installed PowerShell help for an exact command:

`Get-Help {{Get-Service}} -Full`

- Query native command help through the command's supported interface:

`{{command.exe}} /?`

- Search ManT for an offline curated command page:

`mant {{command}} --source pwsh-cli`
<!-- mant:tldr:end -->

# helpctr

## Overview

`helpctr.exe` launched Windows Server 2003 Help and Support Center. Microsoft
marks it deprecated and not guaranteed to be supported. This page exists so
old scripts and images are understandable; it is not a current general help
launcher.

## Common mistakes

### Downloading old Help Center binaries or content packs

Do not install unknown executables/CHM/help content to recreate a retired UI.
Preserve original media in an isolated lab and use current authoritative docs.

### Assuming old help matches the current executable

Syntax, security, lifecycle and behavior change. Prefer installed `/?`, exact
PowerShell module help, and current versioned vendor documentation.

### Opening untrusted help content

Historical help packages can contain active links, scripts or vulnerable
parsers. Treat them as untrusted artifacts and inspect offline.

## PowerShell behavior

PowerShell `Get-Help` is command/module-aware and separate from HelpCtr. Native
executables have their own conventions. Resolve the command first to avoid alias
or application collisions.

## Version and platform differences

HelpCtr is a deprecated Windows Server 2003 component and may be absent. Current
Windows help surfaces, Get Help, PowerShell help and Microsoft Learn are distinct.

## Related documents

- [help](help.md)
- [msdt](msdt.md)

## Sources and license

Adapted as an original retirement guide from Microsoft's [HelpCtr catalog entry](https://learn.microsoft.com/windows-server/administration/windows-commands/helpctr).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
