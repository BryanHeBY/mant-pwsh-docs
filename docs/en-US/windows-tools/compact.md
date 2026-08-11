<!-- mant:tldr:start -->
# compact

> Inspect and change NTFS or CompactOS compression without confusing it with archive creation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/compact.

- Display compression state for one exact file or directory:

`compact.exe "{{path}}"`

- Display compression state recursively, including hidden and system entries:

`compact.exe /S:"{{directory}}" /A`

- Query whether the running Windows installation uses CompactOS:

`compact.exe /CompactOS:query`

- Compress one exact file with ordinary NTFS compression:

`compact.exe /C "{{file}}"`

- Uncompress one exact file that uses ordinary NTFS compression:

`compact.exe /U "{{file}}"`
<!-- mant:tldr:end -->

# compact

## Overview

`compact.exe` displays or changes transparent compression on NTFS files and
directories. Ordinary `/c` and `/u` manage NTFS compression. `/EXE:algorithm`
uses system compression optimized for frequently read, rarely modified files.
`/CompactOS:query|always|never` queries or changes compression of Windows
operating-system binaries.

Compact does not create a ZIP, CAB, or portable archive and has no source/
destination pair. Compressed files remain in place and are decompressed by the
filesystem while applications read them.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `compact.exe`: Display or change NTFS, system-file, or CompactOS compression.

Names after the switches are in-place file or directory patterns. An omitted
name applies to the current directory, so prefer an explicit absolute scope.

<!-- mant:entries role=option case=insensitive -->
- `/c`: Compress the selected files or mark a directory for new compressed files.
- `/u`: Uncompress the selected files or clear a directory's compression default.
- `/s`: Traverse the named directory and all descendants.
- `/a`: Include hidden and system entries in display or mutation scope.
- `/i`: Continue after errors, permitting a partial result.
- `/f`: Force compression even when an item is already marked compressed.
- `/q`: Suppress most result reporting.
- `/exe`: Select `XPRESS4K`, `XPRESS8K`, `XPRESS16K`, or `LZX` system compression.
- `/compactos`: Query or set installation-wide CompactOS policy with `query`,
  `always`, or `never`.
- `/?`: Display syntax supported by the installed executable.

## Scope and algorithms

- Applying `/c` or `/u` to a directory changes its default for new files but
  does not necessarily rewrite existing descendants.
- `/s:directory` traverses that directory and descendants; without an explicit
  directory it uses the current directory.
- `/a` includes hidden and system entries; without it, inventory can be
  incomplete.
- `/i` continues after errors and therefore creates partial-result risk.
- `/f` forces recompression and is mainly useful for partially compressed
  files, not as a general “stronger compression” flag.
- `/EXE` algorithms range from faster XPRESS4K through more compact LZX and
  suit read-mostly files; modification patterns and platform support matter.
- CompactOS is installation-wide OS-binary policy, separate from compressing
  one application directory.

## Common mistakes

### Expecting an archive or destination file

`compact /c /s source destination` does not copy or package a tree. It treats
arguments as in-place patterns/paths. Use an archive tool when the goal is a
portable bundle, encryption, integrity metadata, or transfer.

### Marking a directory and assuming all existing files changed

A directory compression attribute controls files added later. To affect
existing descendants, use an explicit reviewed `/s:directory` scope and
inventory before/after. Links, mount points, hidden/system entries, open files,
and errors require deliberate handling.

### Running from the wrong current directory

Bare `/s` uses the current directory and can recurse much farther than
intended. Use a quoted absolute `/s:"path"`, inspect the path first, and avoid
volume-root examples unless whole-volume scope is genuinely approved.

### Using `/i` and reporting full success

`/i` continues after errors. Preserve output and `$LASTEXITCODE`, enumerate
failures, and verify representative plus total file state. A completed process
can leave a mixed tree.

### Applying `/EXE:LZX` to write-heavy or unsupported data

System compression is designed for frequently read, rarely modified files.
More compact algorithms trade CPU and rewrite behavior for space. Benchmark
the real workload, confirm Windows/version support, backups, free space, and
update/servicing compatibility before broad use.

### Treating `/CompactOS:always` as ordinary folder compression

It changes persistent OS-binary compression policy and can consume time,
power, CPU, and working space. Query first; use only under supported deployment
or device-capacity policy, and verify servicing and recovery afterward.

### Assuming logical size equals physical savings

Compressed size, logical length, sparse allocation, deduplication, cluster
size, already-compressed formats, and underlying virtual/thin storage differ.
Measure allocated space with an appropriate storage-aware method and verify
application performance rather than relying on Explorer's one number.

### Combining compression with unsupported filesystem features

Availability and interaction vary with NTFS features, encryption, sparse
files, integrity streams, deduplication, WOF/system compression, ReFS, and
application requirements. Ordinary compact does not support FAT/FAT32.

## PowerShell boundaries

Compact is a native text tool. Quote absolute paths and `/S:path` as one
argument, capture output and `$LASTEXITCODE`, and do not infer complete tree
success when `/i` was used. PowerShell's `Compress-Archive` creates ZIP files
and is unrelated to NTFS compression.

## Version and platform differences

This Windows-only command applies to supported Windows client and server
releases. NTFS is required for ordinary compression. `/EXE` and CompactOS
behavior depend on Windows version, filesystem/filter stack, architecture,
servicing, and deployment policy.

## Related documents

- [defrag](defrag.md)
- [attrib](attrib.md)
- [cipher](cipher.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Compact reference](https://learn.microsoft.com/windows-server/administration/windows-commands/compact).
The recurring archive-versus-filesystem-compression confusion was cross-
checked against
[practitioner discussion](https://stackoverflow.com/questions/7928840/how-to-use-compact-exe-the-default-windows-compression-in-a-batch-file).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
