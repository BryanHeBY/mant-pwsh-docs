<!-- mant:tldr:start -->
# wsl.exe

> Inventory the exact WSL version and registered distributions before starting
> Linux code or changing components, storage, defaults, or distribution state.
> More information: https://learn.microsoft.com/windows/wsl/.

- Show installed distributions and WSL versions:

`wsl --list --verbose`

- Show installed WSL, kernel, WSLg, graphics/remote-desktop, and Windows
  component versions without updating them:

`wsl.exe --version`

- Run one command in a chosen distribution:

`wsl --distribution {{distribution-name}} -- {{command}}`
<!-- mant:tldr:end -->

# wsl.exe

## Synopsis and command families

```text
wsl.exe [Argument] [Options...] [CommandLine]
```

`wsl.exe` manages Windows Subsystem for Linux distributions and runs Linux
commands from Windows. It is a Windows-native command that starts a Linux
environment; both Windows and Linux quoting, paths, identities, and exit codes
can matter in one invocation.

Installed WSL 2.7.11.0 exposes five distinct surfaces:

| Surface | Representative operations |
| --- | --- |
| Inventory and servicing | `--help`, `--status`, `--version`, `--update`, `--install`, `--uninstall` |
| Distribution inventory/lifecycle | `--list`, `--set-default`, `--set-version`, `--terminate`, `--unregister`, import, export |
| Linux execution and identity | `--distribution`, `--distribution-id`, `--user`, `--system`, `--exec`, `--shell-type`, `--cd`, `--` |
| Distribution-VHD management | `--manage` and its modifiers |
| Physical/VHD attachment | `--mount`, `--unmount` |

The exact set is serviced independently of the inbox `wsl.exe` file version.
Use the target's `--help`; do not synthesize newer switches for an older host.

## Inventory and servicing

<!-- mant:entries role=option case=sensitive -->
- `--help`: Print installed WSL command help. On some Windows builds the native
  text is UTF-16LE and valid help can return a nonzero status.
- `--status`: Show general WSL configuration and kernel/default state.
- `--version`: Show separately serviced WSL, kernel, WSLg and related component
  versions where supported. In installed 2.7.11.0, top-level `-v` is its short
  form; do not confuse it with `--list -v`.
- `--install`: Enable/install WSL and a selected/default distribution on a supported Windows host.
- `--update`: Update WSL components according to installed-client and policy options.
- `--uninstall`: Remove the WSL package on versions that expose this top-level
  operation; it is not the same as unregistering one distribution.
- `--pre-release`: With `--update`, select a prerelease WSL servicing channel.
- `--web-download`: With supported install/update forms, download from the
  documented web source instead of the Microsoft Store path.
- `--no-distribution`: With installation, omit the default Linux distribution.
- `--no-launch`: With distribution installation, do not launch its first-run setup.
- `--enable-wsl1`: With supported installation, also enable the WSL 1 optional component.
- `--from-file`: Install a distribution from one reviewed local distribution file.
- `--location`: Select an explicit new distribution installation directory.
- `--name`: Supply the documented name in install or mount contexts; interpret
  it only under the exact parent operation.
- `--fixed-vhd`: Request a fixed-size VHD for a supported new installation.
- `--vhd-size`: Select the requested new distribution VHD size.
- `--legacy`: Select the installed client's legacy distribution-install route.

Install/update/uninstall and their modifiers can change Windows optional
features, packages, services, kernels, distributions, files, policy-visible
state, and restart requirements. They are never discovery shortcuts.

## Distribution inventory and lifecycle

<!-- mant:entries role=option case=sensitive -->
- `--shutdown`: Terminate all running distributions and the WSL 2 utility virtual machine.
- `--force`: With supported shutdown behavior, force the shared WSL 2 utility
  virtual machine to stop rather than assuming an orderly workload boundary.
- `--list`: List distributions; installed-client modifiers can show all,
  running, quiet, verbose, or online results.
- `--all`: With `--list`, include distributions that are being installed or uninstalled.
- `--running`: With `--list`, include only running distributions.
- `--quiet`: With `--list`, emit distribution names only.
- `--verbose`: With `--list`, include distribution state and WSL version. Its
  contextual short form `-v` collides with top-level version shorthand.
- `--online`: With `--list`, query distributions offered by the configured
  online catalog; this is a network/policy operation, not local inventory.
- `--set-default`: Select the default distribution for later unqualified launches.
- `--set-version`: Convert one exact distribution between supported WSL versions.
- `--set-default-version`: Select the default WSL version for newly installed distributions.
- `--terminate`: Stop all processes in one exact distribution.
- `-d DISTRIBUTION`, `--distribution DISTRIBUTION`: Select the exact distribution for a Linux command or operation.
- `--export`: Export one `DISTRIBUTION` to an archive or supported VHD `FILE`.
- `--import`: Register a `DISTRIBUTION` from an archive at an explicit Windows `LOCATION`.
- `--import-in-place`: Register a `DISTRIBUTION` from a supported ext4 VHDX `FILE` without copying it.
- `--unregister DISTRIBUTION`: Permanently unregister and delete one distribution's WSL storage.
- `--format`: With export, select a supported tar-compression or VHD output format.
- `--vhd`: Under supported export/import/mount parents, treat the artifact as a VHD/VHDX rather than a tar archive or physical disk.

