<!-- mant:tldr:start -->
# cls

> Clear the visible Cmd screen only; this does not erase scrollback, transcripts, logs, history, or secrets already exposed.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cls.

- Clear the current interactive Cmd screen:

`cls`

- Clear the current PowerShell host through PowerShell's command instead:

`Clear-Host`

- Inspect what `cls` resolves to in PowerShell before using the shorthand:

`Get-Command cls -All`

<!-- mant:tldr:end -->

# cls

## Overview

`cls` is a Cmd builtin that clears the Command Prompt display. It is a visual
operation, not data deletion or security cleanup. Calling `cmd /c cls` clears a
short-lived child context and is not a reliable way to clear the parent host.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `cls`: Clear the visible display requested by the current Cmd console; it
  does not delete scrollback, logs, history, transcripts, or retained data.

## Common mistakes

### Using CLS to remove sensitive output

Terminal scrollback, recordings, transcripts, redirected files, remote-session
logs, shell history, telemetry, and observers can retain it. Prevent secret
output at the source and follow the host/data-retention procedure.

### Running CLS in unattended logs

Screen-control behavior can add escape sequences, form feeds, blank output, or
no useful effect in redirected/CI contexts. Do not clear logs; emit structured
phase markers and retain evidence.

### Assuming Cmd and PowerShell commands are identical

PowerShell commonly exposes `cls` as an alias for `Clear-Host`, while Cmd parses
its own builtin. Resolve with `Get-Command`; use the full intended command in
documentation and automation.

### Clearing before preserving an error

Copy the command, timestamp, raw output, exit status, and relevant state before
changing the display. A clean screen can make diagnosis harder without fixing
anything.

## PowerShell boundaries

Use `Clear-Host` for the current PowerShell host, noting host implementations
vary. Do not spawn Cmd solely for CLS. Neither mechanism guarantees clearing
the terminal emulator's scrollback or recording.

## Version and platform differences

Cmd CLS is Windows-only. PowerShell `Clear-Host` is host-dependent and may work
differently in Windows Terminal, legacy console, IDEs, remoting, redirected
output, CI, and non-Windows terminals.

## Related documents

- [cmd.exe](cmd.exe.md)
- [color](color.md)
- [prompt](prompt.md)

## Sources and license

This original guide was adapted from Microsoft's official
[CLS reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cls).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
