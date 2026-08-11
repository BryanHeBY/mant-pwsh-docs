# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to use semantic versioning for published document
bundles.

## [Unreleased]

### Added

- First English release inventory: 108 reviewed ManT pages across `pwsh7`,
  `pwsh51`, and `pwsh-cli`.
- Broad `pwsh7` and `pwsh51` shell manuals, focused language/command pages,
  compatibility guides, and custom `irx` shorthand resolution guidance.
- Native CLI coverage for Microsoft Learn MCP discovery, winget, Windows system
  tools, Git, OpenSSH, curl, tar, and .NET.
- Windows shell, GUI, Settings, Control Panel, MMC, Registry, and Rundll32
  entry-point guides, plus matching `Start-Process`, `start`, `Invoke-Item`,
  and `ii` pages for PowerShell 7 and Windows PowerShell 5.1.
- Cmd batch-state and interaction guides for `set`, `setlocal`, `endlocal`,
  `call`, `choice`, `timeout`, and `exit`.
- Cmd control-flow, search-path, directory-stack, title, and classic file-
  association guides for `for`, `if`, `path`, `pushd`, `popd`, `title`,
  `assoc`, and `ftype`.
- Cmd directory listing, file copy, permanent file deletion, and recursive
  directory removal guides, including `erase` and `rmdir` lookup aliases.
- Per-page locked provenance catalogs, reader-facing source/license sections,
  and an optional upstream accessibility audit.
- Portable Node.js validation with ManT JSON diagnostics and a v1 release gate.

### Changed

- CI is manual-only until ManT 0.6.0 is publicly installable.

### Pending release verification

- Runtime verification on Windows, macOS, and Linux remains required before
  creating the final v1 tag; see [release/v1-runtime.md](release/v1-runtime.md).
