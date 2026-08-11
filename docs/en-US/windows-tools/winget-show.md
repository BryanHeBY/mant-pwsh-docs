<!-- mant:tldr:start -->
# winget-show

> Inspect metadata, versions, installers, and agreements for one Windows package.
> More information: https://learn.microsoft.com/windows/package-manager/winget/show.

- Show a package by exact identifier:

`winget show --id {{package-id}} --exact`

- Inspect a specific available version:

`winget show --id {{package-id}} --exact --version {{version}}`

- Inspect the package from one source:

`winget show --id {{package-id}} --exact --source {{source-name}}`
<!-- mant:tldr:end -->

# winget show

## Synopsis

```text
winget show [query] [--id ID] [--name NAME] [--moniker MONIKER]
            [--version VERSION] [--source SOURCE] [--exact]
```

`winget show` displays details for a package candidate, including metadata,
available versions, installer information, and applicable agreements. Use it
between search and a change operation.

## Inspection options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Select a candidate by free-form query before applying narrower fields.
- `--id ID`: Select by package identifier; combine with `--exact` for a stable review target.
- `--name NAME`, `--moniker MONIKER`: Select by display name or moniker when an exact ID is unavailable.
- `-v VERSION`, `--version VERSION`: Inspect one source-provided package version.
- `-s SOURCE`, `--source SOURCE`: Restrict inspection to one configured source.
- `-e`, `--exact`: Require exact matching for the selected package field.
- `--scope SCOPE`: Restrict installer selection to user or machine scope where supported.
- `--architecture ARCHITECTURE`: Restrict installer metadata to one architecture.
- `--installer-type TYPE`: Restrict results to a supported installer technology.
- `--locale LOCALE`: Select installer locale metadata where available.
- `--versions`: List versions available from the selected source.

## PowerShell boundaries

Treat `winget show` as native display output and check `$LASTEXITCODE` before
consuming it. Do not scrape a changing table to authorize an install.

## Review an exact package

Choose by exact identifier and source, then inspect the details:

```powershell
winget show --id Microsoft.PowerShell --exact --source winget
```

Confirm publisher, package identifier, source, target version, installer type,
architecture, scope, and agreements against the intended deployment. A familiar
display name does not prevent package confusion or a source mismatch.

## Versions and scripts

`--version` narrows inspection to one available version. Use a version only
when the package source provides it and the deployment policy has approved it.
Avoid assuming that every version remains available indefinitely.

Scripts should treat a failed `show` as a stopped precondition, not as a reason
to broaden a name match. Inspect `winget --info` and `$LASTEXITCODE` when a
source, policy, or client-version difference is suspected.

## Common mistakes

### Reviewing a different candidate than the one later installed

Carry the exact ID, source, version, scope, architecture, and installer choice
into the change command. A repeated fuzzy query can resolve differently.

### Treating source metadata as publisher verification

Review installer provenance, signatures/hash policy, agreements, and the
organization's approved source—not only a familiar display name.

## Related documents

- [winget search](winget-search.md)
- [winget install](winget-install.md)
- [winget upgrade](winget-upgrade.md)

## Sources and license

This original command guide was adapted from the official
[winget show documentation](https://learn.microsoft.com/windows/package-manager/winget/show).
It emphasizes inspection before changing a device. Exact upstream revision and
path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
