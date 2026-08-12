<!-- mant:tldr:start -->
# launcher

> Start PowerShell and control its startup behavior.

- Start an interactive session:

`launcher`

- Run a command and exit:

`launcher -Command {{command}}`

- Run a script file:

`launcher -File {{path/to/script.ps1}}`

- Start without loading profiles:

`launcher -NoProfile`
<!-- mant:tldr:end -->

# Launcher title

## Synopsis

Describe the executable and edition it starts.

## Syntax

```text
launcher [options]
```

## Common options

- `-Command COMMAND`: Run a command and exit unless the command starts an interactive session.
- `-File PATH`: Run a script file.
- `-NoProfile`: Do not load PowerShell profiles.
- `-Help`: Display command-line help.

## Examples

Provide safe examples for interactive, command, script, and pipeline use.

## Version and platform differences

State executable names, supported editions, and argument parsing differences.

## Verification boundary

State why launcher behavior has not yet been observed and name the applicable
edition/platform. Replace this entire section with `## Runtime evidence` and
the bounded result after a real observation; never keep both.

## Sources and license

List the authoritative source and license.
