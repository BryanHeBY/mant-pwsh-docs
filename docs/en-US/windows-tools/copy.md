<!-- mant:tldr:start -->
# copy

> Copy or concatenate files with the `cmd.exe` builtin; bare `copy` in PowerShell is different.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/copy.

- Copy one file and require explicit overwrite confirmation:

`cmd.exe /d /c 'copy /-y "{{C:\source\file}}" "{{C:\destination\file}}"'`

- Concatenate explicitly ordered binary files:

`cmd.exe /d /c 'copy /b "{{part1}}" + "{{part2}}" "{{combined}}" /b'`

- Use the PowerShell-native operation for an ordinary copy:

`Copy-Item -LiteralPath '{{source}}' -Destination '{{destination}}' -Confirm`
<!-- mant:tldr:end -->

# copy

## Overview

`copy` is a cmd builtin for files and file concatenation. In PowerShell, `copy`
normally aliases `Copy-Item`; that cmdlet does not implement cmd's `+` and
`/a`/`/b` concatenation semantics.

## Syntax

```text
copy [/d] [/v] [/n] [/y | /-y] [/z] [/a | /b]
     SOURCE [/a | /b] [+ SOURCE ...] [DESTINATION [/a | /b]]
```

`/y` suppresses overwrite confirmation, `/-y` forces it, `/z` supports a
restartable network copy, `/d` permits encrypted input to be written decrypted,
and `/a`/`/b` select text/whole-byte behavior by position.

## Commands and options

<!-- mant:entries role=command case=insensitive -->
- `copy`: Copy files or concatenate multiple sources through the `cmd.exe`
  builtin; it is not a standalone `copy.exe`.

Invoke this grammar with `cmd.exe /d /c` from PowerShell. The position of
`/a` or `/b` matters because it can qualify a source or destination.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Allow an encrypted source file to be written decrypted when the
  destination does not support EFS; verify the resulting protection state.
- `/v`: Verify that new destination data can be read correctly under the
  builtin's write-verification contract.
- `/n`: Use an available short filename while copying a source whose name is
  not compatible with an 8.3 destination convention.
- `/y`: Suppress confirmation before overwriting an existing destination file.
- `/-y`: Require confirmation before overwriting; this overrides `COPYCMD=/y`.
- `/z`: Copy a network file in restartable mode.
- `/a`: Select ASCII/text behavior for the source or destination at that
  position, including Ctrl+Z end-of-file handling.
- `/b`: Select binary behavior and copy all bytes for the source or destination
  at that position.
- `/?`: Display the builtin's installed help through `cmd.exe`.

## PowerShell boundaries

Bare `copy` resolves to `Copy-Item` in normal PowerShell sessions. Use the
cmdlet for ordinary copies, or quote a complete reviewed builtin command for
`cmd.exe /d /c` when concatenation or positional `/a`/`/b` semantics are
required. Capture the destination before-state, check the child cmd exit code,
and verify the resulting file rather than parsing one localized summary line.

## Common mistakes

### Running PowerShell's `copy` alias by accident

Resolve with `Get-Command copy -All`. Use `Copy-Item` for ordinary object-aware
copies and `cmd.exe /d /c` only for the cmd contract.

### Omitting or mistyping the destination directory

If an intended destination directory does not exist, cmd can create a file
with that directory-like name. Test the destination as a directory first and
verify the resulting item type and full path.

### Concatenating binary data without `/b`

Combined files default to ASCII handling, where Ctrl+Z has special meaning.
Use `/b` and remember that byte concatenation does not make formats such as
ZIP, EXE, PDF, or media structurally valid.

### Letting the output match its source wildcard

A preexisting combined output can be selected as an input, making results
order-dependent or duplicative. Generate outside the source pattern or build an
explicit reviewed source list.

### Treating `/v` as end-to-end content verification

It verifies writes according to the command's contract, not business content,
metadata, ACLs, signatures, or a cryptographic identity. Verify the artifact
that the workflow actually requires.

## Version and platform differences

This builtin is Windows-only; WinRE exposes a different form. `COPYCMD` can
preset `/y`, so automation should specify overwrite policy explicitly.

## Runtime evidence

The protected fixture created two binary inputs below a verified GUID-named
temporary root and confirmed that exact Cmd `copy /b /y` concatenated them into
the expected six bytes under both PowerShell collectors. The output and inputs
were removed with the root. This does not cover caller-owned overwrite,
wildcards, network restart, EFS, prompts, or source/output collision.

## Related documents

- [cmd.exe](cmd.exe.md)
- [robocopy.exe](robocopy.exe.md)
- [dir](dir.md)

## Sources and license

This original guide was adapted from Microsoft's official
[copy reference](https://learn.microsoft.com/windows-server/administration/windows-commands/copy).
The PowerShell alias and concatenation mismatch is evidenced by
[Copy (append) multiple files into a single destination file](https://stackoverflow.com/questions/71209707/copy-append-multiple-files-into-a-single-destination-file).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
