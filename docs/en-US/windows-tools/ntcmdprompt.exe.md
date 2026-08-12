<!-- mant:tldr:start -->
# ntcmdprompt.exe

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

# ntcmdprompt.exe

## Overview

`ntcmdprompt` selected `cmd.exe` instead of `command.com` after a DOS TSR or
from an MS-DOS application's prompt, and could be placed in `Config.nt`/PIF
startup configuration. It belongs to the NTVDM-era 16-bit compatibility model;
it is not another name for ordinary modern Command Prompt.

## Command boundary

<!-- mant:entries role=command case=insensitive -->
- `ntcmdprompt.exe`: Select `cmd.exe` inside the historical NTVDM/DOS application environment.

This is not elevation, architecture selection, or a modern Command Prompt alias.

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

## PowerShell boundaries

`cmd.exe /d` disables Cmd AutoRun for that child, reducing hidden startup state.
PowerShell and Cmd have different quoting, variables, pipelines, aliases and
exit semantics; switching interpreters does not translate commands.

## Version and platform differences

NTVDM/16-bit support depends on Windows edition and architecture and is absent
from modern 64-bit Windows scenarios. Use supported application modernization
or an isolated licensed legacy environment rather than copying binaries.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`ntcmdprompt.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains resolution, clean Cmd launch/exit and copied
Config.nt reading only; no PIF/Config.nt/TSR/NTVDM/system mutation is permitted
merely for evidence.

## Related documents
- [cmd.exe](cmd.exe.md)
- [doskey.exe](doskey.exe.md)

## Sources and license

Adapted as an original compatibility guide from Microsoft's [NtCmdPrompt reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ntcmdprompt).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
