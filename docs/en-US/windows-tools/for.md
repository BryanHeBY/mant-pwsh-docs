<!-- mant:tldr:start -->
# for

> Iterate files, directories, ranges, or parsed text inside `cmd.exe`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/for.

- Iterate files in a batch file; use two percent signs there:

`for %%F in ({{*.txt}}) do echo %%~fF`

- Preserve spaces while reading nonblank lines from a file:

`for /f "usebackq delims=" %%L in ("{{C:\path\file.txt}}") do echo(%%L`

- Iterate an inclusive numeric range:

`for /l %%N in ({{1}},{{1}},{{10}}) do echo %%N`

- Iterate directories matched by one reviewed pattern:

`for /d %%D in ("{{C:\root\*}}") do echo %%~fD`

- At an interactive Cmd prompt, use one percent sign instead of the batch-file double form:

`for %F in ({{*.txt}}) do echo %~fF`
<!-- mant:tldr:end -->

# for

## Overview

`for` is cmd iteration syntax. Use `%F` interactively and `%%F` in a batch
file. PowerShell's `foreach`/`ForEach-Object` are different language features.

## Forms

```text
for %V in (SET) do COMMAND
for /d %V in (DIRECTORY-SET) do COMMAND
for /r [ROOT] %V in (FILE-SET) do COMMAND
for /l %V in (START,STEP,END) do COMMAND
for /f ["OPTIONS"] %V in (SOURCE) do COMMAND
```

<!-- mant:entries role=command case=insensitive -->
- `for`: Iterate a Cmd set using one replaceable variable and execute the
  following Cmd command for each selected value.

The slash forms select distinct iteration grammars. Inside a batch file the
replaceable variable starts with `%%`, not the interactive prompt's single `%`.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Match directory names rather than files in the supplied set.
- `/r`: Walk a directory tree from the optional root and match the supplied
  file set in each directory.
- `/l`: Iterate an inclusive numeric `(START,STEP,END)` sequence.
- `/f`: Parse named files, a literal string, or output captured from a child
  `cmd.exe` according to the quoted parsing options.

`/f` options include `eol=C`, `skip=N`, `delims=CHARS`, `tokens=SPEC`, and
`usebackq`. Modifiers such as `%%~fF`, `%%~dpF`, `%%~nxF`, and `%%~zF` return a
full path, directory, name/extension, or size.

## PowerShell boundaries

PowerShell's `for`/`foreach` language syntax is unrelated. Run this form only
inside Cmd or a batch file; a `for /f ('COMMAND')` source adds another child
Cmd parser, text encoding boundary, and separate exit status. Prefer typed
PowerShell enumeration for objects and files, and return an explicit batch
exit code when a Cmd loop is invoked from PowerShell.

## Common mistakes

### Using one percent sign in a batch file

Interactive cmd uses `%F`; `.cmd` and `.bat` files require `%%F`. PowerShell
does not use either form unless it starts a cmd parser explicitly.

### Assuming `/f` reads whole files verbatim

It skips blank lines and, by default, returns only the first space/tab-delimited
token. `delims=` preserves nonblank lines but still is not a lossless text-file
reader. Use PowerShell or another real parser for arbitrary data.

### Losing exclamation marks

Delayed expansion can consume `!` in filenames or input. Capture data with
delayed expansion disabled and enable it only in the narrow scope that needs a
changing block variable.

### Forgetting the child-shell boundary

`for /f %%V in ('COMMAND')` runs COMMAND through a child `cmd.exe` and parses
captured text. Carets, pipes, quotes, percent expansion, encoding, stderr, and
exit status cross another shell boundary.

### Treating parsed text as structured objects

Locale, spacing, encoding, and tool-version changes can break token positions.
Prefer PowerShell objects, CSV/JSON, or a supported API when available.

## Version and platform differences

The basic builtin is Windows-only. `/d`, `/r`, `/l`, `/f`, `usebackq`, and the
listed modifiers require command extensions, enabled by default.

## Runtime evidence

The protected fixture read a task-owned ASCII file containing two nonblank
lines and one blank line. Under both PowerShell collectors, `for /f
"usebackq delims="` preserved each complete nonblank line including spaces and
omitted the blank line. Encoding, `eol`, `skip`, `tokens`, command-output input,
and exclamation-bearing data remain outside this narrow result.

## Related documents

- [cmd.exe](cmd.exe.md)
- [setlocal](setlocal.md)
- [if](if.md)

## Sources and license

This original guide was adapted from Microsoft's official
[for reference](https://learn.microsoft.com/windows-server/administration/windows-commands/for).
The whole-line and blank-line traps are evidenced by
[Read lines with blank spaces from a file using batch](https://stackoverflow.com/questions/13013378/read-lines-with-blank-spaces-from-a-file-using-batch).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
