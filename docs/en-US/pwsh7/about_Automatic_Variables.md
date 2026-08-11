<!-- mant:tldr:start -->
# about_Automatic_Variables

> Use PowerShell 7 variables that describe the current session and command execution.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.6.

- Display runtime and edition information:

`$PSVersionTable`

- Check a native command's exit code:

`{{native-command}}; $LASTEXITCODE`

- Use the current pipeline item:

`Get-ChildItem | ForEach-Object { $_.FullName }`
<!-- mant:tldr:end -->

# about_Automatic_Variables

## Short description

Automatic variables are created and maintained by PowerShell. They expose the
current pipeline item, command arguments, script location, success state,
errors, host information, and runtime version. They are useful context, but
scripts should not overwrite them casually.

## Pipeline and command variables

`$_` and `$PSItem` both name the current object in a pipeline script block.
`$args` contains positional arguments that were not bound to named parameters.
`$input` exposes pipeline input to a function or script block that consumes it.
`$PSBoundParameters` contains parameters that were explicitly bound to an
advanced function or script.

```powershell
Get-ChildItem -File |
    ForEach-Object {
        "{0}: {1}" -f $_.Name, $_.Length
    }
```

Prefer a `param(...)` block over reading `$args` when an interface needs
names, types, defaults, validation, or discoverable help.

## Script and invocation location

`$PSScriptRoot` is the directory that contains the running script or module.
`$PSCommandPath` is its full path. These variables are safer than assuming the
current location, which can differ when a script is started by a scheduler,
test runner, or another process.

```powershell
$configuration = Join-Path $PSScriptRoot 'settings.json'
Get-Content -LiteralPath $configuration -Raw
```

`$MyInvocation` describes how the current command was invoked. Its properties
are useful for diagnostics, but `$PSScriptRoot` and `$PSCommandPath` are
usually clearer for building paths.

## Success, errors, and native exit codes

`$?` reports whether the latest PowerShell operation succeeded. `$Error` holds
recent error records. Neither is a substitute for a deliberate error-handling
boundary with `try`, `catch`, and `-ErrorAction Stop`.

`$LASTEXITCODE` holds the exit code from the latest native program or an
explicitly exited PowerShell child process. A nonzero native code does not
automatically throw:

```powershell
git status --short
if ($LASTEXITCODE -ne 0) {
    throw "git failed with exit code $LASTEXITCODE"
}
```

Check a tool's own documentation before treating every nonzero exit code as a
failure. Some commands use nonzero values for a meaningful non-error result.

## Session and runtime variables

`$PSVersionTable` identifies the installed PowerShell version, edition,
platform, and compatible versions. Use it when a script depends on a feature
introduced after the chosen baseline. `$PID` identifies the current process,
`$Host` identifies the hosting application, `$HOME` identifies the user home
directory, and `$PWD` is the current provider location.

```powershell
if ($PSVersionTable.PSVersion -lt [version]'7.6') {
    throw 'PowerShell 7.6 or later is required.'
}
```

`$PROFILE` identifies profile scripts for the current host and user. See
[about_Profiles](about_Profiles.md) for safe profile discovery and loading.

## Null and collections

`$null` is PowerShell's null value. Compare with `$null` on the left side of a
comparison to avoid collection enumeration surprises:

```powershell
if ($null -eq $value) {
    'No value was supplied.'
}
```

Do not use an empty string, zero, `$false`, and `$null` interchangeably. They
have different meaning in parameter binding, conditionals, serialization, and
native command arguments.

## Platform and version differences

The meaning of automatic variables is mostly portable, but their values can
reflect host, operating system, current provider, startup mechanism, and
PowerShell version. Record a minimum version when a script depends on a
variable or behavior introduced in a later 7.x release. Windows PowerShell
5.1 must be documented and tested separately.

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Profiles](about_Profiles.md)
- [about_Redirection](about_Redirection.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Automatic_Variables reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.6).
It is organized around pipeline state, script location, failures, and runtime
introspection. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
