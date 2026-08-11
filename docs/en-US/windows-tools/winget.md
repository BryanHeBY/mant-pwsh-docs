<!-- mant:tldr:start -->
# winget

> Manage Windows packages with Windows Package Manager.
> More information: https://learn.microsoft.com/windows/package-manager/winget/.

- Show the installed client version:

`winget --version`

- Update package-source metadata:

`winget source update`

- Search and then inspect a package before installing it:

`winget search {{query}}; winget show --id {{package-id}} --exact`
<!-- mant:tldr:end -->

# winget

## Synopsis

```text
winget <command> [options]
```

Windows Package Manager (`winget`) discovers, installs, upgrades, lists, and
uninstalls Windows software. It is a native Windows executable, so it uses its
own options, writes text or structured output, and reports its status through
`$LASTEXITCODE` when invoked from PowerShell.

## Before changing software

Check the client and available sources first. Feature availability, source
behavior, and command options can depend on the installed App Installer and
Windows release.

## Commands

<!-- mant:entries role=command case=insensitive -->
- `install`: Install a selected package after resolving its manifest and installer.
- `show`: Display package metadata without installing it.
- `source`: List, add, update, reset, remove, or export configured package sources.
- `search`: Find packages in configured sources by query or field filters.
- `list`: Inventory installed packages visible to WinGet and correlate available upgrades.
- `upgrade`: List or apply package upgrades; a broad upgrade requires explicit review of every target.
- `uninstall`: Remove a selected installed package through its registered uninstall mechanism.
- `hash`: Calculate a SHA-256 hash for an installer during manifest authoring.
- `validate`: Validate a package manifest for repository submission.
- `settings`: Open or export WinGet settings according to the installed client.
- `features`: Show experimental-feature status for the client.
- `export`: Write a package list for later review or import; it is not a full machine backup.
- `import`: Install packages declared by an import file and selected sources.
- `pin`: Manage package pins that influence upgrade selection.
- `configure`: Apply a reviewed Windows configuration file through the installed configuration engine.
- `download`: Download a selected installer without running it.
- `repair`: Invoke a selected package's supported repair mechanism.
- `dscv3`: Run DSC v3 resource operations when supported by the installed client.

## Global options

<!-- mant:entries role=option case=insensitive -->
- `-v`, `--version`: Print the installed WinGet client version.
- `--info`: Print client, package, policy, license, privacy, and environment information useful for diagnostics.
- `-?`, `--help`: Show global or selected-command help for the installed version.
- `--wait`: Wait for a key press before the client exits; unsuitable for unattended automation.
- `--logs`, `--open-logs`: Open the default diagnostic log location in an interactive session.
- `--verbose`, `--verbose-logs`: Enable verbose logging; protect logs that can contain environment or installer details.
- `--nowarn`, `--ignore-warnings`: Suppress warning display; do not use it to bypass unreviewed risk in automation.
- `--disable-interactivity`: Disable interactive prompts so unattended work fails instead of waiting for input.
- `--proxy URI`: Use an explicit proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

```powershell
winget --version
winget source list
winget source update
if ($LASTEXITCODE -ne 0) {
    throw "winget source update failed with exit code $LASTEXITCODE"
}
```

Search results are not a complete identity or trust decision. Confirm an exact
package identifier, publisher, source, installer type, and version before
changing a managed device. Review any installer agreements and enterprise
policy that apply to the current user or device.

## Command flow

Use [winget search](winget-search.md) to discover candidates, then
[winget show](winget-show.md) with `--id` and `--exact` to inspect one package.
Use [winget install](winget-install.md), [winget upgrade](winget-upgrade.md),
[winget list](winget-list.md), and [winget uninstall](winget-uninstall.md) for
the lifecycle operation.

Prefer exact identifiers in scripts. Names are for interactive discovery and
can match multiple packages or change as source metadata evolves.

## PowerShell boundaries

Do not confuse `winget` with a PowerShell cmdlet. Pass each option and value
as a separate argument, check `$LASTEXITCODE` promptly, and do not parse
human-formatted output as a stable API. When an installed client supports a
structured output option for the specific command, validate its schema and
version before consuming it in automation.

Run an elevated PowerShell only when the target installer or organizational
policy requires it. Avoid running bulk changes with a broad administrator
token merely because one package may need elevation.

## Version and availability

WinGet is supported on Windows 10 version 1809 or later, Windows 11, and
Windows Server 2025 when the required App Installer/client is registered.
Commands and options depend on the independently serviced WinGet version, so
the installed `--help` and `--version` are authoritative for a target host.

## Common mistakes

### Selecting a package by display name alone

Use an exact ID and source after reviewing publisher, version, installer type,
architecture, scope, agreements, and policy. Search ranking is not identity.

### Treating a successful client exit as application verification

Installers can have their own reboot, elevation, repair, or post-install
behavior. Verify the installed package and intended application state.

### Running broad upgrades under an administrator token

Inventory and review every target first. Elevate only when the selected
installer and organizational policy require it.

## Related documents

- [winget search](winget-search.md)
- [winget show](winget-show.md)
- [winget install](winget-install.md)
- [winget upgrade](winget-upgrade.md)
- [winget uninstall](winget-uninstall.md)
- [winget list](winget-list.md)

For PowerShell invocation boundaries, consult the `native-commands` document
in the selected `pwsh51` or `pwsh7` ManT source.

## Sources and license

This original ManT-oriented guide was adapted from the official
[Windows Package Manager documentation](https://learn.microsoft.com/windows/package-manager/winget/)
and its locked source repository. It emphasizes exact package identity, native
exit codes, and PowerShell automation boundaries. Exact upstream revision and
paths are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
