<!-- mant:tldr:start -->
# systeminfo.exe

> Display a Windows host and operating-system configuration snapshot.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/systeminfo.

- Display the local host snapshot in readable list form:

`systeminfo.exe /fo list`

- Request CSV when the output must cross a text pipeline:

`systeminfo.exe /fo csv`

- Use typed PowerShell objects for local automation:

`Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, OsArchitecture, CsTotalPhysicalMemory`
<!-- mant:tldr:end -->

# systeminfo.exe

## Overview

`systeminfo.exe` reports OS, boot, hardware, memory, network, domain, and update
summary data for a local or remote Windows host. `/fo` supports table, list,
and CSV; `/s` selects a remote host.

## Important options

<!-- mant:entries role=option case=insensitive -->
- `/fo FORMAT`: Select `table`, `list`, or `csv` presentation.
- `/nh`: Suppress column headers for table/CSV output; retaining headers is safer for field mapping.
- `/s COMPUTER`: Query one remote computer by name or IP address.
- `/u DOMAIN\USER`: Authenticate the remote query as another user; valid only with `/s`.
- `/p PASSWORD`: Supply the remote password; omit it to prompt instead of exposing a command-line secret.

## PowerShell boundaries

Call `systeminfo.exe` explicitly and capture `$LASTEXITCODE`. Prefer
`Get-ComputerInfo` or CIM for typed local/remote fields; CSV remains localized
native text and is not complete asset or security inventory.

## Common mistakes

### Scraping localized labels from list output

Use CSV only when text interchange is required and validate its locale/header
contract. Prefer `Get-ComputerInfo`, CIM, or a management API for typed fields.

### Treating the snapshot as complete asset or security inventory

Fields can be summarized, permission-limited, stale, or absent. Cross-check
authoritative inventory sources for installed updates, disks, network state,
firmware, security posture, and licensing decisions.

### Putting `/p PASSWORD` in a command

Omit `/p` to receive a protected prompt. Inline credentials leak through
history, logging, monitoring, process command lines, and transcripts.

### Comparing human-formatted values across locales

Dates, numbers, names, and labels vary. Normalize typed values rather than
diffing rendered text.

## Version and platform differences

This executable is Windows-only. Available fields and remote access depend on
Windows release, permissions, services, firewall, policy, and architecture.

## Related documents

- [whoami.exe](whoami.exe.md)
- [driverquery.exe](driverquery.exe.md)
- [tasklist.exe](tasklist.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[systeminfo reference](https://learn.microsoft.com/windows-server/administration/windows-commands/systeminfo).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
