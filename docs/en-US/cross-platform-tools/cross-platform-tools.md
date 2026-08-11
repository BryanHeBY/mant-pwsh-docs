<!-- mant:tldr:start -->
# cross-platform-tools

> Browse separately installed tools commonly called from PowerShell on
> Windows, macOS, and Linux.

- Open this source index:

`mant cross-platform-tools --source cross-platform-tools`

- Inspect one tool document:

`mant {{tool}} --source cross-platform-tools --outline`

- Read one section selected from the outline:

`mant {{tool}} --source cross-platform-tools --node={{section-id}}`

- Search within one tool document:

`mant {{tool}} --source cross-platform-tools --search={{pattern}}`
<!-- mant:tldr:end -->

# Cross-platform tools for PowerShell

## Overview

This source documents tools that are available on Windows, macOS, and Linux
but are not part of PowerShell itself. Each page covers the native process
boundary: command resolution, argument passing, text and byte streams, exit
codes, version differences, credentials, and other behavior that can make a
PowerShell script platform-dependent.

Adding this ManT source installs documentation only. Install each executable
separately with a platform-appropriate, trusted package or installer, and
inspect the selected executable and version before relying on an option.

## Included tools

- [git](git.md): repository context, configuration provenance, pathspecs, and
  command-specific exit codes.
- [ssh](ssh.md): host identity, effective configuration, credentials, remote
  parsing, and exit status.
- [curl](curl.md): executable resolution, HTTP failure handling, secrets, and
  artifact verification.
- [tar](tar.md): implementation-aware archive inspection and safe extraction.
- [dotnet](dotnet.md): SDK selection, project context, restore/build inputs,
  and native process handling.

## Windows companion source

Windows in-box and optional tools, Cmd builtins, Settings URIs, management
consoles, registry tools, and legacy recovery utilities live in the separate
`windows-tools` source. For example:

```text
mant where --source windows-tools
mant winget --source windows-tools
mant reg --source windows-tools
```

This separation lets macOS and Linux users install the cross-platform source
without also installing hundreds of Windows-only pages.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, use commands such as:

```text
mant git --source cross-platform-tools
mant ssh --source cross-platform-tools --outline
mant curl --source cross-platform-tools --search=--fail
mant dotnet --source cross-platform-tools --search=LASTEXITCODE
```

## Sources and license

This source contains original ManT-oriented documentation informed by the
official [Git](https://git-scm.com/docs/git),
[OpenSSH](https://man.openbsd.org/ssh),
[curl](https://curl.se/docs/manpage.html),
[GNU tar](https://www.gnu.org/software/tar/manual/tar.html), and
[.NET CLI](https://learn.microsoft.com/dotnet/core/tools/dotnet)
documentation. Exact revisions and page-level provenance are recorded in
`upstream/cross-platform-tools.json`.

The documentation in this source is licensed under CC BY 4.0. Product names
and trademarks belong to their respective owners.
