<!-- mant:tldr:start -->
# powershell-7-compatibility

> Plan and verify Windows PowerShell 5.1 workloads before moving them to PowerShell 7.
> More information: https://learn.microsoft.com/powershell/whats-new/differences-from-windows-powershell.

- Identify the running edition and version:

`$PSVersionTable`

- Run a script under Windows PowerShell without profile state:

`powershell.exe -NoProfile -File {{script.ps1}}`

- Test migration under PowerShell 7 without profiles:

`pwsh -NoProfile -File {{script.ps1}}`
<!-- mant:tldr:end -->

# Windows PowerShell 5.1 and PowerShell 7 compatibility

## Overview

Windows PowerShell 5.1 and PowerShell 7 share a language heritage but are
different products. Windows PowerShell is Windows-only, uses the `Desktop`
edition and .NET Framework, and starts with `powershell.exe`. PowerShell 7 is
cross-platform, uses the `Core` edition and modern .NET, and starts with
`pwsh`. Validate each supported host explicitly.

## Runtime and language boundaries

Record `$PSVersionTable`, operating system, architecture, module versions, and
native dependencies in diagnostics. PowerShell 7 syntax such as `&&`, `||`,
`??`, `??=`, and `? :` does not parse in Windows PowerShell 5.1. Maintain a
5.1-compatible path or separate scripts when that edition remains supported.

```powershell
$PSVersionTable | Format-List PSVersion, PSEdition, Platform, OS
```

Parsing, quoting, redirection, automatic variables, native argument passing,
and default encodings have also changed across releases. Test spaces, quotes,
Unicode, wildcards, nulls, and nonzero native exit codes in both editions.

## Modules and native programs

Windows inbox and binary modules can depend on .NET Framework or Windows APIs
that PowerShell 7 cannot load natively. Conversely, newer modules can require
PowerShell 7. On Windows, PowerShell 7 can use `Import-Module
-UseWindowsPowerShell` for eligible legacy modules; returned objects are
serialized, so methods, live types, performance, and formatting can differ.

Native programs receive a command line and text/bytes, not PowerShell objects.
Use explicit executable names and test encoding, output, redirection, and
`$LASTEXITCODE` under the edition that will run production automation.

## Migration workflow

1. Inventory scripts, modules, executables, providers, remoting endpoints, and profile dependencies.
2. Run both editions with `-NoProfile` and representative data; capture output, errors, and native exit codes.
3. Replace edition-specific syntax or module calls with supported alternatives.
4. Test Windows, Linux, and macOS separately when the target script claims portability.
5. Retain Windows PowerShell 5.1 coverage until every production dependency is removed.

## Related documents

- [Windows PowerShell 5.1 shell and language](pwsh51.md)
- [Import-Module](Import-Module.md)
- [native-commands](native-commands.md)
- [curl](curl.md)

## Sources and license

This original migration guide was adapted from the official
[differences from Windows PowerShell documentation](https://learn.microsoft.com/powershell/whats-new/differences-from-windows-powershell)
and referenced PowerShell documentation. It is organized around testable
migration boundaries. Exact upstream revision and paths are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
