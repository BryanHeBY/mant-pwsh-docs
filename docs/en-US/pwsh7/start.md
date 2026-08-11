<!-- mant:tldr:start -->
# start

> Windows-only alias for `Start-Process`; it is not a PowerShell 7 alias on Linux or macOS.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.6.

- Resolve every command named `start` in the current session:

`Get-Command start -All`

- Use the portable full cmdlet name:

`Start-Process -FilePath {{app}} -ArgumentList '{{arguments}}'`

- Invoke the different cmd builtin explicitly on Windows:

`cmd.exe /d /c 'start "" {{app.exe}}'`
<!-- mant:tldr:end -->

# start

## Meaning

On Windows, PowerShell 7 defines `start` as an alias for `Start-Process`. The
alias is not defined by default on Linux or macOS. `saps` is the all-platform
alias, but the full cmdlet name is clearer in shared automation.

## Command resolution

```powershell
Get-Command start -All
Get-Alias start -ErrorAction SilentlyContinue
```

Profiles, functions, scripts, and executables can shadow or replace an alias.
Use `Start-Process` when that exact cmdlet is intended.

## Common mistakes

### Assuming cmd syntax applies

The Windows `start` builtin belongs to `cmd.exe` and treats the first quoted
argument as a window title. PowerShell's alias binds `Start-Process` parameters
instead. These are different commands with different waiting and parsing rules.

### Assuming the alias exists on every PowerShell 7 platform

Scripts using bare `start` fail on a default Linux or macOS session. Use
`Start-Process`, or detect a platform-specific command explicitly.

### Using an alias in durable scripts

Aliases can be changed by profiles and make command reviews harder. Prefer the
full name for CI, remoting, modules, and shared scripts.

## Full command

See [Start-Process](Start-Process.md) for parameters, argument passing, streams,
waiting, process objects, and platform differences.

## Related documents

- [Get-Command](Get-Command.md)
- [about_Profiles](about_Profiles.md)
- [native commands](native-commands.md)

## Sources and license

This original alias guide was adapted from the official
[Start-Process reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.6),
which lists `start` under Windows aliases and `saps` under all platforms. The
PowerShell 7.6.3 Linux authoring runtime also confirmed that `start` is absent
by default. Exact provenance is recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
