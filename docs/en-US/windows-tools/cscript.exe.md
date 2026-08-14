<!-- mant:tldr:start -->
# cscript.exe

> Run a reviewed Windows Script Host script in a console with explicit host options, a quoted local path, bounded runtime, least privilege, and native exit/output checks; `.js` here means legacy JScript, not Node.js.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cscript.

- Show the installed Windows Script Host console options:

`cscript.exe //?`

- Run a reviewed local script without the host banner:

`cscript.exe //NoLogo '.\script.vbs'`

- Suppress interactive dialogs and cap a reviewed unattended script at 60 seconds:

`cscript.exe //NoLogo //B //T:60 '.\script.vbs'`

- Run a reviewed script through one explicitly selected registered engine:

`cscript.exe //NoLogo //E:{{VBScript|JScript}} "{{C:\Scripts\script.txt}}"`

- Run one named job from a reviewed Windows Script File:

`cscript.exe //NoLogo //Job:{{job-id}} "{{C:\Scripts\jobs.wsf}}"`

- Use Unicode for redirected console input and output:

`cscript.exe //NoLogo //U "{{C:\Scripts\report.vbs}}" > "{{C:\Evidence\report.txt}}"`

- Enable the registered debugger and break when a script error occurs:

`cscript.exe //NoLogo //D "{{C:\Scripts\script.vbs}}"`

- Start a reviewed script in the registered debugger from its first line:

`cscript.exe //NoLogo //X "{{C:\Scripts\script.vbs}}"`
<!-- mant:tldr:end -->

# cscript.exe

## Overview

`cscript.exe` is the console host for Windows Script Host (WSH) scripts such as
VBScript (`.vbs`), legacy JScript (`.js`) and Windows Script Files (`.wsf`). It
attaches standard streams to a console, so it is normally preferable to
`wscript.exe` for automation, logging and pipeline integration.

## Important options

<!-- mant:entries role=command case=insensitive -->
- `cscript.exe`: Run a Windows Script Host script in the console host.

Real WSH host options use `//` and must precede the script path.

<!-- mant:entries role=option case=insensitive -->
- `//B`: Use batch mode, suppressing alerts, script-error dialogs, and input prompts.
- `//D`: Start the registered script debugger.
- `//E:ENGINE`: Select the registered scripting engine instead of choosing it from the file extension.
- `//H:HOST`: Register `cscript.exe` or `wscript.exe` as the current user's default script host.
- `//I`: Use interactive mode, displaying alerts, errors, and input prompts; this is the default.
- `//Job:ID`: Run the identified job from a Windows Script File (`.wsf`).
- `//Logo`: Display the Windows Script Host banner before the script runs; this is the default.
- `//Nologo`: Suppress the Windows Script Host banner.
- `//S`: Save the current host options as per-user defaults for later launches.
- `//T:SECONDS`: Stop the script after the bounded runtime, up to the installed host's supported limit.
- `//U`: Use Unicode for console input and output that is redirected.
- `//X`: Start the script in the debugger.
- `//?`: Display installed Windows Script Host syntax and parameters.

Use the installed `cscript.exe //?` spelling and put host switches before the
script path. Treat script arguments as the script's own interface and quote
them for PowerShell before WSH parses them.

## Common mistakes

- Executing a downloaded `.vbs`, `.js` or `.wsf` merely to inspect it. WSH
  scripts can use COM and the current user's rights to change files, registry,
  network resources, applications and system configuration.
- Using `wscript.exe` in unattended automation and discovering that
  `WScript.Echo`, errors or prompts appear as blocking GUI dialogs.
- Assuming `//B` makes a script safe. It hides dialogs; it does not restrict
  capabilities, grant input defaults, sandbox COM or make failures visible.
- Omitting `//T` for an untrusted or historically unreliable workload, or using
  too short a timeout that interrupts a non-transactional change halfway.
- Changing the default host with `//H` or saving defaults with `//S` as a casual
  test. These affect later launches for the user and can silently change scripts.
- Treating WSH `.js` as browser JavaScript or Node.js, or assuming a script
  engine exists because the extension is familiar.
- Parsing localized console text without checking exit status, encoding and the
  script's own stdout/stderr contract.

## PowerShell boundaries

Invoke `cscript.exe` explicitly so `.vbs` file association and `wscript.exe`
defaults cannot change the host. PowerShell parses and removes its own quotes
before WSH receives arguments. Capture stdout/stderr deliberately and check
`$LASTEXITCODE`; a script can implement a poor or absent exit-code contract.

## Version and platform differences

`cscript.exe` is Windows-only. Available engines, COM objects, bitness,
security policy, optional legacy components, encoding and script behavior vary
by Windows build, architecture and installed applications.

On Windows NT `10.0.26200.0`, exact System32 file version `10.0.26100.4768`
printed 17 nonempty help lines for `//?`, returned 0, and produced no Windows
PowerShell 5.1 `ErrorRecord` objects. No script path or code was supplied, so
no script engine, COM object, dialog, persisted host option, or script action
ran.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 file version 10.0.26100.4768
explicit //? returned 17 nonempty help lines, status 0 and no Windows
PowerShell 5.1 ErrorRecord objects. No script or code ran and no WSH
default/persisted option changed; an approved inert code-reviewed
least-privilege fixture remains required for execution evidence.

## Related documents
- [wscript.exe](wscript.exe.md)
- [cmd.exe](cmd.exe.md)
- `powershell.exe` and `pwsh` in their respective PowerShell sources
- [where.exe](where.exe.md)

## Sources and license

Microsoft's official [cscript reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cscript)
defines the host and options. The widely referenced
[Stack Overflow cscript/wscript comparison](https://stackoverflow.com/questions/8678441/difference-between-wscript-and-cscript)
records the recurring console-versus-GUI output confusion; it is not syntax
authority. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
