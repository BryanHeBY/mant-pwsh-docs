<!-- mant:tldr:start -->
# xcopy.exe

> Copy Windows files and directory trees; preview with `/l` before writing.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/xcopy.

- Preview a recursive copy, including empty directories and hidden/system files:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /s /e /h /i /l`

- Perform the reviewed copy while requiring overwrite confirmation:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /s /e /h /i /-y`

- Copy only the directory structure, including empty directories:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /t /e`

- Preserve ownership and ACL information while copying:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /s /e /o /x`

- Use restartable mode for a copy over an unstable connection:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /s /e /z`

- Overwrite existing destination files without prompting:

`xcopy.exe "{{C:\source\*}}" "{{D:\destination\}}" /s /e /y`

- Inspect the native status immediately in PowerShell:

`xcopy.exe {{arguments}}; $LASTEXITCODE`

- Display the complete local option reference:

`xcopy.exe /?`
<!-- mant:tldr:end -->

# xcopy.exe

## Overview

`xcopy.exe` copies files and directory trees. `/s` recurses but excludes empty
directories, `/e` includes them, `/h` includes hidden/system files, `/l` lists
without copying, `/i` resolves some directory-destination ambiguity, `/b`
copies symbolic links rather than targets, and `/-y` requests overwrite prompts.

For robust modern tree replication, especially restart, metadata, exclusions,
and deletion policy, consider [robocopy.exe](robocopy.exe.md).

## Options

<!-- mant:entries role=command case=insensitive -->
- `xcopy.exe`: Copy selected files and directory trees using the classic
  Windows selection, metadata, and restart behavior.

The source is required and destination defaults to the current directory.
Preview with `/l` using the identical selection and link options.

<!-- mant:entries role=option case=insensitive -->
- `/w`: Wait for an attended key press before beginning the copy.
- `/p`: Prompt before creating each destination file.
- `/c`: Continue after copy errors, potentially leaving a partial destination.
- `/v`: Verify each destination write under XCOPY's comparison contract.
- `/q`: Suppress normal copy messages.
- `/f`: Display full source and destination filenames while copying.
- `/l`: List selected files without copying them.
- `/g`: Create decrypted destinations when the destination does not support EFS.
- `/d`: With a date, select files changed on/after it; without a date, select
  sources newer than existing destinations.
- `/u`: Copy only source files that already exist at the destination.
- `/i`: When source is a directory or wildcard and destination is absent,
  assume the destination is a directory and create it.
- `/s`: Copy subdirectories but omit empty ones.
- `/e`: Include empty subdirectories; use with `/s` or `/t`.
- `/t`: Copy directory structure without files; add `/e` for empty directories.
- `/k`: Retain the source read-only attribute on destination files.
- `/r`: Permit copying over read-only destination files.
- `/h`: Include hidden and system files.
- `/a`: Select sources with the archive attribute without clearing it.
- `/m`: Select sources with the archive attribute and clear it after copying.
- `/n`: Create destination copies using available 8.3 short names.
- `/o`: Copy owner and discretionary ACL information.
- `/x`: Copy audit/SACL information and imply `/o`; requires sufficient rights.
- `/exclude`: Read path-substring exclusions from the following colon-delimited
  file or `+`-joined files.
- `/y`: Suppress overwrite confirmation.
- `/-y`: Require overwrite confirmation and override `COPYCMD=/y`.
- `/z`: Use restartable mode for a network copy.
- `/b`: Copy a symbolic link itself instead of its target.
- `/j`: Use unbuffered I/O, intended for very large files.
- `/compress`: Request network compression where both ends support it.
- `/sparse`: Preserve sparse state during copying where supported.
- `/-sparse`: Disable sparse-state preservation; it wins if both forms appear.
- `/noclone`: Do not attempt block cloning as a copy optimization.
- `/?`: Display installed command help.

## PowerShell boundaries

`xcopy.exe` is native text software, not a PowerShell provider cmdlet. Pass
source/destination and each colon-form switch as distinct reviewed arguments,
capture `$LASTEXITCODE` immediately, and interpret its documented 0/1/2/4/5
contract. Use `/l` before mutation and compare destination inventory/metadata;
status alone does not prove that the intended set and security data arrived.

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
long paths, block cloning, network compression, and link behavior vary. On
Windows NT `10.0.26200.0`, installed file version `10.0.26100.1` printed 63
nonempty help lines and returned 0 for `/?`; `-?` was treated as a source name,
not help. A `/s /e /h /i /l` run against the bounded existing `tests/runtime`
tree listed seven lines, returned 0, and did not create the preflighted absent
target directory.

## Runtime evidence

The protected fixture selected one task-owned source subtree and a distinct
absent sibling destination, then ran exact `xcopy.exe` with `/s /e /h /i /l`.
Both PowerShell collectors returned a nonempty preview/status `0`, and the
destination still did not exist afterward. No file was copied. The result does
not cover destination-inside-source topology, manual trailing-separator
quoting, prompts, overwrite, links, ACL/SACL, EFS, archive-bit changes,
restart/network behavior, errors hidden by `/c`, or equivalence between preview
and a later changed source tree.

## Related documents

- [robocopy.exe](robocopy.exe.md)
- [copy](copy.md)
- [attrib.exe](attrib.exe.md)
- [mklink](mklink.md)

## Sources and license

This original guide was adapted from Microsoft's official
[xcopy reference](https://learn.microsoft.com/windows-server/administration/windows-commands/xcopy).
The single-file `/i` ambiguity is evidenced by
[XCOPY still asking for file or directory confirmation](https://stackoverflow.com/questions/33752732/xcopy-still-asking-f-file-d-directory-confirmation),
and exit-code edge cases by
[Windows copy command return codes](https://stackoverflow.com/questions/8219040/windows-copy-command-return-codes).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
