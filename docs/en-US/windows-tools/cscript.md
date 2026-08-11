<!-- mant:tldr:start -->
# cscript

> Run a reviewed Windows Script Host script in a console with explicit host options, a quoted local path, bounded runtime, least privilege, and native exit/output checks; `.js` here means legacy JScript, not Node.js.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cscript.

- Show the installed Windows Script Host console options:

`cscript.exe //?`

- Run a reviewed local script without the host banner:

`cscript.exe //NoLogo '.\script.vbs'`

- Suppress interactive dialogs and cap a reviewed unattended script at 60 seconds:

`cscript.exe //NoLogo //B //T:60 '.\script.vbs'`
<!-- mant:tldr:end -->

# cscript

## Overview

`cscript.exe` is the console host for Windows Script Host (WSH) scripts such as
VBScript (`.vbs`), legacy JScript (`.js`) and Windows Script Files (`.wsf`). It
attaches standard streams to a console, so it is normally preferable to
`wscript.exe` for automation, logging and pipeline integration.

## Important options

<!-- mant:entries role=command case=insensitive -->
- `cscript.exe`: Run a Windows Script Host script in the console host.

Real WSH host options use `//` (`//B`, `//E`, `//H`, `//I`, `//Job`, `//Logo`,
`//Nologo`, `//S`, `//T`, and `//X`). ManT does not yet support double-slash
semantic tokens, so they remain fully described below instead of being changed
to invalid single-slash spellings.

```text
cscript SCRIPT [host options] [script arguments]
//B                 batch mode: suppress alerts, errors and input prompts
//I                 interactive mode
//E:ENGINE          select a registered script engine
//Job:ID            run one job from a .wsf file
//NoLogo            suppress the WSH banner
//T:SECONDS         terminate after a bounded time
//U                 use Unicode console I/O mode
//H:cscript|wscript change the default host
//S                 save current per-user host options
```

Use the installed `cscript //?` spelling and put host switches before the
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

## Related documents

- [wscript](wscript.md)
- [cmd](cmd.md)
- `powershell.exe` and `pwsh` in their respective PowerShell sources
- [where](where.md)

## Sources and license

Microsoft's official [cscript reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cscript)
defines the host and options. The widely referenced
[Stack Overflow cscript/wscript comparison](https://stackoverflow.com/questions/8678441/difference-between-wscript-and-cscript)
records the recurring console-versus-GUI output confusion; it is not syntax
authority. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
