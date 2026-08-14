<!-- mant:tldr:start -->
# findstr.exe

> Search file text with Windows literal or limited-regex matching.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/findstr.

- Search for a literal phrase, ignoring case, with line numbers:

`findstr.exe /i /n /l /c:"{{literal phrase}}" "{{C:\path\file.txt}}"`

- List files below a directory that contain a literal string:

`findstr.exe /s /i /m /l /c:"{{literal text}}" "{{C:\path\*}}"`

- Filter another command's text output using a case-insensitive literal phrase:

`{{command}} | findstr.exe /i /l /c:"{{literal phrase}}"`

- Search text files with FINDSTR's limited regular-expression syntax:

`findstr.exe /s /i /n /r "{{expression}}" "{{C:\path\*.txt}}"`

- Print only lines that do not contain a literal string:

`findstr.exe /v /l /c:"{{literal text}}" "{{C:\path\file.txt}}"`

- Print only filenames containing a match:

`findstr.exe /s /m /l /c:"{{literal text}}" "{{C:\path\*}}"`

- Use modern regex and structured match objects in PowerShell:

`Select-String -LiteralPath '{{C:\path\file.txt}}' -Pattern '{{regex}}'`

- Display installed literal, regular-expression, recursion, encoding, and output options:

`findstr.exe /?`
<!-- mant:tldr:end -->

# findstr.exe

## Overview

`findstr.exe` searches files or standard input using literal strings or a
small Windows-specific regex dialect. It is useful for simple installed-box
searches, but it is not compatible with .NET, PCRE, grep, or JavaScript regex.

## Options and status

<!-- mant:entries role=command case=insensitive -->
- `findstr.exe`: Search named files or standard input using literal strings or
  the command's limited Windows regular-expression dialect.

Every switch must precede the search strings and filenames. Colon forms take
their value in the same native argument unless installed help says otherwise.

<!-- mant:entries role=option case=insensitive -->
- `/b`: Match only when the pattern occurs at the beginning of a line.
- `/e`: Match only when the pattern occurs at the end of a line.
- `/l`: Treat search strings literally.
- `/r`: Use the limited regular-expression dialect; this is the default.
- `/s`: Search the current directory and all subdirectories.
- `/i`: Ignore letter case.
- `/x`: Print only lines that match the pattern exactly.
- `/v`: Print only lines that do not contain a match.
- `/n`: Prefix every matching line with its line number.
- `/m`: Print only each filename that contains a match.
- `/o`: Prefix each matching line with its character offset.
- `/p`: Skip files that contain non-printable characters.
- `/off`: Include files with the offline attribute; `/offline` is the full
  documented spelling.
- `/f`: Read the list of files to search from the following colon-delimited
  filename.
- `/c`: Treat the following colon-delimited value as one literal search string,
  preserving spaces inside a quoted value.
- `/g`: Read search strings from the following colon-delimited filename.
- `/d`: Search the following semicolon-delimited directory list.
- `/a`: Select the two-hex-digit console color attribute for matching output.
- `-?`, `/?`: Display installed command help.

Options must precede search strings and filenames. Status is normally 0 for a
match, 1 for no match, and 2 for an operational/syntax error.

## PowerShell boundaries

Call `findstr.exe` explicitly and pass `/c:VALUE`, `/f:FILE`, `/g:FILE`, and
similar colon forms as single native arguments. PowerShell objects are rendered
to text before a native pipeline. Prefer `Select-String` for .NET regex and
match objects; otherwise read `$LASTEXITCODE` immediately and accept 1 as
no-match rather than an execution failure.

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
not a promise for every current build. On Windows NT `10.0.26200.0`, installed
file version `10.0.26100.1` printed 45 nonempty help lines and returned 0 for
both `/?` and `-?`. No pattern, string, file, directory, standard input,
color, or filesystem content was selected by the help probes.

## Runtime evidence

The protected fixture searched one fixed ASCII file with explicit `/i /n /l
/c:"needle phrase"` under both PowerShell collectors. The fixed phrase matched
with status `0`; a fixed absent phrase returned status `1`. It deliberately
did not exercise FINDSTR's limited regex dialect, recursion, file/pattern list
files, color, offline files, arbitrary encoding, long lines, binary data, or
user content; cleanup removed the task root.

## Related documents

- [find.exe](find.exe.md)
- [type](type.md)
- [sort.exe](sort.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[findstr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/findstr).
Real-world regex, encoding, line-length, and exit-status traps are cataloged in
[Undocumented features and limitations of FINDSTR](https://stackoverflow.com/questions/8844868/what-are-the-undocumented-features-and-limitations-of-the-windows-findstr-comman).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
