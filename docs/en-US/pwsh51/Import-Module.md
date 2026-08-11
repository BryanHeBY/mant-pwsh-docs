<!-- mant:tldr:start -->
# Import-Module

> Add commands from a module to the current Windows PowerShell 5.1 session.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/import-module?view=powershell-5.1.

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

`Import-Module` makes module commands available in the current Windows
PowerShell session. A module can contain functions, cmdlets, aliases,
variables, providers, types, and formatting data. Import only trusted modules
from known sources.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Name NAME`: Import an installed module name, manifest/module path, or another supported name form.
- `-FullyQualifiedName SPECIFICATION`: Import a module selected by a module specification.
- `-MinimumVersion VERSION`: Require at least the requested installed module version.
- `-MaximumVersion VERSION`: Limit import to a version no newer than the requested value.
- `-RequiredVersion VERSION`: Require one exact installed module version.
- `-Function NAME`, `-Cmdlet NAME`, `-Variable NAME`, `-Alias NAME`: Restrict the exported members imported into the session.
- `-NoClobber`: Do not import commands whose names already exist.
- `-Prefix PREFIX`: Add a prefix to imported command nouns for this session.
- `-Force`: Remove and reimport an already loaded module; it does not repair binary incompatibility.
- `-PassThru`: Return the imported module object.
- `-Scope SCOPE`: Select local or global import scope where supported by the invocation context.
- `-Global`: Import commands into global scope.
- `-PSSession SESSION`: Import commands from a module available through PowerShell remoting.
- `-CimSession SESSION`: Import a CIM/CDXML module through the supplied CIM session.

## Discovery and explicit imports

Import by name when a module is installed below `$env:PSModulePath`. Import by
manifest or module-file path when automation needs an exact artifact. Inspect
discoverable modules before importing:

```powershell
Get-Module -ListAvailable Microsoft.PowerShell.Management
Import-Module Microsoft.PowerShell.Management
```

Windows PowerShell can autoload a module when its command is invoked. An
explicit import is still useful for an early prerequisite check or an exact
version/path requirement.

## Conflicts and scope

An imported command can collide with an alias, function, cmdlet, or a command
from another module. `-NoClobber` avoids overwriting existing commands;
`-Prefix` adds a prefix to imported command nouns. Check the winner with
`Get-Command NAME -All` after import when a script depends on it.

`-Force` reloads a module but cannot make incompatible binary state safe.
`-Global` imports into global scope and changes more of the session; use it
only when a host integration requires that scope. `-PassThru` returns module
metadata for inspection.

```powershell
Import-Module Pester -PassThru | Select-Object Name, Version, Path
```

## Security and compatibility

Importing a module executes code. Pin source and version expectations, review
dependencies, and do not import a module solely because an untrusted name was
supplied as data. A Windows PowerShell 5.1 module can depend on .NET Framework,
Windows APIs, architecture, installed roles, or a particular Windows release.

```powershell
Import-Module Contoso.Tools -ErrorAction Stop
if ($null -eq (Get-Command Get-ContosoReport -ErrorAction SilentlyContinue)) {
    throw 'Contoso.Tools did not export Get-ContosoReport.'
}
```

PowerShell 7 modules are not automatically compatible with 5.1, and 5.1
modules can require the PowerShell 7 Windows PowerShell compatibility layer.
Test the intended edition rather than inferring from module name alone.

## Common mistakes

### Treating import as installation

The cmdlet loads an already available module. Use a separate, reviewed module
installation and version-lock process.

### Assuming `-Force` solves architecture or .NET incompatibility

Reloading cannot make an incompatible assembly, native dependency, or module
edition requirement work in Windows PowerShell 5.1.

### Letting imported commands silently win

Use `-NoClobber`, a prefix, or module-qualified invocation and verify command
resolution with `Get-Command NAME -All`.

## Related documents

- [Get-Command](Get-Command.md)
- [Get-Help](Get-Help.md)
- [about_Functions](about_Functions.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Import-Module reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/import-module?view=powershell-5.1).
It emphasizes command conflicts, module provenance, and explicit automation
contracts. Exact upstream revision and path are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