The common short forms `-l`, `-o`, `-s`, and `-t` are contextual aliases for
list, online, set-default, and terminate. Prefer long forms in generated
automation. Export can disclose an entire distribution; import/register and
version conversion mutate storage; unregister permanently deletes it.

## Linux process and identity selection

<!-- mant:entries role=option case=sensitive -->
- `--distribution-id`: Select a distribution by the installed client's GUID
  form where supported; do not persist an observed identifier across
  unregister/reimport without rediscovery.
- `--user`: Run the Linux command as one exact distribution user.
- `--system`: Run a shell for the system distribution, a privileged diagnostic
  context distinct from an ordinary user's distribution.
- `--exec`: Execute a Linux command directly rather than through the
  distribution's default shell.
- `--shell-type`: Select the installed standard, login, or no-shell parsing/environment behavior.
- `--cd`: Set the initial Windows or Linux directory under the installed path-conversion rules.

The common short forms `-d`, `-u`, and `-e` are contextual aliases. A standalone
`--` ends WSL option parsing before the Linux command.

## Distribution VHD and disk management

<!-- mant:entries role=option case=sensitive -->
- `--manage`: Select one exact registered distribution for a supported VHD/default-user management operation.
- `--move`: Move the selected distribution's storage to an explicit location.
- `--set-sparse`: Change whether its VHD uses sparse allocation; the required
  boolean and safety gates are version-specific and can include data-corruption warnings.
- `--set-default-user`: Change the default Linux user for one distribution.
- `--resize`: Resize one distribution's virtual disk to an explicit reviewed size.
- `--mount`: Attach and optionally mount one exact physical disk or VHD in WSL 2.
- `--unmount`: Detach one exact WSL 2 disk; omitting the disk can broaden the
  operation to every attached disk on supported versions.
- `--bare`: With mount, attach the disk without mounting a filesystem.
- `--type`: With mount, select the filesystem type instead of relying on its default.
- `--options`: Pass reviewed filesystem-specific mount options.
- `--partition`: Select one exact partition index rather than the default whole-disk interpretation.

Every operation in this section changes shared process, registration, storage,
filesystem, or attachment state. Discover durable disk/VHD/distribution
identity, stop affected workloads, back up and test recovery, and record
before/after topology. Never omit an optional-looking target until the exact
installed help proves the resulting scope.

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

WSL's Windows console output can be UTF-16LE. A byte-oriented or incorrectly
decoded native-process harness can produce NUL-filled mojibake even when the
command succeeds. Set the expected native encoding or capture bytes and decode
deliberately; preserve stdout, stderr and status independently. Installed
2.7.11.0 returned complete `--help` on stdout with status `-1`, so help validity
must be classified from payload and requested operation, not zero status alone.

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

Exact command discovery can return more than one entry: an inbox System32
`wsl.exe` launcher and a per-user app execution alias below
`%LOCALAPPDATA%\Microsoft\WindowsApps` can coexist. The latter is a
Windows-managed reparse point for the Store-serviced WSL package, not an
ordinary PE file whose version resource, signature, or hash should be read from
the alias path. Preserve `Get-Command wsl.exe -All -CommandType Application`
results, but use `wsl.exe --version` for the effective component surface and a
separate read-only registration query when needed:

```powershell
Get-AppxPackage -Name MicrosoftCorporationII.WindowsSubsystemForLinux |
    Select-Object Name, Version, PackageFullName, SignatureKind
```

Package registration does not prove which command path wins, whether the alias
is enabled, or whether WSL can start. An access failure while inspecting the
alias file is not evidence that WSL is absent or unsigned.

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

### Treating `--uninstall` as a synonym for `--unregister`

`--unregister` destroys one distribution's registered storage. Current
`--uninstall` is a top-level WSL package operation. Neither is an ordinary
application uninstall shortcut, and neither should be generated from a vague
request to “reset WSL.” Inventory package/component and every registered
distribution first, then design recovery for the exact intended layer.

### Using a short option without its parent context

On installed 2.7.11.0, top-level `-v` displays component versions while
`--list -v` requests verbose distribution inventory. Other short forms are
similarly parent-dependent. Prefer `--version` and `--list --verbose` in Agent
output so a reordered token cannot silently change meaning.

## Runtime evidence

Exact Get-Command -All also returned a zero-length per-user WindowsApps reparse
point for wsl.exe. Microsoft documents that location/object class as an MSIX
app execution alias and documents Store-serviced WSL separately, so the page
preserves both resolution rows while keeping alias, System32 launcher,
registered package, and effective WSL component version as distinct identities.

## Related documents
- [where.exe](where.exe.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original ManT-oriented guide was adapted from the official
[WSL installation](https://learn.microsoft.com/windows/wsl/install) and
[basic commands](https://learn.microsoft.com/windows/wsl/basic-commands)
documentation, the explanation of
[Store-serviced WSL](https://learn.microsoft.com/windows/wsl/compare-versions#wsl-in-the-microsoft-store),
and Microsoft's description of
[Windows app execution aliases](https://learn.microsoft.com/sysinternals/downloads/microsoft-store).
It emphasizes the Windows/Linux process boundary and explicit
distribution selection. Exact upstream revision and paths are recorded in
`upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
