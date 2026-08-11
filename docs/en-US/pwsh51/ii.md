<!-- mant:tldr:start -->
# ii

> Built-in alias for `Invoke-Item`, commonly used to open a path with its Windows default action.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-5.1.

- Open the current folder in Explorer:

`ii {{.}}`

- Open one exact path without wildcard interpretation:

`Invoke-Item -LiteralPath '{{path}}'`

- Confirm the alias definition:

`Get-Alias ii`
<!-- mant:tldr:end -->

# ii

## Meaning

`ii` is the built-in Windows PowerShell 5.1 alias for `Invoke-Item`. It performs
the provider's default action; `ii .` normally opens the current filesystem
folder in Explorer.

## Common mistakes

### Treating `ii` as an Explorer-only executable

Documents can open their registered applications, executables can run, and
other providers can define different default actions.

### Opening untrusted or broad wildcard input

Invoking a path can execute code or launch many handlers. Inspect the item and
use `Invoke-Item -LiteralPath` for exact input.

### Using the alias in shared automation

Use `Invoke-Item` in scripts so command identity and parameter intent remain
clear. Keep `ii` for concise interactive work.

## Full command

See [Invoke-Item](Invoke-Item.md) for provider behavior, parameters, pipeline
input, output, trust, and Windows PowerShell 5.1 constraints.

## Related documents

- [Start-Process](Start-Process.md)
- [Get-Command](Get-Command.md)
- [about_Profiles](about_Profiles.md)

## Sources and license

This original alias guide was adapted from Microsoft's official
[Invoke-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-5.1)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1).
The practical `ii .` use case is also reflected in
[Is it possible to open a Windows Explorer window from PowerShell?](https://stackoverflow.com/questions/320509/is-it-possible-to-open-a-windows-explorer-window-from-powershell/321092).
Exact sources and licenses are recorded in `upstream/pwsh51.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
