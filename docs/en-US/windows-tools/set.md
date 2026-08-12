<!-- mant:tldr:start -->
# set

> Inspect or change `cmd.exe` environment variables; bare `set` in PowerShell is a different command.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/set_1.

- Show cmd variables whose names begin with a prefix:

`cmd.exe /d /c 'set {{PREFIX}}'`

- Give one child command a temporary value:

`cmd.exe /d /c 'set "{{NAME}}={{value}}" & {{tool.exe}} {{arguments}}'`

- Set the equivalent variable in the current PowerShell process:

`$env:{{NAME}} = '{{value}}'`
<!-- mant:tldr:end -->

# set

## Overview

`set` is a `cmd.exe` builtin that displays, creates, changes, or removes
environment variables. Its `/a` form evaluates integer expressions and `/p`
reads one input line. In PowerShell, bare `set` normally resolves to the
`Set-Variable` alias, not this builtin.

## Syntax

```text
set [VARIABLE=[STRING]]
set /p VARIABLE=[PROMPT]
set /a VARIABLE=EXPRESSION
```

Run cmd semantics explicitly from PowerShell:

```powershell
Get-Command set -All
cmd.exe /d /c 'set PATH'
```

`set NAME=value` changes only the current cmd process and children created
afterward. A child `cmd.exe` cannot modify its parent PowerShell environment.

## Commands and options

<!-- mant:entries role=command case=insensitive -->
- `set`: Display, assign, or remove variables in the current Cmd process; a
  prefix operand displays every variable whose name begins with that prefix.

Use the quoted assignment form `set "NAME=value"` to keep accidental outer
spaces out of the stored value. An empty value removes the variable.

<!-- mant:entries role=option case=insensitive -->
- `/p`: Read one input line into the named variable after displaying an
  optional prompt; initialize and validate the variable for EOF/failure cases.
- `/a`: Evaluate a signed 32-bit integer expression using Cmd's operators and
  number-prefix rules, then assign or display the result.
- `/?`: Display installed builtin help through `cmd.exe`.

## Important forms

- `set`: display the complete cmd environment.
- `set PREFIX`: display variables whose names begin with `PREFIX`.
- `set "NAME=value"`: assign a value without storing accidental outer spaces.
- `set "NAME="`: remove the variable from the current cmd environment.
- `set /p NAME=Prompt`: read one console/input line.
- `set /a NAME=EXPRESSION`: evaluate 32-bit signed integer arithmetic. A leading
  `0` selects octal and `0x` selects hexadecimal.

## PowerShell boundaries

Bare `set` normally resolves to the `Set-Variable` alias. Use `$env:NAME` for
the current PowerShell process environment and `[Environment]` APIs only when
a persistent user/machine change is explicitly intended. Cmd assignments stay
inside that child process; capture output/exit status deliberately and never
expect `cmd.exe /c set ...` to mutate its parent PowerShell session.

## Common mistakes

### Running bare `set` in PowerShell

PowerShell's `set` alias invokes `Set-Variable`, whose variables are not the
same as process environment variables. Use `$env:NAME`, or invoke
`cmd.exe /d /c` when cmd syntax is actually required.

### Expecting a child shell to persist a variable

`cmd.exe /c 'set NAME=value'` ends with the modified environment. Set
`$env:NAME` in PowerShell before launching the child, or make the assignment
and consumer part of the same cmd string.

### Expanding a changing value with `%NAME%` inside parentheses

Cmd expands percent variables when it parses a parenthesized block. Use
`setlocal EnableDelayedExpansion` and `!NAME!` only where execution-time values
are required, and account for literal exclamation marks in data.

### Treating `/a` as general numeric parsing

Values such as `08` and `09` are invalid octal. Undefined names become zero,
integer overflow is possible, and cmd metacharacters still require quoting.
Use PowerShell numeric types for data validation or larger calculations.

### Using `/p` in a noninteractive job

Redirected, absent, or malicious input can leave an old value or inject cmd
metacharacters into a later unquoted expansion. Initialize the variable, test
input availability, validate the result, and never execute it as code.

## Version and platform differences

This builtin is available in `cmd.exe` on supported Windows client and server
releases. The Windows Recovery Environment exposes a different `set` form.

## Runtime evidence

A fixed child-batch fixture confirmed under both PowerShell collectors that
percent expansion inside a parsed parenthesized block retained `before`, while
narrowly enabled delayed expansion observed the later value `after`. All
variables existed only in task-owned child processes. `/A`, `/P`, arbitrary
exclamation-bearing data, and persistent or parent-process environment changes
remain outside this evidence.

## Related documents

- [cmd.exe](cmd.exe.md)
- [setlocal](setlocal.md)
- [timeout.exe](timeout.exe.md)
- [Windows tools index](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's official
[set reference](https://learn.microsoft.com/windows-server/administration/windows-commands/set_1).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
