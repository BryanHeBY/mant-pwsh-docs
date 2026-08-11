<!-- mant:tldr:start -->
# where

> Locate Windows executables and matching files on `PATH` or in specified paths.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/where.

- Find every matching executable on `PATH`:

`where {{command-name}}`

- Search a specific directory tree:

`where /r {{path}} {{file-pattern}}`

- Search one explicit path list:

`where /t /f /r {{path}} {{file-pattern}}`
<!-- mant:tldr:end -->

# where

## Synopsis

```text
where [/r DIR] [/q] [/f] [/t] PATTERN [...]
```

`where.exe` locates matching files, commonly executables resolved through the
Windows `PATH`. It is useful when a native command name is ambiguous or when a
script must diagnose which executable a Windows process can find.

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

## Related documents

- [native command use in PowerShell](windows-tools.md)

## Sources and license

This original command guide was adapted from the official
[where documentation](https://learn.microsoft.com/windows-server/administration/windows-commands/where).
It distinguishes Windows `PATH` lookup from PowerShell command precedence.
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
