# ManT authoring guide

This guide defines the repository's writing conventions. Published documents
must be useful as ordinary Markdown and as structured input to ManT.

## Scope and language

The first release publishes American English under `docs/en-US/`. Each file
should describe one command, alias, concept, launcher, CLI subcommand, or
source index. Keep explanations task-oriented and identify applicable product
versions and platforms.

## Source layout and filenames

Each directory below `docs/en-US/` is one independently installable ManT
source. Keep its Markdown files physically flat because ManT installs source
documents into a flat namespace.

- Preserve official PowerShell casing for cmdlets, such as `Get-Command.md`.
- Use lowercase command names for aliases and native executables, such as
  `irm.md` and `winget.md`.
- Name a CLI subcommand with a hyphen, such as `winget-install.md`.
- Use official `about_*` topic names, such as `about_Pipelines.md`.
- Avoid filenames that are not portable across Windows, macOS, and Linux.
- Treat filename stems as case-insensitively unique within one source.

## Document structure

Use one H1 for the complete document title. H2 headings form the primary ManT
outline; use deeper levels only for genuine hierarchy. Prefer this order when
it fits the subject:

1. Synopsis or overview.
2. Syntax.
3. Description or behavior.
4. Common parameters or options.
5. Examples.
6. Version and platform differences.
7. Related documents.
8. Sources and license.

Do not add YAML front matter or DocFX directives. Avoid raw HTML, block
quotes outside an embedded tldr preface, task lists, images that carry
essential information, and other syntax outside ManT's supported Markdown
subset.

## Embedded tldr quick references

An embedded tldr preface is strongly recommended for command-oriented and
frequently used documents, but it is not required for publication. The
templates include one by default. Remove the complete preface when it would
not provide meaningful quick-reference value.

When present, the opening marker must be the first non-empty construct and
both boundary markers must occupy their own lines:

```markdown
<!-- mant:tldr:start -->
# command

> One-line description.
> More information: https://example.test/official-page.

- Perform a common task:

`command {{value}} {{[-s|--long-option]}}`
<!-- mant:tldr:end -->
```

Use concise imperative example descriptions and runnable commands. Use
`{{placeholder}}` for replaceable values. If a document contains a tldr
preface, it must parse successfully even though tldr coverage itself is not a
release gate.

## Semantic parameters and options

ManT recognizes a complete bullet list as semantic options when every item
starts with one or more inline-code option names, followed by `:`, `—`, or
`–` and a description:

```markdown
- `-Name NAME`: Select commands by name.
- `-Module MODULE`: Restrict results to a module.
- `-All`: Include commands hidden by command precedence.
```

Keep ordinary prose lists separate from semantic option lists. Describe the
most useful options in the semantic summary, then use ordinary subsections
when detailed behavior needs more space.

## Examples and output

Use fenced `powershell` blocks for PowerShell input and `text` or `json` for
output. Examples should be safe by default, explain side effects, and avoid
real credentials or organization-specific identifiers. Prefer examples that
work without administrator privileges. Mark platform-specific examples next
to the example rather than only in a distant note.

## Versions, aliases, and command resolution

Do not infer Windows PowerShell 5.1 behavior from PowerShell 7. Record the
version and platform used for runtime verification. Alias pages should link
to their complete cmdlet page and state whether the alias is built in on each
supported edition and platform. When a PowerShell alias conflicts with a
native executable, describe command precedence and show an unambiguous form
such as `curl.exe` or a module-qualified cmdlet name.

## Links

Local document links use filenames only because published sources are flat.
Include fragments only when the target heading is stable. Use HTTPS links for
official external sources. A link is not a substitute for recording the same
source in the corresponding `upstream/` catalog.

## Sources and attribution

Write original explanations and examples. Every material technical source
must be recorded in the upstream catalog. An adapted document also includes a
short final section similar to:

```markdown
## Sources and license

This document was independently adapted for ManT from the
[official product documentation](https://example.test/official-page).
The source is licensed under CC BY 4.0. This adaptation was reorganized,
shortened, and supplemented with ManT-specific structure and examples.
```

Do not assume that content returned by an MCP server has one blanket license.
Record and verify the final page or repository that supplied the information.

## Portable repository tooling

Repository-wide validation uses dependency-free Node.js ESM and must run on
Linux, macOS, and Windows. Do not make portable checks depend on Bash,
Windows PowerShell, GNU-only utilities, or a live network service. Separate
runtime tests may use a platform-specific shell when the behavior under test
is itself platform-specific.
