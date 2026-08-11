<!-- mant:tldr:start -->
# about_Automatic_Variables

> Use Windows PowerShell 5.1 variables that describe the current session and command execution.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-5.1.

- Display runtime and edition information:

`$PSVersionTable`

- Check a native command's exit code:

`{{native-command}}; $LASTEXITCODE`

- Use the current pipeline item:

`Get-ChildItem | ForEach-Object { $_.FullName }`
<!-- mant:tldr:end -->

# about_Automatic_Variables

## Short description

Automatic variables are created and maintained by Windows PowerShell. They
expose the current pipeline item, command arguments, script location, success
state, errors, host information, and runtime version. Use them as context, not
as ordinary mutable script state.

## Variable index

<!-- mant:entries role=variable case=insensitive -->
- `$_`, `$PSItem`: Refer to the current pipeline object in a script block.
- `$args`: Hold positional arguments not bound to named parameters.
- `$input`: Enumerate pipeline input available to the current function or script block.
- `$PSBoundParameters`: Map parameter names to values explicitly bound to the current advanced function or script.
- `$PSScriptRoot`: Identify the directory containing the running script or module.
- `$PSCommandPath`: Identify the full path of the running script or module.
- `$MyInvocation`: Describe how the current command was invoked.
- `$?`: Report whether the latest Windows PowerShell operation succeeded.
- `$Error`: Hold recent Windows PowerShell error records.
- `$LASTEXITCODE`: Hold the exit code from the latest native program or explicitly exited PowerShell child process.
- `$PSVersionTable`: Describe the current Windows PowerShell version and edition.
- `$PID`: Identify the current Windows PowerShell process.
- `$Host`: Identify the application hosting Windows PowerShell.
- `$HOME`: Identify the current user's home directory.
- `$PWD`: Hold the current provider location.
- `$PROFILE`: Identify the profile paths for the current host and user.
- `$null`: Represent PowerShell's null value.
- `$^`: Hold the first token from the last input line received by the session.
- `$$`: Hold the last token from the last input line received by the session.

## Pipeline and command variables

`$_` and `$PSItem` name the current object in a pipeline script block. `$args`
contains positional arguments not bound to named parameters. `$input` exposes
pipeline input to a function or script block that consumes it.
`$PSBoundParameters` contains values explicitly bound to an advanced function
or script.

```powershell
Get-ChildItem -File |
    ForEach-Object {
        '{0}: {1}' -f $_.Name, $_.Length
    }
```

Prefer a `param(...)` block over decoding `$args` when a public interface needs
names, types, defaults, validation, or help.

In an interactive session, `$^` and `$$` expose the first and last tokens from
the last input line. They are convenient for brief interactive recall, but
scripts should use named variables rather than depend on prior session input.

## Script and invocation location

`$PSScriptRoot` is the directory containing the running script or module.
`$PSCommandPath` is its full path. They are safer than assuming the current
location, which can differ when a script is run by Task Scheduler, a service,
or another process.

```powershell
$configuration = Join-Path $PSScriptRoot 'settings.json'
Get-Content -LiteralPath $configuration -Raw
```

`$MyInvocation` describes how the current command was invoked. Its properties
are useful for diagnostics; `$PSScriptRoot` and `$PSCommandPath` are normally
clearer for building paths.

## Success, errors, and native exit codes

`$?` reports whether the latest PowerShell operation succeeded. `$Error` holds
recent error records. Neither replaces a deliberate error boundary using
`try`, `catch`, and `-ErrorAction Stop`.

`$LASTEXITCODE` holds the exit code from the latest Windows executable or an
explicitly exited PowerShell child process. A nonzero native code does not
automatically throw:

```powershell
git.exe status --short
if ($LASTEXITCODE -ne 0) {
    throw "git failed with exit code $LASTEXITCODE"
}
```

Check a tool's own reference before treating every nonzero code as failure.
For example, `robocopy.exe` has useful informational exit-code ranges.

## Session and runtime variables

`$PSVersionTable` identifies the installed version and edition. Windows
PowerShell 5.1 normally reports `PSEdition` as `Desktop`; record it in support
diagnostics so a script is not silently tested under PowerShell 7 instead.
`$PID` identifies the current process, `$Host` identifies the host,
`$HOME` identifies the user home directory, and `$PWD` is the current provider
location.

```powershell
if ($PSVersionTable.PSEdition -ne 'Desktop') {
    throw 'Windows PowerShell 5.1 is required.'
}
```

`$PROFILE` identifies profile scripts for the current host and user. See
[about_Profiles](about_Profiles.md) for safe discovery and use.

## Null and collections

`$null` is PowerShell's null value. Compare with `$null` on the left side to
avoid collection-enumeration surprises:

```powershell
if ($null -eq $value) {
    'No value was supplied.'
}
```

Do not use empty string, zero, `$false`, and `$null` interchangeably. They
have different effects in parameter binding, conditional statements,
serialization, and native command arguments.

## Edition boundaries

Windows PowerShell 5.1 is Windows-only and based on .NET Framework. Do not use
PowerShell 7-only automatic variables such as `$IsWindows`, `$IsLinux`, or
`$IsMacOS` in a 5.1 script. Use an explicit documented operating-system or
edition check where a script supports multiple hosts.

## Related documents

- [about_Pipelines](about_Pipelines.md)
- [about_Profiles](about_Profiles.md)
- [about_Redirection](about_Redirection.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Automatic_Variables reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-5.1).
It is organized around pipeline state, script location, failures, and runtime
introspection for Windows PowerShell 5.1. Exact upstream revision and path are
recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
