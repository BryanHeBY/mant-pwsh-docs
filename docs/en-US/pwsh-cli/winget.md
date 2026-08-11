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

## PowerShell use

Do not confuse `winget` with a PowerShell cmdlet. Pass each option and value
as a separate argument, check `$LASTEXITCODE` promptly, and do not parse
human-formatted output as a stable API. When an installed client supports a
structured output option for the specific command, validate its schema and
version before consuming it in automation.

Run an elevated PowerShell only when the target installer or organizational
policy requires it. Avoid running bulk changes with a broad administrator
token merely because one package may need elevation.

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
paths are recorded in `upstream/cli.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
