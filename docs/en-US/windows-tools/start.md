<!-- mant:tldr:start -->
# start

> Start a command, program, document, directory, or URL through the `cmd.exe` builtin.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/start.

- Check whether bare `start` resolves to the PowerShell alias:

`Get-Command start -All`

- Start a program with PowerShell semantics:

`Start-Process -FilePath {{app.exe}} -ArgumentList {{argument}}`

- Start a quoted program path with cmd semantics and the required empty title:

`cmd.exe /d /c 'start "" {{notepad.exe}}'`

- Open a URL with its registered handler:

`cmd.exe /d /c 'start "{{title}}" "{{https://example.com}}"'`

- Wait for the started program:

`cmd.exe /d /c 'start "" /wait "{{C:\path\app.exe}}" {{argument}}'`
<!-- mant:tldr:end -->

# start

## Overview

`start` is a `cmd.exe` builtin. It can launch a command or program in a separate
Command Prompt window, open a document or URL through its file association, or
open a directory in Explorer. It is not a standalone `start.exe` program.

In PowerShell, bare `start` normally means the alias for `Start-Process`, which
has different parsing, options, waiting, and output behavior.

## Syntax

```text
start "TITLE" [/d PATH] [/i] [/min | /max] [/separate | /shared]
      [/low | /normal | /high | /realtime | /abovenormal | /belownormal]
      [/node NUMA-NODE] [/affinity HEX-MASK] [/wait] [/b]
      [/machine ARCHITECTURE] [COMMAND-OR-PROGRAM [ARGUMENT ...]]
```

## Important options

The first quoted `"TITLE"` token sets the new Command Prompt window title; it
is not automatically interpreted as the program path.

<!-- mant:entries role=option case=insensitive -->
- `/d PATH`: Set the startup directory.
- `/i`: Pass the original `cmd.exe` startup environment instead of the current
  environment.
- `/min`, `/max`: Start the window minimized or maximized.
- `/separate`, `/shared`: Start a 16-bit Windows program in separate or shared
  memory space where the legacy subsystem supports it; these switches are not
  supported on 64-bit platforms.
- `/low`, `/normal`, `/high`, `/realtime`, `/abovenormal`, `/belownormal`:
  Select a process priority class. Avoid elevated priorities without a measured
  need.
- `/node NUMBER`: Select a preferred NUMA node.
- `/affinity HEX-MASK`: Set a processor affinity mask in hexadecimal.
- `/wait`: Wait for the started application to end.
- `/b`: Do not open a new Command Prompt window; use Ctrl+Break when the target
  does not enable Ctrl+C processing.
- `/machine ARCHITECTURE`: Select `x86`, `amd64`, `arm`, or `arm64` where the
  installed Windows build supports this preview option.

## PowerShell boundaries

`start` is a `cmd.exe` builtin, while PowerShell can resolve `start` as an
alias for `Start-Process`. Invoke `cmd.exe /d /c` for this exact grammar and
preserve the first quoted title argument; use `Start-Process` when its typed
parameters are the intended interface.

## Quoted program paths

Because the first quoted token is the title, use an empty title before a quoted
program path:

```powershell
$line = 'start "" "C:\Program Files\Example\app.exe" "input file.txt"'
cmd.exe /d /c $line
```

When PowerShell features are sufficient, avoid this second parser and use a
direct invocation or `Start-Process` instead.

## Common mistakes

### Using cmd syntax with the PowerShell alias

`start "" /wait app.exe` entered directly in PowerShell binds arguments to
`Start-Process`; it is not parsed as the cmd builtin. Use the full command name
appropriate to the intended shell.

### Treating the first quoted path as the program

`cmd.exe /c 'start "C:\Program Files\Example\app.exe"'` treats the quoted text
as a title and may open an empty command window. Supply `""` as the title
before the quoted path.

### Assuming launch proves completion

Without `/wait`, start normally returns after launching. Even with `/wait`, a
program can delegate work to an existing process or another service. Verify the
requested file, installation, or configuration state instead of treating
window creation as success.

### Copying `/machine` to ordinary scripts

Microsoft documents `/machine` as a preview Windows 11 option. Detect support
on the target build and do not make it a portable default.

## Version and platform differences

`start` is Windows-only and requires `cmd.exe`. Handler availability depends on
file associations, installed applications, Windows version, user session, and
policy. GUI and URL examples require an interactive desktop session.

## Related documents

- [cmd.exe](cmd.exe.md)
- [explorer.exe](explorer.exe.md)
- [ms-settings](ms-settings.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's official
[start reference](https://learn.microsoft.com/windows-server/administration/windows-commands/start).
It also uses the recurring process-wait distinctions discussed in the
community reference
[PowerShell waits on cmd.exe differently depending on environment](https://stackoverflow.com/questions/45122619/powershell-waits-on-cmd-exe-differently-depending-on-environment).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
