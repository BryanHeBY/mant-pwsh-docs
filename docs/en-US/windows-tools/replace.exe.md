<!-- mant:tldr:start -->
# replace.exe

> Add or replace matching files in destination directories with no dry-run mode; inventory source/destination and use `/P` for an interactive first pass.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/replace.

- Display syntax and the mutually exclusive `/A`, `/S`, and `/U` modes:

`replace.exe /?`

- Preview one source selection and the existing same-name destination files with PowerShell objects before invoking REPLACE:

`Get-ChildItem -LiteralPath "{{C:\Source}}" -File | Select-Object Name, Length, LastWriteTimeUtc, FullName`

- Interactively confirm replacement of matching destination filenames in one exact directory:

`replace.exe "{{C:\Source\*.dll}}" "{{C:\Target}}" /P`

- Verify the resulting destination files by path, length, timestamp, and hash instead of trusting the summary line:

`Get-ChildItem -LiteralPath "{{C:\Target}}" -File | Get-FileHash -Algorithm SHA256`

- Prompt before adding source files that do not yet exist in the destination:

`replace.exe "{{C:\Source\*.dll}}" "{{C:\Target}}" /A /P`

- Prompt before replacing matching read-only destination files:

`replace.exe "{{C:\Source\*.dll}}" "{{C:\Target}}" /R /P`

- Prompt while replacing matching names throughout destination subdirectories:

`replace.exe "{{C:\Source\*.dll}}" "{{C:\Target}}" /S /P`

- Prompt while replacing only destination files older than their source counterparts:

`replace.exe "{{C:\Source\*.dll}}" "{{C:\Target}}" /U /P`
<!-- mant:tldr:end -->

# replace.exe

## Overview

`replace.exe` copies source files into destination directories according to
same-name and mode rules. By default it replaces files already present in the
destination directory. `/A` adds files that are absent instead. `/S` searches
destination subdirectories for matching names, and `/U` replaces only when the
source file is newer. There is no documented list-only/dry-run mode.

The destination operand is a directory, not a destination filename. The source
filename is required and can contain wildcards. Hidden and system files cannot
be updated by this command.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `replace.exe`: Add or replace matching files in one or more destination directories.

There is no true dry-run; `/p` is only an interactive confirmation boundary.

<!-- mant:entries role=option case=insensitive -->
- `/a`: Add source files absent from destination; incompatible with `/s` and `/u`.
- `/p`: Prompt before each selected file operation.
- `/r`: Permit replacement of read-only files.
- `/s`: Search destination subdirectories for matching filenames.
- `/w`: Wait for a disk insertion before beginning.
- `/u`: Replace only destination files older than their source counterpart.
- `/?`: Display installed syntax.

## Common mistakes

### Reversing source and destination

The first operand selects source files; the second is a destination directory.
Use absolute paths, inventory both trees, ensure source and destination are not
the same location through links/mounts, and run `/P` on a disposable copy first.

### Assuming `/S` copies the source tree

`/S` searches the destination tree and replaces existing same-name files. It
does not recurse through the source path or mirror directory structure. One
source basename can therefore replace copies in many destination directories.

### Combining modes that the syntax forbids

`/A` cannot be combined with `/S` or `/U`. `/A` adds absent names and leaves
existing ones alone; the other form replaces existing names. Treat them as
different operations with separate previews and verification.

### Treating `/U` as a content comparison

“Update” is based on timestamps, not hashes, versions, signatures, or semantic
newness. Clock skew, copied timestamps, time zones, build reproducibility, and
malicious metadata can make the decision wrong. Compare content and publisher
identity independently.

### Believing `/R` means recursive

`/R` allows replacement of read-only files; `/S` is the destination-recursion
option. Overriding read-only state can violate application or servicing
ownership. Preserve attributes/ACLs and use the supported deployment mechanism.

### Running a wildcard with no complete preview

`/P` prompts per selected file but is not a durable dry-run manifest, and a
large interactive run is error-prone. Build an explicit source/destination
mapping, reject collisions and unexpected links, back up targets, then use a
modern transactional deployment process when rollback matters.

### Reporting success from the summary only

Microsoft documents exit codes `0`, `1`, `2`, `3`, `5`, `8`, and `11` for
distinct results. Capture `$LASTEXITCODE` immediately, preserve output, then
verify every expected path/hash and absence of unexpected additions.

## PowerShell boundaries

Invoke `replace.exe` explicitly because `Replace` is also a common method name
and function name. Native wildcards are interpreted by REPLACE; PowerShell
literal-path inventory should enumerate the exact proposed set first. Do not
construct the invocation with `Invoke-Expression`.

## Version and platform differences

This Windows-only legacy copy utility is documented on supported Windows client
and server releases. On Windows NT `10.0.26200.0`, installed file version
`10.0.26100.1` returned all six documented switches, two mutually constrained
syntax forms, 18 nonempty help lines, and status 0 for explicit `/?`; no source
or destination operand was supplied. Filesystem timestamps, wildcard rules,
attributes, ACLs, links, cloud/offline files, locale, and target-local help
affect behavior.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 explicit /?
returned the documented two syntax forms, all six switches, 18 nonempty lines
and status 0. Runtime verification remains help-only unless approved disposable
fixtures exist; no real file add, replacement, read-only override or recursive
destination scan is permitted merely for evidence.

## Related documents
- [copy](copy.md)
- [xcopy.exe](xcopy.exe.md)
- [robocopy.exe](robocopy.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Replace reference](https://learn.microsoft.com/windows-server/administration/windows-commands/replace).
Recursive-destination and same-name behavior was cross-checked against a
[practitioner use case](https://superuser.com/questions/1286507/in-windows-given-a-new-file-foo-txt-can-i-recursively-search-a-directory-for-fi);
Microsoft's reference governs syntax and exit codes. Exact sources and licenses
are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
