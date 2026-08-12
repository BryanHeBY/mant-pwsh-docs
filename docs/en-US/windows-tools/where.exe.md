<!-- mant:tldr:start -->
# where.exe

> Locate Windows executables and matching files on `PATH` or in specified paths.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/where.

- Find every matching executable on `PATH`:

`where {{command-name}}`

- Search a specific directory tree:

`where /r {{path}} {{file-pattern}}`

- Search one explicit path list:

`where /t /f /r {{path}} {{file-pattern}}`
<!-- mant:tldr:end -->

# where.exe

## Synopsis

```text
where [/r DIR] [/q] [/f] [/t] PATTERN [...]
```

`where.exe` locates matching files, commonly executables resolved through the
Windows `PATH`. It is useful when a native command name is ambiguous or when a
script must diagnose which executable a Windows process can find.

## Important options

<!-- mant:entries role=command case=insensitive -->
- `where.exe`: Locate matching files using Windows current-directory, `PATH`,
  `PATHEXT`, explicit path-list, environment-variable, or recursive-directory
  search rules; this is not PowerShell command precedence.

The following switches select scope, status-only behavior, or display format.

<!-- mant:entries role=option case=insensitive -->
- `/r DIRECTORY`: Recursively search below one explicit directory instead of normal current-directory and `PATH` lookup.
- `/q`: Suppress matches and report only status 0 for a match or 1 for no match/failure.
- `/f`: Quote each matched path in display output.
- `/t`: Include file size and last-modified time in display output.
- `/?`: Show installed command help.

The required pattern can be prefixed with `$ENV:` to search directories held
in an environment variable or `PATH:` to search an explicit path list. Do not
combine these prefix forms with `/r`.

## Command resolution

```powershell
where.exe git
where.exe curl
```

`where.exe` searches Windows paths. PowerShell command resolution also includes
aliases, functions, cmdlets, and scripts. Therefore `where.exe curl` does not
prove that bare `curl` in PowerShell calls that executable. Use
`Get-Command curl -All` to inspect PowerShell precedence, and use `curl.exe`
or an explicit path when the native executable is required.

## Common mistakes

### Calling bare `where` in PowerShell

Depending on the session, `where` can resolve as an alias for `Where-Object`
instead of `where.exe`. Use `where.exe` for file lookup and run
`Get-Command where -All` to inspect every match.

### Treating PATH lookup as PowerShell resolution

`where.exe tool` searches files using Windows path rules. It does not report
PowerShell aliases, functions, cmdlets, modules, or all script resolution
rules. Use `Get-Command tool -All` to answer what PowerShell will invoke.

## Search scope and output

`/r DIR` recursively searches a specified directory. Recursive searches can be
slow and can cross large or protected trees; use the narrowest path and pattern.
`/q` suppresses normal output for a presence check. `/f` and `/t` change output
formatting, which is for humans rather than a stable data interface.

Check `$LASTEXITCODE` in automation and do not parse display output to make a
security decision. If a script has a required executable dependency, validate
the selected file's path, signature or hash where appropriate, and version.

## PowerShell boundaries

Bare `where` can resolve to `Where-Object`; use `where.exe` for Windows file
lookup. `where.exe` follows Windows path and `PATHEXT` rules, while
`Get-Command -All` answers PowerShell command precedence.

## Version and availability

`where.exe` is available on supported Windows client and server releases. Its
filesystem visibility depends on the caller's token, path contents, network
access, and filesystem state at the time of the search.
On exact System32 file version `10.0.26100.1`, `/?` returned 0 with 33
nonempty stdout lines and no PowerShell error records. No search pattern,
directory, environment variable, PATH list, filesystem traversal, or network
path was supplied.

## Runtime evidence

The repeatable read-only Windows CLI fixture resolved exact System32
`where.exe`, captured localized `/?` help, and searched only for `where.exe`
through the current PATH. Both PowerShell collectors returned exit code `0`
and exactly one candidate equal to the expected System32 path. No recursive
directory, wildcard, environment expansion, or network path was supplied.
This remains a Windows path lookup result, not PowerShell command precedence.

## Related documents

- [native command use in PowerShell](windows-tools.md)

## Sources and license

This original command guide was adapted from the official
[where documentation](https://learn.microsoft.com/windows-server/administration/windows-commands/where).
It distinguishes Windows `PATH` lookup from PowerShell command precedence.
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
