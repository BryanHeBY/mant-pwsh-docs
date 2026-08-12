<!-- mant:tldr:start -->
# color

> Change colors only in the current Cmd session; verify digit order with target-local help because Microsoft's page text and example conflict.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/color.

- Display target-local color syntax and digit order:

`cmd.exe /d /c color /?`

- In the current Cmd session, restore configured default colors:

`color`

- Start an isolated interactive Cmd and test black background with light-green foreground according to traditional COLOR help:

`cmd.exe /d /k "color 0A"`

- In PowerShell, use host colors only for optional presentation, not machine-readable meaning:

`Write-Host "{{message}}" -ForegroundColor {{Green}}`

<!-- mant:tldr:end -->

# color

## Overview

`color` is a Cmd builtin that changes the current session's foreground and
background console colors or restores defaults when no attribute is supplied.
Hex digits `0` through `F` select the legacy 16-color palette. Supplying the
same foreground/background value returns ERRORLEVEL 1 and makes no change.

Microsoft's current online page is internally inconsistent: its parameter text
says the first digit is foreground and the second background, while its `84`
example describes first-digit background and second-digit foreground, matching
traditional target-local help. On the reviewed Windows build, `help color`
explicitly says first digit background and second foreground. Treat installed
help and a disposable visual test as the runtime authority; do not silently
choose one for another build.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `color`: Restore default Cmd console colors with no operand, or request one
  two-hex-digit background/foreground palette attribute.

Target-local `color /?` is the authority for digit order because Microsoft's
current prose/example are internally inconsistent. Equal digits fail with
ERRORLEVEL 1.

## Common mistakes

### Reversing foreground and background from copied documentation

Check `color /?` on the exact Windows build and test in an isolated child Cmd.
Record both intended colors and attribute; never infer order from an uncited
snippet or agent memory.

### Encoding status only by color

Color can be unavailable, remapped, low-contrast, inaccessible, or stripped in
logs/remoting. Always include explicit text/symbols and machine-readable exit
status; validate contrast and high-contrast themes.

### Expecting color to persist or affect PowerShell

The command changes the current Cmd session. Terminal profiles, conhost defaults,
ANSI sequences, PowerShell host colors, child processes, and redirected output
are separate. Do not write registry/default settings for a one-session need.

### Sending color commands to logs or noninteractive hosts

It may fail, do nothing, or produce host-specific control effects. In the
reviewed redirected capture environment, both valid `0A` and invalid `00`
returned 1; in separate hidden-console processes, `0A` returned 0 and `00`
returned 1. Detect console capability and keep automation output
plain/structured by default. Do not interpret status 1 as proof that the two
digits were equal unless the process had a suitable console and the operand is
known.

### Ignoring the failure result

Same foreground/background is rejected with ERRORLEVEL 1. Capture result before
another command and restore defaults in cleanup when a script temporarily
changes presentation.

## PowerShell boundaries

Bare `color` is not a PowerShell cmdlet. Use `cmd.exe /d /k` only for an
interactive Cmd session. PowerShell `Write-Host` colors one host stream and is
also host-dependent; neither should carry program logic.

## Version and platform differences

This Windows Cmd builtin uses a legacy palette whose actual rendering depends
on console host, terminal profile, theme, accessibility settings, redirection,
and Windows build. Target-local help is necessary because the online reference
currently contradicts its own example.

On Windows NT `10.0.26200.0`, `cmd.exe /d /c help color` printed the installed
background-then-foreground contract and the `fc` example, with Cmd's usual
help status 1. In separate hidden-console child processes, `color 0A` returned
0 and `color 00` returned 1; the same two calls in a redirected capture context
both returned 1. All children exited and no console, terminal profile,
registry default, environment, filesystem, or persistent color setting was
changed.

## Runtime evidence

Installed `cmd.exe /d /c help color` described the background-first,
foreground-second digit order and returned Cmd's normal help status `1`.
Separate task-owned children with a hidden console returned `0` for `color 0A`
and `1` for invalid same-digit `color 00`; redirected children returned `1`
for both, proving that console capability is part of the result. No shared
console, terminal profile, registry default, or persistent color state changed.

## Related documents

- [cls](cls.md)
- [prompt](prompt.md)
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Color reference](https://learn.microsoft.com/windows-server/administration/windows-commands/color).
The page's current parameter text/example inconsistency is recorded explicitly
rather than resolved by assumption; runtime claims require installed help and a
disposable target-host test. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
