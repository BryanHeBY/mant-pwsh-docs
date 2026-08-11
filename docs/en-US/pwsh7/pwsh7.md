<!-- mant:tldr:start -->
# pwsh7

> PowerShell 7 shell and language reference for Windows, macOS, and Linux.
> The executable is named `pwsh`.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pwsh?view=powershell-7.6.

- Start an interactive shell without loading profiles:

`pwsh -NoProfile`

- Run a command and exit:

`pwsh -NoProfile -Command {{command}}`

- Run a script file:

`pwsh -NoProfile -File {{path/to/script.ps1}} {{arguments}}`

- Stop a script when a native command fails:

`{{native-command}}; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }`

- Browse the complete PowerShell 7 document collection:

`mant powershell-7-docs --source pwsh7`
<!-- mant:tldr:end -->

# PowerShell 7 shell and language

## Name

PowerShell 7 is a cross-platform command shell, scripting language, and
automation environment built around .NET objects. Its executable is `pwsh`
or `pwsh.exe` on Windows.

This page is the source's primary shell manual. It summarizes invocation,
language syntax, command resolution, object pipelines, streams, errors,
native-command interoperability, sessions, and platform behavior. Focused
cmdlet and `about_*` pages provide deeper treatment.

## Synopsis

```text
pwsh [options]
pwsh [[-File] script.ps1 [arguments]]
pwsh -Command command [arguments]
pwsh -CommandWithArgs command [arguments]
```

Parameter names are case-insensitive. With no script or command, `pwsh`
starts an interactive session.

## Invocation

`-File` runs a script. Arguments after the script path belong to that script,
so `-File` and its value normally appear last among launcher options.
`-Command` evaluates PowerShell source supplied by the invoking process and
then exits unless `-NoExit` is present. Quoting for either form is processed
first by the parent shell and then by PowerShell.

Use `-EncodedCommand` only when an integration genuinely requires a
UTF-16LE Base64-encoded command. Prefer `-File` for substantial automation:
script files are easier to review, quote, test, and log.

## Common invocation options

<!-- mant:entries role=option case=insensitive -->
- `-Command COMMAND`, `-c COMMAND`: Execute PowerShell source and then exit.
- `-CommandWithArgs COMMAND`, `-cwa COMMAND`: Execute a command and expose the remaining launcher arguments through `$args`; this option is experimental in the 7.6 baseline.
- `-File PATH`, `-f PATH`: Run a PowerShell script file.
- `-NoProfile`, `-nop`: Do not load any PowerShell profile scripts.
- `-NonInteractive`, `-noni`: Reject attempts to request interactive input.
- `-NoLogo`, `-nol`: Omit the startup banner.
- `-NoExit`, `-noe`: Keep the session open after running startup commands.
- `-WorkingDirectory PATH`, `-wd PATH`: Set the initial working directory.
- `-ExecutionPolicy POLICY`, `-ep POLICY`: Set the process-scope execution policy on Windows without changing the persisted policy.
- `-Login`, `-l`: Start a login shell on Unix-like systems; this option must be first.
- `-Version`, `-v`: Display the installed PowerShell version.
- `-Help`, `-h`, `-?`: Display launcher help.

Some launcher options are platform-specific or were added during the
PowerShell 7 lifecycle. Check `pwsh -Help` on the target machine before
depending on an option in portable deployment code.

## Commands and discovery

PowerShell commands include aliases, functions, filters, cmdlets, scripts,
applications, and external executables. Use `Get-Command` to discover what a
name resolves to and `Get-Command NAME -All` to expose shadowed definitions.
Use `Get-Help NAME -Full` for installed help.

When the same unqualified name exists in multiple command types, aliases and
functions can hide cmdlets or executables. Use an explicit path for a native
program, an extension such as `curl.exe` where appropriate, or a
module-qualified name such as `Microsoft.PowerShell.Utility\Invoke-WebRequest`
to remove ambiguity.

PowerShell command names are normally case-insensitive. Filesystem behavior
can still be case-sensitive on Linux and macOS, and native tools may treat
their own arguments as case-sensitive.

## Parsing and quoting

PowerShell parses the start of a pipeline in expression mode. After a command
name it normally switches to argument mode, where input is interpreted as
expandable strings unless syntax introduces an expression, variable,
subexpression, array, or script block.

Single-quoted strings are literal. Double-quoted strings expand variables and
subexpressions such as `$($value.Name)`. The backtick is PowerShell's escape
character, but repeated escaping across two shells is fragile. Prefer
single-quoted literals, arrays of arguments, splatting, or a script file.

