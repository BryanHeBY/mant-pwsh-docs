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

## Related documents

- [winget search](winget-search.md)
- [winget install](winget-install.md)
- [winget upgrade](winget-upgrade.md)

## Sources and license

This original command guide was adapted from the official
[winget show documentation](https://learn.microsoft.com/windows/package-manager/winget/show).
It emphasizes inspection before changing a device. Exact upstream revision and
path are recorded in `upstream/cli.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
