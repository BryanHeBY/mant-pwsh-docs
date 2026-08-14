<!-- mant:tldr:start -->
# robocopy.exe

> Copy Windows files reliably with explicit source, destination, and exit-code handling.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/robocopy.

- Preview a recursive copy without changing files:

`robocopy {{source}} {{destination}} /E /L`

- Copy selected filename patterns from one directory:

`robocopy {{source}} {{destination}} {{*.jpg}} {{*.png}}`

- Mirror a reviewed source into an empty or dedicated destination:

`robocopy {{source}} {{destination}} /MIR`

- Treat only documented serious exit codes as failures:

`robocopy {{source}} {{destination}} /E; if ($LASTEXITCODE -GE 8) { throw 'robocopy failed' }`

- Copy recursively while skipping source files older than destination files:

`robocopy {{source}} {{destination}} /E /XO`

- Preview files at least 50 MiB without copying them:

`robocopy {{source}} {{destination}} /S /MIN:52428800 /L`

- Use restartable mode with bounded retries for an unstable connection:

`robocopy {{source}} {{destination}} /E /Z /R:5 /W:15`

- Display the complete local option reference:

`robocopy /?`
<!-- mant:tldr:end -->

# robocopy.exe

## Synopsis

```text
robocopy <source> <destination> [<file> [...]] [<options>]
```

`robocopy.exe` is a Windows file-copy utility intended for robust and large
copy jobs. It is a native program: it reports its own multi-valued exit codes,
not normal PowerShell error records.

## Important options

<!-- mant:entries role=command case=insensitive -->
- `robocopy.exe`: Copy, mirror, move, compare, list, monitor, throttle, or log
  one explicitly identified source/destination tree under Robocopy's graded
  exit-code contract.

The following high-impact switches are addressable for precise Agent lookup.

<!-- mant:entries role=option case=insensitive -->
- `/L`: List the proposed operation without copying, deleting, or changing file attributes.
- `/E`: Copy subdirectories including empty ones.
- `/S`: Copy nonempty subdirectories and omit empty ones.
- `/LEV:N`: Limit recursion to `N` levels below the source root.
- `/MIR`: Mirror the directory tree, equivalent to `/E` plus purge behavior; destination-only content can be deleted.
- `/PURGE`: Delete destination files and directories that no longer exist in the source.
- `/MOV`, `/MOVE`: Move files, or files plus directories, by deleting source items after successful copy.
- `/COPY:FLAGS`: Select file data, attributes, timestamps, ACL, owner, and audit fields to copy.
- `/DCOPY:FLAGS`: Select directory data, attributes, timestamps, extended attributes, or skip-alt-stream behavior supported by the installed build.
- `/SEC`, `/COPYALL`: Copy security or all file metadata; verify privileges, ownership, and destination policy.
- `/SECFIX`, `/TIMFIX`: Correct security or timestamps on selected destination files, including skipped files.
- `/Z`, `/B`, `/ZB`: Select restartable, backup, or restartable-then-backup copy mode with different privilege and performance boundaries.
- `/J`: Use unbuffered I/O, commonly useful for large files.
- `/MT:N`: Use multithreaded copy with the selected thread count; observe server, network, and storage load.
- `/R:N`, `/W:N`: Set retry count and wait time explicitly instead of accepting unexpectedly long defaults.
- `/TBD`: Wait for a network share name to become available after system error 67.
- `/IPG:N`: Add an inter-packet gap to reduce network pressure on slower links.
- `/XJ`, `/XJD`, `/XJF`: Exclude junction/reparse traversal broadly, for directories, or for files as supported.
- `/XF FILE`, `/XD DIRECTORY`: Exclude matching files or directories; verify wildcard and path matching with `/L`.
- `/MAXAGE:N`, `/MINAGE:N`: Bound files by age/date according to Robocopy's documented value grammar.
- `/FFT`: Use two-second timestamp granularity for cross-filesystem comparisons.
- `/DST`: Compensate for one-hour daylight-saving timestamp differences.
- `/LOG:FILE`, `/UNILOG:FILE`: Write a normal or Unicode log to an explicit protected path.
- `/TEE`: Write status to both the console and the selected log.
- `/NJH`, `/NJS`, `/NP`: Suppress job header, job summary, or progress percentages; keep enough evidence for diagnosis.
- `/EFSRAW`: Copy encrypted files in EFS raw mode; incompatible with `/MT` and
  low-free-space mode and not a substitute for recovery-key planning.
