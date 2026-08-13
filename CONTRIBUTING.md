# Contributing

Contributions should improve accurate, concise, and task-oriented English
documentation for PowerShell users. The publishable Markdown is maintained
directly rather than generated from copied upstream pages.

## General expectations

- Use American English for published documentation.
- Prefer primary and official technical sources.
- Record every material source in the appropriate `upstream/` catalog.
- Write original explanations and examples instead of copying long passages.
- Identify product version and platform differences explicitly.
- Keep validation and maintenance tooling cross-platform.
- Do not commit generated caches, live MCP responses, or vendored copies of
  upstream documentation.

Follow the detailed conventions in [AUTHORING.md](AUTHORING.md). Run
`npm run validate` before submitting a documentation change. The command
requires Node.js 20 or newer and ManT 0.7.0 or another executable exposing the
same v7 contracts. Use
`npm run validate:structure` only for local structural checks when ManT is not
available; CI requires the complete validation command.

## Contribution licensing

By submitting a contribution, you agree that:

- documentation, templates, and provenance metadata are licensed under
  CC BY 4.0;
- code, tests, workflows, and configuration are licensed under MIT;
- you have the right to submit the contribution; and
- third-party material is clearly identified with its source and license.