Use `@(...)` for an array subexpression, `$(...)` for a subexpression, `@{}`
for a hashtable, and `{...}` for a script block. A here-string begins with
`@'` or `@"` at the end of a line and ends with the matching marker at the
start of a later line.

## Values, variables, and objects

Variables begin with `$` and hold .NET objects rather than untyped shell
text. Assignment does not normally require a declaration:

```powershell
$name = 'Ada'
$items = 1, 2, 3
$record = [pscustomobject]@{ Name = $name; Count = $items.Count }
```

Members are accessed with `.`, static members with `::`, and indexers with
`[]`. Type constraints such as `[int]$count` request conversion and restrict
later assignments. Automatic variables including `$_`, `$args`, `$input`,
`$?`, `$LASTEXITCODE`, `$PSItem`, and `$PSVersionTable` describe the current
execution context.

Environment variables use the `Env:` drive, for example `$env:PATH`.
PowerShell 7 treats environment-variable values as strings and uses
platform-specific name and path-list casing rules.

## Operators and control flow

PowerShell provides arithmetic, assignment, comparison, logical, type,
containment, replacement, matching, formatting, and redirection operators.
Common control statements include `if`, `switch`, `foreach`, `for`, `while`,
`do`, `try`, `catch`, `finally`, `trap`, `throw`, `return`, `break`,
`continue`, and `exit`.

PowerShell 7 also supports the pipeline-chain operators `&&` and `||`, the
null-coalescing operators `??` and `??=`, and the ternary operator `? :`.
These constructs are not available in Windows PowerShell 5.1.

## Functions, scripts, modules, and scope

A function is declared with `function Name { ... }`. Advanced functions use
`[CmdletBinding()]` and a `param(...)` block to gain cmdlet-style parameter
binding, common parameters, and pipeline input. Script blocks can have
`begin`, `process`, `end`, and `clean` clauses where supported.

Scopes include global, script, local, and private. Child scopes can read
parent values but assignments normally affect the current scope. Dot-sourcing
a script with `. ./script.ps1` runs it in the current scope and can therefore
add or replace definitions there.

Modules package functions, cmdlets, aliases, variables, types, and other
resources. `Import-Module` loads a module, while module-qualified command
names select a command without relying on normal name precedence.

## Object pipelines

The pipeline operator `|` sends objects from one command to the next. Cmdlets
bind those objects by value or property name rather than parsing display text.
Formatting normally belongs at the end of a pipeline because formatting
cmdlets emit formatting instructions instead of the original objects.

```powershell
Get-Process |
    Where-Object CPU -GT 10 |
    Sort-Object CPU -Descending |
    Select-Object -First 5 Name, CPU
```

Pipeline input is usually enumerated. Wrap a command in unary comma or use an
appropriate `-NoEnumerate` facility when one collection object must travel as
a single item. Native commands exchange text or bytes rather than live .NET
objects, so crossing the native boundary changes pipeline semantics.

## Streams and redirection

PowerShell has a success output stream plus numbered error, warning, verbose,
debug, and information streams. Redirection operators include `>`, `>>`,
`2>`, `2>&1`, and `*>`. Host or terminal UI is not always redirectable output;
commands should write to the appropriate stream instead of drawing directly
when automation must capture results.

`Write-Output` writes success output, `Write-Error` writes non-terminating
errors by default, and `throw` produces a terminating error. Verbose and debug
streams are normally hidden unless enabled by common parameters or preference
variables.

## Errors and exit status

PowerShell distinguishes terminating errors from non-terminating errors.
`try` and `catch` handle terminating errors. Use `-ErrorAction Stop` when a
normally non-terminating cmdlet error must enter `catch`; use preference
variables deliberately rather than changing them globally without restoring
their prior values.

`$?` reports whether the last PowerShell operation succeeded. After a native
program, `$LASTEXITCODE` contains its process exit code. A nonzero native exit
code does not automatically throw, so automation should test it explicitly:

```powershell
git diff --quiet
if ($LASTEXITCODE -notin 0, 1) {
    throw "git diff failed with exit code $LASTEXITCODE"
}
```

When using `pwsh -Command`, use `exit $LASTEXITCODE` when the caller must
receive a native program's exact exit code. An uncaught terminating error
normally makes the PowerShell process fail.

## Native commands

PowerShell locates native programs through explicit paths and `PATH`. Pass
arguments as separate PowerShell values whenever possible. Avoid constructing
one command line with `Invoke-Expression`; it reparses data as code and creates
quoting and injection hazards.

