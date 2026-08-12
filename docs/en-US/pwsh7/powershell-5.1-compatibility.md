<!-- mant:tldr:start -->
# powershell-5.1-compatibility

> Plan and verify migration from Windows PowerShell 5.1 to PowerShell 7.
> More information: https://learn.microsoft.com/powershell/whats-new/differences-from-windows-powershell.

- Identify the running edition and version:

`$PSVersionTable`

- Run a script under PowerShell 7 without profile state:

`pwsh -NoProfile -File {{script.ps1}}`

- Load a Windows PowerShell module through compatibility on Windows:

`Import-Module {{module-name}} -UseWindowsPowerShell`
<!-- mant:tldr:end -->

# PowerShell 7 and Windows PowerShell 5.1 compatibility

## Overview

PowerShell 7 and Windows PowerShell 5.1 share a language heritage and many cmdlets, but they are different products. Windows PowerShell 5.1 is the Windows-only `Desktop` edition built on .NET Framework and started with `powershell.exe`. PowerShell 7 is the cross-platform `Core` edition built on modern .NET and started with `pwsh`.

Do not validate a script in one edition and assume it behaves identically in the other. Record the edition, full version, operating system, architecture, module version, and native dependencies tested.

## Identify the runtime

`$PSVersionTable` identifies `PSVersion`, `PSEdition`, and related runtime
information. PowerShell 7 also provides `Platform` and `OS` keys, but Windows
PowerShell 5.1 does not. Use .NET environment properties for a diagnostic that
must populate operating-system and architecture fields in both editions.

```powershell
$PSVersionTable
[pscustomobject]@{
    OSVersion = [Environment]::OSVersion.VersionString
    Is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem
    Is64BitProcess = [Environment]::Is64BitProcess
}
```

For scripts that need a feature introduced in a recent PowerShell 7 release, check the version explicitly and fail with an actionable message.

## Language differences

PowerShell 7 added language features that Windows PowerShell 5.1 does not parse or support, including pipeline chain operators `&&` and `||`, null coalescing `??` and `??=`, and the ternary operator `? :`. Use 5.1-compatible control flow or maintain edition-specific script paths when a script must run in both editions.

Parsing, parameter binding, quoting, redirection, automatic variables, and native command argument passing also changed across PowerShell releases. Read the relevant concept page and test inputs with spaces, quotes, Unicode, wildcards, null values, and nonzero exit codes.

## Modules and cmdlets

Module availability is the largest practical compatibility boundary. Some Windows inbox modules and binary modules target .NET Framework or Windows APIs and cannot run natively in PowerShell 7. Conversely, newer PowerShell modules can require PowerShell 7 or a modern .NET runtime.

On Windows, `Import-Module -UseWindowsPowerShell` can create a compatibility session for eligible Windows PowerShell modules. Returned objects are serialized across that boundary, so methods, live types, performance, and formatting can differ from a native import. Treat it as a migration bridge, not proof that a module is fully compatible.

```powershell
Import-Module Legacy.Windows.Module -UseWindowsPowerShell -ErrorAction Stop
Get-Command -Module Legacy.Windows.Module
```

## Native commands, encoding, and streams

Native applications receive a command line and produce text or bytes; they do not receive PowerShell objects. Argument conversion, output encoding, byte stream handling, `$LASTEXITCODE`, and redirection behavior have changed over PowerShell versions. Test each native tool with the PowerShell edition that will run it.

Use explicit command names to avoid alias collisions. Windows PowerShell 5.1
defines `curl` as an alias for `Invoke-WebRequest`; PowerShell 7 does not define
that alias on any platform. Profiles and modules can still add one. Use
`curl.exe` where the Windows executable is required, or use
`Invoke-WebRequest` when the PowerShell cmdlet is intended.

## Profiles and startup

PowerShell 7 and Windows PowerShell use different executable names, profile locations, hosts, module paths, and installed modules. A profile can make an interactive test pass by importing a module or defining an alias that does not exist in automation.

Run migration tests with `-NoProfile`, then explicitly import required modules and configure only the state the script needs:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File ./test.ps1
```

## Remoting and security

Windows PowerShell remoting commonly depends on WSMan and Windows authentication. PowerShell 7 supports multiple remoting transports, including SSH, but availability, session configuration, serialization, credentials, and endpoint policy still vary by host.

Execution policy is not a security boundary in either edition. Avoid parsing untrusted data as code, use least privilege, keep secrets out of source and command lines, and test the identity and endpoint configuration used in production.

## Migration workflow

1. Inventory scripts, imported modules, external executables, providers, remoting endpoints, and profile dependencies.
2. Run the script under `pwsh -NoProfile` with representative data and capture output, errors, and native exit codes.
3. Replace edition-specific syntax or module calls with supported alternatives.
4. Test Windows, Linux, and macOS behavior separately when the script claims portability.
5. Keep Windows PowerShell 5.1 coverage until the production dependency is removed rather than treating one successful PowerShell 7 run as migration completion.

## Version boundary

This guide compares the PowerShell 7.6 documentation baseline with Windows
PowerShell 5.1. It is a migration checklist, not a promise that every interim
PowerShell 7 release or Windows image has the same modules and behavior.

## Runtime evidence

Edition-matched Windows suites run separately under Windows PowerShell
5.1.26100.8875 and PowerShell 7.6.4. They confirm `Desktop` versus `Core`,
absent versus present `Platform`/`OS` keys, different `curl`/`sc` resolution,
UTF-16LE versus BOM-less UTF-8 redirection defaults, legacy versus modern `$?`
wrapper behavior, and edition-specific command parameters. This does not prove
module, .NET API, remoting, provider, or application compatibility; those need
workload-specific migration fixtures.

## Related documents

- [PowerShell 7 shell and language](pwsh7.md)
- [pwsh](pwsh.md)
- [Import-Module](Import-Module.md)
- [native-commands](native-commands.md)
- [curl](curl.md)

## Sources and license

This original ManT-oriented migration guide was adapted from the official [differences from Windows PowerShell documentation](https://learn.microsoft.com/powershell/whats-new/differences-from-windows-powershell) and the referenced PowerShell 7 documentation. It is organized around testable migration boundaries rather than a complete feature inventory. Exact upstream revision and paths are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is licensed under CC BY 4.0.
