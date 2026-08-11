<!-- mant:tldr:start -->
# clip

> Replace the Windows text clipboard with standard input.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/clip.

- Copy native command output to the Windows clipboard:

`{{command}} | clip.exe`

- Copy a text file through cmd redirection:

`cmd.exe /d /c 'clip.exe < "{{C:\path\file.txt}}"'`

- Copy one PowerShell string without native-pipeline encoding ambiguity:

`Set-Clipboard -Value '{{text}}'`
<!-- mant:tldr:end -->

# clip

## Overview

`clip.exe` consumes standard input and replaces the Windows text clipboard.
It is convenient for interactive text, but the clipboard is shared mutable
desktop state rather than a durable automation channel.

## Syntax

```text
COMMAND | clip.exe
clip.exe < FILE
```

## Common mistakes

### Expecting clipboard content on standard output

`clip.exe` writes input to the clipboard; it is not a clipboard reader. Use
`Get-Clipboard` where available and appropriate.

### Losing fidelity through a native text pipeline

PowerShell-to-native encoding behavior differs by PowerShell edition and
configuration. For PowerShell text, prefer `Set-Clipboard`; for a file, test
non-ASCII characters, line endings, and the desired trailing newline.

### Treating clipboard success as durable delivery

Another application, session, remote desktop boundary, service account, or
noninteractive host can make clipboard state unavailable or replace it. Do
not use it for secrets or unattended interprocess guarantees.

### Copying objects instead of intended fields

PowerShell formats objects into text for a native pipeline. Select and render
the exact properties first, or use `Set-Clipboard` with deliberate strings.

## Version and platform differences

`clip.exe` targets interactive Windows clipboard sessions. `Set-Clipboard`
availability and behavior depend on PowerShell edition, platform, and host.

## Related documents

- [type](type.md)
- [find](find.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's official
[clip reference](https://learn.microsoft.com/windows-server/administration/windows-commands/clip).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
