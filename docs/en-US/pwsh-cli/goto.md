<!-- mant:tldr:start -->
# goto

> Transfer control to a fixed label inside the current batch file; use `goto :EOF` to leave the current script/subroutine without terminating Cmd.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/goto.

- Jump to a statically defined label in the current batch file:

`goto {{cleanup}}`

- Define the matching label; execution resumes on the following line:

`:cleanup`

- Return from the current batch file or called label while preserving the current ERRORLEVEL:

`goto :EOF`

<!-- mant:tldr:end -->

# goto

## Overview

`goto` is a Cmd batch control-flow builtin. It searches the current batch file
for a colon-prefixed label and resumes at the line after it. With command
extensions enabled, the virtual `:EOF` label exits the current batch script or
`call :label` subroutine without requiring a physical label.

## Common mistakes

### Falling through into subroutine labels

Cmd does not stop when it reaches a label. Put `goto :EOF` or an explicit main
exit before subroutine definitions, and give every called subroutine a clear
return path.

### Building a label from untrusted input

Dynamic `goto %value%` mixes data with control flow and can redirect execution
or create injection through earlier expansion. Map validated choices to fixed
labels with `if`/`choice`, or use a more structured language.

### Confusing `goto :EOF` with `exit`

`goto :EOF` returns from the current batch context and preserves ERRORLEVEL.
Bare `exit` can terminate the entire Cmd process; `exit /b code` returns with an
explicit result. Choose and document the intended boundary.

### Assuming labels create functions or scope

Labels do not create local variables, parameter validation, or automatic return.
Use `call :label args`, `setlocal/endlocal`, `%~1` modifiers, and explicit error
handling; remember CALL adds another expansion phase in some constructs.

### Hiding an infinite loop

Every backward jump needs a proven progress condition, cancellation/timeout,
and error path. Log bounded iteration state without leaking secrets.

## PowerShell behavior

GOTO exists only inside Cmd batch processing. PowerShell uses functions, loops,
`break`, `continue`, `return`, and exceptions; invoking `cmd /c goto ...` cannot
jump into a PowerShell script or another batch process.

## Version and platform differences

This internal Cmd command is Windows-only. `:EOF` requires command extensions,
which are enabled by default; label parsing depends on batch encoding, line
structure, blocks, and command-extension state.

## Related documents

- [call](call.md)
- [exit](exit.md)
- [if](if.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Goto reference](https://learn.microsoft.com/windows-server/administration/windows-commands/goto).
Subroutine return/fall-through errors were cross-checked against a detailed
[practitioner explanation](https://stackoverflow.com/questions/37515901/where-does-goto-eof-return-to).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
