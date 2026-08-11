<!-- mant:tldr:start -->
# setx

> Persist one reviewed user or machine environment variable for future processes; do not use `setx PATH "%PATH%;..."` because it combines scopes, expands references, and can irreversibly truncate the stored value.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/setx.

- Read the persistent user and machine values before changing either scope:

`'User','Machine' | ForEach-Object { [pscustomobject]@{ Scope = $_; Value = [Environment]::GetEnvironmentVariable('{{name}}', $_) } }`

- Persist one ordinary variable for the current user after recording its original value:

`setx.exe {{name}} "{{value}}"`

- Verify the stored user value exactly; open a new process to observe it through `$env:`:

`[Environment]::GetEnvironmentVariable('{{name}}', 'User')`
<!-- mant:tldr:end -->

# setx

## Overview

`setx.exe` creates, replaces, extracts or removes persistent User or Machine
environment-variable values. It changes the environment inherited by future
processes; it does not update the current PowerShell process. Its file/registry
extraction modes and remote credential options are legacy text interfaces.

## Core syntax

```text
setx NAME VALUE
setx NAME VALUE /m
setx NAME /k REGISTRY_PATH [/m]
setx /f FILE ...
setx /s COMPUTER [/u USER [/p PASSWORD]] ...
```

The default write scope is the current user. `/m` targets Machine scope and
normally requires elevation. Resolve the exact stored scope and existing value
before a write; a process's effective `$env:Path` is not either stored Path.

## Common mistakes

- Running `setx PATH "%PATH%;C:\Tools"`. `%PATH%` is the effective combination
  of Machine and User values, so this can duplicate one scope into the other.
  `setx` also expands embedded references and documents a 1,024-character write
  limit that crops and saves the result.
- Ignoring a truncation warning because the command also prints success. Save
  the exact original value and type first, and verify the stored result rather
  than the unchanged current-process environment.
- Expecting `$env:NAME` or `cmd /c set` in the current shell to change. Start a
  new child only after the write and compare persistent and inherited values.
- Using `/m` when only one user needs the value, or assuming elevation changes
  the current-user identity in the intended way.
- Using `setx NAME ""` without verifying deletion semantics and downstream
  behavior. Empty, absent and inherited values are not interchangeable.
- Putting a password in `/p`; command lines can be exposed through process,
  logging and history surfaces. Prefer authenticated remote management.
- Treating `/k` or `/f` extraction as typed data. Multi-string, expandable,
  numeric, delimiter, line-ending and coordinate conversions can lose meaning.

## PowerShell behavior

PowerShell expands `$env:*` before launching native tools, whereas `%NAME%` is
expanded only by `cmd.exe`. Prefer `[Environment]::GetEnvironmentVariable()` and
`SetEnvironmentVariable()` when explicit Process/User/Machine scope and long
values matter. Back up both stored Path scopes and preserve expandable references
before any Path change; avoid `setx` for Path edits.

Check `$LASTEXITCODE`, warnings and the stored value. A zero exit code does not
prove that existing applications received a change or that consumers resolve
the resulting value safely.

## Version and platform differences

`setx.exe` is Windows-only. Limits, environment broadcast/inheritance behavior,
registry types, remote access, elevation and supported extraction modes vary by
Windows version and target context. The official target help is authoritative
for the installed build.

## Related documents

- [set](set.md)
- [path](path.md)
- [systempropertiesadvanced](systempropertiesadvanced.md)
- [reg](reg.md)

## Sources and license

Microsoft's official [setx reference](https://learn.microsoft.com/windows-server/administration/windows-commands/setx)
defines syntax and explicitly documents future-process visibility, expansion
and truncation behavior. A highly viewed
[Stack Overflow Path question](https://stackoverflow.com/questions/19287379/how-do-i-add-to-the-windows-path-variable-using-setx-having-weird-problems)
records recurring scope duplication and data-loss failures; it is a demand and
mistake signal, not syntax authority. Exact sources and licenses are recorded in
`upstream/cli.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
