<!-- mant:tldr:start -->
# wsl.exe

> Install, configure, and start Windows Subsystem for Linux distributions from Windows.
> More information: https://learn.microsoft.com/windows/wsl/.

- Show installed distributions and WSL versions:

`wsl --list --verbose`

- Install the default WSL distribution:

`wsl --install`

- Run one command in a chosen distribution:

`wsl --distribution {{distribution-name}} -- {{command}}`
<!-- mant:tldr:end -->

# wsl.exe

## Synopsis

```text
wsl [--install] [--list] [--distribution NAME] [-- COMMAND]
```

`wsl.exe` manages Windows Subsystem for Linux distributions and runs Linux
commands from Windows. It is a Windows-native command that starts a Linux
environment; both Windows and Linux quoting, paths, identities, and exit codes
can matter in one invocation.

## Important options

<!-- mant:entries role=option case=sensitive -->
- `--status`: Show general WSL configuration and kernel/default state.
- `--version`: Show WSL component versions where the Store-serviced WSL supports it.
- `--install`: Enable/install WSL and a selected/default distribution on a supported Windows host.
- `--update`: Update WSL components according to installed-client and policy options.
- `--shutdown`: Terminate all running distributions and the WSL 2 utility virtual machine.
- `-l`, `--list`: List installed distributions; modifiers can show verbose, running, quiet, or online results.
- `-v`, `--verbose`: With `--list`, include distribution state and WSL version.
- `-o`, `--online`: With `--list`, show distributions available through the configured online catalog.
- `-d DISTRIBUTION`, `--distribution DISTRIBUTION`: Select the exact distribution for a Linux command or operation.
- `-u USER`, `--user USER`: Run the Linux command as one user in the selected distribution.
- `-e COMMAND`, `--exec COMMAND`: Execute a Linux command without using the distribution's default shell.
- `--cd DIRECTORY`: Set the initial directory for a launched Linux command where supported.
- `--export DISTRIBUTION FILE`: Export one distribution to an archive or supported VHD format.
- `--import DISTRIBUTION LOCATION FILE`: Register a new distribution from an archive at an explicit Windows location.
- `--import-in-place DISTRIBUTION FILE`: Register a supported ext4 VHDX in place without copying it.
- `--unregister DISTRIBUTION`: Permanently unregister and delete one distribution's WSL storage.
- `-t DISTRIBUTION`, `--terminate DISTRIBUTION`: Stop all processes in one distribution.
- `-s DISTRIBUTION`, `--set-default DISTRIBUTION`: Select the default distribution for later unqualified launches.
- `--set-version DISTRIBUTION VERSION`: Convert one distribution between supported WSL versions.
- `--set-default-version VERSION`: Select the default WSL version for newly installed distributions.

A standalone `--` ends WSL option parsing before the Linux command.

## Install and inventory

Check the installed state before changing it:

```powershell
wsl --status
wsl --list --verbose
```

On supported Windows versions, `wsl --install` enables required components and
installs a default distribution. It can require elevation, restart, network
access, organization approval, and a first-run Linux user setup. Use
`wsl --list --online` to review available distributions where supported, and
prefer an explicitly chosen distribution in managed automation.

## Run a Linux command

Use `--distribution` to name the intended Linux environment and `--` to end
WSL option parsing before a Linux command:

```powershell
wsl --distribution Ubuntu -- uname -a
if ($LASTEXITCODE -ne 0) {
    throw "WSL command failed with exit code $LASTEXITCODE"
}
```

The process after `--` is parsed by the Linux shell or program, not by
PowerShell. Pass simple values as separate arguments, avoid nested command
strings where possible, and test paths with spaces or non-ASCII characters.

## Boundaries and safety

Windows paths, Linux paths, line endings, permissions, user identity, mounted
filesystems, networking, and tool versions differ across the boundary. Do not
assume that a successful interactive `wsl` session proves a scheduled task or
CI process has the same distribution, default user, or environment.

Treat `wsl --install`, distribution import/export, and commands that change
Linux filesystems as administrative operations. Back up workloads and verify
the exact distribution before a reset, unregister, or bulk command.

## PowerShell boundaries

PowerShell parses the Windows-side arguments; WSL then selects a distribution,
and the Linux program or shell parses its own arguments. Pass simple arguments
separately, use `--` deliberately, and capture `$LASTEXITCODE` before another
native process overwrites it.

## Version and availability

WSL features depend on Windows build, Store/inbox WSL version, virtualization,
policy, architecture, kernel, and distribution. Use `wsl --help`, `--status`,
and `--version` where supported rather than assuming a recent web example
exists on an older managed host.

## Common mistakes

### Running in the default distribution unintentionally

Name the distribution and user in automation. Defaults can change independently
and interactive configuration is not a deployment contract.

### Treating Windows and Linux paths as interchangeable

Choose the intended filesystem side, case and permission model, and translate
paths explicitly. Performance and metadata differ across mounted boundaries.

### Unregistering as a reset shortcut

`--unregister` deletes that distribution's registered storage. Export and
verify recovery artifacts before an approved removal.

## Related documents

- [where.exe](where.exe.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original ManT-oriented guide was adapted from the official
[WSL installation](https://learn.microsoft.com/windows/wsl/install) and
[basic commands](https://learn.microsoft.com/windows/wsl/basic-commands)
documentation. It emphasizes the Windows/Linux process boundary and explicit
distribution selection. Exact upstream revision and paths are recorded in
`upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
