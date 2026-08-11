<!-- mant:tldr:start -->
# pwsh-cli

> Browse documentation for native command-line tools commonly used from
> PowerShell.

- Open this source index:

`mant pwsh-cli --source pwsh-cli`

- Inspect the sections and options in a CLI document:

`mant {{command}} --source pwsh-cli --outline`

- Explain a command-line option:

`mant {{command}} --source pwsh-cli --explain={{option}}`

- Search within one CLI document:

`mant {{command}} --source pwsh-cli --search={{pattern}}`
<!-- mant:tldr:end -->

# Command-line tools for PowerShell

## Overview

This source documents native command-line tools that PowerShell users
commonly install or encounter. It complements the PowerShell command sources:
pages explain the native tool and also show how quoting, pipelines, streams,
structured output, and exit codes behave when the tool is called from
PowerShell.

The source covers tools shipped with Windows, cross-platform developer tools,
package managers such as `winget`, and selected cloud or system-management
CLIs. A command qualifies by practical usefulness, not by vendor.

## First-release coverage

The first release prioritizes:

- Windows tools and package management, including `winget`, `wsl`, `where`,
  `robocopy`, `schtasks`, `sc`, and selected networking commands;
- cross-platform development tools, including `git`, `ssh`, `curl`, `tar`,
  `dotnet`, and container tooling;
- JSON and text-processing tools commonly composed in automation;
- subcommand pages for large CLIs when one overview would be too broad;
- PowerShell command-resolution conflicts such as an alias and an executable
  sharing the same name.

Destructive or administrative commands require explicit safety notes and
examples with narrowly scoped targets.

## PowerShell interoperability

Native tools exchange text and byte streams rather than PowerShell objects.
Their pages should explain the details that commonly cause automation bugs:

- quoting and argument passing;
- executable discovery and alias precedence;
- standard output, standard error, and progress output;
- `$LASTEXITCODE` and nonzero exit codes;
- structured formats such as JSON and their conversion to PowerShell objects;
- operating-system and tool-version differences.

## Optional Microsoft Learn MCP queries

Microsoft's official Microsoft Learn MCP server can provide current product
documentation to compatible AI clients. Installing it remains optional: every
ManT page stands on its own, and the MCP service is an additional discovery
channel rather than a runtime dependency. See
[microsoft-learn-mcp](microsoft-learn-mcp.md) for focused queries and
provenance rules.

Information found through MCP must still be checked against the returned
Microsoft Learn page. Record that page, its applicable version, and its
license in the document's provenance catalog before adapting material.

## Documentation discovery

- [microsoft-learn-mcp](microsoft-learn-mcp.md): optional live queries for
  current Microsoft CLI documentation, without making MCP a ManT dependency.

## Windows Package Manager

- [winget](winget.md): package discovery and lifecycle safety from PowerShell.
- [winget search](winget-search.md): find candidates and exact package IDs.
- [winget show](winget-show.md): inspect package metadata before a change.
- [winget install](winget-install.md): install one reviewed exact package.
- [winget upgrade](winget-upgrade.md): controlled one-package or bulk upgrades.
- [winget uninstall](winget-uninstall.md): exact-package removal safety.
- [winget list](winget-list.md): inventory limits and upgrade-available review.

## Windows system tools

- [wsl](wsl.md): explicit distribution selection and Windows/Linux boundaries.
- [where](where.md): Windows executable lookup versus PowerShell resolution.
- [robocopy](robocopy.md): safe previews, mirror risk, and special exit codes.
- [schtasks](schtasks.md): scheduled-task inspection and change safety.
- [sc](sc.md): Windows service query and configuration safety.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, use commands such as:

```text
mant winget --source pwsh-cli
mant winget-install --source pwsh-cli --outline
mant winget-install --source pwsh-cli --explain=--id
mant git --source pwsh-cli --search=LASTEXITCODE
```

## Sources and license

This source contains original ManT-oriented documentation informed by each
tool vendor's official documentation and source repositories, including the
[Windows Package Manager documentation](https://learn.microsoft.com/windows/package-manager/winget/).
Exact upstream revisions and page-level provenance are recorded in the
repository's `upstream/cli.json` catalog.

The documentation in this source is licensed under CC BY 4.0. Product names
and trademarks belong to their respective owners.
