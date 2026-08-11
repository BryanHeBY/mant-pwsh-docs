<!-- mant:tldr:start -->
# native-commands

> Run Windows native executables from Windows PowerShell 5.1 with predictable arguments and exit codes.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-5.1.

- Check what command name will run:

`Get-Command {{name}} -All`

- Run an executable and propagate its exit code:

`& {{program.exe}} {{arguments}}; exit $LASTEXITCODE`

- Pass the remaining native command line with minimal PowerShell parsing:

`{{program.exe}} --% {{arguments}}`
<!-- mant:tldr:end -->

# native-commands

## Synopsis

Windows PowerShell 5.1 can invoke Windows executables in a pipeline, but an
executable does not receive PowerShell objects or cmdlet parameter binding. It
receives a Windows command line after PowerShell has resolved the command and
converted its arguments. Treat executable boundaries, text output, and exit
codes as an explicit part of a script's interface.

## Resolve the executable first

A bare name can resolve to an alias, function, cmdlet, script, or executable.
Check the actual candidates before assuming a name calls a particular program:

```powershell
Get-Command curl -All
Get-Command robocopy.exe -All
```

Use an explicit executable name such as `robocopy.exe` when it avoids a naming
collision. Use the call operator (`&`) when the path is held in a variable or
contains spaces:

```powershell
$tool = 'C:\Program Files\Vendor\tool.exe'
& $tool '--input' 'C:\work\input file.txt'
```

Do not construct an executable call as a source string and pass it to
`Invoke-Expression`. Keep the command path and every argument as separate,
reviewable values.

## Argument boundaries and quoting

PowerShell expands a variable or expression before invoking the executable.
The executable then applies its own Windows command-line parsing rules. Quotes
in PowerShell source therefore do not necessarily arrive as literal quote
characters at the target process.

Prefer a script-file interface or a tool-specific response/configuration file
when an executable needs complicated quoting. Test the exact program with
spaces, quotes, trailing backslashes, Unicode, and empty values. `--%` is a
Windows-only stop-parsing token that can pass the rest of one native command
line with minimal PowerShell interpretation; it is a compatibility escape hatch
and not a portable general-purpose quoting rule.

## Input and output

Cmdlets exchange .NET objects in a pipeline. A native executable writes text
or bytes to its standard streams. Pipe native output to a parsing step only
when its format is documented and stable:

```powershell
& ipconfig.exe /all |
    Select-String 'IPv4'
```

For machine-to-machine integration, prefer a documented structured output
format or an API over scraping display text. Be especially careful with code
pages and locale-dependent formatting in legacy Windows tools.

## Exit codes and errors

After an executable returns, Windows PowerShell puts its result in
`$LASTEXITCODE`. It does not automatically make a nonzero native code a
terminating PowerShell error. Check the value immediately and define the
program-specific success rule:

```powershell
& robocopy.exe .\source .\target /E
if ($LASTEXITCODE -gt 7) {
    throw "robocopy failed with exit code $LASTEXITCODE"
}
```

Do not blindly treat every nonzero result as failure: some Windows tools use
nonzero values for warnings, differences, or successful work. Consult the
tool's own reference and propagate the intended code with `exit $LASTEXITCODE`
when PowerShell is acting as a wrapper.

## Redirection

PowerShell's streams and an executable's standard output/error are related but
not interchangeable. Capture diagnostic output when it is needed for an error
report, avoid merging streams before a parser that relies on their distinction,
and test redirection with the installed Windows PowerShell host.

## Version and availability

This page targets Windows PowerShell 5.1 and the Windows process command-line
model. PowerShell 7 changed native argument passing and some redirection
behavior; native utility availability also varies by Windows release.

## Related documents

- [about_Parsing](about_Parsing.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [powershell](powershell.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented guide is informed by the official
[about_Parsing reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-5.1).
It separates command resolution, argument conversion, text streams, and exit
codes for Windows PowerShell 5.1 automation. Exact upstream revision and path
are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
