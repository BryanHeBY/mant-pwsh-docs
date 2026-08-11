<!-- mant:tldr:start -->
# wscript

> Run a reviewed Windows Script Host script only when it intentionally needs interactive GUI dialogs; use `cscript.exe` for console output, redirection, unattended execution and dependable observation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/wscript.

- Show Windows Script Host GUI options:

`wscript.exe //?`

- Run a reviewed local interactive script with the host banner suppressed:

`wscript.exe //NoLogo '.\script.vbs'`

- Use the console host instead when output and exit handling matter:

`cscript.exe //NoLogo //B //T:60 '.\script.vbs'`
<!-- mant:tldr:end -->

# wscript

## Overview

`wscript.exe` is the GUI host for Windows Script Host scripts. Unlike
`cscript.exe`, it does not provide normal console standard streams; operations
such as `WScript.Echo` commonly produce dialogs. It is suited to reviewed,
interactive legacy scripts, not headless automation.

## Common mistakes

- Expecting PowerShell capture or redirection to receive `WScript.Echo` text.
  Choose `cscript.exe` when the script has a console output contract.
- Launching with `Start-Process` and treating process creation or wait completion
  as proof that every dialog, child process and application action succeeded.
- Using `//B` to suppress prompts in an unattended script without ensuring the
  script can proceed safely and expose errors through an alternative channel.
- Running `wscript.exe` without a script as a harmless help command. It opens
  global WSH settings; saved changes can affect later scripts for that user.
- Changing the default host through `//H` or persisted options through `//S`
  without recording and restoring the prior user configuration.
- Executing untrusted script attachments. GUI hosting is not a sandbox; scripts
  retain the user's file, registry, COM, network and application access.
- Confusing `.js` with Node.js or a browser runtime, and `.wsf` with inert XML.

## PowerShell behavior

Invoke `wscript.exe` explicitly and use a fully resolved, quoted script path.
PowerShell normally cannot consume GUI dialog text as stdout.
`Start-Process -Wait -PassThru` can observe the WScript host process, but the script's own
dialogs, child processes and exit semantics still require an explicit contract.

## Version and platform differences

`wscript.exe` is Windows-only. Script engines, COM automation objects, default
host configuration, bitness and policy vary by build, architecture, user and
installed applications.

## Related documents

- [cscript](cscript.md)
- [cmd](cmd.md)
- [tasklist](tasklist.md)
- [where](where.md)

## Sources and license

Microsoft's official [wscript reference](https://learn.microsoft.com/windows-server/administration/windows-commands/wscript)
defines GUI-host options and persisted defaults. The highly viewed
[Stack Overflow host comparison](https://stackoverflow.com/questions/8678441/difference-between-wscript-and-cscript)
captures the recurring dialog-versus-console mistake; it is not syntax
authority. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
