<!-- mant:tldr:start -->
# edit.exe

> Resolve the exact executable before using `edit`: current Windows 11 can
> provide modern Microsoft Edit, while historical scripts can mean the retired
> 16-bit MS-DOS Editor with incompatible switches.
> More information: https://learn.microsoft.com/windows/edit/.

- Identify every command candidate and the signed file actually selected:

`Get-Command edit, edit.exe, msedit -All -ErrorAction SilentlyContinue | Select-Object Name, CommandType, Source, Version`

- Ask a confirmed modern Microsoft Edit binary for its version and syntax
  without opening a file or entering the editor:

`& "$env:SystemRoot\System32\edit.exe" --version; & "$env:SystemRoot\System32\edit.exe" --help`

- Inspect a text file without starting an editor or allowing a save:

`Get-Content -LiteralPath "{{path}}" -Raw`

- Open one exact file interactively only after deciding that edits are allowed:

`edit.exe "{{path}}"`

<!-- mant:tldr:end -->

# edit.exe

## Overview

The name `edit` now refers to two different Microsoft programs:

- **Microsoft Edit** is a modern, open-source, Rust-based, modeless terminal
  editor. It is included in Windows 11 beginning with the September 2025
  optional update and Windows 11 version 25H2, and can also be installed on
  other supported Windows releases. The upstream project also provides it on
  Linux and macOS, commonly under the conflict-avoiding name `msedit`.
- **MS-DOS Editor** is the retired 16-bit full-screen editor described by the
  older Windows command reference. Its `/b`, `/h`, `/r`, `/s`, and `/<nnn>`
  switches do not describe modern Microsoft Edit.

Command-name identity is therefore part of the syntax contract. Resolve the
exact application, inspect its version/help, and do not infer an interface from
an old runbook or from the bare name alone.

## Current Microsoft Edit interface

On the recorded Windows host, signed System32 Microsoft Edit 1.2.1 reports:

```text
edit [OPTIONS] [FILE[:LINE[:COLUMN]]]
```

<!-- mant:entries role=command case=insensitive -->
- `edit.exe`: Start the resolved Windows Microsoft Edit or historical editor;
  identify the binary generation before supplying options or a file.
- `edit`: Use the canonical upstream command name after normal command
  discovery and identity checks.
- `msedit`: Use the upstream alternative package/executable name intended to
  avoid conflicts on Linux, macOS, or packaging systems.

The installed modern binary exposes only these command-line options:

<!-- mant:entries role=option case=sensitive -->
- `-h`, `--help`: Print modern Microsoft Edit command-line help without opening
  a file or entering the TUI.
- `-v`, `--version`: Print the modern editor version.

`FILE[:LINE[:COLUMN]]` opens a file and can position the cursor. Treat a path
plus line/column as one editor operand, not as a PowerShell drive qualifier or
an alternate data stream constructed by string concatenation. Prefer a
resolved literal path; verify exact drive-colon behavior on the target version
before generating a position suffix for an absolute Windows path.

Starting the editor is interactive, and saving mutates the opened file. Before
editing, resolve the path, reject directories and unexpected reparse targets,
inspect encoding/newlines/permissions, preserve a recoverable copy when
appropriate, and define how a save will be validated.

## Historical MS-DOS Editor interface

The legacy Microsoft reference documents the following separate grammar:

```text
edit [/b] [/h] [/r] [/s] [/<nnn>] [[drive:][path]filename ...]
```

These entries exist for old-script recognition only. They must not be sent to
a modern binary merely because its filename is also `edit.exe`.

<!-- mant:entries role=option case=insensitive -->
- `/b`: Force monochrome display in the historical MS-DOS Editor.
- `/h`: Request its maximum-height display mode.
- `/r`: Load historical editor files read-only.
- `/s`: Force historical short-filename handling.
- `/?`: Display historical MS-DOS Editor command-line help when that binary is
  actually present.

The numeric legacy `/<nnn>` binary-wrap form remains prose because the value is
embedded in the switch. It does not establish binary-safe editing: encoding,
control bytes, line wrapping, and round-trip preservation still require
independent verification.

## Common mistakes

### Sending DOS switches to current Microsoft Edit

Modern `-h`/`--help` and `-v`/`--version` use hyphens. The legacy slash
switches belong to a different executable generation. Always capture the
resolved path, signature/package provenance, version output, help output, and
exit status before generating an invocation.

### Assuming `edit` is always Microsoft's executable

PowerShell can resolve an alias, function, script, application, or a package
named by another vendor. On Unix-like systems, `edit` can already have a
different meaning, which is why the upstream project recommends `msedit` as an
alternative package name. Use `Get-Command -All` on Windows or equivalent
application discovery, then invoke an exact trusted path when identity matters.

### Treating an editor launch as a read-only inspection

Opening a file may be harmless, but the session is designed to save changes;
an absent path can also become a new-file buffer. For evidence collection use
`Get-Content`, `Format-Hex`, or a reviewed parser. If interactive editing is
intended, use a copy or version-controlled file, avoid secrets, and verify the
result after exit.

### Calling every text file ASCII or UTF-8

Legacy OEM/ANSI code pages, UTF encodings, BOMs, newline conventions, control
bytes, and binary data are different. Inspect bytes and metadata before an edit
or conversion, choose an explicit encoding-aware workflow, and verify content
and newline preservation afterward.

## PowerShell boundaries

PowerShell does not define Microsoft Edit's path/position grammar. Quoting
protects a path as one PowerShell argument but does not resolve the editor's
own `FILE[:LINE[:COLUMN]]` interpretation. Avoid shell-built command strings;
pass the file as a distinct argument and use `--help` from the exact version as
the interface of record.

`Get-Content -Raw` is useful for bounded text inspection, but it is not a
binary-preserving editor and default encodings differ between Windows
PowerShell 5.1 and current PowerShell. For a write, select the target encoding
and newline policy explicitly and protect against unintended replacement.

## Version and platform differences

Windows 11 availability begins with the September 2025 optional update or
version 25H2 according to current Microsoft documentation; installation and
servicing can still vary by image and policy. Older Windows hosts may have no
`edit.exe`, while a historical 16-bit binary generally cannot run natively in
a modern 64-bit Windows environment.

The current upstream project supports Windows, Linux, and macOS. Package and
executable names can be `edit` or `msedit`, so cross-platform automation must
discover the exact command and version instead of assuming the Windows
System32 path or a globally unique name.

## Runtime evidence

On Windows NT 10.0.26200.0, exact signed System32 Microsoft Edit file version
1.2.1 returned version stdout/status 0 and six nonempty help lines/status 0
with no stderr. Only --version and --help ran under a three-second bounded
concurrent-stream harness; no file operand, TUI session, new buffer, read,
save, encoding conversion or filesystem mutation occurred.

## Related documents
- [type](type.md)
- [more.com](more.com.md)
- [chcp.com](chcp.com.md)
- [where.exe](where.exe.md)

## Sources and license

Current behavior and availability are based on Microsoft's
[Microsoft Edit documentation](https://learn.microsoft.com/windows/edit/) and
the MIT-licensed [microsoft/edit repository](https://github.com/microsoft/edit).
Historical syntax is retained from Microsoft's
[MS-DOS Editor command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/edit).
Exact provenance is in `upstream/windows-tools.json`. Microsoft Learn content
and this original adaptation use CC BY 4.0; the linked editor source is MIT.
