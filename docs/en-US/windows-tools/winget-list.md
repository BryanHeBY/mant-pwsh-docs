<!-- mant:tldr:start -->
# winget-list

> List Windows applications detected by Windows Package Manager.
> More information: https://learn.microsoft.com/windows/package-manager/winget/list.

- List detected installed packages:

`winget list`

- Find one installed package by exact identifier:

`winget list --id {{package-id}} --exact`

- Show installed packages with an upgrade available:

`winget list --upgrade-available`
<!-- mant:tldr:end -->

# winget list

## Synopsis

```text
winget list [query] [--id ID] [--name NAME] [--source SOURCE]
            [--exact] [--upgrade-available]
```

`winget list` reports applications the Windows Package Manager client can
detect as installed. It is an inventory view, not a universal software asset
database.

## Inventory options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Filter detected packages by a free-form query.
- `--id ID`: Filter by package identifier; combine with `--exact` for automation.
- `--name NAME`, `--moniker MONIKER`: Filter by display name or source moniker.
- `--tag TAG`: Filter installed-package correlations by a source-defined package tag.
- `--cmd COMMAND`, `--command COMMAND`: Filter by a command associated with source package metadata.
- `-s SOURCE`, `--source SOURCE`: Correlate detected packages with one configured source.
- `-n COUNT`, `--count COUNT`: Limit displayed matches to between 1 and 1000 results.
- `-e`, `--exact`: Require exact matching for the selected field.
- `--scope SCOPE`: Restrict results to user or machine installation scope where detection exposes it.
- `--upgrade-available`: Show packages for which current source metadata reports an available upgrade.
- `-u`, `--unknown`, `--include-unknown`: Include packages whose installed version cannot be determined; current help limits this to `--upgrade-available` queries.
- `--pinned`, `--include-pinned`: Include packages with upgrade-blocking pins; current help limits this to `--upgrade-available` queries.
- `--details`: Show detailed, `show`-like information for each matched installed package instead of the normal table.
- `--sort PROPERTY`: Sort by a property; repeat the option for multiple keys. This appears in the locally reviewed WinGet 1.29 help but not the cited 2026-07-19 page.
- `--asc`, `--ascending`: Sort in ascending order in clients that provide `--sort`.
- `--desc`, `--descending`: Sort in descending order in clients that provide `--sort`.
- `--header HEADER`: Send a reviewed HTTP header to a REST package source; do not expose credentials in process arguments or logs.
- `--authentication-mode MODE`: Choose `silent`, `silentPreferred`, or `interactive` source authentication behavior.
- `--authentication-account ACCOUNT`: Select the account used for source authentication.
- `--accept-source-agreements`: Accept reviewed source agreements for unattended inventory.

## Execution and diagnostics options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display help for this subcommand without enumerating installed packages.
- `--wait`: Wait for a key press before the client exits; avoid it in unattended automation.
- `--logs`, `--open-logs`: Open the WinGet log directory in the interactive desktop.
- `--verbose`, `--verbose-logs`: Enable verbose WinGet logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warning display; it does not make inventory complete.
- `--disable-interactivity`: Disable interactive prompts so unattended inventory does not wait for input.
- `--proxy URL`: Use the specified proxy for this invocation; protect credentials embedded in a proxy URL.
- `--no-proxy`: Disable proxy use for this invocation.

## Interpret matches carefully

Use an exact ID whenever a script acts on the output:

```powershell
winget list --id Microsoft.PowerShell --exact
```

Detection depends on the client, package sources, installer registration,
current user, architecture, and Windows state. An absent result does not prove
software is absent, and a displayed entry does not necessarily describe every
installed component or configuration.

`--upgrade-available` is useful for maintenance review, but it reflects the
current sources and client knowledge. Inspect each candidate with `winget show`
before approving an upgrade.

## Automation

Avoid scraping formatted columns as a stable interface. If an installed client
offers a structured output for the needed workflow, pin/test its version and
validate the schema. Capture exit status and distinguish a query failure from
a zero-match result.

## PowerShell boundaries

Formatted list output is not a typed inventory API. Check `$LASTEXITCODE`,
retain source/client context, and avoid selecting a destructive follow-up by
column position.

## Version and availability

Detection and options depend on WinGet/App Installer version, current user,
architecture, registration data, source metadata, pins, and policy.

## Common mistakes

### Treating absence as proof software is not installed

Portable apps, unregistered components, another user's installation, source
failure, or unsupported detection can all be absent from this view.

### Treating `--upgrade-available` as approval

It is a candidate report. Inspect exact package metadata, change policy,
compatibility, and rollback before upgrading.

## Runtime evidence

A 2026-08-12 help-only audit matched all 37 WinGet 1.29.280 long options to
local ManT entries under both PowerShell collectors; locally present
sort/direction options are explicitly labeled as absent from the
contemporaneous official page. No installed-package or source inventory ran.

## Related documents
- [winget upgrade](winget-upgrade.md)
- [winget uninstall](winget-uninstall.md)
- [winget search](winget-search.md)

## Sources and license

This original command guide was adapted from the official
[winget list documentation](https://learn.microsoft.com/windows/package-manager/winget/list).
It emphasizes inventory limits and exact identifiers. Exact upstream revision
and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
