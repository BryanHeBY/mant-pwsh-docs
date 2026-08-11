<!-- mant:tldr:start -->
# iex

> Alias for `Invoke-Expression`, which parses a string as Windows PowerShell 5.1 code.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-expression?view=powershell-5.1.

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

## Meaning and availability

`iex` is the built-in alias for `Invoke-Expression`. It parses a string as
Windows PowerShell source code in the current scope. This reclassifies data as
code and creates an injection risk. Check the alias with `Get-Alias iex` if a
profile or constrained endpoint might have changed it.

## Syntax

```powershell
Invoke-Expression [-Command] <string> [<CommonParameters>]
```

`iex` is an alias, so it has the same parameter binding behavior as
`Invoke-Expression`.

## Important parameter

<!-- mant:entries role=option case=insensitive -->
- `-Command COMMAND`: Evaluate one required string as Windows PowerShell source in the current scope. The parameter is positional and accepts pipeline input by value.

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
Get-Content -LiteralPath .\reviewed-script.ps1 -Raw | Invoke-Expression
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
block, invoke it directly. Pass values as parameters or separate arguments,
not concatenated source text:

```powershell
$script = Join-Path $PSScriptRoot 'build.ps1'
& $script -Configuration Release
```

Use splatting for dynamically assembled parameters and the call operator `&`
for a command path or script block. These preserve the data/code boundary that
`Invoke-Expression` removes.

## Common mistakes

### Treating pipeline input as safer than `-Command`

Piping a string to `iex` still executes it as code. The pipeline changes only
how `-Command` receives the string; it does not add validation or isolation.

### Piping a multi-line file without `-Raw`

`Get-Content .\script.ps1 | iex` sends one line at a time. Blocks, functions,
and here-strings can fail to parse or behave differently. Prefer direct
invocation with `& .\script.ps1`. If evaluation is unavoidable and the file is
trusted and reviewed, use `Get-Content -Raw` so it is one string.

### Executing downloaded or constructed text

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
