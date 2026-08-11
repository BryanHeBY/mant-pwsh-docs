<!-- mant:tldr:start -->
# ntcmdprompt

> Recognize the NTVDM/MS-DOS compatibility switch from Command.com to Cmd.exe; launch `cmd.exe` directly on current Windows.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ntcmdprompt.

- Resolve the current command interpreter explicitly:

`Get-Command cmd.exe -ErrorAction Stop | Select-Object Name, Source, Version`

- Open a clean child Cmd session without AutoRun commands:

`cmd.exe /d`

- Confirm whether the historical compatibility command exists without running it:

`Get-Command ntcmdprompt.exe -ErrorAction SilentlyContinue`

- Inspect an approved legacy Config.nt copy as text:

`Get-Content -LiteralPath "{{C:\Evidence\Config.nt}}"`
<!-- mant:tldr:end -->

# ntcmdprompt

## Overview

`ntcmdprompt` selected `cmd.exe` instead of `command.com` after a DOS TSR or
from an MS-DOS application's prompt, and could be placed in `Config.nt`/PIF
startup configuration. It belongs to the NTVDM-era 16-bit compatibility model;
it is not another name for ordinary modern Command Prompt.

## Common mistakes

### Running it to obtain an elevated or 64-bit shell

It neither elevates nor selects modern architecture. Launch the explicit
`cmd.exe` under the intended token/architecture and verify identity separately.

### Copying Config.nt or PIF changes to current systems

Those artifacts can load drivers/TSRs and change legacy application startup.
Preserve and review them only for an identified 16-bit dependency in an isolated
compatible environment.

### Assuming Cmd makes the TSR available

Microsoft notes that the TSR might not remain usable under Cmd. Preserve the
whole application/runtime dependency and migrate or virtualize deliberately.

## PowerShell behavior

`cmd.exe /d` disables Cmd AutoRun for that child, reducing hidden startup state.
PowerShell and Cmd have different quoting, variables, pipelines, aliases and
exit semantics; switching interpreters does not translate commands.

## Version and platform differences

NTVDM/16-bit support depends on Windows edition and architecture and is absent
from modern 64-bit Windows scenarios. Use supported application modernization
or an isolated licensed legacy environment rather than copying binaries.

## Related documents

- [cmd](cmd.md)
- [doskey](doskey.md)

## Sources and license

Adapted as an original compatibility guide from Microsoft's [NtCmdPrompt reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ntcmdprompt).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
