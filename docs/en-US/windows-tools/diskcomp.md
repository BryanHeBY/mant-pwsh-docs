<!-- mant:tldr:start -->
# diskcomp

> Compare the track contents of two same-type floppy disks; this is not a file, hard-disk, image, or network comparison tool.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/diskcomp.

- Confirm the executable and its installed help before relying on legacy media:

`Get-Command diskcomp.exe -ErrorAction Stop; diskcomp.exe /?`

- Compare two explicitly identified floppy drives and capture the four-way result:

`diskcomp.exe {{A:}} {{B:}}; $diskcompExitCode = $LASTEXITCODE`

- Compare two floppies using one physical drive and follow the swap prompts:

`diskcomp.exe {{A:}} {{A:}}`

- Compare modern files byte-for-byte instead:

`fc.exe /b "{{source.img}}" "{{copy.img}}"; $compareExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# diskcomp

## Overview

`diskcomp.exe` compares tracks on two floppy disks. The disks must be compatible
types; it does not support fixed disks, network drives, or `subst` drives. It
ignores the volume serial number and can prompt repeatedly when one drive is
used for both disks.

## Exit codes

`0` means the disks match, `1` means differences were found, `3` is a hard
error, and `4` is an initialization error. Capture `$LASTEXITCODE` immediately;
both mismatch and operational failure are nonzero but mean different things.

## Common mistakes

### Using DiskComp for files, disk images, USB media, or hard disks

It is floppy-track tooling. Use `fc /b`, a cryptographic hash, or an approved
imaging/verification tool for modern artifacts. A file-level match is also not
the same contract as a track-level floppy match.

### Assuming files copied with `copy` must pass DiskComp

File copies can place identical files on different tracks. DiskComp may report
a track difference even when the file contents are equal.

### Automating an interactive swap without media identity

Single-drive operation prompts for disk changes, and the source/destination
labels are not a cryptographic chain of custody. Physically label media and
record hashes of acquired images when preservation matters.

## PowerShell behavior

This native tool reads the console and emits localized text. Do not pipe objects
to it or parse success text. Use explicit drive tokens and its documented exit
code; do not infer that every nonzero value is merely a mismatch.

## Version and platform differences

The command is cataloged for current Windows releases, but usable floppy
hardware, drivers, firmware, media geometry, and the executable's presence must
be confirmed on the target host.

## Related documents

- [diskcopy](diskcopy.md)
- [fc](fc.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DiskComp reference](https://learn.microsoft.com/windows-server/administration/windows-commands/diskcomp).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
