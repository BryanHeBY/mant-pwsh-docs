<!-- mant:tldr:start -->
# tree

> Render a human-readable Windows directory tree.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tree.

- Show directories using plain text connector characters:

`tree.com "{{C:\path}}" /a`

- Include filenames in the rendered tree:

`tree.com "{{C:\path}}" /a /f`

- Use PowerShell objects when output must be filtered or automated:

`Get-ChildItem -LiteralPath '{{C:\path}}' -Recurse`
<!-- mant:tldr:end -->

# tree

## Overview

`tree.com` renders the directory hierarchy below a drive or path. `/f`
includes filenames and `/a` selects plain text connectors instead of extended
graphics characters.

## Important options

<!-- mant:entries role=option case=insensitive -->
- `/f`: Include filenames as well as directory names in the rendered hierarchy.
- `/a`: Use plain ASCII connector characters instead of code-page-dependent extended graphics.

## PowerShell boundaries

Call `tree.com` explicitly because another platform or profile can provide a
different `tree`. The output is a diagram, not filesystem objects; use
`Get-ChildItem` and deliberate metadata export for automation.

## Common mistakes

### Parsing the diagram as a stable inventory

The output is presentation text, not a structured manifest. It omits metadata
such as ACLs, attributes, link targets, hashes, and stable identifiers. Use
filesystem objects or a deliberate export format for automation.

### Using `/f` on an unbounded root

The result can be enormous and slow. Narrow the root first and redirect only
after confirming the intended scope.

### Assuming visible containment proves storage containment

Reparse points, mounts, and links can refer elsewhere. Inventory link metadata
separately before using a tree diagram to reason about copy or deletion scope.

### Depending on graphic characters

Use `/a` for logs, diffs, terminals, and text transports where the code page or
font may not reproduce line-drawing characters.

## Version and platform differences

This page describes Windows `tree.com`. Other platforms may install unrelated
`tree` programs with different options and traversal behavior.

## Related documents

- [dir](dir.md)
- [mklink](mklink.md)
- [attrib](attrib.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tree reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tree).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
