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

## Search options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Search the default package fields for a free-form value.
- `--id ID`: Match a package identifier; combine with `--exact` for automation.
- `--name NAME`: Match package display name rather than stable identity.
- `--moniker MONIKER`: Match a package moniker where source metadata provides one.
- `--tag TAG`: Match source-defined package tags.
- `--cmd COMMAND`, `--command COMMAND`: Match packages associated with a command name.
- `-s SOURCE`, `--source SOURCE`: Restrict discovery to one configured source.
- `-e`, `--exact`: Require an exact match for the selected field/query.
- `-n COUNT`, `--count COUNT`: Limit displayed results; it does not prove additional matches do not exist.
- `--versions`: Include available versions where the installed client supports it.
- `--accept-source-agreements`: Accept reviewed source agreements for unattended access.

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

## PowerShell boundaries

Pass each option/value separately and check `$LASTEXITCODE`. Search results are
native formatted output, not package objects or an authorization decision.

## Version and availability

Options depend on the independently serviced WinGet client and configured
sources. Confirm `winget search --help` and `winget --version` on the target.

## Common mistakes

### Installing the first fuzzy result

Search is discovery only. Resolve one exact ID/source and inspect it with
`winget show` before any change.

### Treating no rows as proof that no package exists

Source failure, stale metadata, policy, authentication, or client version can
also produce incomplete discovery. Check source and exit state.

## Related documents

- [winget](winget.md)
- [winget show](winget-show.md)
- [winget install](winget-install.md)

## Sources and license

This original command guide was adapted from the official
[winget search documentation](https://learn.microsoft.com/windows/package-manager/winget/search).
It emphasizes exact identifiers and source boundaries. Exact upstream revision
and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
