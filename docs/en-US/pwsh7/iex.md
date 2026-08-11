<!-- mant:tldr:start -->
# iex

> Alias for `Invoke-Expression`, which parses a string as PowerShell code.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-expression?view=powershell-7.6.

- Prefer direct invocation of reviewed code:

`& {{./reviewed-script.ps1}}`

- Use a script block for controlled local code:

`& { {{command}} }`

- Inspect a command string instead of executing it:

`$commandText`
<!-- mant:tldr:end -->

# iex

## Meaning

`iex` is a built-in alias for `Invoke-Expression`. It parses a string as
PowerShell source code in the current scope. Parsing data as code creates an
injection risk and usually has safer alternatives.

## Availability

`iex` is available by default in the tested PowerShell 7.6 Linux session.
Profiles and constrained endpoints can change alias availability. Use
`Get-Alias iex` or `Get-Command iex -All` when diagnosing an interactive
session.

## Prefer direct invocation

When the target is a reviewed script, module command, executable, or script
block, invoke it directly. Pass data through parameters or separate arguments
instead of concatenating it into source text.

```powershell
$script = Join-Path $PSScriptRoot 'build.ps1'
& $script -Configuration Release
```

Use splatting for dynamically assembled parameters and the call operator `&`
for a command path or script block. These patterns preserve data/code
boundaries that `Invoke-Expression` removes.

## Dangerous patterns

Never pass user input, a URL response, a file from an untrusted source, an
environment variable, or a command-line argument to `iex`. In particular,
`irm URL | iex` downloads text and executes it with the authority of the
current PowerShell session.

If an integration produces command text, redesign it to use a structured
interface. If no redesign is possible, restrict the source, validate against a
strict allowlist, log the exact text, and run with least privilege; this is
still higher risk than direct invocation.

## Scope and output

`Invoke-Expression` evaluates in the current scope, so it can create or alter
variables and functions visible to later commands. Its output becomes normal
PowerShell pipeline output, but that does not reduce its code-execution risk.

## Related documents

- [irm](irm.md)
- [iwr](iwr.md)
- [about_Parsing](about_Parsing.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original alias page was adapted from the official
[Invoke-Expression reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-expression?view=powershell-7.6)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.6).
It emphasizes safer alternatives and the security boundary between data and
code. Exact upstream revision and paths are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
