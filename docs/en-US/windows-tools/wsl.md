<!-- mant:tldr:start -->
# wsl

> Install, configure, and start Windows Subsystem for Linux distributions from Windows.
> More information: https://learn.microsoft.com/windows/wsl/.

- Show installed distributions and WSL versions:

`wsl --list --verbose`

- Install the default WSL distribution:

`wsl --install`

- Run one command in a chosen distribution:

`wsl --distribution {{distribution-name}} -- {{command}}`
<!-- mant:tldr:end -->

# wsl

## Synopsis

```text
wsl [--install] [--list] [--distribution NAME] [-- COMMAND]
```

`wsl.exe` manages Windows Subsystem for Linux distributions and runs Linux
commands from Windows. It is a Windows-native command that starts a Linux
environment; both Windows and Linux quoting, paths, identities, and exit codes
can matter in one invocation.

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

## Related documents

- [where](where.md)
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
