<!-- mant:tldr:start -->
# start

> Built-in Windows PowerShell 5.1 alias for `Start-Process`, not the `cmd.exe` builtin.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-5.1.

- Resolve every command named `start` in the current session:

`Get-Command start -All`

- Use the unambiguous full cmdlet name:

`Start-Process -FilePath {{app.exe}} -ArgumentList '{{arguments}}'`

- Invoke the different cmd builtin explicitly:

`cmd.exe /d /c 'start "" {{app.exe}}'`
<!-- mant:tldr:end -->

# start

## Meaning

`start` is a built-in Windows PowerShell 5.1 alias for `Start-Process`. It is
not the `start` builtin implemented by `cmd.exe`; the two commands have
different syntax, parsing, waiting, and output behavior.

## Command resolution

```powershell
Get-Command start -All
Get-Alias start
```

Profiles and functions can shadow the built-in alias. Use the full cmdlet name
in reviewed scripts.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-FilePath PATH`: Select the executable, document, or command to start.
- `-ArgumentList ARGUMENTS`: Supply process arguments; Windows PowerShell joins array elements into one string for the target parser.
- `-WorkingDirectory PATH`: Set the new process's initial working directory.
- `-Wait`: Wait for the started process and its descendants to exit before returning.
- `-PassThru`: Return a process object instead of producing no output.
- `-NoNewWindow`: Reuse the current console; it cannot be combined with `-WindowStyle`.
- `-RedirectStandardInput PATH`, `-RedirectStandardOutput PATH`, `-RedirectStandardError PATH`: Connect standard streams to files.
- `-Credential CREDENTIAL`: Start with another Windows credential where the operating system permits it.
- `-Verb VERB`: Request a ShellExecute verb such as `RunAs`; it belongs to the shell-execute parameter set.

## Version and availability

The alias and cmdlet are built into Windows PowerShell 5.1 on Windows. Do not
infer PowerShell 7 cross-platform behavior from this interface.

## Common mistakes

### Supplying cmd's empty title argument

`start "" /wait app.exe` entered in Windows PowerShell binds arguments to
`Start-Process`, not cmd. Use `Start-Process -Wait app.exe` or invoke the cmd
builtin through `cmd.exe /d /c`.

### Copying a PowerShell alias into a batch file

A `.cmd` or `.bat` file resolves `start` as the cmd builtin. PowerShell named
parameters such as `-FilePath` and `-PassThru` are invalid there.

### Using the alias in durable scripts

Prefer `Start-Process` so a reviewer can see the exact command and parameter
contract without depending on ambient aliases.

## Full command

See [Start-Process](Start-Process.md) for arguments, streams, credentials,
waiting, process objects, and Windows PowerShell 5.1 constraints.

## Related documents

- [Get-Command](Get-Command.md)
- [about_Profiles](about_Profiles.md)
- [native commands](native-commands.md)

## Sources and license

This original alias guide was adapted from Microsoft's official
[Start-Process reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-5.1)
and [about_Aliases](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-5.1).
Exact locked provenance is recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
