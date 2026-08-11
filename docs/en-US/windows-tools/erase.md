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

## Common mistakes

- Assuming the alternate spelling is safer: it performs the same deletion.
- Running it without an explicit cmd context from PowerShell.
- Using `/s /q` or wildcards before enumerating the exact target.

## Sources and license

This original alias guide is based on Microsoft's official
[del/erase reference](https://learn.microsoft.com/windows-server/administration/windows-commands/del).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
