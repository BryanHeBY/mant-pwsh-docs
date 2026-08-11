<!-- mant:tldr:start -->
# irx

> Resolve `irx` before using it: it is not a built-in PowerShell 7 alias or cmdlet.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.6.

- See whether the current session defines it:

`Get-Command irx -All`

- Inspect it if it is an alias:

`Get-Alias irx -ErrorAction SilentlyContinue`

- Find profile code that defines it:

`Get-ChildItem (Split-Path -Parent $PROFILE) -Filter '*.ps1' | Select-String -Pattern '\birx\b'`
<!-- mant:tldr:end -->

# irx

## Meaning

`irx` is not a built-in PowerShell 7 alias, cmdlet, function, or executable.
The PowerShell 7.6 Linux runtime used for this source did not resolve it. If it
works in a session, it was supplied by a profile, module, script, endpoint, or
executable on that environment; its meaning is not portable.

## Resolve rather than guess

Inspect every matching definition before using `irx` in an interactive command
or script:

```powershell
Get-Command irx -All
Get-Alias irx -ErrorAction SilentlyContinue
```

Do not infer that it means `Invoke-RestMethod`, `Invoke-Expression`, or any
other command because of its spelling. A custom alias can be changed or removed
by a profile, module import, constrained endpoint, or user configuration.

## Replace it in shared automation

Use the resolved full command name in code that another user, CI job, remoting
endpoint, or future session must run. If a team intentionally defines `irx`,
document its target, module/profile owner, required versions, and exact scope;
do not rely on ambient startup state.

```powershell
$irx = Get-Command irx -ErrorAction SilentlyContinue
if ($null -ne $irx) {
    $irx | Select-Object Name, CommandType, Source, Definition
}
```

When diagnosing its origin, inspect profile files, imported modules, and
`Get-Command irx -All`. Do not execute unknown alias definitions merely to
discover their behavior.

## Related documents

- [irm](irm.md)
- [iex](iex.md)
- [Get-Command](Get-Command.md)
- [about_Profiles](about_Profiles.md)

## Sources and license

This original availability guide is informed by the official
[about_Aliases reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.6).
It records that `irx` is not a built-in PowerShell 7 command and requires
session-specific resolution. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
