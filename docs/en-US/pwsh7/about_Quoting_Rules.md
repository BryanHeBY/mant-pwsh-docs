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

- Keep child-process PowerShell source literal in the parent session:

`$childSource = '$value = 1; $value'; pwsh -NoProfile -Command $childSource`
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

## Nested PowerShell processes

When one PowerShell process starts another with `-Command`, the parent parses
the argument before the child parses it as PowerShell source. An expandable
string in the parent can therefore replace `$variables` and `$()` expressions
before the child sees them. Keep fixed child source in a single-quoted string,
pass a script block when both sides are PowerShell and that boundary is
intentional, or prefer a reviewed script file for substantial automation:

```powershell
$childSource = '$value = 1; $value'
pwsh -NoProfile -Command $childSource
```

Do not keep adding escape layers until a nested command happens to work. Check
which process owns each expansion, and inspect the exact value passed across
the process boundary.

## External commands

Quoted PowerShell strings become argument values before a native program sees
them. The target program can apply different quoting rules, especially on
Windows. Do not assume that quotes visible in PowerShell source are passed as
literal quote characters. Pass values as separate arguments, avoid
`Invoke-Expression`, and test difficult values such as spaces, quotes,
backslashes, Unicode, and leading hyphens.

## Culture and conversion

PowerShell uses invariant culture when it converts values inserted by
expandable-string interpolation. An explicit `.ToString()` call uses the
current culture unless an overload or format provider says otherwise. For
example, with a `de-DE` current culture, `"$number"` can produce `1.2` while
`$number.ToString()` produces `1,2`.

Choose an explicit invariant or named culture for machine-readable text. Use a
structured format such as JSON when the consumer needs typed data rather than
display strings.

## Runtime evidence

PowerShell 7.6.4 on Windows confirmed that an indexed array reference embedded
directly in an expandable string emits the whole array plus literal index text,
while `$()` selects the intended item. A scoped `de-DE` culture probe confirmed
invariant interpolation `1.2` versus current-culture `.ToString()` output
`1,2`, with both thread cultures restored in `finally`. A literal child-command
string preserved `$value` for the child parser. The earlier Linux parser pass
covered the page; macOS, smart quotes, here-string edge cases, Unicode, and
target-native parsers remain outstanding.

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
