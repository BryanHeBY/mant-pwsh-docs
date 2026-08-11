<!-- mant:tldr:start -->
# Invoke-Item

> Perform the PowerShell provider's default action on a path or item.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-7.6.

- Open the current folder with its default action on Windows:

`Invoke-Item -LiteralPath {{.}}`

- Open a document with its registered application:

`Invoke-Item -LiteralPath '{{C:\path\document.pdf}}'`

- Open several exact paths supplied by the pipeline:

`'{{path1}}', '{{path2}}' | Invoke-Item`
<!-- mant:tldr:end -->

# Invoke-Item

## Synopsis

`Invoke-Item` performs the default action for an item exposed by a PowerShell
provider. On Windows, that commonly means opening a folder in Explorer, opening
a document with its registered application, or running an executable.

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

- `-Path PATH`: Select one or more provider paths; wildcard characters are
  interpreted.
- `-LiteralPath PATH`: Use the path exactly as written, without wildcard
  interpretation.
- `-Filter`, `-Include`, `-Exclude`: Ask the provider to limit selected items;
  provider support and efficiency differ.
- `-Credential`: Present for provider compatibility, but unsupported by the
  providers installed with PowerShell. It does not elevate the action.
- `-WhatIf`, `-Confirm`: Participate in ShouldProcess, but the external default
  handler ultimately owns the action it performs.

String paths can arrive through the pipeline. The cmdlet has no output of its
own, although an invoked item can produce output.

## Default action and trust

The PowerShell provider determines the action. On Windows, file associations
and shell verbs can start applications or execute files. Inspect an untrusted
item, signature, association, and resolved path before invoking it.

Use `Get-Item` or `Get-ChildItem` to retrieve objects without opening them.
Use `Start-Process` when explicit process controls, redirection, a verb, or a
process object are required.

## Common mistakes

### Using `-Path` for a literal wildcard character

A filename containing `[` or `*` can be interpreted as a pattern. Use
`-LiteralPath` for an exact user-supplied or discovered path.

### Invoking every wildcard match

`Invoke-Item *.xlsx` can open many GUI applications or documents. Enumerate and
review the selected items before invoking a broad pattern.

### Expecting item objects as output

`Invoke-Item` performs an action; it is not `Get-Item`. Do not use its output to
prove that a file exists or a handler completed its work.

### Assuming `-Credential` changes the user

Installed PowerShell providers do not support this parameter. Use an explicitly
supported remoting or process credential mechanism instead.

### Assuming the same action across platforms and profiles

Providers, desktop handlers, file associations, and session types differ.
Windows Explorer behavior is not evidence for Linux or macOS desktop behavior.

## Version and platform differences

The cmdlet exists in PowerShell 7 on Windows, Linux, and macOS. The default
action is provider- and platform-specific and can require an interactive
desktop. `ii` is its built-in alias in the tested PowerShell 7.6 Linux session.

## Related documents

- [ii alias](ii.md)
- [Start-Process](Start-Process.md)
- [Get-ChildItem](Get-ChildItem.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Invoke-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-7.6)
and the practical guide to
[manipulating items directly](https://learn.microsoft.com/powershell/scripting/samples/manipulating-items-directly?view=powershell-7.6).
The high-frequency folder-opening use case is also informed by
[Is it possible to open a Windows Explorer window from PowerShell?](https://stackoverflow.com/questions/320509/is-it-possible-to-open-a-windows-explorer-window-from-powershell/321092).
Exact sources and licenses are recorded in `upstream/pwsh7.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
