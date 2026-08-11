# Tests

`npm run validate` is the portable structural test suite. It covers document
structure, provenance, links, filename portability, and ManT JSON diagnostics
across supported host platforms.

The GitHub Actions workflow is manual-only until ManT 0.6.0 is publicly
installable in CI. When enabled, it runs the same check on Linux, macOS, and
Windows. Future runtime tests may invoke PowerShell 7 on all three platforms
and Windows PowerShell 5.1 only on Windows; those checks must remain separate
from the portable Node.js validator.
