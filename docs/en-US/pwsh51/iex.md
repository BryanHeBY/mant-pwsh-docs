<!-- mant:tldr:start -->
# iex

> Alias for `Invoke-Expression`, which parses a string as Windows PowerShell 5.1 code.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-expression?view=powershell-5.1.

- Prefer direct invocation of reviewed code:

`& {{./reviewed-script.ps1}}`

- Use a script block for controlled local code:

`& { {{command}} }`

- Inspect a command string instead of executing it:

`$commandText`
<!-- mant:tldr:end -->

# iex

## Meaning and availability

`iex` is the built-in alias for `Invoke-Expression`. It parses a string as
Windows PowerShell source code in the current scope. This reclassifies data as
code and creates an injection risk. Check the alias with `Get-Alias iex` if a
profile or constrained endpoint might have changed it.

## Prefer direct invocation

When the target is a reviewed script, module command, executable, or script
block, invoke it directly. Pass values as parameters or separate arguments,
not concatenated source text:

```powershell
$script = Join-Path $PSScriptRoot 'build.ps1'
& $script -Configuration Release
```

Use splatting for dynamically assembled parameters and the call operator `&`
for a command path or script block. These preserve the data/code boundary that
`Invoke-Expression` removes.

## Dangerous patterns

Never pass user input, a URL response, an untrusted file, an environment
variable, or a command-line argument to `iex`. In particular, `irm URL | iex`
downloads text and executes it with the current account's authority.

If an integration produces command text, redesign it around a structured
interface. If redesign is impossible, restrict the source, validate against a
strict allowlist, log the exact text, and use least privilege; it remains
higher risk than direct invocation.

`Invoke-Expression` works in the current scope, so it can create or modify
variables and functions visible to later commands. Its output is ordinary
pipeline output, but that does not reduce the code-execution risk.

## Related documents

- [irm](irm.md)
- [iwr](iwr.md)
- [about_Parsing](about_Parsing.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original alias page was adapted from the official
[Invoke-Expression reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-expression?view=powershell-5.1)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1).
It emphasizes safer alternatives and the security boundary between data and
code. Exact upstream revision and paths are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
