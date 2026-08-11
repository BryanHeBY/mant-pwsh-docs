<!-- mant:tldr:start -->
# erase

> Exact cmd synonym for `del`; it permanently deletes files, not directories.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/del.

- Open the complete safe-use guide:

`mant del --source windows-tools`

- Preview one pattern before using either spelling:

`cmd.exe /d /c 'dir /b /a "{{C:\path\pattern}}"'`

- Prefer the canonical spelling in new batch files:

`del /p "{{C:\path\file}}"`
<!-- mant:tldr:end -->

# erase

## Meaning

`erase` is the same `cmd.exe` builtin as `del`, with identical parameters and
permanent deletion behavior. It is not a separate executable. Use [del](del.md)
for syntax, wildcard/8.3 risks, recursion, attributes, preview, and PowerShell
command-resolution guidance.

## Command identity and options

<!-- mant:entries role=command case=insensitive -->
- `erase`, `del`: Permanently delete selected files through the same cmd builtin.

The following switches have cmd deletion semantics.

<!-- mant:entries role=option case=insensitive -->
- `/p`: Prompt before deleting each selected file.
- `/f`: Force deletion of read-only files.
- `/s`: Delete matching files from the current directory and all subdirectories.
- `/q`: Suppress confirmation when deleting through a wildcard or broad selection.
- `/a:ATTRIBUTES`: Select files by documented attribute expression.

## PowerShell boundaries

`erase` is cmd syntax, not a PowerShell deletion cmdlet. Invoke it through
`cmd.exe /d /c` only when cmd matching semantics are required; otherwise use
`Remove-Item -LiteralPath` with an explicit preview and scope.

## Version and availability

The synonym and options are Windows cmd builtins. Filesystem permissions,
attributes, reparse points, current directory, wildcard expansion, and Windows
version constrain actual deletion.

## Common mistakes

- Assuming the alternate spelling is safer: it performs the same deletion.
- Running it without an explicit cmd context from PowerShell.
- Using `/s /q` or wildcards before enumerating the exact target.

## Related documents

- [del](del.md)
- [cmd.exe](cmd.exe.md)
- [rmdir](rmdir.md)

## Sources and license

This original alias guide is based on Microsoft's official
[del/erase reference](https://learn.microsoft.com/windows-server/administration/windows-commands/del).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
