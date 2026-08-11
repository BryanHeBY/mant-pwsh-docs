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
6. Common mistakes, when the subject has recurring high-impact traps.
7. Version and platform differences.
8. Related documents.
9. Sources and license.

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

Choose tldr examples from actual high-frequency tasks and the shortest
important correction. For a conflicted command name, include an unambiguous
form; for a destructive tool, lead with inspection or preview; for a GUI
launcher, show the supported PowerShell entry point; and for an unusual success
contract, show the correct status check. Avoid filling the preface with generic
help/version commands when more useful safe operations are known.

## Semantic parameters and options

Declare every list that represents parameters, options, subcommands, or
environment variables. The declaration makes each item addressable through
ManT outline and explain operations and records the runtime matching policy:

```markdown
<!-- mant:entries role=option case=insensitive -->
- `-Name NAME`: Select commands by name.
- `-Module MODULE`: Restrict results to a module.
- `-All`: Include commands hidden by command precedence.
```

Use `role=option` for PowerShell parameters and native switches,
`role=command` for subcommands, and `role=environment-variable` for variables
that form part of the documented interface. Use `case=insensitive` for
PowerShell parameters and ordinary Windows switches. Use `case=sensitive`
when a native tool distinguishes spellings such as `-p` and `-P`.

The declaration must be the only construct on its line and must target the
bullet list beginning on the next non-empty line. Every list item starts with
one or more inline-code terms and includes `:`, `—`, or `–` in the same
leading paragraph. Put placeholders in uppercase so ManT can distinguish a
value placeholder from a fixed colon value:

```markdown
<!-- mant:entries role=option case=insensitive -->
- `/S COMPUTER`: Select a remote computer.
- `/server:NAME`: Select a server; the selector is `/server`.
- `/reg:32`, `/reg:64`: Select a fixed registry view.
```

Do not split the term and its required delimiter across paragraphs. This is
an ordinary list rather than a semantic entry list:

```markdown
- `-Name NAME`
  Select commands by name.
```

Keep ordinary prose lists separate from semantic option lists. Describe the
most useful options in the semantic summary, then use ordinary subsections
when detailed behavior needs more space. A table does not create semantic
entries in the current ManT release; use a declared list when rows need to be
discoverable through outline or explain.

Do not invent empty or dummy entries for a command that genuinely has no
options, subcommands, or interface environment variables. The repository
content audit records and reviews those pages separately.

## Examples and output

Use fenced `powershell` blocks for PowerShell input and `text` or `json` for
output. Examples should be safe by default, explain side effects, and avoid
real credentials or organization-specific identifiers. Prefer examples that
work without administrator privileges. Mark platform-specific examples next
to the example rather than only in a distant note.

## Common mistakes

Add a `## Common mistakes` section when users or automation agents regularly
produce a plausible command that is wrong, unsafe, or valid only in another
shell or product version. This section is strongly recommended for command
resolution conflicts, nested-shell quoting, unusual exit codes, destructive
defaults, GUI launchers, URI handlers, and version-dependent behavior. It is
not required when the page has no meaningful recurring trap.

Use short mistake/correction pairs. Show the incorrect form only when readers
can recognize it safely, explain why it fails, then give an unambiguous form
and a way to verify the result. Prefer headings such as:

```markdown
## Common mistakes

### Using the PowerShell alias instead of the executable

`sc` can resolve to `Set-Content`. Use `sc.exe` for the Service Controller and
check resolution with `Get-Command sc -All`.
```

Do not use the section as a generic warning dump. Keep destructive-operation
guidance prominent even when it also appears in a common-mistake example.

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

High-quality community questions, answers, and issue reports are valuable
page-level sources for real usage patterns, recurring failure modes, and
shell-integration gaps that an official syntax reference might not emphasize.
Verify their technical claims against current product behavior and official
contracts, link the exact discussion, and record its applicable license in the
upstream catalog. Distinguish community evidence from a vendor support promise;
neither source type makes the other unnecessary.

## Portable repository tooling

Repository-wide validation uses dependency-free Node.js ESM and must run on
Linux, macOS, and Windows. Do not make portable checks depend on Bash,
Windows PowerShell, GNU-only utilities, or a live network service. Separate
runtime tests may use a platform-specific shell when the behavior under test
is itself platform-specific.
