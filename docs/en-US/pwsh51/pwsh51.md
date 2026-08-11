<!-- mant:tldr:start -->
# pwsh51

> Windows PowerShell 5.1 shell and language reference for Windows.
> The executable is named `powershell.exe`.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1.

- Start an interactive shell without loading profiles:

`powershell.exe -NoProfile`

- Run a command and exit:

`powershell.exe -NoProfile -Command {{command}}`

- Run a script file:

`powershell.exe -NoProfile -File {{path\to\script.ps1}} {{arguments}}`

- Stop a script when a native command fails:

`{{native-command}}; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }`

- Browse the complete Windows PowerShell 5.1 document collection:

`mant windows-powershell-5.1-docs --source pwsh51`
<!-- mant:tldr:end -->

# Windows PowerShell 5.1 shell and language

## Name

Windows PowerShell 5.1 is the Windows-only command shell, scripting language,
and automation environment built on .NET Framework. Its console executable is
`powershell.exe`, and `$PSVersionTable.PSEdition` reports `Desktop`.

This page is the source's primary shell manual. It summarizes invocation,
language syntax, command resolution, object pipelines, streams, errors,
native-command interoperability, sessions, and Windows behavior. Focused
cmdlet and `about_*` pages provide deeper treatment.

## Synopsis

```text
powershell.exe [options]
powershell.exe [[-File] script.ps1 [arguments]]
powershell.exe -Command command [arguments]
```

Parameter names are case-insensitive. With no script or command,
`powershell.exe` starts an interactive console session.

## Invocation

`-File` runs a script. Arguments after the script path belong to that script,
so the script path and its arguments appear at the end of the launcher command.
`-Command` evaluates PowerShell source supplied by the invoking process and
then exits unless `-NoExit` is present. The parent process parses quoting
before Windows PowerShell sees the command.

Use `-EncodedCommand` only when an integration genuinely requires a
UTF-16LE Base64-encoded command. Prefer `-File` for substantial automation:
script files are easier to review, quote, test, and log.

## Common invocation options

- `-Command COMMAND`, `-c COMMAND`: Execute PowerShell source and then exit.
- `-File PATH`, `-f PATH`: Run a Windows PowerShell script file.
- `-NoProfile`, `-nop`: Do not load any Windows PowerShell profile scripts.
- `-NonInteractive`, `-noni`: Reject attempts to request interactive input.
- `-NoLogo`, `-nol`: Omit the startup banner.
- `-NoExit`, `-noe`: Keep the session open after running startup commands.
- `-ExecutionPolicy POLICY`, `-ep POLICY`: Set the process-scope execution policy without changing the persisted policy.
- `-EncodedCommand BASE64`, `-e BASE64`: Execute a UTF-16LE Base64-encoded command.
- `-InputFormat FORMAT`, `-if FORMAT`: Select text or CLIXML input from the parent process.
- `-OutputFormat FORMAT`, `-of FORMAT`: Select text or CLIXML output for the parent process.
- `-STA`, `-MTA`: Select the apartment state for the session thread.
- `-Help`, `-h`, `-?`: Display launcher help.

Launcher behavior can depend on whether Windows PowerShell is started from
`cmd.exe`, another PowerShell session, Task Scheduler, a service, or a process
API. Test the actual host used by production automation.

## Commands and discovery

Windows PowerShell commands include aliases, functions, filters, cmdlets,
scripts, applications, and external executables. Use `Get-Command` to discover
what a name resolves to and `Get-Command NAME -All` to expose shadowed
definitions. Use `Get-Help NAME -Full` for installed help and `Update-Help`
where the module supports downloadable help.

Aliases and functions can hide cmdlets or executables. Use an explicit path
for a native program, an extension such as `curl.exe`, or a module-qualified
name such as `Microsoft.PowerShell.Utility\Invoke-WebRequest` to remove
ambiguity. Command names are normally case-insensitive on Windows.

## Parsing and quoting

Windows PowerShell parses the start of a pipeline in expression mode. After a
command name it normally switches to argument mode, where input is interpreted
as expandable strings unless syntax introduces an expression, variable,
subexpression, array, or script block.

Single-quoted strings are literal. Double-quoted strings expand variables and
subexpressions such as `$($value.Name)`. The backtick is the escape character,
but repeated escaping across `cmd.exe`, Task Scheduler, process APIs, and
Windows PowerShell is fragile. Prefer single-quoted literals, argument arrays,
splatting, or a script file.

