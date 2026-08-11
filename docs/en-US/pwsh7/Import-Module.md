<!-- mant:tldr:start -->
# Import-Module

> Add commands from a PowerShell module to the current PowerShell 7 session.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/import-module?view=powershell-7.6.

- Import a module by name:

`Import-Module {{module-name}}`

- Show imported module information:

`Import-Module {{module-name}} -PassThru`

- Import with a command prefix:

`Import-Module {{module-name}} -Prefix {{prefix}}`
<!-- mant:tldr:end -->

# Import-Module

## Synopsis

```powershell
Import-Module [-Name] <string[]> [-Force] [-Global] [-NoClobber] [-Prefix <string>]
    [-PassThru] [<CommonParameters>]
```

`Import-Module` makes module commands available in the current session. A
module can contain functions, cmdlets, aliases, variables, providers, types,
and formatting data. Import only trusted modules from known sources.

## Module discovery

Import by module name when the module is installed in a location on
`$env:PSModulePath`. Import by manifest or module-file path when automation
requires an exact artifact. Use `Get-Module -ListAvailable` to inspect
discoverable modules before importing them.

```powershell
Get-Module -ListAvailable Microsoft.PowerShell.Management
Import-Module Microsoft.PowerShell.Management
```

PowerShell can autoload a module when a command is invoked. Explicit import is
still useful when a script needs an early, clear prerequisite check or must
control which module version is used.

## Command conflicts and prefixes

An imported command can collide with an alias, function, cmdlet, or command
from another module. `-NoClobber` avoids overwriting existing commands.
`-Prefix` adds a prefix to imported command nouns, making coexisting command
sets easier to distinguish.

```powershell
Import-Module Contoso.Tools -Prefix Contoso
Get-Command *Contoso*
```

Use `Get-Command NAME -All` after import when a script must verify which
definition wins. Module-qualified invocation can be clearer than relying on
session-wide command precedence.

## Force, global, and pass-through

`-Force` reloads a module and can refresh commands or state, but it does not
make incompatible binary or session state safe. `-Global` imports commands
into the global scope; use it sparingly because it changes more of the session
than a local import. `-PassThru` returns module information for inspection.

```powershell
Import-Module Pester -PassThru |
    Select-Object Name, Version, Path
```

## Security and reproducibility

Modules execute code when imported. Pin version and source expectations for
automation, review dependencies, and avoid installing or importing a module
based only on an untrusted name. Module paths can differ by platform and user,
so a bare module name is not a complete supply-chain contract.

For a reusable script, check required commands after import and produce an
actionable error when they are absent:

```powershell
Import-Module Contoso.Tools -ErrorAction Stop
if ($null -eq (Get-Command Get-ContosoReport -ErrorAction SilentlyContinue)) {
    throw 'Contoso.Tools did not export Get-ContosoReport.'
}
```

## Platform and version differences

Module compatibility depends on PowerShell edition, .NET runtime, operating
system, architecture, native dependencies, and module manifest requirements.
A module that loads in PowerShell 7 on one platform may not load on another.
Windows PowerShell 5.1 modules are not automatically compatible with
PowerShell 7.

## Related documents

- [Get-Command](Get-Command.md)
- [Get-Help](Get-Help.md)
- [about_Functions](about_Functions.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Import-Module reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/import-module?view=powershell-7.6).
It emphasizes command conflicts, module provenance, and explicit automation
contracts. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
