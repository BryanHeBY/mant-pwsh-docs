<!-- mant:tldr:start -->
# Invoke-Item

> Perform the Windows PowerShell provider's default action on a path or item.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-5.1.

- Open the current folder in Explorer:

`Invoke-Item -LiteralPath {{.}}`

- Open a document with its registered Windows application:

`Invoke-Item -LiteralPath '{{C:\path\document.pdf}}'`

- Accept exact string paths from the pipeline:

`'{{C:\path\one}}', '{{C:\path\two}}' | Invoke-Item`
<!-- mant:tldr:end -->

# Invoke-Item

## Synopsis

`Invoke-Item` performs the default action for an item exposed by a Windows
PowerShell provider. For filesystem paths, that commonly means opening a folder
in Explorer, opening a document with its registered application, or running an
executable.

## Syntax

```powershell
Invoke-Item [-Path] <string[]> [-Filter <string>] [-Include <string[]>]
  [-Exclude <string[]>] [-Credential <pscredential>]
  [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-Item -LiteralPath <string[]> [-Filter <string>]
  [-Include <string[]>] [-Exclude <string[]>]
  [-Credential <pscredential>] [-WhatIf] [-Confirm]
  [<CommonParameters>]
```

## Important parameters

- `-Path PATH`: Select provider paths and interpret wildcard characters.
- `-LiteralPath PATH`: Use an exact path without wildcard interpretation.
- `-Filter`, `-Include`, `-Exclude`: Limit selected items where the provider
  supports the requested filter.
- `-Credential`: Present for provider compatibility, but unsupported by the
  providers installed with Windows PowerShell. It does not elevate the action.
- `-WhatIf`, `-Confirm`: Participate in ShouldProcess; the registered external
  handler still owns the action it performs.

String paths can arrive through the pipeline. The cmdlet returns no output of
its own, although an invoked item can produce output.

## Default action and trust

The provider and Windows file associations determine the action. Inspect an
untrusted path, signature, association, and executable resolution before
invoking it. Use `Get-Item` or `Get-ChildItem` when the goal is to retrieve an
object without opening or executing it.

Use `Start-Process` when explicit credentials, window controls, redirection, a
verb, or a process object are required.

## Common mistakes

### Using `-Path` for a filename containing wildcard characters

Use `-LiteralPath` for an exact user-supplied or discovered path; otherwise
characters such as `[` and `*` can select unintended items.

### Invoking every wildcard match

`Invoke-Item *.xlsx` can open many documents and processes. Enumerate and
review the selection before invoking it.

### Expecting item objects as output

This command performs an action. Use `Get-Item` to test existence, read
metadata, or continue an object pipeline.

### Assuming `-Credential` changes the user

The parameter appears in syntax for provider compatibility but isn't supported
by providers installed with Windows PowerShell. Use an explicitly supported
remoting or process credential mechanism instead.

## Version and platform differences

This page is specific to Windows PowerShell 5.1 on Windows. Default actions
depend on the active provider, file associations, installed applications,
interactive user session, and policy. `ii` is the built-in alias.

## Related documents

- [ii alias](ii.md)
- [Start-Process](Start-Process.md)
- [Get-ChildItem](Get-ChildItem.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Invoke-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-5.1)
and the practical guide to
[manipulating items directly](https://learn.microsoft.com/powershell/scripting/samples/manipulating-items-directly?view=powershell-5.1).
The high-frequency folder-opening use case is also informed by
[Is it possible to open a Windows Explorer window from PowerShell?](https://stackoverflow.com/questions/320509/is-it-possible-to-open-a-windows-explorer-window-from-powershell/321092).
Exact sources and licenses are recorded in `upstream/pwsh51.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