Use `@(...)` for an array subexpression, `$(...)` for a subexpression, `@{}`
for a hashtable, and `{...}` for a script block. A here-string begins with
`@'` or `@"` at the end of a line and ends with the matching marker at the
start of a later line.

## Values, variables, and objects

Variables begin with `$` and hold .NET Framework objects rather than untyped
shell text. Assignment does not normally require a declaration:

```powershell
$name = 'Ada'
$items = 1, 2, 3
$record = New-Object psobject -Property @{
    Name = $name
    Count = $items.Count
}
```

Members are accessed with `.`, static members with `::`, and indexers with
`[]`. Type constraints such as `[int]$count` request conversion and restrict
later assignments. Automatic variables including `$_`, `$args`, `$input`,
`$?`, `$LASTEXITCODE`, `$PSItem`, and `$PSVersionTable` describe the current
execution context.

Environment variables use the `Env:` drive, for example `$env:PATH`.
Environment-variable names are case-insensitive on Windows.

## Operators and control flow

Windows PowerShell 5.1 provides arithmetic, assignment, comparison, logical,
type, containment, replacement, matching, formatting, and redirection
operators. Common control statements include `if`, `switch`, `foreach`,
`for`, `while`, `do`, `try`, `catch`, `finally`, `trap`, `throw`, `return`,
`break`, `continue`, and `exit`.

The PowerShell 7 pipeline-chain operators `&&` and `||`, null-coalescing
operators `??` and `??=`, and ternary operator `? :` are not available.
Use `if`, `$?`, or `$LASTEXITCODE` explicitly when porting newer scripts.

## Functions, scripts, modules, and scope

A function is declared with `function Name { ... }`. Advanced functions use
`[CmdletBinding()]` and a `param(...)` block to gain cmdlet-style parameter
binding, common parameters, and pipeline input. Pipeline-aware functions can
use `begin`, `process`, and `end` clauses.

Scopes include global, script, local, and private. Child scopes can read
parent values but assignments normally affect the current scope. Dot-sourcing
a script with `. .\script.ps1` runs it in the current scope and can therefore
add or replace definitions there.

Modules package functions, cmdlets, aliases, variables, types, and other
resources. Windows PowerShell can load script and binary modules built for its
edition and .NET Framework. A module available in PowerShell 7 is not
necessarily compatible with Windows PowerShell 5.1, or vice versa.

## Object pipelines

The pipeline operator `|` sends objects from one command to the next. Cmdlets
bind those objects by value or property name rather than parsing display text.
Formatting normally belongs at the end of a pipeline because formatting
cmdlets emit formatting instructions instead of the original objects.

```powershell
Get-Process |
    Where-Object { $_.CPU -gt 10 } |
    Sort-Object CPU -Descending |
    Select-Object -First 5 Name, CPU
```

Pipeline input is usually enumerated. Use unary comma or an appropriate
`-NoEnumerate` facility when one collection object must travel as a single
item. Native programs exchange encoded text rather than live .NET objects, so
crossing the native boundary changes pipeline semantics.

## Streams and redirection

Windows PowerShell 5.1 has a success output stream plus numbered error,
warning, verbose, debug, and information streams. Redirection operators
include `>`, `>>`, `2>`, `2>&1`, and `*>`. Host UI is not always redirectable
output; commands should write to the appropriate stream when automation must
capture results.

`Write-Output` writes success output, `Write-Error` writes non-terminating
errors by default, and `throw` produces a terminating error. Verbose and debug
streams are normally hidden unless enabled by common parameters or preference
variables.

## Errors and exit status

Windows PowerShell distinguishes terminating errors from non-terminating
errors. `try` and `catch` handle terminating errors. Use `-ErrorAction Stop`
when a normally non-terminating cmdlet error must enter `catch`; avoid changing
global preference variables without restoring their prior values.

`$?` reports whether the last PowerShell operation succeeded. After a native
program, `$LASTEXITCODE` contains its process exit code. A nonzero native exit
code does not automatically throw, so automation should test it explicitly:

```powershell
robocopy.exe .\source .\destination /E
if ($LASTEXITCODE -ge 8) {
    throw "robocopy failed with exit code $LASTEXITCODE"
}
```

Do not assume that every native tool uses zero for success and every nonzero
value for failure; tools such as `robocopy.exe` define ranges of successful or
informational codes. When using `powershell.exe -Command`, use
`exit $LASTEXITCODE` when the caller must receive a native program's exact
exit code.

## Native commands

Windows PowerShell locates native programs through explicit paths, file
associations where applicable, and `PATH`. Argument conversion ultimately
targets the Windows process command-line model, so quoting can differ between
executables that use different argument parsers.

