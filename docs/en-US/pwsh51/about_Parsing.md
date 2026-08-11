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

## Related documents

- [about_Quoting_Rules](about_Quoting_Rules.md)
- [native-commands](native-commands.md)
- [powershell](powershell.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Parsing reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-5.1).
It emphasizes the 5.1 parsing boundary, literal paths, and Windows native
command composition. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
