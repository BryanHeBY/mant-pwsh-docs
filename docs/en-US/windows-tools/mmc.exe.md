<!-- mant:tldr:start -->
# mmc.exe

> Open Microsoft Management Console or a saved `.msc` administrative console.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mmc.

- Open a saved console:

`mmc.exe {{C:\path\console.msc}}`

- Open a console in author mode:

`mmc.exe {{C:\path\console.msc}} /a`

- Select the snap-in architecture on 64-bit Windows:

`mmc.exe {{C:\path\console.msc}} {{[/32|/64]}}`
<!-- mant:tldr:end -->

# mmc.exe

## Overview

Microsoft Management Console (`mmc.exe`) is a GUI host for administrative
snap-ins. It can open a saved `.msc` console, open one in author mode, or select
the 32-bit or 64-bit host required by a snap-in.

MMC provides an interactive management surface. Starting a console does not
perform or verify the administrative action shown inside it.

## Syntax

```text
mmc.exe [FULL-PATH\CONSOLE.msc] [/a] [/32 | /64]
```

## Options

<!-- mant:entries role=command case=insensitive -->
- `mmc.exe`: Open Microsoft Management Console, optionally with one explicit saved `.msc` console path.

A leading `FULL-PATH\CONSOLE.msc` operand opens a saved console. Microsoft
documents a complete path; use an expanded PowerShell path rather than cmd
`%VARIABLE%` syntax.

<!-- mant:entries role=option case=insensitive -->
- `/a`: Open the saved console in author mode so its layout and snap-ins can be
  changed. This does not permanently change the file's default mode by itself.
- `/32`: Use the 32-bit MMC host on 64-bit Windows for a 32-bit-only snap-in.
- `/64`: Use the 64-bit MMC host on 64-bit Windows for a 64-bit snap-in.

```powershell
$console = Join-Path $env:SystemRoot 'System32\eventvwr.msc'
mmc.exe $console /64
```

## PowerShell boundaries

Pass the resolved `.msc` path and architecture switch as separate arguments to
`mmc.exe`. Starting the GUI returns no structured result for actions later
performed inside a snap-in; use the owning management API for automation.

## Common mistakes

### Assuming every `.msc` file exists everywhere

Console files and snap-ins depend on Windows edition, installed features,
RSAT packages, and server roles. Check the path and prerequisites before
launching.

### Choosing the wrong host architecture

A 32-bit-only snap-in cannot necessarily load in 64-bit MMC, and the reverse
can also fail. Match `/32` or `/64` to the installed snap-in, not merely the OS
architecture.

### Treating elevation as part of `mmc.exe`

Some snap-ins can display information as a standard user but require
administrative rights for changes. MMC launch success does not prove that the
later operation is authorized. Elevate only the approved task and verify state
afterward.

### Using MMC for unattended automation

MMC is a GUI host, not a stable output or exit-code API for snap-in actions.
Use the snap-in's supported cmdlets, CIM provider, command tool, or management
API when an unattended result is required.

## Version and platform differences

MMC is Windows-only. The host exists on supported Windows client and server
desktop installations, while individual consoles and snap-ins vary by release,
edition, architecture, and installed roles or features.

## Related documents

- [control.exe](control.exe.md)
- [reg.exe](reg.exe.md)
- [sc.exe](sc.exe.md)
- [schtasks.exe](schtasks.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[mmc command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mmc)
and [MMC overview](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/what-is-microsoft-management-console).
Exact locked upstream revision and paths are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
