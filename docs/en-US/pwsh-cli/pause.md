<!-- mant:tldr:start -->
# pause

> Wait for any key only in a human-attended Cmd batch file; PAUSE has no timeout or choice result and can hang unattended work.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pause.

- Pause an attended batch file with the standard localized prompt:

`pause`

- Hide only PAUSE's prompt while still waiting indefinitely for a key:

`pause >nul`

- Ask for a bounded explicit decision instead of “any key”:

`choice.exe /C YN /N /T {{30}} /D N /M "Continue? [Y/N]"`

- Wait a fixed time without allowing a key to skip it:

`timeout.exe /T {{5}} /NOBREAK`

<!-- mant:tldr:end -->

# pause

## Overview

`pause` is a Cmd batch builtin that displays “Press any key to continue...” and
blocks until console input arrives. It provides no parameter for a custom
message, allowed keys, default action, or timeout. Ctrl+C enters Cmd's batch-
termination confirmation flow.

## Common mistakes

### Leaving PAUSE in CI, remoting, scheduled tasks, or services

Without an interactive console it can block forever or consume redirected input
unexpectedly. Remove it from unattended paths; use bounded `choice`, `timeout`,
process waits, or an orchestration primitive with explicit failure handling.

### Treating `>nul` as nonblocking

Redirection hides the prompt only. PAUSE still waits for a key. This is a common
agent-generated mistake that turns a silent run into an invisible hang.

### Using PAUSE for consent or confirmation

Any key continues, so it cannot distinguish approve/deny or prove informed
consent. Use CHOICE with explicit labels, safe default, finite timeout, and
correct one-based ERRORLEVEL handling; require stronger controls for destructive
operations.

### Feeding a synthetic key through a pipe

Piping input can be consumed by an earlier prompt/child command and hides an
interactive design flaw. It also launches pipe sides in child Cmd contexts.
Refactor the script rather than automating keystrokes.

### Adding PAUSE merely to keep a window open

Run the script from an existing terminal, capture logs, or fix the launcher.
An unconditional final pause annoys callers and breaks composition.

## PowerShell behavior

PAUSE is not a PowerShell command. `Read-Host` waits for a line, not any key;
`$Host.UI.RawUI.ReadKey()` is host-dependent. Prefer explicit parameters and
noninteractive defaults for scripts, and use `cmd.exe /d /c` only for actual
batch behavior.

## Version and platform differences

This Windows Cmd builtin depends on console/host input, redirection, session,
and locale. “Any key,” Ctrl+C, and noninteractive behavior can differ by host.

## Related documents

- [choice](choice.md)
- [timeout](timeout.md)
- [waitfor](waitfor.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Pause reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pause).
The unattended-hang and false-confirmation risks were prioritized using
[high-demand practitioner discussion](https://stackoverflow.com/questions/988403/how-to-prevent-auto-closing-of-console-after-the-execution-of-batch-file)
and [choice-based guidance](https://stackoverflow.com/questions/30552328/how-do-i-test-for-button-press-on-pause-command-in-batch).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
