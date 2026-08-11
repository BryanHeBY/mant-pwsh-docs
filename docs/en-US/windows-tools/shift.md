<!-- mant:tldr:start -->
# shift

> Destructively move Cmd batch parameters 1 through 9 left to process more arguments; the original all-arguments expansion never changes and there is no reverse shift.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/shift.

- In a batch file, move `%2` into `%1`, `%3` into `%2`, and so on:

`shift`

- With command extensions, keep `%0` and `%1` unchanged while shifting from `%2`:

`shift /2`

- Read one dequoted current argument before shifting it away:

`set "current=%~1"`

<!-- mant:tldr:end -->

# shift

## Overview

`shift` changes the current batch parameter slots by copying each later value
to the preceding slot. It enables access to arguments beyond `%9`. `/N n`
(written commonly as `/2`) starts at slot 0 through 8 and requires command
extensions. `%*` retains the original full argument text and is not shifted.

## Common mistakes

### Reading `%10` as the tenth argument

Cmd parses `%10` as `%1` followed by `0`. Process one current `%1` at a time and
shift, or choose a language with an actual argument array.

### Shifting before validating or saving an argument

There is no backward shift and the old `%0`/parameter value cannot be recovered
from the slots. Validate count/form, save required values with quoted SET
syntax, then shift exactly once on each successful loop path.

### Looping forever on an empty or invalid parameter

Define a termination condition before SHIFT and ensure every continue/error path
makes progress. Distinguish an omitted argument from an intentionally empty
quoted argument according to the script's contract.

### Assuming `%*` tracks the remaining arguments

Microsoft explicitly says SHIFT has no effect on `%*`. Do not use `%*` as the
remaining queue after shifting; it still represents the original argument text.

### Losing quotes and metacharacter boundaries

`%~1` removes surrounding quotes; `%1` retains source quoting but is still Cmd
syntax when expanded. Avoid re-parsing untrusted arguments, preserve path/data
boundaries, and test spaces, empty strings, `&|<>^%!`, and Unicode.

## PowerShell behavior

SHIFT is only a Cmd batch builtin. PowerShell exposes `$args` and declared
parameters; use parameter binding rather than spawning Cmd. A batch file called
from PowerShell still owns its own parameter slots and quoting rules.

## Version and platform differences

This Windows Cmd builtin is documented on supported releases. `/N` needs
command extensions; parsing varies with CALL, delayed expansion, batch encoding,
and nested Cmd layers.

## Related documents

- [call](call.md)
- [for](for.md)
- [setlocal](setlocal.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Shift reference](https://learn.microsoft.com/windows-server/administration/windows-commands/shift).
The `%10` misconception was prioritized using a high-demand
[practitioner question](https://stackoverflow.com/questions/8328338/how-do-you-utilize-more-than-9-arguments-when-calling-a-label-in-a-cmd-batch-scr).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
