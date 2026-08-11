<!-- mant:tldr:start -->
# ftype

> Inspect the classic open command registered for a cmd file-type identifier.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ftype.

- Query one file type without changing it:

`cmd.exe /d /c 'ftype {{txtfile}}'`

- List file types with open commands:

`cmd.exe /d /c ftype`

- Inspect the extension mapping first:

`cmd.exe /d /c 'assoc {{.txt}}'`
<!-- mant:tldr:end -->

# ftype

## Overview

`ftype` is a `cmd.exe` builtin that displays or changes the classic open command
for a file-type/ProgID name. It complements `assoc`, which maps an extension to
that name. Query first; changes are persistent and security-sensitive.

## Syntax

```text
ftype [FILETYPE[=[OPEN-COMMAND-STRING]]]
```

Within an open command, `%0` or `%1` becomes the launched filename, `%*` all
arguments, `%2` onward individual extra arguments, and `%~N` all remaining
arguments starting at N.

## Command forms

<!-- mant:entries role=command case=insensitive -->
- `ftype`: List classic file-type open commands, query one `FILETYPE`, assign
  `FILETYPE=OPEN-COMMAND`, or remove it with `FILETYPE=` inside `cmd.exe`.

The stored string is later interpreted as a launch command. Preserve the
literal percent placeholders and quote the trusted executable and `"%1"`.

## PowerShell boundaries

There is no `ftype.exe`. PowerShell must invoke the builtin through
`cmd.exe /d /c`, where percent signs, quotes, and metacharacters receive Cmd
parsing before registration. Avoid constructing this string from untrusted
data; after a change check the child exit code, query the exact stored value,
and test only a dedicated safe extension/file type.

## Common mistakes

### Running it directly in PowerShell

There is no `ftype.exe`; use `cmd.exe /d /c`. PowerShell percent syntax and cmd
percent substitutions must not be mixed casually.

### Failing to quote the executable and filename placeholder

An open command normally needs an absolute, trusted executable path and quoted
`"%1"`. Missing quotes breaks paths with spaces and can create command-line
injection or executable-resolution risks.

### Treating `%1` as a batch argument during registration

The string is stored for later shell substitution, but extra cmd/PowerShell
parsing can consume percent signs or quotes while setting it. Inspect the exact
stored command afterward and launch a safe test file.

### Assuming `ftype` controls modern user defaults

It registers a classic open command; protected per-user defaults and policy can
take precedence. Use supported Settings or managed default-association flows.

### Registering a script interpreter without a trust boundary

Opening a file can execute code. Restrict the extension, interpreter path,
arguments, working-directory assumptions, and file provenance.

## Version and platform differences

This builtin is Windows-only. Default-app behavior varies across Windows
versions and management policy even when the classic command remains present.

## Related documents

- [assoc](assoc.md)
- [cmd](cmd.md)
- [path](path.md)

## Sources and license

This original guide was adapted from Microsoft's official
[ftype reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ftype)
and current Windows app-default guidance. The placeholder quoting failure is
also evidenced by
[FType Script omitting "%1" when running](https://stackoverflow.com/questions/39027059/ftype-script-omitting-1-when-running).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
