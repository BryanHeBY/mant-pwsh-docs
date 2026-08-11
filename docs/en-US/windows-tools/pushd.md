<!-- mant:tldr:start -->
# pushd

> Save the current cmd directory and change to a local or UNC directory.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pushd.

- Enter a directory and save the current location:

`pushd "{{C:\path\directory}}"`

- Enter a UNC share using cmd's temporary drive mapping:

`pushd "{{\\server\share\directory}}"`

- Return and remove any temporary mapping created by `pushd`:

`popd`
<!-- mant:tldr:end -->

# pushd

## Overview

`pushd` saves the current directory on a per-`cmd.exe` stack, then changes to
another directory. With command extensions, a UNC target receives the highest
available temporary drive letter starting at Z:.

## Syntax

```text
pushd [PATH]
```

Use `popd` in the same cmd process to restore the saved directory and remove a
temporary UNC mapping.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `pushd`: Push the current Cmd directory and change to the supplied local or
  UNC path, creating a temporary drive mapping for UNC when extensions allow.

## PowerShell boundaries

PowerShell's `Push-Location`/`Pop-Location` stack is separate and can use UNC
filesystem locations directly. Cmd's stack and temporary mapping exist only
inside one `cmd.exe`, so do not split `pushd`, the dependent operation, and
`popd` across child invocations. Return an explicit exit code to PowerShell and
ensure cleanup executes on every batch path.

## Common mistakes

### Using `cd` for a UNC current directory

Cmd normally cannot use a UNC path as its current directory. `pushd` is the
documented temporary-mapping mechanism when extensions are enabled.

### Forgetting `popd`

Early `goto`, `exit`, or error paths can leave the stack unbalanced and a
temporary mapping alive for the cmd process. Centralize cleanup or pair the
commands in a small called subroutine.

### Running `pushd` and `popd` in different shells

The stack belongs to one `cmd.exe`. Separate `cmd /c` calls cannot share it,
and PowerShell's `Push-Location` stack is unrelated.

### Assuming a particular temporary drive letter

Drive availability changes and mappings are allocated from the highest unused
letter. Use the resulting current directory; never hard-code Z:.

### Treating access as authentication

The current user/session must already have network access. Do not place
credentials in command strings; use approved identity and share mechanisms.

## Version and platform differences

Local stack behavior is Windows cmd syntax. UNC mapping and automatic cleanup
require command extensions, enabled by default.

## Related documents

- [popd](popd.md)
- [cmd.exe](cmd.exe.md)
- [path](path.md)

## Sources and license

This original guide was adapted from Microsoft's official
[pushd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pushd).
The high-frequency UNC use case is evidenced by
[cmd does not support UNC paths as current directories](https://stackoverflow.com/questions/24482801/cmd-does-not-support-unc-paths-as-current-directories-pushd).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
