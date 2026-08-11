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

## Selection and upgrade options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Select a package by free-form query; prefer exact ID in automation.
- `--id ID`: Select one package identifier.
- `-e`, `--exact`: Require exact selection.
- `-v VERSION`, `--version VERSION`: Request one exact source-provided target version.
- `-s SOURCE`, `--source SOURCE`: Restrict the upgrade candidate to one configured source.
- `--scope SCOPE`, `--architecture ARCHITECTURE`, `--installer-type TYPE`: Restrict installer selection to reviewed deployment characteristics.
- `--all`: Upgrade every eligible detected package, creating a multi-installer partial-failure boundary.
- `--include-unknown`: Include packages whose current version cannot be determined reliably.
- `--include-pinned`: Include packages otherwise excluded by non-blocking pin behavior where supported.
- `--uninstall-previous`: Request uninstall of the previous version where the manifest supports it.
- `-i`, `--interactive`: Request interactive installer behavior.
- `-h`, `--silent`: Request silent installer behavior; it is package-specific.
- `--accept-package-agreements`, `--accept-source-agreements`: Accept reviewed agreements for unattended work.
- `--force`: Continue through selected non-security checks without proving upgrade safety.
- `--allow-reboot`: Permit installer-triggered restart inside an approved maintenance window.
- `--disable-interactivity`: Disable prompts for unattended execution.

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

## PowerShell boundaries

Call WinGet as a native process, preserve exact selection arguments, and check
`$LASTEXITCODE`. For `--all`, one client status must be correlated with each
package's installer log and post-upgrade state.

## Version and availability

Upgrade eligibility and options depend on client version, installed detection,
source metadata, pins, manifest installer choice, and policy.

## Common mistakes

### Running `--all` without a partial-failure plan

Inventory candidates, stage testing, coordinate restarts, and verify each
application. Bulk invocation is not atomic.

### Including unknown versions blindly

An unknown installed version weakens comparison and rollback reasoning.
Identify the product/version independently before opting it into upgrade.

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
