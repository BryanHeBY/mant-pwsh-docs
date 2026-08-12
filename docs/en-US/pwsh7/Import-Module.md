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

- Select one discovered module object, then import that exact object through the pipeline:

`Get-Module -ListAvailable {{module-name}} | Sort-Object Version -Descending | Select-Object -First 1 | Import-Module -PassThru`
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

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-Name NAME`: Import a module by installed name, manifest/module path, or another supported name form.
- `-FullyQualifiedName SPECIFICATION`: Import a module selected by a module specification such as name plus exact version.
- `-MinimumVersion VERSION`: Require at least the requested installed module version.
- `-MaximumVersion VERSION`: Limit import to a version no newer than the requested value.
- `-RequiredVersion VERSION`: Require one exact installed module version.
- `-Function NAME`, `-Cmdlet NAME`, `-Variable NAME`, `-Alias NAME`: Restrict which exported members are imported; wildcard names are supported.
- `-NoClobber`: Do not import commands whose names already exist in the target scope.
- `-Prefix PREFIX`: Add a prefix to imported command nouns for this session.
- `-Force`: Remove and reimport an already loaded module; it does not repair incompatibility or unload every external dependency.
- `-PassThru`: Return the imported module object instead of producing no ordinary output.
- `-Scope SCOPE`: Import into the local or global scope allowed by the current invocation context.
- `-Global`: Import commands into global scope; prefer narrower scope unless global exposure is required.
- `-SkipEditionCheck`: On Windows, bypass the compatible-editions check for a module under the Windows PowerShell module path; this does not make incompatible code safe.
- `-UseWindowsPowerShell`: On Windows, load a compatible Windows PowerShell module through the compatibility session.
- `-PSSession SESSION`: Import commands from a module available in a PowerShell remoting session.
- `-CimSession SESSION`: Import a CIM/CDXML module through the supplied CIM session.
- `-ModuleInfo MODULE`: Import one or more discovered module objects; accepts pipeline input by value.
- `-Assembly ASSEMBLY`: Import cmdlets and providers implemented by supplied assembly objects; accepts pipeline input by value and executes trusted code.
- `-ArgumentList ARGUMENTS`: Pass arguments to a script module while importing
  it; the parameter is valid only for script modules.
- `-AsCustomObject`: Return a script module as a custom object whose exported
  members become properties and script methods instead of normal session commands.
- `-DisableNameChecking`: Suppress warnings for unapproved verbs or prohibited
  command-name characters; it does not correct the module's naming problem.
- `-CimNamespace NAMESPACE`, `-CimResourceUri URI`: Override CIM module
  discovery for a `-CimSession`, primarily for non-Windows CIM servers.

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

## Pipeline input

`-Name`, `-FullyQualifiedName`, `-ModuleInfo`, and `-Assembly` have parameter
sets that accept compatible values from the pipeline by value. Every incoming
value can cause an import; `Get-Module -ListAvailable` can return multiple
versions and paths, so filter and verify the exact object before piping it:

```powershell
Get-Module -ListAvailable Contoso.Tools |
    Where-Object Version -eq '2.4.1' |
    Where-Object Path -Like "$approvedRoot*" |
    Select-Object -First 1 |
    Import-Module -PassThru
```

An empty pipeline imports nothing, and `-PassThru` emits imported module objects
for downstream inspection. Pipeline binding does not make an untrusted module
safe; importing executes module or assembly code in the current session.

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

## Common mistakes

### Treating import as installation

`Import-Module` loads an already discoverable artifact; it does not install a
missing module. Establish a separate, reviewed acquisition and version-lock
workflow.

### Using `-Force` as a compatibility switch

`-Force` reloads module state. It does not make a Windows PowerShell binary
module compatible with PowerShell 7 or remove every loaded assembly and native
dependency.

### Ignoring command collisions

An import can change which command wins. Use `-NoClobber`, a prefix, or a
module-qualified command, then verify with `Get-Command NAME -All`.

## Platform and version differences

Module compatibility depends on PowerShell edition, .NET runtime, operating
system, architecture, native dependencies, and module manifest requirements.
A module that loads in PowerShell 7 on one platform may not load on another.
Windows PowerShell 5.1 modules are not automatically compatible with
PowerShell 7.

## Runtime evidence

PowerShell 7.6.4 on Windows imported a trusted fixture module created inside
the smoke test's GUID temporary directory. `-NoClobber` preserved an existing
`Get-MantDocFixture` function; after isolated cleanup, `-Prefix Probe` created
`Get-ProbeMantDocFixture`, and `-PassThru` returned the expected module object.
The module was unloaded and the verified temporary tree removed. This does not
generalize to third-party, binary, remote, or cross-platform compatibility.

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
