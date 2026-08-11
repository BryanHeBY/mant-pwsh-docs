<!-- mant:tldr:start -->
# command

> Describe the native command-line tool in one sentence.
> More information: https://example.test/official-documentation.

- Display help:

`command {{[-h|--help]}}`

- Perform the most common task:

`command {{input}} --option {{value}}`

- Capture output in PowerShell:

`$output = command {{input}}`

- Stop when the command fails:

`command {{input}}; if ($LASTEXITCODE -ne 0) { throw 'command failed' }`
<!-- mant:tldr:end -->

# command

## Overview

Describe the tool, installation source, and supported platforms.

## Syntax

```text
command [global options] <subcommand> [options]
```

## Common options

- `-h`, `--help`: Display command help.
- `--version`: Display the installed version.

## PowerShell usage

Explain quoting, object-versus-text output, streams, and `$LASTEXITCODE`.

## Examples

Provide safe, task-oriented PowerShell examples.

## Common mistakes

When useful, show recurring wrong forms, explain the shell or tool behavior
that makes them wrong, and give an unambiguous correction plus verification.
Remove this section when there is no meaningful recurring trap.

## Version and platform differences

State relevant differences.

## Find more with official documentation tools

For Microsoft products, optionally provide focused Microsoft Learn MCP search
queries. For other products, link only to the vendor's official resources.

## Sources and license

List all authoritative sources and their licenses.
