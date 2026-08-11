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
