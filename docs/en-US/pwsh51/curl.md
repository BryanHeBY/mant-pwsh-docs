<!-- mant:tldr:start -->
# curl

> In Windows PowerShell 5.1, `curl` is normally an alias for `Invoke-WebRequest`, while `curl.exe` is the native executable.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1.

- See what `curl` resolves to:

`Get-Command curl -All`

- Require the Windows executable explicitly:

`curl.exe {{arguments}}`

- Use the PowerShell cmdlet explicitly:

`Invoke-WebRequest -Uri {{https://example.test}}`
<!-- mant:tldr:end -->

# curl

## Meaning

In a default Windows PowerShell 5.1 session, `curl` is an alias for
`Invoke-WebRequest`. This is not the native curl command. Use `Get-Command
curl -All` to inspect the actual session rather than assuming the name's
meaning from a guide or another shell.

## Command identities

<!-- mant:entries role=command case=insensitive -->
- `curl`: In a default Windows PowerShell 5.1 session, resolve the alias to `Invoke-WebRequest`.
- `curl.exe`: Request the native executable explicitly, subject to Windows application search order.
- `Invoke-WebRequest`, `iwr`: Request the Windows PowerShell cmdlet or its built-in alias explicitly.

## Alias versus executable

`Invoke-WebRequest` accepts PowerShell cmdlet parameters such as `-Uri` and
returns a PowerShell response object. Native `curl.exe` has its own short and
long options, emits text or bytes, and reports a native exit code through
`$LASTEXITCODE`. The interfaces are not interchangeable.

Use `curl.exe` when a script needs the executable; use the full
`Invoke-WebRequest` name when it needs the PowerShell cmdlet. Windows 10 and
later commonly include `curl.exe`, but do not treat its presence or version as
an invariant across managed Windows estates.

## Automation contract

Do not write bare `curl` in a script whose behavior must survive profiles,
PowerShell 7 migration, or a change of host. For a native dependency, test the
actual application command and version:

```powershell
$command = Get-Command curl.exe -CommandType Application -ErrorAction SilentlyContinue
if ($null -eq $command) {
    throw 'The native curl.exe executable is required.'
}
& $command.Source --version
```

## Version and availability

The `curl` alias belongs to Windows PowerShell 5.1. Native `curl.exe` became a
Windows inbox component only in later Windows 10-era releases, so older or
serviced hosts can differ in presence and version.

## Common mistakes

### Passing native curl options to the alias

Options such as `-L`, `-H`, and `--fail` are native curl syntax. A bare `curl`
in Windows PowerShell 5.1 normally binds `Invoke-WebRequest` parameters.

### Assuming `curl.exe` exists because the alias exists

The alias does not prove that the executable is installed. Resolve
`curl.exe` as an application and validate its version when it is a dependency.

## Related documents

- [iwr](iwr.md)
- [native-commands](native-commands.md)
- [Get-Command](Get-Command.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original conflict guide was informed by the official
[about_Aliases reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1)
and [Invoke-WebRequest reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1).
It adds Windows command-resolution guidance. Exact upstream revision and paths
are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
