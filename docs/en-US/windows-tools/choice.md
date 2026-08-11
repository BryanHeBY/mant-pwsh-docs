<!-- mant:tldr:start -->
# choice

> Prompt for one character and use its one-based position as the result.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/choice.

- Prompt for Yes or No in a batch file:

`choice.exe /c YN /n /m "{{Continue?}}"`

- Use No after a timeout:

`choice.exe /c YN /n /t {{30}} /d N /m "{{Continue?}}"`

- Read the selected index after direct PowerShell invocation:

`choice.exe /c YN /n /m '{{Continue?}}'; $selection = $LASTEXITCODE`
<!-- mant:tldr:end -->

# choice

## Overview

`choice.exe` waits for one character from a declared list and returns its
one-based position. It is intended for an interactive console or batch menu;
it does not return the chosen character on stdout.

## Syntax

```text
choice [/c CHOICES] [/n] [/cs] [/t SECONDS /d DEFAULT] [/m TEXT]
```

- `/c`: valid characters in result order; default is `YN`.
- `/n`: hide the displayed choice list.
- `/cs`: make matching case-sensitive.
- `/t` with `/d`: select a declared default after 0 through 9999 seconds.
- `/m`: display prompt text.

## Result contract

The first character returns 1, the second 2, and so on. An error returns 255;
Ctrl+C or Ctrl+Break returns 0. In a batch file, `if errorlevel N` means
greater than or equal to N, so exact branches must be tested in decreasing
order or compared numerically after capturing the value.

```bat
choice /c YN /n /m "Continue?"
if errorlevel 255 exit /b 255
if errorlevel 2 goto no
if errorlevel 1 goto yes
exit /b 130
```

## Common mistakes

### Treating ERRORLEVEL as the chosen character

For `/c YN`, Y returns 1 and N returns 2. A timed default returns the same index
as if that key were pressed, not zero.

### Testing `if errorlevel 1` first

That condition is also true for 2 and 255. Test decreasing thresholds, or use
an exact numeric comparison with a value captured at the correct parse time.

### Reading `%ERRORLEVEL%` later in a parenthesized block

Percent expansion can capture the value from before `choice` ran. Branch
immediately with `if errorlevel`, or use carefully scoped delayed expansion.

### Using it in a headless process

Services, redirected jobs, CI, and scheduled tasks may have no interactive
console. Supply configuration as validated arguments or input instead of
waiting for a key.

## Version and platform differences

`choice.exe` is Windows-only. Extended-character input depends on the active
console environment; prefer explicit ASCII choices for portable batch files.

## Related documents

- [cmd](cmd.md)
- [setlocal](setlocal.md)
- [timeout](timeout.md)

## Sources and license

This original guide was adapted from Microsoft's official
[choice reference](https://learn.microsoft.com/windows-server/administration/windows-commands/choice).
The decreasing-ERRORLEVEL trap is also evidenced by
[Using CHOICE with CMD script](https://stackoverflow.com/questions/16902319/using-choice-with-cmd-script).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow content
under CC BY-SA 4.0. This adaptation is CC BY 4.0; no answer text is reproduced.
