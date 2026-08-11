<!-- mant:tldr:start -->
# winget-search

> Find Windows packages by name, identifier, tag, command, or source.
> More information: https://learn.microsoft.com/windows/package-manager/winget/search.

- Search by a display name or keyword:

`winget search {{query}}`

- Find an exact known package identifier:

`winget search --id {{package-id}} --exact`

- Search only one source:

`winget search {{query}} --source {{source-name}}`
<!-- mant:tldr:end -->

# winget search

## Synopsis

```text
winget search [query] [--id ID] [--name NAME] [--moniker MONIKER]
              [--tag TAG] [--command COMMAND] [--source SOURCE] [--exact]
```

`winget search` queries configured package sources. Use it to discover
candidate packages, not as the final confirmation for an automated install.

## Exact identity

Search by `--id` with `--exact` when a script has a known package identifier:

```powershell
winget search --id Microsoft.PowerShell --exact
if ($LASTEXITCODE -ne 0) {
    throw "Package discovery failed with exit code $LASTEXITCODE"
}
```

An unqualified name can match multiple publishers, installers, or sources.
After discovery, run `winget show --id ID --exact` and review the package before
running an install, upgrade, or uninstall command.

## Sources and automation

Use `--source` when the source is part of the intended trust boundary. Source
names, policy, availability, and package catalog contents can differ between
devices. Run `winget source list` and `winget source update` during setup or
diagnosis, not as an unreviewed prerequisite hidden inside every deployment.

Search output is human-oriented and can change between client releases. Do not
scrape columns to choose a package. Store an approved exact package ID and
validate it with `winget show`.

## Related documents

- [winget](winget.md)
- [winget show](winget-show.md)
- [winget install](winget-install.md)

## Sources and license

This original command guide was adapted from the official
[winget search documentation](https://learn.microsoft.com/windows/package-manager/winget/search).
It emphasizes exact identifiers and source boundaries. Exact upstream revision
and path are recorded in `upstream/cli.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
