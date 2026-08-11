<!-- mant:tldr:start -->
# getmac

> Inventory Windows adapter MAC addresses and associated transports.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/getmac.

- Show verbose local adapter information in CSV form:

`getmac.exe /v /fo csv`

- Show a concise local table without suppressing its identifying header:

`getmac.exe /fo table`

- Inspect typed adapter identity, status, and MAC address:

`Get-NetAdapter | Select-Object Name, InterfaceDescription, InterfaceIndex, MacAddress, Status, Virtual`

- Query a reviewed remote computer using the current credentials:

`getmac.exe /s {{computer-name}} /v /fo csv`
<!-- mant:tldr:end -->

# getmac

## Overview

`getmac.exe` reports MAC addresses and associated network transports for local
or remote Windows computers. `/v` adds adapter details and `/fo table|list|csv`
selects presentation. `/s`, `/u`, and `/p` control legacy remote access.

## Common mistakes

### Selecting the first MAC address

Physical, virtual, VPN, tunnel, disconnected, and management adapters can all
appear. Select by interface identity and status relevant to the path, and
expect some transports to report no usable physical address.

### Treating a MAC as stable global identity

A MAC is link-layer context, not a durable asset or user identity. Hardware
replacement, virtualization, spoofing, docking, and privacy randomization can
change or duplicate it.

### Parsing a formatted table

Fixed-width output can truncate and labels can be localized. Request CSV for
interchange, retain its headers, or prefer `Get-NetAdapter` objects for local
automation.

### Putting a remote password on the command line

Avoid `/p password`: arguments can leak through history, process inspection,
logs, and agent transcripts. Prefer current credentials or an approved remote
management channel; if alternate credentials are unavoidable, omit the
password argument and use an interactive protected prompt supported by the
environment.

### Assuming remote failure means no adapters

Firewall, RPC, authentication, name resolution, service, and policy failures
can block the query. Distinguish transport/access errors from an empty result.

## Version and platform differences

This executable and `Get-NetAdapter` are Windows-only. Remote availability
depends on target Windows version, policy, services, firewall, and credentials.

## Related documents

- [arp](arp.md)
- [ipconfig](ipconfig.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[getmac reference](https://learn.microsoft.com/windows-server/administration/windows-commands/getmac).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
