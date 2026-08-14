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

- Display installed local, remote, credential, and output-format options:

`systeminfo.exe /?`
<!-- mant:tldr:end -->

# systeminfo.exe

## Overview

`systeminfo.exe` reports OS, boot, hardware, memory, network, domain, and update
summary data for a local or remote Windows host. `/fo` supports table, list,
and CSV; `/s` selects a remote host.

## Important options

<!-- mant:entries role=command case=insensitive -->
- `systeminfo.exe`: Report a local or explicitly selected remote Windows host
  snapshot without changing host configuration.

The following slash forms select remote access and output presentation.

<!-- mant:entries role=option case=insensitive -->
- `/fo FORMAT`: Select `table`, `list`, or `csv` presentation.
- `/nh`: Suppress column headers for table/CSV output; retaining headers is safer for field mapping.
- `/s COMPUTER`: Query one remote computer by name or IP address.
- `/u`: Authenticate the remote query as another user or `DOMAIN\USER`; valid only with `/s`.
- `/p PASSWORD`: Supply the remote password; omit it to prompt instead of exposing a command-line secret.
- `-?`, `/?`: Display installed command help.

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
On Windows NT `10.0.26200.0`, installed file version `10.0.26100.8457` printed
25 nonempty help lines and returned 0 for both `/?` and `-?`; its six-option
surface matched the page. No local/remote host snapshot, credential, service,
firewall, hardware, update, or network state was queried by the help probes.

## Runtime evidence

The repeatable read-only Windows CLI fixture resolved exact System32
`systeminfo.exe`, captured localized `/?` help, and ran one local `/fo csv /nh`
snapshot with a 30-second bound. It returned exit code `0` and nonempty output
under both PowerShell collectors; the machine inventory was counted but not
emitted into test logs. No remote host or credential was supplied. Field
completeness, locale, servicing authority, and other Windows builds remain
separate concerns.

## Related documents

- [whoami.exe](whoami.exe.md)
- [driverquery.exe](driverquery.exe.md)
- [tasklist.exe](tasklist.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[systeminfo reference](https://learn.microsoft.com/windows-server/administration/windows-commands/systeminfo).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
