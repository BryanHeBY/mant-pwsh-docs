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

<!-- mant:entries role=command case=insensitive -->
- `choice.exe`: Read one declared console character and return its one-based
  position as the process status.

The default character must be present in `/c`; `/d` is valid only with a
finite `/t` timeout.

<!-- mant:entries role=option case=insensitive -->
- `/c`: Declare valid characters in result order; the default list is `YN` and
  duplicate characters are not a useful unambiguous contract.
- `/n`: Hide the displayed bracketed choice list while retaining prompt text.
- `/cs`: Make character matching case-sensitive.
- `/t`: Set 0 through 9999 seconds before the `/d` character is selected.
- `/d`: Select the following declared default character when `/t` expires.
- `/m`: Display the following prompt text before waiting for input.
- `/?`: Display installed command help.

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

## PowerShell boundaries

`choice.exe` writes a prompt but returns the selection index through the native
exit status, not stdout. Capture `$LASTEXITCODE` immediately after direct
PowerShell invocation and map it against the exact `/c` order. Do not use this
interactive contract in redirected, scheduled, service, or CI contexts.

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
