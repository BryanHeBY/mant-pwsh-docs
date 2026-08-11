<!-- mant:tldr:start -->
# winget-upgrade

> Review and upgrade installed Windows packages with Windows Package Manager.
> More information: https://learn.microsoft.com/windows/package-manager/winget/upgrade.

- List packages with available upgrades:

`winget upgrade`

- Upgrade one exact package:

`winget upgrade --id {{package-id}} --exact`

- Upgrade all eligible packages after an approved maintenance review:

`winget upgrade --all`
<!-- mant:tldr:end -->

# winget upgrade

## Synopsis

```text
winget upgrade [query] [--id ID] [--exact] [--all]
                [--source SOURCE] [--version VERSION] [--silent]
```

`winget upgrade` finds newer package versions and can upgrade one package or a
set of eligible packages. An upgrade is a change operation: review it as
carefully as an initial installation.

## Upgrade one package

Start with the report, inspect the package, and select an exact identifier:

```powershell
winget upgrade
winget show --id Microsoft.PowerShell --exact
winget upgrade --id Microsoft.PowerShell --exact
if ($LASTEXITCODE -ne 0) {
    throw "winget upgrade failed with exit code $LASTEXITCODE"
}
```

Version availability and installer options depend on the configured source and
client. Record the source and desired version when repeatability matters.

## Bulk upgrades

`--all` can invoke multiple independent installers, each with its own
prerequisites, agreements, restart behavior, and failure modes. Use it only in
an approved maintenance process with backups, staged testing, logging, and a
clear policy for partial success. It is not a substitute for endpoint
configuration management.

Silent operation and agreement switches should be explicit and tested against
the target package manifests. Do not hide an upgrade behind a profile or
unreviewed logon script.

## Related documents

- [winget list](winget-list.md)
- [winget show](winget-show.md)
- [winget install](winget-install.md)
- [winget uninstall](winget-uninstall.md)

## Sources and license

This original command guide was adapted from the official
[winget upgrade documentation](https://learn.microsoft.com/windows/package-manager/winget/upgrade).
It emphasizes one-package review and controlled bulk maintenance. Exact
upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
