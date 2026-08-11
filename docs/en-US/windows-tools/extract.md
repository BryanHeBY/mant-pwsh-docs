<!-- mant:tldr:start -->
# extract

> Inspect or extract Microsoft Cabinet files with the inbox `extrac32.exe`; `extract.exe` is not provided on modern Windows.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/extract.

- Resolve both names before choosing syntax:

`Get-Command extract.exe, extrac32.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- List a cabinet without extracting it:

`extrac32.exe /D "{{C:\Packages\payload.cab}}"`

- Extract a reviewed cabinet into a new, empty staging directory:

`New-Item -ItemType Directory -Path "{{C:\Staging\payload}}" -ErrorAction Stop; extrac32.exe /E /L "{{C:\Staging\payload}}" "{{C:\Packages\payload.cab}}"; if ($LASTEXITCODE -ne 0) { throw "extrac32 failed: $LASTEXITCODE" }`

- Make otherwise invisible help output observable:

`cmd.exe /d /c 'extrac32.exe /? | more'`
<!-- mant:tldr:end -->

# extract / extrac32

## Overview

`extract.exe` and `extrac32.exe` extract or list Microsoft Cabinet content.
Microsoft says `extract.exe` is neither provided nor supported on Windows 10
and Windows Server 2016 or later; the operating-system `extrac32.exe` replaces
it. `/D` lists, `/E` extracts all, `/L <dir>` chooses the destination, `/A`
follows a cabinet chain, `/C` copies a source, and `/Y` suppresses overwrite
prompts.

## Common mistakes

### Running an SFX package to inspect its files

A self-extracting `.exe` can run embedded or follow-on code. Do not execute an
untrusted package merely to reveal its contents. Work on a copy in an isolated
analysis environment and use a format-aware extractor only after identifying
the actual container; a `.exe` is not necessarily a raw cabinet.

### Extracting before listing and validating paths

Inventory the cabinet first, create a new empty destination, and inspect output
for absolute paths, traversal, links/reparse points, collisions, executables,
scripts, and unexpected cabinet chaining. Never extract untrusted content into
`System32`, an application directory, `PATH`, or a production tree.

### Using `/Y` as harmless automation

`/Y` permits replacement without prompting. It does not constrain destination
scope or make the archive trusted. Prefer a new directory; hash source and
results, retain logs, and promote reviewed files separately.

### Assuming no console output means failure

Microsoft documents that `extrac32.exe` shows no normal console output and even
its help must be piped through `more`. Check `$LASTEXITCODE` and verify the
expected file set, hashes, sizes, and signatures.

### Confusing CAB and ZIP tools

`Expand-Archive` is for ZIP archives, not CAB. DISM, `expand.exe`, package
managers, and installers have different validation and servicing semantics;
choose the supported tool for the artifact and goal.

## PowerShell behavior

Invoke `extrac32.exe` explicitly, quote paths, use a pre-created destination,
and inspect `$LASTEXITCODE` immediately. Native output is text; file objects
must be enumerated separately after extraction. Do not pipe downloaded bytes or
untrusted names directly into a command line.

## Version and platform differences

Modern Windows provides `extrac32.exe`, not `extract.exe`; older images may
behave differently. Cabinet chaining and compression support depend on the
actual utility/version. Verify local help and test a known fixture before a
recovery or deployment workflow.

## Related documents

- [expand](expand.md)
- [makecab](makecab.md)
- [dism](dism.md)

## Sources and license

Adapted as an original operational guide from Microsoft's
[extract/extrac32 reference](https://learn.microsoft.com/windows-server/administration/windows-commands/extract).
A [Stack Overflow incident question](https://stackoverflow.com/questions/5097155/how-to-extract-a-win32-cabinet-self-extractor-without-executing-the-extracted-fi)
was used only as a practitioner demand signal for the non-execution boundary.
Exact provenance and licenses are in `upstream/windows-tools.json`. Microsoft material and
this adaptation are CC BY 4.0; the cited Q&A is CC BY-SA 4.0.
