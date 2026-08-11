<!-- mant:tldr:start -->
# native-commands

> Call external programs from PowerShell 7 without losing argument, output, or exit-status intent.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.6.

- Check which command a name resolves to:

`Get-Command {{name}} -All`

- Call an executable explicitly on Windows:

`{{command}}.exe {{arguments}}`

- Stop when a native command fails:

`{{command}} {{arguments}}; if ($LASTEXITCODE -ne 0) { throw "failed: $LASTEXITCODE" }`
<!-- mant:tldr:end -->

# Native commands in PowerShell 7

## Overview

A native command is an external executable such as `git`, `ssh`, `curl`, or a
Windows system tool. PowerShell parses the invocation first, then starts the
program, then maps its output and exit status into PowerShell's pipeline and
stream model. The executable still owns its own option syntax and argument
parser.

## Command resolution

An unqualified name can resolve to an alias, function, cmdlet, script, or
executable. Use `Get-Command NAME -All` to see every match. When an alias can
hide an executable, use an explicit executable name such as `curl.exe`, an
absolute path, or the call operator with a resolved path.

```powershell
Get-Command curl -All
& (Get-Command git -CommandType Application).Source --version
```

Do not assume that a name has the same meaning on Windows, Linux, and macOS.
PowerShell aliases, `PATH`, filesystem casing, installed packages, and shell
wrappers can all differ.

## Arguments and quoting

Pass one logical argument as one PowerShell value. Let PowerShell convert the
argument list for the target program instead of concatenating a command string
and reparsing it with `Invoke-Expression`.

```powershell
$message = 'fix: preserve spaces'
git commit -m $message
```

Quoting visible in PowerShell source is not necessarily a literal quote seen
by the target process. The target executable can use a different parser, and
PowerShell 7 has changed native argument-passing behavior across releases.
Test values containing spaces, quotes, Unicode, backslashes, wildcards, and
leading hyphens on every supported platform.

On Windows, the stop-parsing token `--%` passes the rest of a native command
line with minimal PowerShell interpretation. It is Windows-only and should be
a last resort for a tool that cannot be expressed as separate arguments.

## Output and streams

Native programs have standard output and standard error, not PowerShell object
output and six diagnostic streams. Their output can enter a PowerShell pipeline
as text or, in supported PowerShell 7 scenarios, as bytes. Do not treat native
text as an object with properties; parse a documented structured format such
as JSON explicitly.

```powershell
$json = tool list --output json
if ($LASTEXITCODE -ne 0) {
    throw "tool failed with exit code $LASTEXITCODE"
}
$items = $json | ConvertFrom-Json
```

Use `2>&1` or `*> FILE` only when the consumer truly needs merged diagnostic
content. Merging streams does not make a failed native process successful.

## Exit status

After a native command, `$LASTEXITCODE` holds its numeric process exit code.
`$?` reports the success state of the latest PowerShell operation, but it does
not replace a tool-specific exit-code policy. Check the native tool's manual:
some commands use nonzero values for useful states rather than failures.

```powershell
git diff --quiet
switch ($LASTEXITCODE) {
    0 { 'no changes' }
    1 { 'changes found' }
    default { throw "git diff failed: $LASTEXITCODE" }
}
```

When a PowerShell script must forward a native status to its caller, use
`exit $LASTEXITCODE` after applying any tool-specific interpretation.

## Security

Never turn untrusted input into PowerShell source with `Invoke-Expression`.
Avoid putting secrets in command-line arguments because other local processes
can often observe them. Prefer a tool's standard input, environment contract,
or credential store when its documentation supports one.

Use `-LiteralPath` for PowerShell cmdlets that handle filenames containing
wildcards, and validate user-controlled argument values before passing them to
destructive native tools.

## Platform and version differences

PowerShell 7 is cross-platform, but executable availability, `PATH` entries,
filesystem semantics, console encodings, and native argument parsing are not.
The `PSNativeCommandArgumentPassing` preference and byte-stream handling can
also depend on the PowerShell 7 version. Document a minimum version whenever
automation depends on these details.

## Related documents

- [about_Parsing](about_Parsing.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [about_Pipelines](about_Pipelines.md)
- [about_Redirection](about_Redirection.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented guide was informed by the native-command sections
of the official [about_Parsing reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.6)
and related PowerShell 7 documentation. It adds a task-oriented model for
command resolution, data conversion, exit status, and safety. Exact upstream
revision and paths are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
