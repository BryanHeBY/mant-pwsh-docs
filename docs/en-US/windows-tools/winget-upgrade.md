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
- `-m PATH`, `--manifest PATH`: Upgrade using a reviewed local manifest or manifest directory.
- `--id ID`: Select one package identifier.
- `--name NAME`, `--moniker MONIKER`: Select by display name or moniker only when exact identity is verified separately.
- `-e`, `--exact`: Require exact selection.
- `-v VERSION`, `--version VERSION`: Request one exact source-provided target version.
- `-s SOURCE`, `--source SOURCE`: Restrict the upgrade candidate to one configured source.
- `--scope SCOPE`, `--architecture ARCHITECTURE`, `--installer-type TYPE`: Restrict installer selection to reviewed deployment characteristics.
- `--locale LOCALE`: Select an installer locale where available.
- `-l LOCATION`, `--location LOCATION`: Request an upgrade location only where the installer supports it.
- `-o FILE`, `--log FILE`: Request an installer log path where the selected installer supports it.
- `--custom ARGUMENTS`: Add reviewed arguments after WinGet's normal installer switches.
- `--override ARGUMENTS`: Replace WinGet's normal installer arguments; this substantially changes the manifest contract.
- `-r`, `--recurse`, `--all`: Upgrade every eligible detected package, creating a multi-installer partial-failure boundary.
- `-u`, `--unknown`, `--include-unknown`: Include packages whose current version cannot be determined reliably.
- `--pinned`, `--include-pinned`: Include packages otherwise excluded by non-blocking pin behavior where supported.
- `--purge`: Delete the portable package directory during the applicable upgrade workflow; review data-retention impact.
- `--skip-dependencies`: Skip dependency processing only when dependencies are managed and verified separately.
- `--ignore-security-hash`: Bypass an installer hash mismatch; this weakens a security control and should not be routine automation.
- `--ignore-local-archive-malware-scan`: Skip the malware scan for a local archive-manifest operation; require independent verification.
- `--uninstall-previous`: Request uninstall of the previous version where the manifest supports it.
- `-i`, `--interactive`: Request interactive installer behavior.
- `-h`, `--silent`: Request silent installer behavior; it is package-specific.
- `--accept-package-agreements`, `--accept-source-agreements`: Accept reviewed agreements for unattended work.
- `--force`: Continue through selected non-security checks without proving upgrade safety.
- `--allow-reboot`: Permit installer-triggered restart inside an approved maintenance window.
- `--header HEADER`: Send a reviewed HTTP header to a REST package source; do not expose credentials in process arguments or logs.
- `--authentication-mode MODE`: Choose `silent`, `silentPreferred`, or `interactive` source authentication behavior.
- `--authentication-account ACCOUNT`: Select the account used for source authentication.
- `--disable-interactivity`: Disable prompts for unattended execution.

## Execution and diagnostics options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display help for this subcommand without selecting or upgrading a package.
- `--wait`: Wait for a key press before the client exits; avoid it in unattended automation.
- `--logs`, `--open-logs`: Open the WinGet log directory in the interactive desktop.
- `--verbose`, `--verbose-logs`: Enable verbose WinGet logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warning display; it does not make an upgrade safe.
- `--proxy URL`: Use the specified proxy for this invocation; protect credentials embedded in a proxy URL.
- `--no-proxy`: Disable proxy use for this invocation.

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

## Runtime evidence

A dual-collector local help audit against WinGet `1.29.280` matched all 47
printed `upgrade --help` long options to ManT entries. It ran no inventory,
source query, installer, download, agreement, package selection, upgrade, or
restart operation. Eligibility, pins, detection, rollback, logs, and
post-upgrade state remain outside this option-surface evidence.

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
