<!-- mant:tldr:start -->
# xcopy

> Copy Windows files and directory trees; preview with `/l` before writing.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/xcopy.

- Preview a recursive copy, including empty directories and hidden/system files:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /s /e /h /i /l`

- Perform the reviewed copy while requiring overwrite confirmation:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /s /e /h /i /-y`

- Inspect the native status immediately in PowerShell:

`xcopy.exe {{arguments}}; $LASTEXITCODE`
<!-- mant:tldr:end -->

# xcopy

## Overview

`xcopy.exe` copies files and directory trees. `/s` recurses but excludes empty
directories, `/e` includes them, `/h` includes hidden/system files, `/l` lists
without copying, `/i` resolves some directory-destination ambiguity, `/b`
copies symbolic links rather than targets, and `/-y` requests overwrite prompts.

For robust modern tree replication, especially restart, metadata, exclusions,
and deletion policy, consider [robocopy](robocopy.md).

## Exit codes

- `0`: Files copied without error.
- `1`: No files found to copy (documented contract; observed edge cases vary).
- `2`: User terminated the copy.
- `4`: Initialization, resource, drive, or syntax error.
- `5`: Disk write error.

## Common mistakes

### Copying before using `/l` with identical selection options

Preview the same source, mask, recursion, hidden/system, date, exclude, and link
policy. Confirm that destination is outside the selected source tree.

### Assuming `/i` always removes file-versus-directory ambiguity

For a single source file and nonexistent destination, `/i` may not prevent the
localized F/D prompt. Prefer an existing destination directory with a trailing
backslash or an explicit destination filename.

### Treating `/s` and `/e` as synonyms

`/s` omits empty directories; `/e` includes them when used with recursive/tree
operations. Decide whether empty structure is data the workflow must preserve.

### Following links without a policy

Use `/b` only when copying the symbolic link itself is intended and supported.
Otherwise a recursive copy can duplicate target content or escape visual scope.

### Assuming status alone proves the expected inventory

Community reports show zero-match behavior can differ from the documented 1 in
some wildcard scenarios. Verify counts, paths, sizes/hashes, attributes, ACLs,
and omissions required by the workflow.

### Using `/c` to hide errors

`/c` continues after errors and can yield partial output. Capture diagnostics
and perform a final inventory; it is not a success guarantee.

## Version and platform differences

This executable is Windows-only. Filesystem features, EFS, ACL/SACL handling,
long paths, block cloning, network compression, and link behavior vary.

## Related documents

- [robocopy](robocopy.md)
- [copy](copy.md)
- [attrib](attrib.md)
- [mklink](mklink.md)

## Sources and license

This original guide was adapted from Microsoft's official
[xcopy reference](https://learn.microsoft.com/windows-server/administration/windows-commands/xcopy).
The single-file `/i` ambiguity is evidenced by
[XCOPY still asking for file or directory confirmation](https://stackoverflow.com/questions/33752732/xcopy-still-asking-f-file-d-directory-confirmation),
and exit-code edge cases by
[Windows copy command return codes](https://stackoverflow.com/questions/8219040/windows-copy-command-return-codes).
Exact sources and licenses are recorded in `upstream/cli.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
