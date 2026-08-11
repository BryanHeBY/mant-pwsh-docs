<!-- mant:tldr:start -->
# iex

> Alias for `Invoke-Expression`, which parses a string as PowerShell code.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-expression?view=powershell-7.6.

- Prefer direct invocation of reviewed code:

`& {{./reviewed-script.ps1}}`

- Use a script block for controlled local code:

`& { {{command}} }`

- Evaluate one reviewed expression received through the pipeline:

`Write-Output '{{reviewed expression}}' | Invoke-Expression`

- Evaluate a reviewed multi-line file as one string:

`Get-Content -LiteralPath {{reviewed-script.ps1}} -Raw | Invoke-Expression`

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

## Syntax

```powershell
Invoke-Expression [-Command] <string> [<CommonParameters>]
```

`iex` is an alias, so it has the same parameter binding behavior as
`Invoke-Expression`.

## Pipeline input

`-Command` accepts `System.String` values from the pipeline by value. Each
incoming string is evaluated separately:

```powershell
'1 + 1', '2 + 2' | Invoke-Expression
```

```text
2
4
```

PowerShell does not concatenate multiple pipeline items into one script. This
matters when the text contains a multi-line block, function, or here-string.
If a trusted, reviewed file must be evaluated as code, `-Raw` reads the whole
file as one string:

```powershell
Get-Content -LiteralPath ./reviewed-script.ps1 -Raw | Invoke-Expression
```

Without `-Raw`, `Get-Content` emits one string per line and `Invoke-Expression`
tries to parse and run each line independently. The output produced by every
evaluated string continues through the pipeline normally:

```powershell
'Get-Process' | Invoke-Expression | Where-Object CPU -gt 10
```

Pipeline binding is only an input mechanism; it does not make the text safer.
Prefer direct invocation whenever the input is already a script path, command,
or script block.

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

## Common mistakes

### Treating pipeline input as safer than `-Command`

Piping a string to `iex` still executes it as code. The pipeline changes only
how `-Command` receives the string; it does not add validation or isolation.

### Piping a multi-line file without `-Raw`

`Get-Content ./script.ps1 | iex` sends one line at a time. Blocks, functions,
and here-strings can fail to parse or behave differently. Prefer direct
invocation with `& ./script.ps1`. If evaluation is unavoidable and the file is
trusted and reviewed, use `Get-Content -Raw` so it is one string.

### Executing downloaded or constructed text

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
