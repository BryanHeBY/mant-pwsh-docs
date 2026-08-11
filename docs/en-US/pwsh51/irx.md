<!-- mant:tldr:start -->
# irx

> Resolve `irx` before using it: it is not a built-in Windows PowerShell 5.1 alias or cmdlet.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1.

- See whether the current session defines it:

`Get-Command irx -All`

- Inspect it if it is an alias:

`Get-Alias irx -ErrorAction SilentlyContinue`

- Find profile code that defines it:

`Get-ChildItem (Split-Path -Parent $PROFILE) -Filter '*.ps1' | Select-String -Pattern '\birx\b'`
<!-- mant:tldr:end -->

# irx

## Meaning

`irx` is not a built-in Windows PowerShell 5.1 alias, cmdlet, function, or
executable. If it works on a Windows PowerShell machine, a profile, module,
script, endpoint, or executable defined it; its meaning is not a portable
Windows PowerShell contract.

## Resolve rather than guess

Inspect all matching definitions before using it:

```powershell
Get-Command irx -All
Get-Alias irx -ErrorAction SilentlyContinue
```

Do not infer it means `Invoke-RestMethod`, `Invoke-Expression`, or another
command from the spelling. Profiles, module imports, constrained endpoints,
and user configuration can create, replace, or remove a custom alias.

## Replace it in shared automation

Use the resolved full command in scripts, scheduled tasks, remoting endpoints,
and CI jobs. If a team intentionally defines `irx`, document its target,
owner, required modules, scope, and version; do not rely on an interactive
profile being present.

```powershell
$irx = Get-Command irx -ErrorAction SilentlyContinue
if ($null -ne $irx) {
    $irx | Select-Object Name, CommandType, Source, Definition
}
```

Inspect profile files, imported modules, and `Get-Command irx -All` to find its
origin. Do not execute an unknown definition merely to learn what it does.

## Related documents

- [irm](irm.md)
- [iex](iex.md)
- [Get-Command](Get-Command.md)
- [about_Profiles](about_Profiles.md)

## Sources and license

This original availability guide is informed by the official
[about_Aliases reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1).
It records that `irx` is not a built-in Windows PowerShell command and requires
session-specific resolution. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
