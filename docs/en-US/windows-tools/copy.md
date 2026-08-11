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

## Related documents

- [cmd](cmd.md)
- [robocopy](robocopy.md)
- [dir](dir.md)

## Sources and license

This original guide was adapted from Microsoft's official
[copy reference](https://learn.microsoft.com/windows-server/administration/windows-commands/copy).
The PowerShell alias and concatenation mismatch is evidenced by
[Copy (append) multiple files into a single destination file](https://stackoverflow.com/questions/71209707/copy-append-multiple-files-into-a-single-destination-file).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
