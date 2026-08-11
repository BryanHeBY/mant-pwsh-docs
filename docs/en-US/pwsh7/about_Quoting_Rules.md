<!-- mant:tldr:start -->
# about_Quoting_Rules

> Quote PowerShell 7 strings without accidentally changing data into code.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-7.6.

- Create a literal string:

`$literal = '{{text with $no expansion}}'`

- Expand a variable in a string:

`$message = "Hello, ${{name}}"`

- Create a multi-line literal here-string:

`$text = @'
{{multi-line text}}
'@`
<!-- mant:tldr:end -->

# about_Quoting_Rules

## Short description

Single-quoted strings are literal. Double-quoted strings are expandable:
PowerShell replaces variables, subexpressions, and selected escape sequences.
Here-strings are multi-line forms of the same two choices.

## Single-quoted strings

Single quotes preserve text as written. A dollar sign, subexpression, and
backtick have no expansion role inside a single-quoted string. Write one
literal single quote by doubling it:

```powershell
$literal = 'The value is $HOME and it is not expanded.'
$name = 'O''Brien'
```

Use single quotes for fixed text, regular expressions that should not expand
variables, and arguments where PowerShell interpolation is not intended.

## Double-quoted strings

Double quotes create expandable strings. PowerShell expands a simple variable
such as `$name`; use `${name}` when adjacent text would otherwise be part of
the variable name, and `$()` when an expression or property access is needed:

```powershell
$name = 'Ada'
"Hello, $name"
"Hello, $($name.ToUpper())"
"${name}_report.txt"
```

The backtick introduces PowerShell escape sequences in expandable strings.
Common sequences include `` `n `` for a newline and `` `t `` for a tab. Avoid
using backticks for line continuation when a natural syntactic continuation is
available.

## Quotes inside strings

Double a single quote inside a single-quoted string. Escape a double quote in
a double-quoted string with a backtick, or choose the other quote style when
that makes the value clearer:

```powershell
'It''s literal.'
"He said `"hello`"."
```

Use the format operator (`-f`) or composite formatting when a string requires
many nested quotes. It often makes templates easier to read than repeated
escaping.

## Here-strings

A here-string starts with `@'` or `@"` at the end of a line and ends with the
matching marker at the beginning of a later line. The opening and closing
markers have placement rules; indenting the closing marker changes it into
ordinary content.

```powershell
$literal = @'
line one: $notExpanded
line two: ''quoted''
'@

$expanded = @"
user: $env:USER
count: $((Get-ChildItem).Count)
"@
```

Use literal here-strings for data or templates that must not evaluate. Use
expandable here-strings only when the interpolation is deliberate and reviewed.

## External commands

Quoted PowerShell strings become argument values before a native program sees
them. The target program can apply different quoting rules, especially on
Windows. Do not assume that quotes visible in PowerShell source are passed as
literal quote characters. Pass values as separate arguments, avoid
`Invoke-Expression`, and test difficult values such as spaces, quotes,
backslashes, Unicode, and leading hyphens.

## Culture and conversion

String interpolation uses PowerShell and .NET conversion behavior. Culture can
affect formatted values such as dates and numbers. For machine-readable data,
choose an explicit invariant format or a structured serialization format such
as JSON rather than relying on display conversion.

## Related documents

- [about_Parsing](about_Parsing.md)
- [pwsh](pwsh.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Quoting_Rules reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-7.6).
It is reorganized into literal, expandable, multi-line, and native-command
use cases. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
