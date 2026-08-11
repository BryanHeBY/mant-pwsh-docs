<!-- mant:tldr:start -->
# echo

> Display Cmd text or control batch command echoing; dynamic text is parsed as Cmd syntax, so use PowerShell output APIs for untrusted values.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/echo.

- Display the echo state in a clean child Cmd process:

`cmd.exe /d /c echo`

- Display one fixed literal message through Cmd:

`cmd.exe /d /c "echo Hello from Cmd"`

- Emit a blank line in a batch file without an empty variable turning into an echo-state query:

`echo(`

- Write a PowerShell value as data without constructing a Cmd command line:

`Write-Output -NoEnumerate {{value}}`

<!-- mant:tldr:end -->

# echo

## Overview

`echo` is a Cmd builtin that displays a message or sets command echoing `on` or
`off`. Bare `echo` reports the current state; `@` suppresses echoing for one
batch line, and `@echo off` commonly suppresses it for the script.

Message text still passes through Cmd expansion and metacharacter parsing.
`&`, `|`, `<`, `>`, `^`, parentheses, `%variables%`, and delayed `!variables!`
can change control flow, redirection, or content. ECHO is not a safe encoder.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `echo`: Display Cmd message text, display current command-echo state, or set
  that state with the `on`/`off` operand.

The `@` prefix suppresses command echoing for one batch line; `echo(` is a
parser idiom for deliberate blank/value output, not a safe data encoder.

## Common mistakes

### Getting “ECHO is off/on” instead of a value

An empty expansion turns `echo %value%` into bare `echo`, which reports state.
Validate the variable and prefix output with fixed text or use the established
`echo(` blank-line form. Spaces around `=` in `set name = value` also become
part of a different variable name.

### Echoing untrusted text into a command

Quoting alone does not neutralize every Cmd metacharacter and expansion phase.
Do not concatenate user/file/network data into `cmd /c "echo ..."`; write with
PowerShell/.NET file or stream APIs using an explicit encoding.

### Expanding variables too early inside parentheses

Percent expansions for a parenthesized block commonly occur when the block is
parsed, before later assignments execute. Use correct delayed-expansion design
only after considering literal `!` loss, or restructure into subroutines.

### Confusing output with command echoing

`echo off` hides command lines, not command output or errors, and is not secret
redaction. Secrets can still appear in arguments, child output, logs, history,
or process inspection.

### Escaping only one parsing layer

A caret may be consumed by a parent Cmd, batch block, pipe-created child Cmd,
or another nested shell. Avoid nested command strings and test exact fixtures
for literal metacharacters, Unicode, empty values, and newlines.

## PowerShell boundaries

PowerShell's `Write-Output`, `Write-Host`, and `echo` alias have object/stream
semantics unrelated to Cmd echo state. Use `cmd.exe /d /c` only when testing a
fixed Cmd expression, and `Get-Command echo -All` to inspect PowerShell
resolution.

## Version and platform differences

This builtin runs inside `cmd.exe` on supported Windows releases. Parsing can
differ with command extensions, delayed expansion, batch versus interactive
mode, pipe/subshell context, code page, locale, and nested launch syntax.

## Related documents

- [cmd.exe](cmd.exe.md)
- [set](set.md)
- [setlocal](setlocal.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Echo reference](https://learn.microsoft.com/windows-server/administration/windows-commands/echo).
The empty-expansion failure was prioritized using a high-demand
[practitioner question](https://stackoverflow.com/questions/14334850/why-this-code-says-echo-is-off).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
