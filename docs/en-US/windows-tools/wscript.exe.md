<!-- mant:tldr:start -->
# wscript.exe

> Run a reviewed Windows Script Host script only when it intentionally needs interactive GUI dialogs; use `cscript.exe` for console output, redirection, unattended execution and dependable observation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/wscript.

- Inspect the exact WScript executable/version without opening a GUI dialog:

`Get-Item -LiteralPath "$env:SystemRoot\System32\wscript.exe" | Select-Object FullName, Length, @{n='FileVersionFixed';e={$_.VersionInfo.FileVersionRaw.ToString()}}, @{n='FileVersionString';e={$_.VersionInfo.FileVersion}}`

- Run a reviewed local interactive script with the host banner suppressed:

`wscript.exe //NoLogo '.\script.vbs'`

- Use the console host instead when output and exit handling matter:

`cscript.exe //NoLogo //B //T:60 '.\script.vbs'`
<!-- mant:tldr:end -->

# wscript.exe

## Overview

`wscript.exe` is the GUI host for Windows Script Host scripts. Unlike
`cscript.exe`, it does not provide normal console standard streams; operations
such as `WScript.Echo` commonly produce dialogs. It is suited to reviewed,
interactive legacy scripts, not headless automation.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `wscript.exe`: Run one reviewed Windows Script Host script with GUI/dialog
  semantics, or open per-user host settings when no script is supplied.

Double-slash switches belong to WSH and must precede the script path.

<!-- mant:entries role=option case=insensitive -->
- `//B`: Use batch mode and suppress alerts/prompts; the script still needs a
  safe unattended error/output contract.
- `//D`: Enable active debugging.
- `//E:ENGINE`: Use the named registered script engine instead of extension-based selection.
- `//H:HOST`: Make `cscript.exe` or `wscript.exe` the current user's default WSH host.
- `//I`: Use interactive mode (the default).
- `//Job:ID`: Run the identified job from a `.wsf` file.
- `//Logo`: Display the host banner.
- `//Nologo`: Suppress the host banner.
- `//S`: Save current command options as per-user defaults.
- `//T:SECONDS`: Stop the script after the bounded number of seconds.
- `//X`: Launch under a debugger.
- `//U`: Use Unicode for redirected console I/O where applicable to the host.
- `//?`: Display installed WSH command help.

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

## PowerShell boundaries

Invoke `wscript.exe` explicitly and use a fully resolved, quoted script path.
PowerShell normally cannot consume GUI dialog text as stdout.
`Start-Process -Wait -PassThru` can observe the WScript host process, but the script's own
dialogs, child processes and exit semantics still require an explicit contract.

## Version and platform differences

`wscript.exe` is Windows-only. Script engines, COM automation objects, default
host configuration, bitness and policy vary by build, architecture, user and
installed applications.

On Windows NT `10.0.26200.0`, exact System32 file version `10.0.26100.4768`
was confirmed without supplying a script. A console-capture attempt produced no
reliable text payload and left no residual WScript process. `wscript.exe` is a
GUI host, so no help-output or exit-code claim is retained. Use
`cscript.exe //?` for bounded console discovery, or verify WScript interactively
in a disposable desktop session. No script, engine, COM object, dialog response,
or persistent option was supplied or changed.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 file version 10.0.26100.4768 was
confirmed without supplying a script. A console-capture attempt produced no
reliable text payload and left no residual process; WScript is a GUI host, so
no help-output/status claim is retained. An approved disposable interactive
fixture remains required and no script or persisted option changed.

## Related documents
- [cscript.exe](cscript.exe.md)
- [cmd.exe](cmd.exe.md)
- [tasklist.exe](tasklist.exe.md)
- [where.exe](where.exe.md)

## Sources and license

Microsoft's official [wscript reference](https://learn.microsoft.com/windows-server/administration/windows-commands/wscript)
defines GUI-host options and persisted defaults. The highly viewed
[Stack Overflow host comparison](https://stackoverflow.com/questions/8678441/difference-between-wscript-and-cscript)
captures the recurring dialog-versus-console mistake; it is not syntax
authority. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
