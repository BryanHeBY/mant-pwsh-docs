<!-- mant:tldr:start -->
# about_Quoting_Rules

> Quote Windows PowerShell 5.1 strings without accidentally changing data into code.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-5.1.

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
Windows PowerShell replaces variables, subexpressions, and selected escape
sequences. Here-strings are multi-line forms of the same two choices.

## Single-quoted strings

Single quotes preserve text as written. A dollar sign, subexpression, and
backtick have no expansion role inside a single-quoted string. Write one
literal single quote by doubling it:

```powershell
$literal = 'The value is $env:USERPROFILE and it is not expanded.'
$name = 'O''Brien'
```

Use single quotes for fixed text, regular expressions that should not expand
variables, and arguments where interpolation is not intended.

## Double-quoted strings

Double quotes create expandable strings. Windows PowerShell expands a simple
variable such as `$name`; use `${name}` when adjacent text would otherwise be
part of the variable name, and `$()` when an expression or property access is
needed:

```powershell
$name = 'Ada'
"Hello, $name"
"Hello, $($name.ToUpper())"
"${name}_report.txt"
```

The backtick introduces escape sequences in expandable strings. Common
sequences include `` `n `` for a newline and `` `t `` for a tab. Avoid using a
trailing backtick for line continuation when a pipe, comma, opening delimiter,
or operator already permits natural continuation.

## Quotes inside strings

Double a single quote inside a single-quoted string. Escape a double quote in
a double-quoted string with a backtick, or choose the other quote style when
that makes the value clearer:

```powershell
'It''s literal.'
"He said `"hello`"."
```

Use the format operator (`-f`) or composite formatting when a template has
many nested quotes. It is usually easier to review than repeated escaping.

## Here-strings

A here-string starts with `@'` or `@"` at the end of a line and ends with the
matching marker at the beginning of a later line. The opening and closing
markers have placement rules; a closing marker with preceding text or spaces
is not a valid terminator in Windows PowerShell 5.1.

```powershell
$literal = @'
line one: $notExpanded
line two: ''quoted''
'@

$expanded = @"
user: $env:USERNAME
count: $((Get-ChildItem).Count)
"@
```

Use literal here-strings for data or templates that must not evaluate. Use an
expandable here-string only when every interpolation is deliberate and
reviewed.

## Native commands

Quoted PowerShell strings become argument values before a Windows native
program sees them. The target program then applies its own Windows command-line
parsing rules. Do not assume that a quote visible in PowerShell source arrives
as a literal quote character. Pass values as separate arguments where possible,
avoid `Invoke-Expression`, and test paths with spaces, quotes, backslashes,
Unicode, and leading hyphens against the actual executable.

## Version and availability

This page follows Windows PowerShell 5.1. Quoting inside PowerShell is stable,
but the final native command-line reconstruction is Windows- and
application-specific and differs from modern PowerShell argument passing.

## Related documents

- [about_Parsing](about_Parsing.md)
- [native-commands](native-commands.md)
- [powershell.exe](powershell.exe.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Quoting_Rules reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-5.1).
It is reorganized around literal, expandable, multi-line, and Windows native
command use cases. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
