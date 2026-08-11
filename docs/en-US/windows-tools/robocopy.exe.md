<!-- mant:tldr:start -->
# robocopy.exe

> Copy Windows files reliably with explicit source, destination, and exit-code handling.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/robocopy.

- Preview a recursive copy without changing files:

`robocopy {{source}} {{destination}} /E /L`

- Mirror a reviewed source into an empty or dedicated destination:

`robocopy {{source}} {{destination}} /MIR`

- Treat only documented serious exit codes as failures:

`robocopy {{source}} {{destination}} /E; if ($LASTEXITCODE -GE 8) { throw 'robocopy failed' }`
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
