<!-- mant:tldr:start -->
# diskcopy.exe

> Clone one floppy disk to a same-type destination floppy, treating the destination as destructively overwritten.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/diskcopy.

- Confirm the executable and installed syntax before loading media:

`Get-Command diskcopy.exe -ErrorAction Stop; diskcopy.exe /?`

- Copy between explicit source and destination floppy drives and verify the write:

`diskcopy.exe {{A:}} {{B:}} /v; $diskcopyExitCode = $LASTEXITCODE`

- Copy between two floppies using one drive and carefully follow source/destination prompts:

`diskcopy.exe {{A:}} {{A:}} /v`

- Compare the completed floppy tracks separately:

`diskcomp.exe {{A:}} {{B:}}; $compareExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# diskcopy.exe

## Overview

`diskcopy.exe` copies an entire floppy disk to a formatted or unformatted
same-type floppy. It can format the destination during copying, reproduces
source fragmentation, and assigns a new volume serial number. It does not copy
to a hard disk and is not a general disk-cloning or file-copy command.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `diskcopy.exe`: Copy one complete floppy disk onto another compatible floppy.

The first drive is source and the second is overwritten destination.

<!-- mant:entries role=option case=insensitive -->
- `/v`: Verify copied information after writing it.
- `/?`: Display installed syntax.

## Exit codes

`0` is success, `1` is a nonfatal read/write error, `3` is a fatal hard error,
and `4` is an initialization error. `/v` verifies the copied information but
slows the operation. Preserve the code immediately and do not call code `1` a
successful verified archive.

## Common mistakes

### Reversing source and destination

The destination is overwritten and may be formatted. Label both physical disks,
write-protect the source where possible, and say the direction aloud before
continuing. Do not rely only on drive letters when one drive prompts for swaps.

### Using DiskCopy as a modern imaging tool

It is limited to compatible floppy disks. For forensic preservation, damaged
media, USB devices, or fixed disks, use a purpose-built imaging workflow that
records errors and hashes and never writes to the source.

### Equating `/v` with long-term integrity

Verification checks the just-written copy. It does not provide durable identity,
authenticity, or future readability. Record image hashes and storage metadata
when those guarantees matter.

## PowerShell boundaries

DiskCopy is interactive native software. It reads console input and writes
localized text; it is unsuitable for unattended remoting. Capture
`$LASTEXITCODE` immediately and preserve the operator/media log.

## Version and platform differences

Although cataloged for current Windows, availability and operation depend on
legacy floppy hardware, drivers, compatible geometry, and interactive access.

## Related documents

- [diskcomp.exe](diskcomp.exe.md)
- [copy](copy.md)
- [xcopy.exe](xcopy.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DiskCopy reference](https://learn.microsoft.com/windows-server/administration/windows-commands/diskcopy).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
