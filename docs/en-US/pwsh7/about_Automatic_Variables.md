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

## Variable index

<!-- mant:entries role=variable case=insensitive -->
- `$_`, `$PSItem`: Refer to the current pipeline object in a script block.
- `$args`: Hold positional arguments that were not bound to named parameters.
- `$input`: Enumerate pipeline input available to the current function or script block.
- `$PSBoundParameters`: Map parameter names to values explicitly bound to the current advanced function or script.
- `$PSScriptRoot`: Identify the directory containing the running script or module.
- `$PSCommandPath`: Identify the full path of the running script or module.
- `$MyInvocation`: Describe how the current command was invoked.
- `$?`: Report whether the latest PowerShell operation succeeded.
- `$Error`: Hold recent PowerShell error records.
- `$LASTEXITCODE`: Hold the exit code from the latest native program or explicitly exited PowerShell child process.
- `$PSVersionTable`: Describe the current PowerShell version, edition, platform, and compatibility data.
- `$PID`: Identify the current PowerShell process.
- `$Host`: Identify the application hosting PowerShell.
- `$HOME`: Identify the current user's home directory.
- `$PWD`: Hold the current provider location.
- `$PROFILE`: Identify the profile paths for the current host and user.
- `$null`: Represent PowerShell's null value.
- `$^`: Hold the first token from the last input line received by the session.
- `$$`: Hold the last token from the last input line received by the session.
- `$ConsoleFileName`: Identify the most recently used legacy `.psc1` console file where that Windows PowerShell console-file feature exists; it is absent in the recorded PowerShell 7.6.4 session.
- `$EnabledExperimentalFeatures`: List the experimental PowerShell features enabled for the current process.
- `$Event`: Hold the event currently being processed inside an event-registration `-Action` block.
- `$EventArgs`: Hold event arguments inside an event-registration `-Action` block.
- `$EventSubscriber`: Hold the subscriber for the event-registration `-Action` block currently running.
- `$Sender`: Hold the object that generated the event inside an event-registration `-Action` block.
- `$PSSenderInfo`: Describe the client that created the current PSSession; client-supplied application arguments are untrusted input.
- `$ExecutionContext`: Expose the current host's `EngineIntrinsics` execution context for advanced runtime inspection.
- `$PSCmdlet`: Expose the current cmdlet or advanced-function context, including parameter-set and ShouldProcess services.
- `$foreach`: Hold the enumerator of the currently running `foreach` statement, not the emitted values.
- `$switch`: Hold the enumerator of the currently running `switch` statement, not the emitted values.
- `$Matches`: Hold capture groups from the most recent successful scalar regex match or regex switch match.
- `$this`: Refer to the current instance inside a PowerShell class, ETS script property/method, or supported event delegate.
- `$StackTrace`: Hold the PowerShell stack trace for the most recent error.
- `$PSDebugContext`: Expose debugger context while stopped in the debugger; a normal PowerShell 7 session may not define the variable.
- `$NestedPromptLevel`: Report the current nested prompt or debugger prompt depth, with zero for the original prompt.
- `$PSEdition`: Identify the PowerShell product edition, normally `Core` in PowerShell 7.
- `$PSHOME`: Identify the PowerShell installation directory, not the user's home directory.
- `$PSCulture`: Identify the current culture name used for locale-sensitive behavior.
- `$PSUICulture`: Identify the current UI culture name used for localized resources.
- `$ShellId`: Identify the current PowerShell shell registration.
- `$IsCoreCLR`: Report whether the current session runs on CoreCLR; it is true for supported PowerShell 7.
- `$IsWindows`: Report whether the current PowerShell 7 process runs on Windows.
- `$IsLinux`: Report whether the current PowerShell 7 process runs on Linux.
- `$IsMacOS`: Report whether the current PowerShell 7 process runs on macOS.
- `$true`: Represent the Boolean true constant; do not assign application state to it.
- `$false`: Represent the Boolean false constant; do not assign application state to it.

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

`$PSCmdlet` exists in cmdlets and advanced functions and exposes the active
parameter set plus services such as `ShouldProcess`. `$ExecutionContext`
exposes lower-level engine services; it is not a portable replacement for
ordinary cmdlets and language features.

