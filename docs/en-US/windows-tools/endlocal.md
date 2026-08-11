<!-- mant:tldr:start -->
# endlocal

> Restore the environment and cmd parsing state saved by the matching `setlocal`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/endlocal.

- End the innermost localized batch scope:

`endlocal`

- Return a simple trusted value across the scope boundary:

`endlocal & set "{{RESULT}}=%{{LOCAL_RESULT}}%"`

- Rely on the implicit restore at the end of a batch file:

`exit /b {{exit-code}}`
<!-- mant:tldr:end -->

# endlocal

## Overview

`endlocal` is a `cmd.exe` batch builtin that restores environment variables,
command extensions, and delayed-expansion state saved by the innermost
`setlocal`. It has no effect outside a batch file; reaching end-of-file performs
an implicit `endlocal` for every remaining scope.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `endlocal`: Pop the innermost `setlocal` scope and restore its saved Cmd
  environment, command-extension state, and delayed-expansion state.

## Returning a value

Cmd expands a complete line before executing it, which permits a simple value
to cross the boundary:

```bat
setlocal DisableDelayedExpansion
set "LOCAL_RESULT=ready"
endlocal & set "RESULT=%LOCAL_RESULT%"
```

This technique is parser-sensitive, not a general safe serialization format.
Values containing `%`, `!`, `^`, `&`, `|`, parentheses, quotes, or newlines
require a deliberately tested encoding/transfer design.

## PowerShell boundaries

`endlocal` is batch control syntax and cannot close a PowerShell scope. Keep
the scope transition and any parser-sensitive value transfer inside the batch
file. Return only a deliberate numeric exit code and structured output across
the child-process boundary; PowerShell then reads `$LASTEXITCODE` and output
without inheriting the child's environment mutations.

## Common mistakes

### Expecting all local changes to remain

The purpose of `endlocal` is restoration. Return only named results and keep
temporary PATH, prompt, extension, and delayed-expansion changes local.

### Copying the one-line return trick for arbitrary text

The value is expanded and parsed around a scope transition. Metacharacters can
change command structure, and delayed expansion can remove exclamation marks.
Do not use this form for untrusted or unrestricted data.

### Ending the wrong nested scope

`endlocal` matches the most recent active `setlocal`. Keep nesting visible and
avoid exits that make ownership unclear.

### Assuming it preserves a prior ERRORLEVEL automatically

Commands used to copy a result can change status. Capture and return the
intended numeric code explicitly with `exit /b CODE` after designing expansion
at the correct time.

## Version and platform differences

This builtin is available inside `cmd.exe` batch files on supported Windows
client and server releases. It is not PowerShell scope syntax.

## Related documents

- [setlocal](setlocal.md)
- [set](set.md)
- [exit](exit.md)

## Sources and license

This original guide was adapted from Microsoft's official
[endlocal reference](https://learn.microsoft.com/windows-server/administration/windows-commands/endlocal).
The common value-transfer use case and its parser constraints are reflected in
[Batch script make setlocal variable accessed by other batch files](https://stackoverflow.com/questions/15494688/batch-script-make-setlocal-variable-accessed-by-other-batch-files).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
