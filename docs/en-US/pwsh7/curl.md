<!-- mant:tldr:start -->
# curl

> In PowerShell 7, `curl` is not a built-in alias; resolve the ambient name before depending on a native executable or custom definition.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.6.

- See what `curl` resolves to:

`Get-Command curl -All`

- Require the Windows executable explicitly:

`curl.exe {{arguments}}`

- Use the PowerShell cmdlet explicitly:

`Invoke-WebRequest -Uri {{https://example.test}}`
<!-- mant:tldr:end -->

# curl

## Meaning

PowerShell 7 does not define `curl` as an alias on Windows, Linux, or macOS.
The ambient name normally resolves to a native executable when one is
installed, but a profile, module, or endpoint can still define an alias or
function with that name. Windows PowerShell 5.1 is different: it defines
`curl` as an alias for `Invoke-WebRequest` by default.

Never infer the meaning from the spelling alone. Query the current session:

```powershell
Get-Command curl -All
```

## Command identities

<!-- mant:entries role=command case=insensitive -->
- `curl`: Resolve this ambient name before use; it can be an alias, function, or native application.
- `curl.exe`: Request the native Windows executable explicitly, subject to normal application search order.
- `Invoke-WebRequest`, `iwr`: Request the PowerShell web cmdlet or its built-in alias explicitly.

## Alias versus executable

`Invoke-WebRequest` takes PowerShell cmdlet parameters such as `-Uri` and
returns PowerShell response data. Native curl uses its own short and long
options, writes text or bytes, and reports a native exit code through
`$LASTEXITCODE`. The two commands are not interchangeable.

On Windows, use `curl.exe` when a script requires the executable. Use the full
`Invoke-WebRequest` cmdlet name when it requires PowerShell web-request
behavior. On Linux and macOS, use an explicit command path or validate the
installed curl version if an automation contract depends on it.

## Portable scripting

Do not write `curl` in a cross-platform PowerShell script unless the script
first validates what it resolves to. Prefer an explicit PowerShell cmdlet for
PowerShell object handling, or document the native curl dependency and its
minimum version.

```powershell
$command = Get-Command curl -CommandType Application -ErrorAction SilentlyContinue
if ($null -eq $command) {
    throw 'The native curl executable is required.'
}
& $command.Source --version
```

## Version and platform differences

PowerShell 7 does not define `curl` as a built-in alias on any platform.
Windows PowerShell 5.1, migrated profiles, modules, and endpoint configuration
can introduce one, while Windows versions vary in whether and which native
`curl.exe` is installed.

## Common mistakes

### Copying curl options into an alias invocation

Options such as `-L`, `-H`, and `--fail` belong to native curl. They are not a
portable shorthand for `Invoke-WebRequest` parameters.

### Checking only the first resolved command

Use `Get-Command curl -All` to expose shadowed aliases, functions, and
applications before deciding which command a script requires.

## Runtime evidence

PowerShell 7.6.4 on Windows and 7.6.3 on Linux both resolved bare `curl` to a
native application without a built-in PowerShell alias. The Windows result was
`curl.exe`; the Linux result was `/usr/bin/curl`. These observations prove
command identity only. macOS, executable version drift, profile/module
collisions, and native curl option behavior remain environment-specific.

## Related documents

- [iwr](iwr.md)
- [native-commands](native-commands.md)
- [Get-Command](Get-Command.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original conflict guide was informed by the official
[about_Aliases reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.6)
and [Invoke-WebRequest reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.6).
It adds platform-specific command-resolution guidance. Exact upstream revision
and paths are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
