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

## Related documents

- [winget upgrade](winget-upgrade.md)
- [winget uninstall](winget-uninstall.md)
- [winget search](winget-search.md)

## Sources and license

This original command guide was adapted from the official
[winget list documentation](https://learn.microsoft.com/windows/package-manager/winget/list).
It emphasizes inventory limits and exact identifiers. Exact upstream revision
and path are recorded in `upstream/cli.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
