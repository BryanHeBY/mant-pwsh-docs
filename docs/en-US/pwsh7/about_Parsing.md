<!-- mant:tldr:start -->
# about_Parsing

> Understand how PowerShell 7 turns source text into commands and values.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.6.

- See how a command name resolves:

`Get-Command {{name}} -All`

- Pass a literal path to a cmdlet:

`Get-Item -LiteralPath {{path/with[special]characters}}`

- Stop parsing the rest of a Windows native command line:

`{{native-command}} --% {{native arguments}}`
<!-- mant:tldr:end -->

# about_Parsing

## Short description

PowerShell parses input in expression mode and argument mode. Knowing which
mode is active explains most quoting, wildcard, parameter-binding, and native
command surprises.

## Expression mode

At the start of a pipeline, PowerShell expects an expression. It recognizes
variables, numbers, strings, operators, member access, arrays, hashtables,
subexpressions, and command expressions. For example, the right side of an
assignment and the condition of `if` are parsed as expressions:

```powershell
$total = (Get-ChildItem).Count + 1
if ($total -gt 1) { 'many items' }
```

Expression mode evaluates language syntax rather than treating every token as
command text. Parentheses group expressions, `$()` evaluates a subexpression,
and `@()` creates an array from expression output.

## Argument mode

After PowerShell recognizes a command name, it normally switches to argument
mode. Unquoted input is then an expandable argument string unless it has a
special syntactic role. Variables and subexpressions still expand, but spaces,
quotes, commas, braces, wildcards, and parameter-looking text have rules that
depend on the command and position.

```powershell
Get-ChildItem -Path ./logs -Filter '*.log'
Write-Output "items: $((Get-ChildItem).Count)"
```

PowerShell cmdlets use parameter binding after parsing. A parameter name is
usually introduced with `-`, while a value beginning with `-` can need an
explicit parameter form, a quoted string, or an end-of-parameters token.

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

Without the subexpression, PowerShell expands the simple `$parts` reference
and treats `[1]` as literal text. The same rule matters when building native
arguments such as `"--explain=$($parts[1])"`. Assign the selected value to a
scalar first when that is clearer.

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

Characters such as spaces, quotes, dollar signs, backticks, commas, semicolons,
pipes, braces, parentheses, wildcard characters, and redirection operators can
have syntactic meaning. Quote data when it must remain one argument, and use
`-LiteralPath` rather than `-Path` when a cmdlet must not expand wildcard
characters in a filesystem name.

Do not concatenate untrusted data into a command string and pass it to
`Invoke-Expression`. It causes PowerShell to parse data as code. Prefer typed
parameters, separate argument values, hashtables for splatting, and script
files.

## Line continuation

PowerShell can continue a statement after syntactic constructs such as a pipe,
comma, opening delimiter, or operator. Prefer those natural continuation
points over a trailing backtick: trailing whitespace after a backtick changes
its meaning and makes reviews fragile.

```powershell
Get-Process |
    Where-Object CPU -GT 10 |
    Sort-Object CPU -Descending
```

## Native commands

Native programs do not use PowerShell parameter binding. PowerShell still
parses the command and converts argument values before starting the program,
then the target program applies its own command-line parser. Pass arguments as
separate values where possible and test the exact PowerShell version and
platform used by automation.

On Windows, `--%` is a stop-parsing token for a native command. It passes the
remaining text with minimal PowerShell interpretation. It is Windows-only and
is not a portable substitute for correct quoting or a script-file interface.

## End-of-parameters token

`--` tells PowerShell cmdlets to stop interpreting later tokens as parameters.
It is useful when a positional value begins with a hyphen. It does not give
native programs a universal escape rule: each native CLI defines its own
argument conventions.

## Tilde expansion

In argument mode, `~` can expand to the current user's home directory at the
start of an unquoted path-like argument. Do not use it when a literal tilde is
required; quote the value or use `-LiteralPath` as appropriate.

## Version and platform differences

This page follows the PowerShell 7.6 parser. Native argument passing and the
meaning of platform paths can vary by operating system and by PowerShell 7
version; test the actual native executable boundary.

## Runtime evidence

PowerShell 7.6.4 on Windows parsed every PowerShell example in this edition's
document set; the earlier Linux 7.6.3 pass covered the same page. Windows
probes confirmed indexed interpolation requiring `$()`, the
`EmptyPipeElement` error for piping directly from a `foreach` statement,
literal child source, and the current native argument-passing mode. A failed
catalog-read probe also confirmed that missing whitespace before parameter
tokens can invalidate the read while later null calculations look plausible.
macOS and target-native parser combinations remain outstanding.

## Related documents

- [about_Quoting_Rules](about_Quoting_Rules.md)
- [pwsh](pwsh.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Parsing reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.6).
It is shortened and reorganized around the expression/argument boundary,
safe literal input, and native-command composition. Exact upstream revision
and path are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
