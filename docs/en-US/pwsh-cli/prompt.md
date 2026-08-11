<!-- mant:tldr:start -->
# prompt

> Change only the current Cmd session's prompt display; prompt text is not identity, privilege, or trustworthy audit context.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/prompt.

- Start an isolated interactive Cmd with the conventional current-path prompt:

`cmd.exe /d /k 'prompt $p$g'`

- In Cmd, reset the current prompt to its default:

`prompt`

- In Cmd, include current path and one marker while keeping the template fixed:

`prompt [dev]$s$p$g`

- Inspect PowerShell's own prompt function instead of expecting Cmd PROMPT state:

`Get-Command prompt | Format-List Name, CommandType, Definition`

<!-- mant:tldr:end -->

# prompt

## Overview

`prompt` is a Cmd builtin that sets the current session's command prompt. `$p`,
`$g`, `$t`, `$d`, `$v`, `$n`, `$m`, `$+`, and other tokens render path, marker,
time/date/version, network association, or stack depth. With no text it restores
the default current-drive/path plus `>` prompt.

## Common mistakes

### Configuring Cmd PROMPT and expecting PowerShell to change

PowerShell uses a `prompt` function. Cmd's PROMPT environment/session state and
PowerShell's function are separate; configure each deliberately and inspect
command resolution before troubleshooting.

### Trusting prompt text as host, directory, or privilege proof

The prompt is user-controlled display and can be stale, forged, truncated, or
hidden. Query actual identity, location, process elevation, and target before an
administrative action.

### Passing `$` tokens through PowerShell double quotes

PowerShell may expand `$p` and `$g` before Cmd sees them. Use a reviewed literal
single-quoted command string for a fixed template, or configure inside Cmd.

### Embedding untrusted or control text

`$e` emits escape code 27, and literal/control sequences can spoof terminal
output or hyperlinks. Keep templates fixed, printable, short, and accessible;
never incorporate raw branch/path/remote strings without sanitization.

### Persisting through Command Processor AutoRun casually

AutoRun affects scripts and tools that start Cmd and can already contain other
commands. Prefer session-local configuration. Review user/machine AutoRun values,
escaping, `/D` bypass, policy, and rollback before persistent changes.

## PowerShell behavior

Use PowerShell's `prompt` function for PowerShell sessions. `cmd.exe /d /k`
creates an interactive child and keeps it open; do not use it in unattended
automation. Prompt changes do not affect command results or security context.

## Version and platform differences

This is a Windows Cmd builtin. Tokens depend on command extensions, current
drive/network mapping, console/terminal rendering, code page, locale, and font.

## Related documents

- [cmd](cmd.md)
- [pushd](pushd.md)
- [title](title.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Prompt reference](https://learn.microsoft.com/windows-server/administration/windows-commands/prompt).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
