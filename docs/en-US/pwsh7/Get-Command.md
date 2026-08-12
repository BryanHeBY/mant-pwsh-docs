<!-- mant:tldr:start -->
# Get-Command

> Discover aliases, functions, cmdlets, scripts, and native applications available to PowerShell 7.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-command?view=powershell-7.6.

- Find the command that a name resolves to:

`Get-Command {{name}}`

- Show every matching definition, including shadowed commands:

`Get-Command {{name}} -All`

- List commands exported by a module:

`Get-Command -Module {{module-name}}`
<!-- mant:tldr:end -->

# Get-Command

## Synopsis

```powershell
Get-Command [[-Name] <string[]>] [-All] [-CommandType <CommandTypes>]
    [-Module <string[]>] [-ExcludeModule <string[]>]
    [-FullyQualifiedModule <ModuleSpecification[]>]
    [-ParameterName <string[]>] [-ParameterType <PSTypeName[]>]
    [-UseFuzzyMatching] [-Syntax] [<CommonParameters>]
```

`Get-Command` returns command metadata for aliases, functions, filters,
cmdlets, scripts, external applications, and workflow-related command types
when available. Use it before assuming that an unqualified name invokes the
command you expect.

## Command resolution

PowerShell can resolve the same name to multiple command types. An alias or
function can hide a cmdlet or native executable. `Get-Command NAME` shows the
definition that wins under normal precedence; `Get-Command NAME -All` exposes
every matching definition.

```powershell
Get-Command curl -All
Get-Command where -All
```

Use an explicit executable name such as `curl.exe`, a full path, or a
module-qualified cmdlet name when the selected definition matters. Do not
assume the result is identical on Windows, Linux, and macOS.

## Common parameters

<!-- mant:entries role=option case=insensitive -->
- `-Name NAME`: Find commands by name, including wildcard patterns.
- `-All`: Return all definitions for matching names instead of only the precedence winner.
- `-CommandType TYPE`: Restrict results to aliases, functions, cmdlets, external scripts, applications, or other command types.
- `-Module MODULE`: Return commands exported by one or more modules.
- `-Syntax`: Display parameter syntax rather than the default command metadata.
- `-ListImported`: Restrict results to commands from imported modules.
- `-TotalCount COUNT`: Return at most the requested number of matching commands.
- `-Verb VERB`, `-Noun NOUN`: Find commands by wildcard-aware approved-verb
  or noun patterns.
- `-ParameterName NAME`, `-ParameterType TYPE`: Find commands in the current
  session that expose matching parameter names, aliases, or types.
- `-ArgumentList ARGUMENTS`: Resolve command metadata in the context of
  arguments that trigger dynamic parameters, such as a provider path.
- `-FullyQualifiedModule SPECIFICATION`: Select a module by name plus version
  or GUID constraints; it is mutually exclusive with `-Module`.
- `-ExcludeModule MODULE`: Omit named modules from command discovery.
- `-UseFuzzyMatching`, `-FuzzyMinimumDistance DISTANCE`: Rank inexact command
  name matches and optionally cap their Damerau-Levenshtein distance; do not
  combine fuzzy matching with wildcard patterns.
- `-UseAbbreviationExpansion`: Match abbreviated characters against uppercase
  characters in command names; wildcard patterns do not match in this mode.
- `-ShowCommandInfo`: Use the command-information display rather than the
  normal metadata view.

`-Name` supports wildcards. Quote patterns when the calling shell could expand
them before PowerShell receives them.

## Modules and availability

`Get-Command -Module NAME` can discover commands exported by an installed
module even when it is not imported, subject to module discovery behavior.
`-ListImported` asks only about commands from modules already loaded into the
current session. Use `Get-Module -ListAvailable` to inspect installed modules
and `Import-Module` when an explicit import is appropriate.

```powershell
Get-Command -Module Microsoft.PowerShell.Management
Get-Command -ListImported -CommandType Cmdlet
```

Module availability depends on PowerShell edition, operating system, installed
products, and session configuration. A command found on one host is not proof
that it exists on another.

## Syntax and parameter discovery

Use `-Syntax` for a compact parameter-set overview and `Get-Help -Full` for
descriptions, examples, input types, and output types. Command metadata also
contains parameter and source details that are useful in scripts and tooling.

```powershell
Get-Command Get-ChildItem -Syntax
Get-Command -ParameterName *Credential*
Get-Command Get-ChildItem -ArgumentList Cert:\ -Syntax
Get-Help Get-ChildItem -Full
```

## Examples

Check whether a preferred native executable is hidden by a PowerShell alias:

```powershell
$matches = Get-Command curl -All
$matches | Select-Object CommandType, Name, Source, Definition
```

Find aliases that begin with `i`:

```powershell
Get-Command i* -CommandType Alias
```

Fail early when an automation prerequisite is unavailable:

```powershell
if ($null -eq (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
    throw 'git is required but was not found on PATH.'
}
```

## Platform and version differences

Command availability is environment-specific. Windows can include aliases and
applications that do not exist on Unix-like systems; Unix-like systems can
have native utilities with names that collide with Windows PowerShell aliases.
Use `Get-Command -All` during compatibility testing rather than inferring from
one machine.

## Common mistakes

### Omitting `-All` while diagnosing a collision

The default result can hide lower-precedence aliases, functions, scripts, or
applications. Use `-All` and inspect `CommandType`, `Source`, and `Definition`.

### Treating discovery as a portability guarantee

A command found through module auto-discovery or the current `PATH` may be
absent or resolve differently on another host. Validate type, source, version,
and prerequisites at the automation boundary.

## Runtime evidence

PowerShell 7.6.4 on Windows was tested in a clean `-NoProfile` process with a
session-local function and same-name alias. Normal lookup selected the alias,
`-All` returned the alias followed by the function, and `-Syntax` returned a
nonempty syntax view. The repository smoke test also confirms the documented
core commands, Windows aliases, native-name resolution, and option names
against live command metadata. The provider fixture passed FileSystem,
Registry, and Certificate paths through `-ArgumentList`: the first exposed six
selected filesystem parameters, Registry exposed none of that set, and
Certificate exposed `CodeSigningCert`. These are path/provider-dependent
dynamic parameters, not static portability guarantees. Module inventories,
third-party providers, external `PATH` layouts, macOS, and Linux remain
outstanding.

## Related documents

- [Get-Help](Get-Help.md)
- [Get-Member](Get-Member.md)
- [native-commands](native-commands.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[Get-Command reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-command?view=powershell-7.6).
Dynamic-parameter behavior is cross-checked against Microsoft's
[cmdlet dynamic parameter guidance](https://learn.microsoft.com/powershell/scripting/developer/cmdlet/cmdlet-dynamic-parameters?view=powershell-7.6).
It emphasizes command precedence, module discovery, and cross-platform
diagnostics. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
