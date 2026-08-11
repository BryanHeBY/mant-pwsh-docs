<!-- mant:tldr:start -->
# ii

> Built-in alias for `Invoke-Item`, commonly used to open a path with its default action.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-7.6.

- Open the current folder on a Windows desktop:

`ii {{.}}`

- Open one exact path without wildcard interpretation:

`Invoke-Item -LiteralPath '{{path}}'`

- Confirm the alias definition in the current session:

`Get-Alias ii`
<!-- mant:tldr:end -->

# ii

## Meaning

`ii` is the built-in alias for `Invoke-Item`. It performs the provider's
default action on a path. On Windows, `ii .` commonly opens the current folder
in Explorer.

## Availability

The alias exists in the tested PowerShell 7.6.3 Linux session and is documented
for `Invoke-Item`. The resulting action still depends on the provider,
operating system, desktop session, and file association.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Path PATH`: Invoke the provider's default action for one or more paths; wildcard characters are interpreted.
- `-LiteralPath PATH`: Invoke one or more exact paths without wildcard expansion.
- `-Filter FILTER`: Ask a supporting provider to filter items before PowerShell receives them.
- `-Include PATTERN`: Include only matching paths; its effect depends on path contents and provider expansion.
- `-Exclude PATTERN`: Omit matching paths; it does not make an otherwise untrusted invocation safe.

## Common mistakes

### Treating `ii` as an Explorer-specific command

The alias invokes the provider's default action. Documents can open another
application, executables can run, and non-filesystem providers can behave
differently.

### Opening untrusted or broad wildcard input

Invoking a path can execute code or launch many handlers. Inspect the item and
use `Invoke-Item -LiteralPath` for exact input.

### Using the alias in shared automation

Use `Invoke-Item` in scripts so intent, parameter names, and command resolution
remain clear. Keep `ii` for concise interactive work.

## Full command

See [Invoke-Item](Invoke-Item.md) for provider behavior, parameters, pipeline
input, output, trust, and platform differences.

## Related documents

- [Start-Process](Start-Process.md)
- [Get-Command](Get-Command.md)
- [about_Profiles](about_Profiles.md)

## Sources and license

This original alias guide was adapted from Microsoft's official
[Invoke-Item reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/invoke-item?view=powershell-7.6).
The practical `ii .` use case is also reflected in
[Is it possible to open a Windows Explorer window from PowerShell?](https://stackoverflow.com/questions/320509/is-it-possible-to-open-a-windows-explorer-window-from-powershell/321092).
Exact sources and licenses are recorded in `upstream/pwsh7.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
