<!-- mant:tldr:start -->
# comp.exe

> Compare two exact files byte by byte interactively; for automation prefer `fc.exe /B` or hashes because COMP normally prompts to compare more files.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/comp.

- Display target-local syntax and check whether this build documents `/M` prompt suppression:

`comp.exe /?`

- Compare two exact files byte by byte and capture the native result immediately, expecting an interactive follow-up prompt:

`comp.exe "{{first.bin}}" "{{second.bin}}"; $compExitCode = $LASTEXITCODE`

- Use the already documented noninteractive binary comparator for automation:

`fc.exe /B "{{first.bin}}" "{{second.bin}}"; $fcExitCode = $LASTEXITCODE`

- Compare complete file content by SHA-256 when a digest equality check is sufficient:

`Get-FileHash -Algorithm SHA256 -LiteralPath "{{first.bin}}", "{{second.bin}}"`

<!-- mant:tldr:end -->

# comp.exe

## Overview

`comp.exe` compares two files or matched sets byte by byte. It reports differing
offsets and byte values and stops after ten mismatches. Wildcards are accepted;
directory-only operands derive matching names. Missing operands trigger prompts,
and after a comparison COMP normally asks whether to compare more files.

`/D` prints byte differences as decimal, `/A` as characters, `/L` labels the
location as a line number, `/C` compares without case, and `/N=number` compares
only a specified number of lines. These change reporting or scope; they do not
make a full equality proof stronger.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `comp.exe`: Compare two exact files or matched file sets byte by byte.

Missing operands and the follow-up prompt make default invocation interactive.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Display differing byte values in decimal.
- `/a`: Display differing bytes as characters.
- `/l`: Report mismatch locations as line numbers.
- `/n`: Compare only the specified number of lines rather than complete inputs.
- `/c`: Compare ASCII letters without case distinction.
- `/offline`: Do not skip files carrying the Offline attribute.
- `/?`: Display installed syntax; some builds also expose target-local `/m`.

## Common mistakes

### Letting the “Compare more files” prompt hang automation

An exact comparison can still enter an interactive follow-up. Current installed
help on some Windows builds lists `/M` to suppress it even though Microsoft's
online page does not. Do not assume that undocumented switch everywhere: query
target help and gate by supported build, or use `fc.exe /B`/hashes for a stable
noninteractive workflow.

### Using `/N` and reporting complete equality

`/N` deliberately compares only the requested prefix and permits different-size
files. A zero result for that prefix does not prove equal length or remaining
content. Record lengths and use a full comparison or cryptographic hash when
complete identity is required.

### Treating `/C` as text-aware Unicode comparison

COMP is byte-oriented; case-insensitive behavior is not culture-aware semantic
text equality. Decode with the known encoding and use a text-aware comparison
when newline, normalization, locale, or Unicode case rules matter.

### Comparing directory trees with wildcards as a manifest proof

Wildcard pairing follows legacy filename rules and can fail on edge-case names,
missing counterparts, recursion, links, streams, metadata, or path collisions.
Build explicit sorted manifests with paths, sizes, and hashes for tree identity.

### Parsing the first ten differences as the complete difference set

COMP stops reporting after ten mismatches. Its output is a diagnostic sample,
not a patch or exhaustive diff. Preserve both inputs and use a suitable binary
or text diff tool for complete analysis.

### Ignoring prompts and localized output in result handling

Capture `$LASTEXITCODE` immediately, but verify target-local result semantics
and distinguish identical, different, missing/path, syntax, and interrupted
states. Do not parse localized prose as the only success condition.

### Comparing changing files

Open databases, logs, virtual disks, and application files can change between
reads. Quiesce through the owning application or compare consistent snapshots;
a comparator cannot create a transactionally consistent view.

## PowerShell boundaries

Call `comp.exe` explicitly; `Compare-Object` compares PowerShell objects and is
not a byte-for-byte file replacement. Pass exact literal paths, avoid wildcard
expansion unless deliberately reviewed, and store the exit code before running
another native command. Redirecting the prompt does not fix ambiguous scope or
version behavior.

## Version and platform differences

This legacy native comparator is Windows-only. Installed help, prompt-suppression
options, wildcard behavior, output text, code page, and file-system semantics
can vary by build and locale. Target help plus fixture verification is required
before automation.

## Related documents

- [fc.exe](fc.exe.md)
- [find.exe](find.exe.md)
- [certutil.exe](certutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[COMP reference](https://learn.microsoft.com/windows-server/administration/windows-commands/comp).
The interactive prompt and target-local `/M` discrepancy were cross-checked
against a high-quality
[PowerShell automation answer](https://stackoverflow.com/questions/76870606/powershell-how-to-get-cmd-comp-to-run-quietly)
and earlier [prompt discussion](https://stackoverflow.com/questions/14460857/windows-comp-command-in-batch-script-remove-prompts).
Official documentation and installed help remain the support authorities. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