Native standard output becomes pipeline input, and native standard error is
connected to PowerShell's error handling and redirection behavior. Encoding,
argument passing, and byte-stream redirection changed across PowerShell 7
releases, so scripts that depend on exact native behavior should state and
test their minimum PowerShell version.

On Windows, the stop-parsing token `--%` passes the remainder of a line with
minimal PowerShell interpretation. It is a compatibility escape hatch, not a
portable quoting mechanism.

## Paths, providers, and locations

PowerShell exposes data stores through providers and drives. Filesystem paths
are the most common, but drives such as `Env:`, `Alias:`, `Function:`, and
`Variable:` expose other stores through related cmdlets. Use `Join-Path` and
provider-aware cmdlets instead of assuming one directory separator.

The process working directory and PowerShell's current provider location can
differ when native APIs change the process directory. Native programs operate
on filesystem paths and cannot consume arbitrary provider paths.

## Profiles and sessions

`$PROFILE` identifies the current user/current host profile and exposes other
profile paths as properties. Profiles can define functions, aliases, modules,
prompt behavior, and preferences. Use `pwsh -NoProfile` for reproducible
automation and troubleshooting.

Session state includes variables, functions, aliases, imported modules,
locations, jobs, and preferences. A new `pwsh` process starts a new session;
changes made only in memory do not persist unless written to a profile,
module, configuration file, or external store.

## Jobs and remoting

Background jobs and thread jobs run work outside the foreground pipeline and
return results through serialization or in-process object transfer depending
on the job type. PowerShell remoting uses sessions and transports such as
WSMan or SSH; availability and authentication vary by platform.

Treat remoting boundaries like process boundaries: types can be deserialized,
credentials require explicit handling, and commands run under the remote
session's modules, policy, paths, and identity.

## Security

Execution policy is a safety feature for controlling script-loading behavior,
not a security boundary. Do not execute untrusted source merely because it is
signed or allowed by policy. Validate input, avoid reparsing data as code,
request only required privileges, and use constrained endpoints or language
modes where an administrator has designed them for the threat model.

Secrets should come from an appropriate secret store or credential mechanism,
not source files, command histories, or command-line arguments visible to
other processes.

## Platform and version differences

PowerShell 7 uses the `Core` edition and runs on Windows, macOS, and Linux.
Available modules, providers, authentication mechanisms, execution policy
behavior, path casing, native tools, and installation locations differ by
operating system. `$PSVersionTable` is the authoritative runtime summary.

This manual follows the supported PowerShell 7 LTS channel. Features added in
later stable releases must be labeled with their minimum version. Do not infer
Windows PowerShell 5.1 compatibility from this page.

## Common mistakes

### Confusing object output with display text

Formatting is a host view, not the object contract. Inspect members and export
a deliberate interchange format instead of parsing tables.

### Reusing native-shell quoting rules unchanged

PowerShell parses arguments before a native program receives them. Keep data
as separate arguments, use the stop-parsing token only for its documented
Windows cases, and test the actual target executable.

### Treating non-terminating errors as process failure

Set an intentional error and exit-status policy for automation; inspect
`$LASTEXITCODE` separately after native commands.

## Examples

Run a script predictably from another process:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File ./build.ps1
```

Turn command failures into a terminating error:

```powershell
$ErrorActionPreference = 'Stop'
try {
    Get-Item -LiteralPath ./required.json | Out-Null
} catch {
    Write-Error "Preparation failed: $_"
    exit 1
}
```

Convert native JSON output into objects while preserving failure status:

```powershell
$json = tool list --output json
if ($LASTEXITCODE -ne 0) {
    throw "tool failed with exit code $LASTEXITCODE"
}
$items = $json | ConvertFrom-Json
```

## Related documents

- [PowerShell 7 documentation](powershell-7-docs.md)

Focused launcher, cmdlet, alias, and `about_*` documents will be linked here
as they are added.

## Sources and license

This original ManT-oriented reference was written from the official
[PowerShell launcher documentation](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pwsh?view=powershell-7.6),
plus the official parsing, quoting, pipeline, and automatic-variable topics,
with runtime checks against PowerShell 7.6.3 on Linux. Exact upstream
repository revisions and paths are recorded in `upstream/pwsh7.json`.

The documentation is licensed under CC BY 4.0. The cited PowerShell
documentation is licensed under CC BY 4.0; cited PowerShell source code is
licensed under MIT. This page reorganizes and summarizes those materials and
adds ManT-specific navigation and examples.
