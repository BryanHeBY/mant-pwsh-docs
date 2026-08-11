<!-- mant:tldr:start -->
# append

> Inspect or migrate an MS-DOS `APPEND` dependency; Microsoft says the command is unsupported on Windows 10.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/append.

- Check whether this host actually provides the legacy executable:

`Get-Command append.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Display the active appended-directory list on a compatible legacy host:

`append.exe`

- Inspect the `APPEND` environment variable without changing it:

`[Environment]::GetEnvironmentVariable('APPEND', 'Process')`

- Replace an `APPEND` dependency with an explicit, literal file lookup:

`Get-Item -LiteralPath "{{C:\LegacyData\records.dat}}"`
<!-- mant:tldr:end -->

# append

## Overview

`append.exe` let DOS-era programs find data files in additional directories as
though those directories were current. A path list selects directories;
`/x:on` also affects executable search, `/path:on` affects requests that already
contain a path, `/e` copies the initial list to the process `APPEND` variable,
and `append ;` clears the list.

This is compatibility documentation, not a recommendation for new automation.
Microsoft's page explicitly says the command is unsupported on Windows 10,
despite its broad generated applicability banner. Use explicit paths, a
controlled working directory, or application configuration instead.

## Common mistakes

### Assuming PATH and APPEND are interchangeable

`PATH` participates in command discovery. `APPEND` redirected compatible
programs' data-file searches; `/x:on` broadened its behavior and could cause an
unexpected executable to be found. Do not add legacy data directories to
`PATH` as a mechanical migration.

### Treating `/e` as a normal repeatable setter

Microsoft says `/e` can be used only the first time `append` is invoked after
system startup. It stores a copy of the list in the `APPEND` environment
variable; it does not make the mechanism a modern persistent configuration API.

### Clearing state while trying to inspect it

`append` with no arguments displays the list; `append ;` clears it. Keep the
semicolon out of discovery scripts.

## PowerShell behavior

Call `append.exe` explicitly if it exists. PowerShell's environment provider can
inspect `$env:APPEND`, but changing that variable does not reproduce every
legacy program's `APPEND` semantics. Prefer `-LiteralPath` and explicit absolute
paths in replacement scripts.

## Version and platform differences

This is a Windows/DOS compatibility command and is absent or unsupported on
many modern systems. Verify executable resolution and the target application's
behavior on the exact legacy image; a Microsoft Learn applicability banner is
not evidence that the binary ships or is supported.

## Related documents

- [path](path.md)
- [where](where.md)

## Sources and license

Adapted as an original migration guide from Microsoft's
[append reference](https://learn.microsoft.com/windows-server/administration/windows-commands/append).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
