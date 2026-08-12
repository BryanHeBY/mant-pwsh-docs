<!-- mant:tldr:start -->
# break

> Recognize a no-effect MS-DOS compatibility builtin; it is not the PowerShell
> loop keyword, a Cmd loop exit, or a safe file-clearing primitive.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/break.

- Display the installed Cmd compatibility help:

`cmd.exe /d /c "help break"`

- In PowerShell, leave the nearest loop with the language keyword:

`foreach ($item in 1..10) { if ($item -eq 5) { break }; $item }`

- Create a new empty file while refusing to overwrite an existing path:

`New-Item -ItemType File -Path "{{new-file}}" -ErrorAction Stop`

- Before intentionally clearing an existing file, inspect its exact identity:

`Get-Item -LiteralPath "{{existing-file}}" | Format-List FullName, Length, LastWriteTime, Attributes, LinkType, Target`

<!-- mant:tldr:end -->

# break

## Overview

Cmd's `break=on|off` is retained for compatibility with MS-DOS batch files.
Microsoft states that it is no longer in use and has no ordinary command-line
effect because Ctrl+C handling is automatic. With command extensions enabled,
a `break` statement in a batch file has a debugger-specific hard-coded
breakpoint behavior when that batch file is being debugged.

This command is unrelated to PowerShell's `break` language keyword. Cmd has no
general `break` statement for leaving `for` loops; structure batch control flow
explicitly rather than relying on this compatibility name.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `break`: Display or set the obsolete Cmd `break=on|off` compatibility state;
  it does not exit loops in ordinary batch execution.

The `on` and `off` values are operands, not PowerShell switches. Redirection
still occurs even though the compatibility setting has no normal effect.

## Common mistakes

### Using `break` to exit a Cmd loop

It does not provide that control flow. Rework the loop, call a subroutine with a
clear return contract, or use a fixed `goto` label only when maintaining batch
code requires it. In PowerShell, `break` is parsed by PowerShell and exits the
applicable loop, switch, or labeled construct.

### Assuming a no-effect command makes redirection harmless

Redirection is performed by the shell. `break>log` can create or truncate `log`
even though `break` itself has no normal effect. Never use this idiom against an
unresolved, variable, linked, shared, or evidence-bearing path.

### Copying `break>file` as an empty-file recipe

For a new file, use `New-Item` without `-Force` so an existing target causes an
error. For an intentional truncation, resolve and inspect the exact path, back
up retained data, reject reparse links, then use an explicit file operation such
as `Clear-Content -LiteralPath ... -Confirm`. Verify the result and preserve the
audit record.

### Confusing compatibility behavior with Ctrl+C policy

Modern console input, process groups, services, remoting, terminals, debugger
state, PowerShell stopping, and application-specific cancellation are separate.
Do not use `break on` as a reliability or security control.

### Ignoring debugger-only behavior

A legacy line that appears inert can behave differently while the batch file is
under a debugger with command extensions enabled. Preserve it only with a known
compatibility reason and test the actual debug workflow.

## PowerShell boundaries

In PowerShell source, `break` is a language keyword, not a command resolved by
`Get-Command`. To reach the Cmd compatibility builtin, invoke an explicit child
Cmd. Do not place untrusted expressions inside a `cmd.exe /c` command string.

## Version and platform differences

Microsoft documents this builtin on supported Windows client and server
releases solely for MS-DOS compatibility. Historical MS-DOS behavior must not
be projected onto modern Cmd. PowerShell's keyword semantics are documented by
the applicable PowerShell edition and language version.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 `cmd.exe` fixed version
`10.0.26100.8737` returned six nonempty lines and status `1` for
`cmd.exe /d /c help BREAK` under both PowerShell collectors. The fixture did
not retain the localized payload. This proves only static help discovery: no
BREAK statement ran, no debugger context was entered, and no redirection or
file target was supplied.

## Related documents
- [for](for.md)
- [goto](goto.md)
- [cmd.exe](cmd.exe.md)
- [del](del.md)

## Sources and license

This original compatibility guide was adapted from Microsoft's official
[Break reference](https://learn.microsoft.com/windows-server/administration/windows-commands/break),
which also documents the dangerous redirection idiom so readers can recognize
rather than copy it. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
