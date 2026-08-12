<!-- mant:tldr:start -->
# if

> Branch in a Windows batch file using status, existence, definition, or comparison tests.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/if.

- Test whether the previous cmd status is nonzero:

`if errorlevel 1 exit /b %errorlevel%`

- Test whether a path exists:

`if exist "{{C:\path\file}}" (echo found) else (echo missing)`

- Compare strings without case sensitivity:

`if /i "{{%VALUE%}}"=="{{expected}}" echo matched`
<!-- mant:tldr:end -->

# if

## Overview

`if` performs conditional processing in `cmd.exe` batch files. It is not
PowerShell's `if` statement; syntax and expansion timing differ.

## Syntax

```text
if [not] errorlevel NUMBER COMMAND [else EXPRESSION]
if [not] STRING1==STRING2 COMMAND [else EXPRESSION]
if [not] exist PATH COMMAND [else EXPRESSION]
if [/i] STRING1 COMPARE-OP STRING2 COMMAND [else EXPRESSION]
if defined VARIABLE COMMAND [else EXPRESSION]
if cmdextversion NUMBER COMMAND [else EXPRESSION]
```

Comparison operators are `EQU`, `NEQ`, `LSS`, `LEQ`, `GTR`, and `GEQ`.
`else` must be on the same physical line as the closing command/parenthesis.

## Conditions and option

<!-- mant:entries role=command case=insensitive -->
- `if`: Conditionally execute a Cmd command using the following comparison or
  test grammar.
- `errorlevel`: Test whether the current Cmd status is greater than or equal to
  the supplied integer, optionally preceded by `not`.
- `exist`: Test whether the following path pattern resolves to an entry.
- `defined`: Test whether an environment variable exists; this form requires
  command extensions.
- `cmdextversion`: Test whether Cmd command-extension version is at least the
  supplied integer.

Only the string-compare switch is prefix-shaped; the comparison operators and
condition keywords are operands in Cmd grammar.

<!-- mant:entries role=option case=insensitive -->
- `/i`: Compare string operands without regard to case; it does not affect
  numeric `EQU`/`NEQ`/`LSS`/`LEQ`/`GTR`/`GEQ` comparisons.

## PowerShell boundaries

PowerShell's `if` is parsed by PowerShell and does not implement `errorlevel`,
`exist`, or `/i` syntax. Keep these conditions inside a batch file or one
explicit `cmd.exe /d /c` command. When PowerShell launches that boundary,
capture `$LASTEXITCODE` immediately and avoid interpolating untrusted text into
the child command string.

## Common mistakes

### Treating `if errorlevel N` as equality

It means the current status is at least N. Test thresholds from largest to
smallest, or capture the status and use an exact numeric comparison.

### Expanding a status or value before the block executes

`%ERRORLEVEL%` and other percent variables in a parenthesized block are
expanded when the block is parsed. Branch immediately or use deliberately
scoped delayed expansion.

### Comparing empty or untrusted text as batch syntax

`if %VALUE%==yes` becomes invalid when empty and can be structurally altered by
metacharacters. Quoting helps empty values but does not make arbitrary input
safe. Prefer `choice` for one-key menus and validate data before expansion.

### Shadowing the dynamic ERRORLEVEL expansion

An environment variable literally named `ERRORLEVEL` can shadow cmd's dynamic
`%ERRORLEVEL%` expansion. Do not define it; use `if errorlevel` where possible.

### Assuming `exist` distinguishes file from directory

The basic test only proves a matching filesystem entry. Use a more specific,
supported inspection when type, reparse target, permissions, or readiness
matters.

## Version and platform differences

This page targets supported Windows `cmd.exe`. `/i`, comparison operators,
`defined`, and `cmdextversion` require command extensions.

## Runtime evidence

The protected fixture set a child status to `7` and confirmed under both
PowerShell collectors that `if errorlevel 8` is false while `if errorlevel 7`
is true. It did not exercise caller-controlled comparison text, `exist` file
type distinctions, `CMDEXTVERSION`, or environment variables that shadow
dynamic status expansion.

## Related documents

- [choice.exe](choice.exe.md)
- [for](for.md)
- [setlocal](setlocal.md)
- [exit](exit.md)

## Sources and license

This original guide was adapted from Microsoft's official
[if reference](https://learn.microsoft.com/windows-server/administration/windows-commands/if).
The unsafe/empty comparison failure is evidenced by
[Why is processing of my batch file exited with a syntax error on string comparison?](https://stackoverflow.com/questions/34690602/why-is-processing-of-my-batch-file-exited-with-a-syntax-error-on-string-comparsi).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
