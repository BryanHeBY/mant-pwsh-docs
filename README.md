# ManT PowerShell Documentation

This repository publishes concise, structured English documentation for
Windows PowerShell 5.1, PowerShell 7, and command-line tools commonly used
from PowerShell. The Markdown files are written for direct consumption by
[ManT](https://github.com/BryanHeBY/ManT) and remain readable on ordinary
CommonMark renderers.

## Planned document sources

- `pwsh51`: Windows PowerShell 5.1 commands, aliases, and concepts.
- `pwsh7`: PowerShell 7 commands, aliases, and concepts.
- `pwsh-cli`: Native command-line tools and PowerShell interoperability.

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

## Project status

The repository is being initialized. Document sources, authoring templates,
and validation tools will be added incrementally.

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