In an interactive session, `$^` and `$$` expose the first and last tokens from
the last input line. They are convenient for brief interactive recall, but
scripts should use named variables instead of depending on prior session input.

## Language and matching context

`$foreach` and `$switch` are the live enumerators of their corresponding
language statements and exist only while those statements run. Calling their
methods changes iteration state; read or advance them only when that behavior
is deliberate. They are unrelated to the `ForEach-Object` cmdlet.

`$Matches` is populated by a successful scalar `-match` or `-notmatch`, and by
regex `switch` matching. It retains the last successful match when a later
comparison fails, and a later successful match overwrites it. Copy required
capture values immediately instead of treating `$Matches` as a fresh result
after every comparison.

`$this` identifies the current instance in PowerShell class methods, ETS
script properties/methods, and supported event delegates. It has no general
meaning outside those contexts.

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

## Events and remoting identity

`$Event`, `$EventArgs`, `$EventSubscriber`, and `$Sender` are populated only
inside an event registration's `-Action` script block. Their lifetime and
thread/runspace context differ from normal sequential pipeline variables; copy
only the data required by the action and unregister bounded test subscribers.

`$PSSenderInfo` is available only inside a PSSession and describes the
originating client. Its `ApplicationArguments` property contains
client-supplied data and must never be used as authentication or authorization
evidence.

## Success, errors, and native exit codes

`$?` reports whether the latest PowerShell operation succeeded. `$Error` holds
recent error records. Neither is a substitute for a deliberate error-handling
boundary with `try`, `catch`, and `-ErrorAction Stop`.

PowerShell 7 keeps the actual command status in `$?` when a statement is
wrapped in parentheses `(...)`, a subexpression `$(...)`, or an array
expression `@(...)`. Windows PowerShell 5.1 instead resets `$?` to `$true`
after these wrappers, so migration tests must not assume the legacy result.

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

`$StackTrace` records the most recent PowerShell error stack. It can contain
paths, command text, and implementation details, so protect diagnostic output.
`$PSDebugContext` is populated while the debugger controls execution; on the
recorded 7.6.4 ordinary session the variable was absent outside debugging, so
test it with `Get-Variable -ErrorAction SilentlyContinue` rather than assuming
that it always exists with a null value.

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

`$PSEdition`, `$PSHOME`, `$PSCulture`, `$PSUICulture`, `$ShellId`, and
`$EnabledExperimentalFeatures` describe the running product and process.
`$IsWindows`, `$IsLinux`, and `$IsMacOS` are mutually exclusive platform
flags; `$IsCoreCLR` identifies the runtime family. Prefer these explicit flags
over parsing OS description strings.

The official topic also retains `$ConsoleFileName` for legacy `.psc1` console
files populated by Windows PowerShell's `-PSConsoleFile` or `Export-Console`.
Those snap-in console-file interfaces are not PowerShell 7 features, and the
variable was absent in the recorded 7.6.4 session. Gate legacy code with
`Get-Variable ConsoleFileName -ErrorAction SilentlyContinue`.

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

`$true` and `$false` are Boolean constants. Although PowerShell variable names
are case-insensitive, use the conventional lowercase spellings and store
application state in a separate, descriptively named variable.

## Platform and version differences

The meaning of automatic variables is mostly portable, but their values can
reflect host, operating system, current provider, startup mechanism, and
PowerShell version. Record a minimum version when a script depends on a
variable or behavior introduced in a later 7.x release. Windows PowerShell
5.1 must be documented and tested separately.

## Runtime evidence

The page's semantic index matches all 47 automatic-variable names in the
locked PowerShell 7.6 source, with no missing or extra names. PowerShell 7.6.4
on Windows confirmed the stable runtime/platform variables, `Core` edition,
mutually exclusive Windows/Linux/macOS flags, retained `$Matches` data after a
failed match, and `$foreach`/`$switch` enumerators. In an ordinary non-debugger
session, `$ConsoleFileName` and `$PSDebugContext` were absent rather than
defined with null values. macOS, Linux, debugger, event, remoting, nested
prompt, and legacy console-file contexts remain outstanding.

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
