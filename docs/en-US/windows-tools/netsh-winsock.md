<!-- mant:tldr:start -->
# netsh winsock

> Inspect the Windows Winsock provider catalog and send-autotuning state.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-winsock.

- Show registered Winsock layered and namespace providers:

`netsh.exe winsock show catalog`

- Show Winsock send-autotuning state:

`netsh.exe winsock show autotuning`

- Show the provider installation/removal audit trail:

`netsh.exe winsock audit trail`

- Emit a configuration script for review without executing it:

`netsh.exe winsock dump`
<!-- mant:tldr:end -->

# netsh winsock

## Overview

`netsh winsock` inspects and changes the Winsock catalog used by Windows
network applications. It can show or dump providers, show audit history and
autotuning, remove one provider, reset the catalog, or change send autotuning.
The TLDR stays read-only because catalog changes can affect many applications.

## Context commands

<!-- mant:entries role=command case=insensitive -->
- `netsh.exe`: Run one fully qualified Windows Netsh command.
- `winsock`: Enter or address the Winsock catalog context.
- `show`: Display the catalog or Winsock send-autotuning state.
- `audit`: Display the provider installation/removal audit trail.
- `dump`: Emit a Winsock configuration script for review.
- `reset`: Reset the Winsock catalog to a clean state, removing custom layered
  providers without resetting every namespace/network component.
- `remove`: Remove one exact verified provider by the context's identifier.
- `set`: Change supported Winsock send-autotuning state.

## PowerShell boundaries

Run fully qualified `netsh.exe winsock ...` commands instead of interactive
context state. Netsh output is native/localized text; preserve inventory and
dump output, capture `$LASTEXITCODE`, and independently verify applications and
provider catalog after a change. A catalog reset is not a PowerShell network
stack reset and should never be an unconditional repair step.

## Common mistakes

### Using reset as a universal network repair

`winsock reset` returns the catalog to a clean state and removes custom layered
service providers; it does not reset namespace providers and is not a generic
DNS, route, adapter, firewall, or application fix. Inventory the catalog and
identify the failing layer first.

### Removing a provider by an unverified ID

Catalog IDs are local snapshot identifiers. Re-query immediately, distinguish
layered providers from namespace-provider GUIDs, confirm vendor/software
ownership, and establish reinstall/rollback before removal.

### Executing dump output blindly

`dump` produces a configuration script, not a portable proof that another
host has identical providers or software. Review every line and target
baseline; do not pipe discovery output directly back into `netsh`.

### Confusing Winsock autotuning with TCP global autotuning

`winsock set autotuning` controls send buffering in this context. It is not
the same option surface as `netsh interface tcp set global`. Measure the
specific workload and record the original setting before a change.

## Version and platform differences

This Windows-only context can require elevation for changes. Catalog contents
depend on architecture, Windows release, and installed networking/security
software; restart requirements and application impact must be verified.

## Related documents

- [netsh](netsh.md)
- [netsh-interface](netsh-interface.md)
- [netstat](netstat.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netsh winsock reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-winsock).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