Pass arguments as separate PowerShell values whenever possible. Avoid
constructing one command line with `Invoke-Expression`; it reparses data as
code and creates quoting and injection hazards. The Windows-only stop-parsing
token `--%` can pass the remainder of a line with minimal PowerShell
interpretation, but it is a compatibility escape hatch rather than a general
composition mechanism.

Native output enters PowerShell as decoded text. Input and output encoding can
depend on console code pages, `$OutputEncoding`, cmdlet defaults, and the
native tool. Test scripts that exchange non-ASCII data or binary content; do
not pass binary data through a text pipeline without an explicit safe format.

## Paths, providers, and locations

PowerShell exposes data stores through providers and drives. Filesystem paths
are the most common, but drives such as `HKLM:`, `HKCU:`, `Certificate:`,
`Env:`, `Alias:`, `Function:`, and `Variable:` expose other stores through
related cmdlets. Not every provider is available on every Windows
installation.

Use `Join-Path`, `-LiteralPath`, and provider-aware cmdlets instead of manual
string concatenation. Native programs accept filesystem paths and cannot
consume arbitrary PowerShell provider paths.

## Profiles and sessions

`$PROFILE` identifies the current user/current host profile and exposes other
profile paths as properties. Different hosts, including the console host and
Windows PowerShell ISE, load different host-specific profiles. Use
`powershell.exe -NoProfile` for reproducible automation and troubleshooting.

Session state includes variables, functions, aliases, imported modules,
locations, jobs, and preferences. A new `powershell.exe` process starts a new
session; in-memory changes do not persist unless written to a profile, module,
configuration file, registry location, or other external store.

## Jobs and remoting

Background jobs run commands outside the foreground pipeline and normally
return serialized results. Windows PowerShell remoting commonly uses WSMan,
registered session configurations, and Windows authentication. Availability
depends on Windows configuration, network policy, identity, and endpoint
permissions.

Treat remoting boundaries like process boundaries: returned types can be
deserialized, credentials require explicit handling, and commands run under
the remote endpoint's modules, policy, paths, architecture, and identity.

## Security

Execution policy is a safety feature for controlling script-loading behavior,
not a security boundary. Do not execute untrusted source merely because it is
signed or allowed by policy. Validate input, avoid reparsing data as code,
request only required privileges, and use constrained endpoints or language
modes where administrators have designed them for the threat model.

Secrets should come from an appropriate credential or secret mechanism, not
source files, command histories, or command-line arguments visible to other
processes. Be explicit about 32-bit versus 64-bit hosts when registry,
filesystem redirection, or binary modules are involved.

## Version and compatibility

Windows PowerShell 5.1 is the final Windows PowerShell release and is distinct
from cross-platform PowerShell 7. It uses the `Desktop` edition and .NET
Framework, is installed as a Windows component, and receives servicing with
Windows rather than following the PowerShell 7 release lifecycle.

Available inbox modules and command versions depend on the Windows edition,
Windows release, installed roles and features, and management products.
Record those dependencies per document. Do not infer 5.1 behavior from a
PowerShell 7 runtime test.

## Examples

Run a script predictably from another process:

```powershell
powershell.exe -NoLogo -NoProfile -NonInteractive -File .\build.ps1
```

Turn cmdlet failures into a terminating error:

```powershell
$ErrorActionPreference = 'Stop'
try {
    Get-Item -LiteralPath .\required.json | Out-Null
} catch {
    Write-Error "Preparation failed: $_"
    exit 1
}
```

Capture JSON from a native tool while preserving failure status:

```powershell
$json = tool.exe list --output json
if ($LASTEXITCODE -ne 0) {
    throw "tool failed with exit code $LASTEXITCODE"
}
$items = $json | ConvertFrom-Json
```

## Related documents

- [Windows PowerShell 5.1 documentation](windows-powershell-5.1-docs.md)

Focused launcher, cmdlet, alias, and `about_*` documents will be linked here
as they are added.

## Sources and license

This original ManT-oriented reference was written from the official
[Windows PowerShell launcher documentation](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1),
plus the official parsing, quoting, pipeline, and automatic-variable topics.
Windows-specific runtime verification is still required before the document
can be marked `verified`. Exact upstream repository revisions and paths are
recorded in `upstream/pwsh51.json`.

The documentation is licensed under CC BY 4.0. The cited Microsoft
documentation is licensed under CC BY 4.0. This page reorganizes and
summarizes those materials and adds ManT-specific navigation and examples.
