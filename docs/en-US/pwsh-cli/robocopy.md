<!-- mant:tldr:start -->
# robocopy

> Copy Windows files reliably with explicit source, destination, and exit-code handling.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/robocopy.

- Preview a recursive copy without changing files:

`robocopy {{source}} {{destination}} /E /L`

- Mirror a reviewed source into an empty or dedicated destination:

`robocopy {{source}} {{destination}} /MIR`

- Treat only documented serious exit codes as failures:

`robocopy {{source}} {{destination}} /E; if ($LASTEXITCODE -GE 8) { throw 'robocopy failed' }`
<!-- mant:tldr:end -->

# robocopy

## Synopsis

```text
robocopy <source> <destination> [<file> [...]] [<options>]
```

`robocopy.exe` is a Windows file-copy utility intended for robust and large
copy jobs. It is a native program: it reports its own multi-valued exit codes,
not normal PowerShell error records.

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

## Exit codes and PowerShell

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

## Related documents

- [where](where.md)
- [schtasks](schtasks.md)
- [Command-line tools for PowerShell](pwsh-cli.md)

## Sources and license

This original command guide was adapted from the official
[robocopy documentation](https://learn.microsoft.com/windows-server/administration/windows-commands/robocopy).
It emphasizes bounded previews, mirror deletion risk, and Robocopy's special
exit-code contract. Exact upstream revision and path are recorded in
`upstream/cli.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
