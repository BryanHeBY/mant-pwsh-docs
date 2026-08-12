<!-- mant:tldr:start -->
# makecab.exe

> Package reviewed files into Microsoft Cabinet format at an explicit new destination; compression is not signing or encryption.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/makecab.

- Display installed syntax and options:

`makecab.exe /?`

- Package one exact file into one explicitly named CAB in an existing output directory:

`makecab.exe /L "{{C:\Build\cab-output}}" "{{C:\Build\payload\file.dll}}" "{{file.cab}}"`

- Run a version-controlled, fully reviewed directive file for a multi-file or split-cabinet layout:

`makecab.exe /V3 /F "{{C:\Build\package.ddf}}"`

- List the produced CAB before distributing or installing it:

`expand.exe -d "{{C:\Build\cab-output\file.cab}}"`

<!-- mant:tldr:end -->

# makecab.exe

## Overview

`makecab.exe` packages existing files into Microsoft Cabinet (`.cab`) files.
The simple form takes one source and an optional destination. More complex or
multi-file cabinets use one or more directive (`.ddf`) files. `diantz.exe`
performs the same actions and is retained as a searchable compatibility name.

A CAB is a container with compression and layout metadata. Creating one does
not sign, encrypt, authorize, validate, or make its contents safe to execute.
Repacking a signed update, driver, or vendor cabinet invalidates its original
signature and provenance.

## Simple and directive-file modes

<!-- mant:entries role=command case=insensitive -->
- `makecab.exe`: Build one Microsoft Cabinet directly or from a directive file.

Direct mode accepts one source and optional destination name; multi-file or
split output requires a reviewed DDF.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Define or override one MakeCab directive variable.
- `/f`: Process a named directive file; repeat to process additional files.
- `/l`: Select the destination directory for direct-mode output.
- `/v`: Set message verbosity from errors only through full debugging.
- `/?`: Display installed syntax and target-build directive support.

In simple mode, omitting destination replaces the source filename's final
character with `_`. Avoid that implicit name: choose an explicit clean output
directory and destination, and verify both source and artifact hashes.

Directive files control file lists, source paths, compression, cabinet names,
disk directories, cabinet splitting, and other layout behavior. For example,
`CabinetNameTemplate` determines generated CAB names and
`DiskDirectoryTemplate` determines their output directories. Treat the DDF as
build code: pin it in version control, review every directive and included path,
run from a known working directory, and inventory every produced file.

## Common mistakes

### Passing several files to the simple form

The positional form packages one source file. Use a reviewed directive file
for multiple files; do not assume additional positional values are more input
files. High-volume practitioner questions about this behavior are an important
reason the distinction belongs in the first-use guidance.

### Letting current directory and default names choose the artifact

Implicit destinations and DDF defaults can create underscore-suffixed files,
`Disk1` directories, or numbered cabinets where the operator did not expect.
Use explicit absolute source/output paths and templates, start with a clean
output directory, then reject missing, extra, overwritten, or stale artifacts.

### Building a DDF from untrusted filenames without quoting or review

A directive file is parsed as directives and file specifications, not as an
opaque list. Generate it with a format-aware process, quote and validate paths,
reject line breaks and directive-like input, and review the exact generated DDF
before execution.

### Expecting directory recursion or path preservation automatically

The simple form does not recursively archive a directory. Cabinet member names
and layout require deliberate DDF design; duplicate base names and extraction
behavior can defeat assumptions about subdirectories. Test with the actual
consumer and inspect the CAB member list.

### Appending to an existing cabinet

Do not assume a later `makecab` run appends safely. Rebuild deterministically
from the complete manifest into a new output, verify it, then replace/publish
through an atomic controlled step if the consumer permits.

### Treating compression success as release readiness

Hash and list the artifact, test extraction into an empty directory, validate
expected member names/counts/content, and separately apply the required signing
and supply-chain controls. Never install a test CAB merely to verify creation.

## PowerShell boundaries

Invoke `makecab.exe` explicitly. Pass `/D` variable assignments as individual
quoted arguments when values contain spaces, capture output and
`$LASTEXITCODE`, and do not build a command string for `Invoke-Expression`.
PowerShell's `Compress-Archive` creates ZIP files and is not a CAB replacement.

## Version and platform differences

This Windows-only utility is documented for supported Windows client and server
releases. Directive variables, compression/layout constraints, filename rules,
and the consuming installer or servicing stack determine compatibility. Use
installed help and the relevant Cabinet SDK/reference for advanced DDF builds.

On Windows NT `10.0.26200.0`, exact System32 file version `5.00` printed 12
nonempty help lines for `/?`, returned 0, and produced no Windows PowerShell
5.1 `ErrorRecord` objects. No source, cabinet, directive file, report, setup
artifact, compression job, or filesystem output was supplied or created.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 file version 5.00 explicit /?
returned 12 nonempty help lines, status 0 and no Windows PowerShell 5.1
ErrorRecord objects. No cabinet or report was created; an approved disposable
build fixture remains required and no production package, update, driver,
installer or signed artifact may be created, replaced or installed merely for
evidence.

## Related documents
- [diantz.exe](diantz.exe.md)
- [expand.exe](expand.exe.md)
- [msiexec.exe](msiexec.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[MakeCab reference](https://learn.microsoft.com/windows-server/administration/windows-commands/makecab)
and [Cabinet format documentation](https://learn.microsoft.com/windows/win32/devnotes/cabinet-api-functions).
Multi-file and output-name pitfalls were cross-checked against high-demand
[directive-file](https://stackoverflow.com/questions/15843347/using-makecab-exe-ddf-file-i-e-using-directive-file-how-to-specify-destina)
and [multi-file](https://stackoverflow.com/questions/25662399/how-to-add-more-then-one-files-in-the-cab-using-makecab)
practitioner questions; Microsoft sources remain authoritative for syntax.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
