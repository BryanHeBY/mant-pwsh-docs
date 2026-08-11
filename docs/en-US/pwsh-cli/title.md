<!-- mant:tldr:start -->
# title

> Set the title of the current interactive Command Prompt window.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/title.

- Set a title inside a batch file:

`title {{Updating files}}`

- Set it through an explicitly retained cmd window:

`cmd.exe /d /k 'title {{Maintenance shell}}'`

- Set the current PowerShell host title when supported:

`$Host.UI.RawUI.WindowTitle = '{{Maintenance shell}}'`
<!-- mant:tldr:end -->

# title

## Overview

`title` is a `cmd.exe` builtin that changes the title of the current Command
Prompt window. It is UI state, not an operation status, process identity, or
supported coordination channel.

## Syntax

```text
title [TEXT]
```

Run it inside the cmd process whose visible title should change. A short-lived
`cmd /c title ...` normally exits before the title is useful.

## Common mistakes

### Expecting it to rename another terminal tab or process

Windows Terminal and other hosts can apply their own tab-title policy. The
builtin requests a console title; the host decides what is displayed.

### Running it as ordinary PowerShell syntax

PowerShell has no equivalent `title` builtin. Use its host API where supported,
or invoke/retain a cmd process explicitly.

### Passing untrusted text through cmd

Characters such as `&`, `|`, `<`, `>`, `^`, `%`, and `!` participate in cmd
parsing. Do not concatenate arbitrary job names or user input into a title
command string.

### Using the title as machine-readable state

Titles are mutable, localized UI labels. Track work with process objects,
structured logs, task identifiers, and verified output instead.

## Version and platform differences

The builtin is Windows-only. Visible results depend on an interactive console
host, terminal settings, remote/session context, and host support.

## Related documents

- [cmd](cmd.md)
- [start](start.md)
- [timeout](timeout.md)

## Sources and license

This original guide was adapted from Microsoft's official
[title reference](https://learn.microsoft.com/windows-server/administration/windows-commands/title).
Exact locked provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
