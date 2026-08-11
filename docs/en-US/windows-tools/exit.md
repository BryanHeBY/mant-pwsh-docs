<!-- mant:tldr:start -->
# exit

> Return from a batch context with `/b`, or terminate the entire cmd process without it.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/exit.

- Return from the current batch file or subroutine with an explicit failure:

`exit /b {{1}}`

- Set and inspect a child cmd process exit code from PowerShell:

`cmd.exe /d /c 'exit /b {{7}}'; $LASTEXITCODE`

- Exit a PowerShell script or process instead of cmd:

`exit {{7}}`
<!-- mant:tldr:end -->

# exit

## Overview

`exit` is cmd control syntax. `exit /b CODE` exits the current batch script or
called subroutine and sets its ERRORLEVEL. Without `/b`, it terminates the whole
`cmd.exe` process and uses CODE as the process exit code.

## Syntax

```text
exit [/b] [EXIT-CODE]
```

Outside a batch file, `/b` also exits `cmd.exe`. In PowerShell, `exit` is a
PowerShell language keyword with a different runtime boundary.

## Command and option

<!-- mant:entries role=command case=insensitive -->
- `exit`: Terminate the current Cmd process, or return only from the current
  batch/subroutine when `/b` is present.

An optional integer becomes the batch ERRORLEVEL or child process exit code at
the boundary selected by `/b`.

<!-- mant:entries role=option case=insensitive -->
- `/b`: Exit the current batch script or called label without terminating its
  parent Cmd process; outside a batch file it exits the Cmd process.
- `/?`: Display installed builtin help through `cmd.exe`.

## PowerShell boundaries

PowerShell parses bare `exit` as its own language keyword. Keep Cmd's `/b`
form inside a batch file or child `cmd.exe`; after that process returns, save
`$LASTEXITCODE` immediately. Do not use `exit` merely to return from a
PowerShell function—use `return` for that scope.

## Common mistakes

### Omitting `/b` in a called batch file

Plain `exit` terminates the command interpreter, preventing the parent batch
file or interactive cmd session from continuing. Use `/b` for a subroutine or
batch return.

### Omitting an explicit code at an automation boundary

Cmd's internal ERRORLEVEL and its final process exit code have edge cases when
a batch file returns without a code. At scheduled-task, PowerShell, CI, or
process-API boundaries, return an intentional numeric code and test it.

### Expanding `%ERRORLEVEL%` too early

In a parenthesized block, `exit /b %ERRORLEVEL%` can use the status from before
the failing command. Capture at execution time or branch immediately; do not
add delayed expansion globally to arbitrary text just for this purpose.

### Assuming every nonzero value is failure

The called program owns its status contract. Tools such as Robocopy and MSI use
some nonzero codes for nonfatal or reboot-required outcomes. Translate only
after consulting that command's documentation.

### Reading `$LASTEXITCODE` after another native process

PowerShell updates `$LASTEXITCODE` for native invocations. Save it immediately
after the child `cmd.exe` or batch operation.

## Version and platform differences

The cmd form is Windows-only. PowerShell's `exit` works on every PowerShell
platform but exits the current script/runspace/process context according to how
PowerShell was hosted.

## Related documents

- [cmd](cmd.md)
- [call](call.md)
- [setlocal](setlocal.md)
- [robocopy](robocopy.md)

## Sources and license

This original guide was adapted from Microsoft's official
[exit reference](https://learn.microsoft.com/windows-server/administration/windows-commands/exit).
The `/b` process-boundary pitfall is evidenced by
[How to return an error code without closing the Command Prompt window?](https://stackoverflow.com/questions/14905876/how-to-return-an-error-code-without-closing-the-command-prompt-window).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
