<!-- mant:tldr:start -->
# explorer

> Open a Windows folder or shell item in the interactive desktop shell.
> More information: https://learn.microsoft.com/powershell/scripting/samples/manipulating-items-directly.

- Open the current folder with the common `Invoke-Item` alias:

`ii {{.}}`

- Use the unambiguous full cmdlet name:

`Invoke-Item -LiteralPath {{.}}`

- Open a specific folder in Explorer:

`explorer.exe {{C:\path\folder}}`

- Resolve the executable explicitly:

`Get-Command explorer.exe -All`
<!-- mant:tldr:end -->

# explorer

## Overview

`Explorer.exe` is the default Windows desktop shell and file-management user
interface. From PowerShell, `Invoke-Item` is the provider-aware way to perform
the default action on a folder; on a normal Windows desktop this opens the
folder in File Explorer.

This page intentionally does not present an exhaustive Explorer switch table.
Microsoft's current supported Windows documentation describes shell opening
behavior but does not publish a complete Windows 10/11 `Explorer.exe` command
line contract. Do not build new automation around copied legacy switches
without verifying them on every target release.

## Open a folder

```powershell
$folder = Resolve-Path -LiteralPath 'C:\Windows'
Invoke-Item -LiteralPath $folder
```

Direct invocation is also common when Explorer itself is specifically needed:

```powershell
explorer.exe 'C:\Windows'
```

Opening a folder is an interactive action. It does not return a directory
object, provide a dependable process exit code, or make the window a reliable
automation endpoint.

## Default handlers versus Explorer

`Invoke-Item` performs the provider's default action. A folder normally opens
in Explorer, while a document opens in its registered application. Use
`Get-Item` or `Get-ChildItem` when the goal is to inspect data rather than open
a GUI.

`Start-Process` offers explicit process-launch controls, verbs, and optional
process objects. File associations and shell policy still determine the final
handler for non-executable items.

## Common mistakes

### Using Explorer in headless automation

Explorer requires an interactive Windows shell and user session. A scheduled
task, service account, remote session, or container may have no visible desktop
even if process creation succeeds.

### Waiting for one Explorer process to mean a window closed

Explorer is also the desktop shell and can reuse an existing process. A PID or
`Start-Process -Wait` is not a reliable lifecycle for one folder window.

### Treating UI launch as data access

Opening a folder does not enumerate it, validate permissions, or confirm that a
user completed an action. Use filesystem cmdlets for those tasks.

### Copying undocumented switches

Old Explorer recipes are widely copied, but support varies by Windows release
and shell implementation. Prefer `Invoke-Item`, a documented shell API, or a
plain folder target unless a switch has a current authoritative contract.

## Version and platform differences

This page applies to interactive Windows 10, Windows 11, and Windows Server
desktop installations. Server Core and noninteractive sessions do not provide
the same shell experience. Explorer is not available on Linux or macOS.

## Related documents

- [start](start.md)
- [ms-settings](ms-settings.md)
- [control](control.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original guide is based on Microsoft's PowerShell example for
[manipulating items directly](https://learn.microsoft.com/powershell/scripting/samples/manipulating-items-directly),
the official [Invoke-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item),
and the Windows [Shell Launcher overview](https://learn.microsoft.com/windows/configuration/shell-launcher/).
The high-frequency `ii .` usage and alternative forms are reflected in the
community discussion
[Is it possible to open a Windows Explorer window from PowerShell?](https://stackoverflow.com/questions/320509/is-it-possible-to-open-a-windows-explorer-window-from-powershell/321092).
Page-level provenance is recorded in `upstream/windows-tools.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
