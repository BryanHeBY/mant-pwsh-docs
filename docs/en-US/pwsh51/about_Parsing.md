<!-- mant:tldr:start -->
# about_Parsing

> Understand how Windows PowerShell 5.1 turns source text into commands and values.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-5.1.

- See how a command name resolves:

`Get-Command {{name}} -All`

- Pass a literal path to a cmdlet:

`Get-Item -LiteralPath {{path/with[special]characters}}`

- Stop parsing the rest of a Windows native command line:

`{{native-command}} --% {{native arguments}}`
<!-- mant:tldr:end -->

# about_Parsing

## Short description

Windows PowerShell 5.1 parses input in expression mode and argument mode.
Knowing the active mode explains most quoting, wildcard, parameter-binding, and
native command surprises. Do not assume that a later PowerShell 7 parsing
feature exists in 5.1.

## Expression mode

At the start of a pipeline, Windows PowerShell expects an expression. It
recognizes variables, strings, numbers, operators, member access, arrays,
hashtables, subexpressions, and command expressions.

```powershell
$total = (Get-ChildItem).Count + 1
if ($total -gt 1) { 'many items' }
```

Parentheses group expressions, `$()` evaluates a subexpression, and `@()`
creates an array from expression output.

## Argument mode

After PowerShell recognizes a command name, it normally switches to argument
mode. Unquoted input is then an expandable argument string unless syntax gives
it another role. Variables and subexpressions still expand, but spaces, quotes,
commas, braces, wildcards, and parameter-looking text have command-specific
rules.

```powershell
Get-ChildItem -Path .\logs -Filter '*.log'
Write-Output "items: $((Get-ChildItem).Count)"
```

Cmdlets bind parameters after parsing. Use complete parameter names in shared
scripts and quote data that could be mistaken for syntax.

## Piping language statements

Language statements such as `foreach`, `if`, and `switch` are not commands and
cannot be followed directly by `|`. This source fails during parsing with
`EmptyPipeElement`:

```text
foreach ($item in 1..3) { $item } | Measure-Object
```

Capture the statement output first, or invoke a script block when the output
should stream directly into the next command:

```powershell
$items = foreach ($item in 1..3) { $item }
$items | Measure-Object

& { foreach ($item in 1..3) { $item } } | Measure-Object
```

`ForEach-Object` is a cmdlet, so it can appear as a normal pipeline element;
the `foreach` language statement has different grammar and behavior.

## Embedding indexed values

An index works when the variable reference is the complete argument, but an
index or member access embedded in a larger expandable token needs `$()`:

```powershell
$parts = @('alpha', 'beta')
Write-Output $parts[1]                 # beta
Write-Output "value=$parts[1]"         # value=alpha beta[1]
Write-Output "value=$($parts[1])"      # value=beta
```

Without the subexpression, Windows PowerShell expands the simple `$parts`
reference and treats `[1]` as literal text. The same rule matters when
building native arguments such as `"--explain=$($parts[1])"`. Assign the
selected value to a scalar first when that is clearer.

## Token boundaries around variables and parameters

Whitespace still separates command arguments. Compressing a generated command
can silently change its tokens:

Incorrect—the intended variable and parameter boundaries are absent:

```text
Get-Content $catalogPath-Raw-Encoding utf8
```

Correct—make every boundary explicit:

```powershell
# Keep file paths and parameter names as separate tokens.
Get-Content -LiteralPath $catalogPath -Raw -Encoding utf8
```

The first form can bind a different variable/text token and report an unknown
combined parameter such as `-Raw-Encoding`. If a diagnostic script continues
after that error, later null/default calculations can still print plausible
counts. Prefer named parameters with visible spaces; use
`$ErrorActionPreference = 'Stop'` or explicit `-ErrorAction Stop` when a failed
read must invalidate all downstream evidence. Fail fast before calculating or
publishing any derived count.

Missing whitespace does not always produce an error. In `Where-Object`'s
simplified syntax, this form is syntactically valid but combines the intended
property, operator, and variable boundaries and can silently select nothing:

```powershell
$name = 'alpha'
$rows = @([pscustomobject]@{ document = 'alpha' })
$matches = @($rows | Where-Object document-eq$name) # Incorrect: count is 0.
```

Use an explicit predicate when variables or generated tokens participate, then
assert the expected coverage before publishing a result:

```powershell
$matches = @($rows | Where-Object { $_.document -eq $name })
if ($matches.Count -ne 1) {
    throw "Expected one document, found $($matches.Count)."
}
```

A successful pipeline status and an empty collection do not prove that no
source rows matched. Treat the input count, selected count, and expected key
set as evidence invariants.

## Special characters and literal input

Spaces, quotes, dollar signs, backticks, commas, semicolons, pipes, braces,
parentheses, wildcard characters, and redirection operators can have syntactic
meaning. Use `-LiteralPath` rather than `-Path` when a filesystem name must
not expand wildcard characters.

Do not concatenate untrusted data into a string for `Invoke-Expression`.
Prefer typed parameters, separate argument values, hashtables for splatting,
and reviewed script files.

## Line continuation

Use natural continuation after a pipe, comma, opening delimiter, or operator.
Avoid a trailing backtick where possible: trailing whitespace changes its
meaning and produces fragile scripts.

```powershell
Get-Process |
    Where-Object CPU -GT 10 |
    Sort-Object CPU -Descending
```

## Native commands

Native programs do not use PowerShell parameter binding. Windows PowerShell
parses the invocation and converts arguments for the Windows process command
line; the target program then applies its own parser. Pass arguments as
separate values where possible and test the exact executable being called.

`--%` is a Windows-only stop-parsing token that passes the remaining text with
minimal PowerShell interpretation. It is a compatibility escape hatch, not a
portable quoting mechanism or a substitute for a script-file interface.

## End-of-parameters token

`--` tells PowerShell cmdlets to stop interpreting later tokens as parameters.
It does not define a universal escape rule for native programs. Each native
CLI owns its own option and argument conventions.

## Version and availability

This page describes the Windows PowerShell 5.1 parser on Windows. Do not copy
PowerShell 7 native-argument behavior or newer parsing features into a 5.1
script without testing the exact host.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 parsed every PowerShell example in this
edition's document set. Bounded probes confirmed indexed interpolation
requiring `$()`, the `EmptyPipeElement` error for piping directly from a
`foreach` statement, and literal child source preserving `$value` for the
child parser. A failed catalog-read probe also confirmed that removing
whitespace before `-Raw` or `-Encoding` changes tokenization and can lead to
plausible but invalid downstream counts. Native target parsers and arbitrary
quoting combinations remain application-specific.

## Related documents

- [about_Quoting_Rules](about_Quoting_Rules.md)
- [native-commands](native-commands.md)
- [powershell.exe](powershell.exe.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Parsing reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-5.1).
It emphasizes the 5.1 parsing boundary, literal paths, and Windows native
command composition. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
