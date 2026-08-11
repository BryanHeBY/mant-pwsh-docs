<!-- mant:tldr:start -->
# findstr

> Search file text with Windows literal or limited-regex matching.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/findstr.

- Search for a literal phrase, ignoring case, with line numbers:

`findstr.exe /i /n /l /c:"{{literal phrase}}" "{{C:\path\file.txt}}"`

- List files below a directory that contain a literal string:

`findstr.exe /s /i /m /l /c:"{{literal text}}" "{{C:\path\*}}"`

- Use modern regex and structured match objects in PowerShell:

`Select-String -LiteralPath '{{C:\path\file.txt}}' -Pattern '{{regex}}'`
<!-- mant:tldr:end -->

# findstr

## Overview

`findstr.exe` searches files or standard input using literal strings or a
small Windows-specific regex dialect. It is useful for simple installed-box
searches, but it is not compatible with .NET, PCRE, grep, or JavaScript regex.

## Useful options and status

- `/l`: Treat patterns literally.
- `/r`: Use the limited regex dialect; this is the documented default.
- `/c:"STRING"`: Keep a phrase with spaces as one pattern.
- `/i`: Ignore case.
- `/n`: Prefix matching lines with line numbers.
- `/s`: Recurse below the current directory.
- `/m`: Print only names of files containing a match.
- `/v`: Print nonmatching lines.

Options must precede search strings and filenames. Status is normally 0 for a
match, 1 for no match, and 2 for an operational/syntax error.

## Common mistakes

### Assuming modern regex features exist

There is no alternation operator, grouping, lookaround, lazy quantifier, or
general repetition count. Whitespace separates alternative search strings;
use repeated `/c:` forms for phrases. Choose `Select-String` for complex regex.

### Omitting `/l /c:` for literal phrases

An unescaped dot is a wildcard in regex mode, and spaces split patterns.
`/l /c:"literal phrase"` states the intended contract explicitly.

### Ignoring encoding and long-line limits

Code pages, BOMs, non-ASCII patterns, redirected/piped input, and very long
lines have historical edge cases. Test representative files; prefer a modern
text API for Unicode-sensitive or unbounded input.

### Treating no match as tool failure

Capture `$LASTEXITCODE` immediately and distinguish 1 from actual errors.

## Version and platform differences

This executable is Windows-only. Some limitations documented by community
experiments vary across old Windows versions, so they are evidence of risk,
not a promise for every current build.

## Related documents

- [find](find.md)
- [type](type.md)
- [sort](sort.md)

## Sources and license

This original guide was adapted from Microsoft's official
[findstr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/findstr).
Real-world regex, encoding, line-length, and exit-status traps are cataloged in
[Undocumented features and limitations of FINDSTR](https://stackoverflow.com/questions/8844868/what-are-the-undocumented-features-and-limitations-of-the-windows-findstr-comman).
Exact sources and licenses are recorded in `upstream/cli.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
