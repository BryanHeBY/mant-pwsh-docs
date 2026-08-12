<!-- mant:tldr:start -->
# recover.exe

> Salvage readable sectors from one exact file only after imaging failing media; unreadable sectors remain lost.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/recover.

- Display the installed command's syntax without reading a damaged file:

`recover.exe /?`

- Record one exact file's identity and metadata before any salvage attempt:

`Get-Item -LiteralPath "{{X:\path\file}}" -Force | Select-Object FullName, Length, CreationTimeUtc, LastWriteTimeUtc, Attributes`

- Hash a readable clone or working copy before and after recovery so the change is explicit:

`Get-FileHash -LiteralPath "{{X:\path\file}}" -Algorithm SHA256`

- On a disposable image or clone, attempt sector-by-sector salvage of one reviewed file with no wildcard:

`recover.exe "{{X:\path\file}}"`

<!-- mant:tldr:end -->

# recover.exe

## Overview

`recover.exe` reads one named file sector by sector and retains information
from readable sectors. Data stored in unreadable sectors is lost. The command
accepts no wildcard and exposes no separate output-file argument, so it must
not be described as a read-only copier or a bulk recovery engine.

This is a narrow legacy salvage tool. It is not DiskPart's `recover` command,
Windows File Recovery (`winfr`), CHKDSK, filesystem repair, undelete, snapshot
restore, or professional media recovery.

## Invocation boundary

<!-- mant:entries role=command case=insensitive -->
- `recover.exe`: Salvage readable sectors in one exact existing file.

### Installed help

<!-- mant:entries role=option case=insensitive -->
- `/?`: Display the installed single-file syntax without reading or changing a target file.

The documented syntax accepts one filename and no wildcard or separate output
path. Work only on a disposable image/clone when the source matters.

## Safe recovery sequence

1. Stop normal use of the failing device and preserve power/controller/error
   evidence. Continued reads and writes can worsen some failures.
2. Decide whether evidence handling, encryption, RAID/Storage Spaces, firmware,
   or physical damage requires a specialist.
3. Create and verify a sector-aware image or clone with an appropriate recovery
   process. Keep the original unchanged whenever possible.
4. Work on a disposable copy, identify one exact file, record its metadata and
   hash if readable, then run `recover.exe` only if its loss model is acceptable.
5. Copy useful results to healthy storage, validate content with the owning
   application, and retain the original image and recovery log.

## Common mistakes

### Running directly against the only copy

Recovery work can increase I/O and change the target file. Do not experiment
on unique business data or forensic evidence. Image first, preserve chain of
custody where relevant, and keep an untouched copy for another method.

### Expecting an output path

The documented syntax names only the file to recover. A second path is not an
output destination. Work on a clone and explicitly copy validated results to
healthy storage afterward.

### Recovering a directory, wildcard, or whole volume

Filename is required and wildcards are unsupported. The command does not
reconstruct directory trees, deleted entries, partition tables, or an entire
filesystem. Choose a tool matched to the actual failure and recovery goal.

### Assuming missing bytes can be reconstructed

Readable sectors are salvaged; data in bad sectors is lost. A command that
returns does not prove semantic integrity. Open or validate the result with a
format-aware application and compare it with known hashes, redundancy, or
backups.

### Confusing current bad sectors with CHKDSK's recorded list

Microsoft distinguishes sectors already marked bad when the disk was prepared
from the file being read by `recover`. Do not use either observation as proof
that the physical device is safe. Review current storage-health evidence.

### Treating filesystem repair as hardware repair

CHKDSK, `recover`, controller diagnostics, file-signature repair, backup
restore, and physical-media recovery solve different problems. Running more
repair tools in sequence can erase evidence or reduce later recovery options.

## PowerShell boundaries

Invoke `recover.exe` explicitly so the native utility is unambiguous. Use a
literal, fully qualified path from a reviewed scalar value, never a wildcard,
recursive pipeline, or user-controlled concatenation. Preserve native output
and `$LASTEXITCODE`, but validate the file content separately because a process
result cannot certify recovered bytes.

## Version and platform differences

This Windows-only utility is present on supported Windows client and server
releases covered by Microsoft. On Windows NT `10.0.26200.0`, installed file
version `10.0.26100.1` returned four nonempty help lines and status 0 for
explicit `/?`; no file operand was supplied. Filesystem, device, encryption,
virtual-storage, and recovery-environment constraints can make a different
tool necessary.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 explicit /?
returned four nonempty syntax lines and status 0 without a file operand. No
production, failing, unique, evidentiary or user-data file may be read or
changed merely for evidence.

## Related documents
- [chkdsk.exe](chkdsk.exe.md)
- [diskpart.exe](diskpart.exe.md)
- [wbadmin.exe](wbadmin.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Recover reference](https://learn.microsoft.com/windows-server/administration/windows-commands/recover).
The source defines the single-file syntax and its explicit unreadable-sector
data-loss model. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
