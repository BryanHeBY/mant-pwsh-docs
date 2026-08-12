<!-- mant:tldr:start -->
# setlocal

> Localize environment and cmd parsing state inside a batch file.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/setlocal.

- Start a normal local environment scope:

`setlocal`

- Enable execution-time `!NAME!` expansion in the current batch scope:

`setlocal EnableExtensions EnableDelayedExpansion`

- Restore the state saved by the matching `setlocal`:

`endlocal`
<!-- mant:tldr:end -->

# setlocal

## Overview

`setlocal` is a `cmd.exe` batch-file builtin. It saves environment variables,
command-extension state, and delayed-expansion state; `endlocal` or the end of
the batch file restores them. It has no effect when entered outside a batch
script.

## Syntax

```text
setlocal [EnableExtensions | DisableExtensions]
         [EnableDelayedExpansion | DisableDelayedExpansion]
```

Scopes can be nested and must be reasoned about as a stack.

## Commands and modes

<!-- mant:entries role=command case=insensitive -->
- `setlocal`: Save the current batch environment, extension state, and delayed
  expansion state on a nested localization stack.
- `EnableExtensions`: Enable Cmd command extensions in the new local scope.
- `DisableExtensions`: Disable Cmd command extensions in the new local scope.
- `EnableDelayedExpansion`: Enable execution-time `!NAME!` expansion in the
  new local scope.
- `DisableDelayedExpansion`: Disable execution-time exclamation-mark expansion
  in the new local scope.

## Delayed expansion

Percent references such as `%COUNT%` are expanded when cmd parses a complete
parenthesized block. After enabling delayed expansion, `!COUNT!` reads the value
when that command executes:

```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "COUNT=0"
for %%F in (*.txt) do (
  set /a COUNT+=1 >nul
  echo !COUNT!: %%F
)
endlocal
```

## PowerShell boundaries

`setlocal` is valid only while a batch file is executing; it is not a
PowerShell scoping primitive and has no durable effect on its parent process.
Use PowerShell functions/script blocks and explicit child-process environment
values for PowerShell code. When invoking a batch file, rely on its explicit
process exit code rather than attempting to import its localized variables.

## Common mistakes

### Expecting local values to survive

Environment changes after `setlocal` are discarded at the matching `endlocal`
or implicit end of file. Return only explicitly designed values; do not remove
localization merely to make every temporary variable global.

### Enabling delayed expansion for arbitrary text

When delayed expansion is enabled, literal `!` characters can be consumed or
reinterpreted during parsing. Disable it while capturing untrusted filenames or
text, then enable it only around operations that require changing block values.

### Reading `%ERRORLEVEL%` after a command inside a block

The percent form may have been expanded before the command ran. Use a direct
`if errorlevel N` test, or carefully scoped delayed expansion with
`!ERRORLEVEL!`.

### Forgetting that `setlocal` itself changes ERRORLEVEL

Microsoft documents `ERRORLEVEL` 0 when an enable/disable argument is supplied
and 1 when none is supplied. Capture a preceding command's result before
running `setlocal`.

### Running it from PowerShell or an interactive prompt

This is batch control syntax, not a PowerShell scope primitive. PowerShell
scripts should use normal variables, script blocks, functions, and child
process environment rules.

## Version and platform differences

`setlocal` requires a Windows batch file. Command extensions are enabled by
default on supported Windows releases but can be changed by policy, registry,
launcher options, or an outer batch scope.

## Runtime evidence

The protected fixture used only a child `cmd.exe` and fixed task variables. It
confirmed parse-time percent versus execution-time delayed expansion and the
narrow `endlocal & set "NAME=%NAME%"` same-line transfer idiom under both
PowerShell collectors. Arbitrary exclamation-bearing input, nested extension
state, and persistence outside the child were not exercised.

## Related documents

- [set](set.md)
- [cmd.exe](cmd.exe.md)
- [Windows tools index](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's official
[setlocal reference](https://learn.microsoft.com/windows-server/administration/windows-commands/setlocal).
The recurring parse-time versus execution-time confusion is reflected in the
community discussion
[How do you use SETLOCAL in a batch file?](https://stackoverflow.com/questions/13704223/how-do-you-use-setlocal-in-a-batch-file).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow content
under CC BY-SA 4.0. This adaptation is CC BY 4.0; no answer text is reproduced.
