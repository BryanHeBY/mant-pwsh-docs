<!-- mant:tldr:start -->
# timeout

> Pause a Windows command processor; prefer `Start-Sleep` in PowerShell code.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/timeout.

- Wait a fixed number of seconds and ignore keystrokes:

`timeout.exe /t {{10}} /nobreak`

- Wait until a key is pressed:

`timeout.exe /t -1`

- Use the PowerShell-native equivalent:

`Start-Sleep -Seconds {{10}}`
<!-- mant:tldr:end -->

# timeout

## Overview

Windows `timeout.exe` pauses command processing for -1 or 0 through 99999
seconds. By default any keystroke resumes execution; `/nobreak` ignores normal
keystrokes. Use `Start-Sleep` in PowerShell unless Windows timeout's console-key
behavior is specifically required.

## Syntax

```text
timeout.exe /t SECONDS [/nobreak]
```

`-1` waits indefinitely for a key. `/nobreak` is unsuitable with `-1` when no
external cancellation mechanism exists.

## Common mistakes

### Using timeout as a process deadline

This command only sleeps. It does not monitor, cancel, or terminate another
process after a deadline. Use a process/job wait API with explicit cancellation
and cleanup for that task.

### Running it with redirected standard input

`timeout.exe` can fail immediately with “Input redirection is not supported”
in background jobs, CI, or another non-console host. `Start-Sleep` does not
depend on a console input handle.

### Omitting `/nobreak` in unattended console work

An incidental keypress can shorten the delay. Add `/nobreak` only when a real
console is present; it does not fix redirected-input environments.

### Confusing Windows timeout with a Unix utility

On Linux, `timeout COMMAND` limits another process's run time. Windows
`timeout.exe` is a delay utility with incompatible syntax. Resolve the command
and do not copy examples across platforms.

### Using sleeps to prove readiness

A fixed delay cannot prove that a service, file, port, installer, or GUI is
ready. Poll a supported state with a bounded deadline and useful diagnostics.

## Version and platform differences

This page describes Windows `timeout.exe`. PowerShell 7 on Linux or macOS can
resolve a different native program named `timeout`, or none at all.

## Related documents

- [cmd](cmd.md)
- [choice](choice.md)
- [Windows tools index](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's official
[timeout reference](https://learn.microsoft.com/windows-server/administration/windows-commands/timeout).
The redirected-input failure is evidenced by
[PowerShell batch script Timeout ERROR: Input redirection is not supported](https://stackoverflow.com/questions/74842935/powershell-batch-script-timeout-error-input-redirection-is-not-supported-exiti).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow content
under CC BY-SA 4.0. This adaptation is CC BY 4.0; no answer text is reproduced.
