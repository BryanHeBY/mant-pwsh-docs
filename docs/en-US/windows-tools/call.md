<!-- mant:tldr:start -->
# call

> Call another batch file or a labeled subroutine and return to the caller.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/call.

- Call another batch file from a batch file:

`call "{{C:\path\child.cmd}}" {{arguments}}`

- Call a labeled subroutine in the current batch file:

`call :{{label}} {{arguments}}`

- Get the full directory of the current batch file inside a called context:

`set "{{SCRIPT_DIR}}=%~dp0"`
<!-- mant:tldr:end -->

# call

## Overview

`call` is a `cmd.exe` batch builtin. It invokes another `.bat`/`.cmd` file or a
label as a subroutine and then resumes after the call. It has no useful effect
at an interactive prompt and is not required to invoke a batch file from
PowerShell.

## Syntax

```text
call [DRIVE:][PATH]FILE.cmd [BATCH-ARGUMENTS]
call :LABEL [ARGUMENTS]
```

Command extensions must be enabled for label subroutines. `exit /b CODE` or
the end of the subroutine returns to the caller.

<!-- mant:entries role=command case=insensitive -->
- `call`: Invoke another batch file or a `:LABEL` subroutine and resume at the
  following line when that called context returns.

## Arguments and modifiers

Inside the called context, `%0` is its name and `%1` through `%9` are arguments;
`%*` represents all arguments. Modifiers include `%~1` (remove outer quotes),
`%~f1` (full path), `%~dp1` (drive and directory), `%~nx1` (name and extension),
and `%~$PATH:1` (resolve through PATH). `%~` modifiers do not apply to `%*`.

## PowerShell boundaries

`call` is batch control syntax, not a PowerShell command and not a required
prefix for launching `.cmd`/`.bat` from PowerShell. Keep it inside a reviewed
batch file. At a PowerShell process boundary invoke the batch file explicitly,
pass an argument array rather than concatenated syntax where possible, and
capture `$LASTEXITCODE` after the child `cmd.exe` returns.

## Common mistakes

### Omitting `call` between batch files

From one batch file, executing another batch file without `call` transfers
control and does not reliably return to the following parent line. PowerShell
and process APIs have different launch rules; do not add `call` there.

### Losing arguments containing spaces or metacharacters

Quote each path/argument for cmd's parser and consume a quoted pathname as
`%~1`. Never concatenate untrusted input into executable batch syntax.

### Relying on CALL's second expansion pass

Some legacy recipes use `call echo %%NAME%%` for another percent-expansion
round. It can consume percent signs and reinterpret metacharacters in data.
Prefer direct arguments or narrowly scoped delayed expansion.

### Combining `call` with pipes or redirection

Microsoft explicitly says not to use pipe or redirection symbols with `call`.
Apply redirection to a separately designed command boundary and test the exact
batch parsing context.

### Recursing without an exit condition

A batch file can call itself, exhausting resources or looping indefinitely.
Validate the base case and return an explicit status.

## Version and platform differences

This builtin runs only inside Windows batch files. Label calls require command
extensions, enabled by default on supported Windows releases.

## Runtime evidence

The protected Cmd fixture used a fixed ASCII batch file below a verified
GUID-named temporary root and confirmed under both PowerShell collectors that
`call echo [%%MANT_VALUE%%]` performs CALL's second percent-expansion pass and
returns `0`. It did not pass caller-controlled metacharacters, invoke another
untrusted batch file, recurse, or combine CALL with pipes or redirection.

## Related documents

- [cmd.exe](cmd.exe.md)
- [setlocal](setlocal.md)
- [exit](exit.md)

## Sources and license

This original guide was adapted from Microsoft's official
[call reference](https://learn.microsoft.com/windows-server/administration/windows-commands/call).
The extra-expansion data-loss trap is evidenced by
[Windows Batch Function Removing Special Character From Arguments](https://stackoverflow.com/questions/24176297/windows-batch-function-removing-special-character-from-arguments).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
