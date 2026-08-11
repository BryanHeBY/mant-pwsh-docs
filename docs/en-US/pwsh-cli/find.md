<!-- mant:tldr:start -->
# find

> Filter lines containing a literal string; exit 1 means no match, not an execution error.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/find.

- Search case-insensitively and include line numbers:

`find.exe /i /n "{{literal text}}" "{{C:\path\file.txt}}"`

- Filter another native command's text output:

`{{command}} | find.exe /i "{{literal text}}"`

- Distinguish match, no-match, and error after a search in PowerShell:

`find.exe "{{text}}" "{{file}}"; $LASTEXITCODE`
<!-- mant:tldr:end -->

# find

## Overview

`find.exe` searches for a literal string and writes matching lines. It accepts
standard input when no file is given. It is not Windows file-name discovery,
Unix `find`, PowerShell filtering, or a regular-expression engine.

## Syntax and status

```text
find [/v] [/c] [/n] [/i] [/offline] "STRING" [FILE ...]
```

- `0`: At least one match.
- `1`: No match.
- `2`: Missing file or invalid command line.

`/v` inverts matches, `/c` counts matching lines, `/n` adds line numbers, and
`/i` ignores case. The search string must be quoted.

## Common mistakes

### Treating exit 1 as a broken command

For search tools, no match is an expected result. Branch explicitly on 0, 1,
and 2; in PowerShell read `$LASTEXITCODE` immediately.

### Expecting wildcards or regular expressions in the search string

`find` performs literal substring matching. Use `findstr` only for its limited
Windows regex dialect, or `Select-String` for .NET regular expressions and
PowerShell objects.

### Using a platform-dependent bare name

Use `find.exe` on Windows. On Unix-like platforms, `find` is a filesystem
traversal program with an unrelated contract.

### Parsing localized command output as stable data

Native producers such as `tasklist` can localize columns and values. Prefer a
structured API/cmdlet when correctness depends on fields rather than visible
text.

## Version and platform differences

This executable is Windows-only. Matching and input/output depend on the
active code page and text encoding.

## Related documents

- [findstr](findstr.md)
- [type](type.md)
- [sort](sort.md)

## Sources and license

This original guide was adapted from Microsoft's official
[find reference](https://learn.microsoft.com/windows-server/administration/windows-commands/find).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
