# ManT PowerShell and Tool Documentation

This repository publishes concise, structured English documentation for
Windows PowerShell 5.1, PowerShell 7, and operating-system or cross-platform
tools commonly used from PowerShell. The Markdown files are written for direct consumption by
[ManT](https://github.com/BryanHeBY/ManT) and remain readable on ordinary
CommonMark renderers.

## Document sources

- `pwsh51`: Windows PowerShell 5.1 commands, aliases, and concepts.
- `pwsh7`: PowerShell 7 commands, aliases, and concepts.
- `windows-tools`: Windows-native, optional, GUI, URI, builtin, and legacy
  tools used from PowerShell.
- `cross-platform-tools`: Separately installed tools used from PowerShell on
  Windows, macOS, and Linux.

The publishable Markdown under `docs/en-US/` is the repository's source of
truth. Documentation is authored and reviewed directly; it is not generated
from vendored upstream prose. The `upstream/` catalogs record authoritative
sources, versions, licenses, and verification status without storing copies
of upstream documentation.

## Portability

Repository-wide validation is designed to run unchanged on Linux, macOS, and
Windows. Cross-platform checks use Node.js and platform-neutral command-line
interfaces. Tests that verify behavior unique to Windows PowerShell 5.1 are
kept separate from the portable documentation checks.

## Install with ManT

Copy or merge the desired source entries from
[sources.example.toml](sources.example.toml) into ManT's `sources.toml`, then
update the installed sources. Each entry is independent: a Windows-only setup can
omit `cross-platform-tools`, while a macOS or Linux setup can omit
`windows-tools`.

```text
mant --update-docs
mant pwsh7 --source pwsh7
mant pwsh51 --source pwsh51
mant windows-tools --source windows-tools
mant cross-platform-tools --source cross-platform-tools
```

The source names keep shell manuals, Windows PowerShell 5.1 references, and
tool documentation distinct even where a document name overlaps. For
example, use `mant curl --source pwsh51` for the Windows PowerShell alias
boundary and `mant curl --source cross-platform-tools` for the native
executable guide.

ManT 0.7 compares configured source priorities with native manuals at priority
`0`. The example keeps the PowerShell and Windows-specific collections above
that boundary, while `cross-platform-tools` uses `-5` so an installed native
manual wins an unqualified query. An explicit `--source` still selects this
repository's guide.

Windows entry-point documents retain their canonical suffixes, for example
`winget.exe`, `tree.com`, `services.msc`, and `prncnfg.vbs`. On Windows, ManT
tries `PATHEXT` after an extensionless exact-name lookup, so this works when
`.EXE` is present:

```text
mant winget --source windows-tools
```

An explicitly suffixed query is exact and portable across host platforms:

```text
mant winget.exe --source windows-tools
```

ManT does not omit Windows suffixes on macOS or Linux. Cmd builtins such as
`dir`, PowerShell cmdlets and aliases, URI entries, and conceptual family or
subcommand pages remain unsuffixed.

## Source maintenance

ManT 0.7 reports source updates as `mant.sources-update/v2`. Removing an entry
from `sources.toml` makes its installed document source orphaned, but an ordinary
`mant --update-docs` does not delete it. Preview the exact source directories
first, then prune only when those sources are no longer needed:

```text
mant --prune-docs --dry-run
mant --prune-docs
```

The prune report uses `mant.sources-prune/v1`. Treat these report identifiers
as CLI data-format versions, independently of this repository's 0.7.0 release
number.

## Project status

The planned English 0.7.0 inventory contains 416 reviewed pages: 30 for
PowerShell 7, 30 for Windows PowerShell 5.1, 350 Windows tool pages, and 6
cross-platform tool pages. The normative inventory lives in
[release/v0.7.0.json](release/v0.7.0.json).
The repository-wide deep-review gates, current batches, and confirmed findings
are tracked in [QUALITY-AUDIT.md](QUALITY-AUDIT.md).

Portable ManT parsing, provenance validation, and locked-upstream
accessibility audit pass locally. The final `v0.7.0` tag remains pending recorded
runtime verification on all platforms required by
[V0.7.0-SCOPE.md](V0.7.0-SCOPE.md). Windows PowerShell 5.1 and PowerShell 7.6
now have completed editorial/source/metadata passes and partial platform
runtime evidence; remaining Windows fixtures, macOS, and compatible dotnet SDK
hosts remain incomplete. CI runs the ManT 0.7.0 portable validator and v7
protocol contract on Linux,
macOS, and Windows. A separate Windows job runs the version-neutral runtime
fixtures through both Windows PowerShell and PowerShell 7 in parallel with the
portable matrix.

## License

Documentation, templates, and provenance metadata are licensed under the
[Creative Commons Attribution 4.0 International License](LICENSE.md).
Scripts, tests, workflows, and configuration code are licensed under the
[MIT License](LICENSE-CODE.md).

Some documents may be independently adapted from third-party official
documentation. Those sources and licenses are identified in the individual
documents and in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

This project is not affiliated with or endorsed by Microsoft. Microsoft,
Windows, PowerShell, and winget are trademarks of the Microsoft group of
companies. All other trademarks belong to their respective owners.
