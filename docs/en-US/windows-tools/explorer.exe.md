<!-- mant:tldr:start -->
# explorer.exe

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

- Inspect both fixed and displayed version-resource values without opening Explorer:

`$explorer = Get-Item -LiteralPath (Get-Command explorer.exe -CommandType Application).Source; $explorer.VersionInfo | Select-Object FileVersionRaw, FileVersion, ProductVersionRaw, ProductVersion`
<!-- mant:tldr:end -->

# explorer.exe

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

## Command identities

<!-- mant:entries role=command case=insensitive -->
- `explorer.exe`: Request the Windows desktop shell or a folder window; no complete current switch contract is claimed here.
- `Invoke-Item`, `ii`: Perform a PowerShell provider item's default action; a filesystem folder normally opens in Explorer on an interactive Windows desktop.
- `Start-Process`: Request explicit process-launch behavior while leaving shell associations and GUI lifecycle to Windows.

## PowerShell boundaries

Opening a shell item is a side effect, not object enumeration. Use
`Get-Item`/`Get-ChildItem` for data and do not interpret an Explorer PID or
launcher exit as the lifecycle of one visible window.

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

On the recorded Windows NT `10.0.26200.0` host, `explorer.exe` resolved from
`C:\Windows\explorer.exe`, not System32. The exact file had fixed file/product
version `10.0.26100.8875`, Windows PowerShell 5.1-selected version strings
`10.0.26100.8117`, a valid
Microsoft Windows signature, and SHA-256
`80B21E6F70524EFD84037A4EDA479DDC4BC55C0D6C1A33439B85A554E740F30C`.
No Explorer process or window was started for this identity evidence.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\explorer.exe`. Its fixed numeric file version was
`10.0.26100.8875`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [start](start.md)
- [ms-settings](ms-settings.md)
- [control.exe](control.exe.md)
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
