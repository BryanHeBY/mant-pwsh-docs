<!-- mant:tldr:start -->
# rem

> Add supported comments to Cmd batch files; comments still participate in enough parsing that arbitrary disabled code is unsafe.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rem.

- Add one supported comment line to a batch file:

`rem This explains the next command.`

- Keep redirection and pipe metacharacters out of a REM comment:

`rem Review the pipeline below before enabling it.`

- Use PowerShell's comment syntax in a `.ps1` file instead of invoking Cmd:

`# This is a PowerShell comment.`

<!-- mant:tldr:end -->

# rem

## Overview

`rem` is Cmd's documented comment builtin for batch scripts (and historical
configuration files). Microsoft explicitly warns that `<`, `>`, and `|` cannot
be used in a batch-file REM comment. Comments are not a universal lexical layer:
percent expansion, blocks, pipes, continuations, and nested Cmd parsing can
still make supposedly disabled text fail or affect surrounding syntax.

## Common mistakes

### Commenting out arbitrary code by prefixing `rem`

The old line may contain expansions, redirection, pipes, carets, or parentheses
that are processed before/around REM. Delete it under version control or replace
it with a plain-language comment that contains no executable syntax.

### Assuming `::` is an equivalent supported comment

`::` is an invalid/unused label idiom, not the documented comment command. It
has surprising behavior inside parenthesized blocks and around redirection.
Prefer REM, while keeping comments outside complex/piped blocks when practical.

### Putting REM inside a piped block

Cmd can fold and execute each side of a pipe in child shells; REM may then
consume the folded remainder, including a closing parenthesis. Refactor the
pipeline or place comments before the block and test the exact batch file.

### Storing secrets in comments

Comments remain plaintext source and can reach repositories, logs, packages,
backups, and code review. Never place passwords, tokens, private keys, or
recovery material in REM text.

### Expecting comments to appear at runtime

REM records source commentary; it is not user-facing output. Use ECHO or a
logging command for deliberate messages and keep operational output separate
from source comments.

## PowerShell behavior

REM has meaning only after Cmd parses a batch file or command string. In
PowerShell use `#` or `<# ... #>` comments. Do not pass a REM line through
`cmd /c` merely to annotate a PowerShell operation.

## Version and platform differences

This is an internal `cmd.exe` command on Windows. Parsing depends on batch,
block, pipe, expansion, command-extension, and nested-shell context.

## Related documents

- [cmd](cmd.md)
- [echo](echo.md)
- [goto](goto.md)

## Sources and license

This original guide was adapted from Microsoft's official
[REM reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rem).
Block/pipe and `::` risks were cross-checked against detailed practitioner
[analysis](https://stackoverflow.com/questions/12407800/which-comment-style-should-i-use-in-batch-files).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
