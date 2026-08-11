<!-- mant:tldr:start -->
# doskey.exe

> Inspect interactive console history and executable-scoped macros; DOSKEY macros are not PowerShell aliases and cannot be invoked from batch programs.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/doskey.

- List macros registered for every console executable in the current console session:

`doskey.exe /macros:all`

- Display the current executable's in-memory command history, treating it as secret-bearing data:

`doskey.exe /history`

- Inspect PowerShell aliases, functions, cmdlets, and applications instead of expecting DOSKEY macro visibility:

`Get-Command {{name}} -All -ErrorAction SilentlyContinue`

- Display the installed syntax for positional/trailing arguments, command separators, redirection, and pipe tokens:

`doskey.exe /?`

<!-- mant:tldr:end -->

# doskey.exe

## Overview

`doskey.exe` supplies interactive line editing, per-console/per-executable
history, and text macros for compatible console processes. A macro belongs to
the named executable context and the current console session. It is input-line
expansion, not a shell function, executable, PowerShell alias, or durable script.

Microsoft explicitly says a DOSKEY macro cannot be run from a batch program.
Macros also do not behave reliably as commands on either side of pipes or other
non-interactive input. Use `.cmd` files for Cmd automation and functions/scripts
for PowerShell automation.

## Macro tokens and scope

`$1` through `$9` represent positional macro arguments and `$*` represents all
remaining text. `$T` separates commands; other `$` tokens represent redirection,
append, input, pipe, or a literal dollar sign. These are textual expansions
processed before the target program, so untrusted arguments can acquire shell
meaning. Do not build security boundaries on macro quoting.

`/exename` selects the console executable whose input gets the macro. Macro and
history buffers are in-memory console state. `/macrofile` imports definitions;
`/reinstall` clears history while reinstalling DOSKEY behavior. Exported macro
and history files can contain credentials, tokens, hostnames, paths, or commands.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `doskey.exe`: Manage interactive line editing, history, and text macros for
  one compatible executable in the current console session.

Macros are input-line expansion and cannot be invoked reliably from batch files.

<!-- mant:entries role=option case=insensitive -->
- `/reinstall`: Reinstall DOSKEY behavior and clear the associated command history.
- `/listsize`: Set the maximum history-buffer size.
- `/macros`: Display macros for the current executable context.
- `/history`: Display command history for the selected executable context.
- `/insert`: Insert newly typed characters at the cursor.
- `/overstrike`: Replace existing characters as new characters are typed.
- `/exename`: Select the executable context whose macros/history are managed.
- `/macrofile`: Import macro definitions from the following reviewed text file.
- `/?`: Display installed command help.

## Common mistakes

### Calling a macro from `.bat` or `.cmd`

The definition command can run in a batch file, but later macro invocation from
batch input is unsupported. Replace it with a called batch file/subroutine or
an actual executable. Do not automate keystrokes to simulate interactive input.

### Treating a macro as a PowerShell alias

PowerShell's parser and PSReadLine normally own its interactive command line;
`Get-Command` does not discover DOSKEY macros. Use PowerShell functions for
arguments and control flow, aliases only for simple command-name mapping, and
profiles with appropriate trust/review.

### Forgetting `$*`

Unlike common shell aliases, remaining user input is not automatically appended.
If a macro deliberately accepts trailing text, include `$*` and test spaces,
quotes, metacharacters, redirection, empty arguments, and malicious input. A
macro is not a safe parameter binder.

### Importing an unreviewed macro file

A macro can chain commands, redirect files, or pass credentials. Read the exact
file as data, review every target executable and token, verify path/ACL/hash,
and import only into a disposable or approved interactive session.

### Exporting history as a reusable batch script

`/history` records text, not a validated idempotent program. It can include
secrets, failed partial commands, destructive operations, interactive state,
and environment-specific paths. Protect the export and rewrite/review it rather
than executing it directly.

### Clearing shared history accidentally

`/reinstall`, Alt+F7, and other editing keys affect the current program's
in-memory buffer. Record anything required for an investigation first and
coordinate with the console owner.

## PowerShell boundaries

Invoke `doskey.exe` explicitly for inspection. PowerShell's `$` interpolation
can alter macro-token text in double-quoted strings, while Cmd metacharacters
have another parsing pass. Avoid dynamic macro construction; if legacy use is
unavoidable, pass reviewed literal arguments and verify with `/macros:all`.

## Version and platform differences

This Windows-only compatibility utility applies to supported Windows client
and server releases. Behavior depends on console process, input mode, terminal
host, PSReadLine/readline layer, executable key handling, session lifetime, and
policy. It is not evidence that MS-DOS is running.

## Related documents

- [cmd.exe](cmd.exe.md)
- [call](call.md)
- [windows-tools](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DOSKEY reference](https://learn.microsoft.com/windows-server/administration/windows-commands/doskey).
The batch/noninteractive and PowerShell-scope traps were prioritized using
high-demand practitioner discussions about
[batch invocation](https://stackoverflow.com/questions/36616151/doskey-alias-does-not-work-in-batch-script-windows-7),
[PowerShell resolution](https://stackoverflow.com/questions/55090336/how-to-get-full-command-from-doskey-alias-in-windows-powershell),
and [interactive alias limitations](https://superuser.com/questions/560519/how-to-set-an-alias-in-windows-command-line).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow and Super User contributions are licensed under CC BY-SA 4.0.
