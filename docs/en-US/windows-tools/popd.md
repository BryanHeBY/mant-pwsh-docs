<!-- mant:tldr:start -->
# popd

> Restore the most recently saved cmd directory and clean its temporary UNC mapping.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/popd.

- Restore the directory saved by the latest `pushd`:

`popd`

- Use a balanced batch pattern:

`pushd "{{path}}" && ({{command}} & popd)`

- Use PowerShell's separate location stack instead:

`Push-Location -LiteralPath '{{path}}'; try { {{command}} } finally { Pop-Location }`
<!-- mant:tldr:end -->

# popd

## Overview

`popd` removes the top entry from the current `cmd.exe` directory stack and
changes back to that saved directory. With command extensions, it also removes
the temporary drive mapping created when `pushd` entered a UNC path.

## Command identities

<!-- mant:entries role=command case=insensitive -->
- `popd`: In cmd, restore and remove the latest entry from that cmd process's directory stack.
- `Pop-Location`: In PowerShell, restore the latest location from a PowerShell location stack.

## PowerShell boundaries

Cmd and PowerShell keep separate, process-local stacks. Use an explicit
same-process pairing and `try`/`finally` or equivalent failure cleanup; neither
command can pop state owned by the other shell.

## Common mistakes

### Calling it without a matching `pushd`

The stack is ordered and process-local. Unbalanced cleanup can restore the
wrong directory or do nothing useful; pair ownership explicitly.

### Assuming batch exit always cleans the desired scope

Complex control flow makes implicit behavior hard to audit. Ensure every
successful `pushd` reaches one same-process `popd`, including failure paths.

### Mixing cmd and PowerShell stacks

`Push-Location`/`Pop-Location` operate inside PowerShell. They cannot pop a cmd
stack or remove a mapping owned by a different `cmd.exe` process.

### Popping before a child finishes using the mapping

An asynchronous child may still depend on the temporary drive. Wait for the
actual operation or give the child a stable UNC path supported by that tool.

## Version and platform differences

This page describes Windows cmd. Removal of a UNC temporary drive assignment
requires command extensions.

## Runtime evidence

The protected fixture confirmed that a balanced local `pushd`/`popd` pair in
one child `cmd.exe` restores its original directory under both PowerShell
collectors. It did not use UNC mapping, cross-process stacks, an unbalanced
`popd`, or a child still using a temporary mapping.

## Related documents

- [pushd](pushd.md)
- [cmd.exe](cmd.exe.md)
- [start](start.md)

## Sources and license

This original guide was adapted from Microsoft's official
[popd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/popd)
and the paired `pushd` contract. Exact locked provenance is recorded in
`upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
