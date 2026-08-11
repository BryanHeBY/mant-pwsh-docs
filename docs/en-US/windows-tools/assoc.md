<!-- mant:tldr:start -->
# assoc

> Inspect the classic cmd mapping from a filename extension to a file-type identifier.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/assoc.

- Query one extension without changing it:

`cmd.exe /d /c 'assoc {{.txt}}'`

- List classic extension mappings:

`cmd.exe /d /c assoc`

- Inspect the open command for the file type returned by `assoc`:

`cmd.exe /d /c 'ftype {{txtfile}}'`
<!-- mant:tldr:end -->

# assoc

## Overview

`assoc` is a `cmd.exe` builtin that displays or modifies the classic mapping
from `.extension` to a file-type/ProgID name. It is unavailable as a standalone
PowerShell command; invoke `cmd.exe /d /c assoc ...` explicitly.

## Syntax

```text
assoc [.EXT[=[FILETYPE]]]
```

No arguments lists mappings. `.ext` queries one. Assignment changes persistent
association state and requires administrator privileges according to Microsoft.
Use `ftype FILETYPE` to inspect the associated open command.

## Command forms

<!-- mant:entries role=command case=insensitive -->
- `assoc`: List classic extension mappings, query one `.EXT`, assign
  `.EXT=FILETYPE`, or delete the mapping with `.EXT=` inside `cmd.exe`.

The extension must include its leading dot. Query both this mapping and the
corresponding `ftype` command before any persistent change.

## PowerShell boundaries

There is no `assoc.exe`, so PowerShell cannot invoke the builtin directly.
Use one explicit `cmd.exe /d /c` string for read-only inspection and treat
assignment/removal as persistent system state. Check the child exit code,
re-query both layers, and never infer the effective user default application
from this classic mapping alone.

## Common mistakes

### Running bare `assoc` in PowerShell

There is no `assoc.exe`. PowerShell cannot discover this cmd builtin as an
application. Use `cmd.exe /d /c` and keep the cmd string explicit.

### Assuming the mapping is the current user's default app

Modern Windows protects user-selected defaults and does not allow applications
to change them silently. `assoc`/`ftype` classic registration does not prove
which handler the shell will use. Use Settings for user choice or supported
default-association policy/DISM mechanisms for managed devices and images.

### Changing before recording both layers

Back up/query the extension mapping and its `ftype` open command. A valid
extension-to-ProgID link is incomplete if the ProgID command is missing or
unsafe.

### Removing or replacing common associations casually

Changes affect process launch and can break applications or security controls.
Test with a dedicated extension and explicit rollback; do not use production
extensions for experiments.

## Version and platform differences

The builtin exists on supported Windows client/server releases, but modern app
defaults add per-user and managed-policy layers beyond this classic mapping.

## Related documents

- [ftype](ftype.md)
- [cmd.exe](cmd.exe.md)
- [control.exe](control.exe.md)
- [ms-settings](ms-settings.md)

## Sources and license

This original guide was adapted from Microsoft's official
[assoc reference](https://learn.microsoft.com/windows-server/administration/windows-commands/assoc)
and current [Windows app defaults platform](https://learn.microsoft.com/windows/apps/develop/windows-integration/default-apps-platform)
guidance. Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