- `/NOCOPY`, `/NODCOPY`: Copy no file or directory metadata; these are useful
  with narrow operations such as purge but can produce unexpected metadata.
- `/CREATE`: Create only the directory tree and zero-length files; it still
  mutates the destination and is not a dry run.
- `/NOOFFLOAD`: Disable Windows Copy Offload for the transfer.
- `/COMPRESS`: Request SMB/network compression when the path and peer support it.
- `/SPARSE`: Enable or disable preserving sparse file state during copy.
- `/NOCLONE`: Disable block-cloning optimization; this can change space,
  performance, and copy-on-write behavior.
- `/IOMAXSIZE`, `/IORATE`, `/THRESHOLD`: Select copy-file throttling I/O size,
  rate, and minimum file-size threshold; the system/tool can adjust requested
  values to supported limits.
- `/LFSM`: Pause/resume in low-free-space mode at an explicit floor; without a
  value the current reference uses 10% of destination size, and the mode is
  incompatible with `/MT` and `/EFSRAW`.
- `/?`: Display installed help. Complete help can return 16, which is a help
  status and must not be interpreted through completed-copy exit semantics.

## Start with a bounded preview

Specify a source and a narrowly scoped destination. Use `/L` to list what a
job would copy without modifying files:

```powershell
robocopy.exe C:\source D:\staging /E /L
if ($LASTEXITCODE -ge 8) {
    throw "robocopy preview failed with exit code $LASTEXITCODE"
}
```

Review reparse points, permissions, files in use, network paths, and free
space before running a production copy. Test first with a representative
directory and explicit logging.

## Mirror is destructive

`/MIR` makes the destination mirror the source, including deleting destination
files absent from the source. Never use it on an unverified path, a user home,
or a broad root. Prefer `/L` first, require an explicit dedicated destination,
and maintain a recovery plan.

Other switches such as `/E`, retry controls, copy flags, and logging alter the
transfer contract. Read the official reference for the exact installed tool;
do not assume a copied command line has suitable security and retention rules.

## Common mistakes

### Treating every nonzero exit code as failure

Generic checks such as `if ($LASTEXITCODE -ne 0)` report normal copy or
difference results as failures. For Robocopy, interpret the documented graded
codes and treat values `8` and above as a failure threshold.

### Running `/MIR` before `/L`

`/MIR` can delete destination content. Preview the exact source, destination,
filters, and options with `/L`, and verify that the destination is dedicated
to the mirror operation.

### Checking `$LASTEXITCODE` after another native command

Another native executable overwrites `$LASTEXITCODE`. Save or test Robocopy's
code immediately after it exits.

## PowerShell boundaries

Robocopy uses bitmapped/graded exit codes. Values below `8` can mean files were
copied, skipped, or had nonfatal differences; `8` and higher indicate at least
one failure. Preserve and interpret the code explicitly:

```powershell
robocopy.exe C:\source D:\destination /E /LOG:C:\logs\copy.log
if ($LASTEXITCODE -ge 8) {
    exit $LASTEXITCODE
}
```

Do not use `$?` alone for Robocopy success criteria.

## Version and availability

Robocopy is Windows-only. Options and metadata behavior vary by Windows build,
source/destination filesystem, SMB/server capabilities, privileges, reparse
points, and installed tool version. Query `robocopy /?` on the target.
On exact System32 file version `10.0.26100.1`, `/?` printed 163 nonempty stdout
lines, produced no PowerShell error records, and returned 16. No source,
destination, filter, path, log, job, filesystem traversal, copy, deletion,
metadata, network, or registry operation was supplied.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 file version 10.0.26100.1 /? printed
163 nonempty stdout lines, no PowerShell error records, and returned 16.
Current installed/official high-impact entries added EFS raw,
no-metadata/create, offload/compression/sparse/block-clone, I/O throttling,
low-free-space mode, executable and help selectors. No source, destination,
filter, log, job, traversal, copy, deletion, metadata, network, or registry
operation ran.

## Related documents
- [where.exe](where.exe.md)
- [schtasks.exe](schtasks.exe.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original command guide was adapted from the official
[robocopy documentation](https://learn.microsoft.com/windows-server/administration/windows-commands/robocopy).
It emphasizes bounded previews, mirror deletion risk, and Robocopy's special
exit-code contract. Exact upstream revision and path are recorded in
`upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
