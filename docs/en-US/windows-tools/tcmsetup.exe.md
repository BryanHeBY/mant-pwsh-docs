<!-- mant:tldr:start -->
# tcmsetup.exe

> Review TAPI client prerequisites and the complete desired server list before replacing or clearing it.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tcmsetup.

- Read installed syntax without changing client configuration:

`tcmsetup.exe /?`

- Inventory the local domain/trust context before selecting telephony servers:

`Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, PartOfDomain`

- Resolve every proposed server name before an approved replacement:

`Resolve-DnsName -Name {{tapi01.example.com}},{{tapi02.example.com}}`

- Replace the server list only after recording the old configuration and validating all entries:

`tcmsetup.exe /c {{tapi01}} {{tapi02}}; $tcmsetupExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# tcmsetup.exe

## Overview

`tcmsetup.exe /c <servers...>` configures the remote telephony servers used by
a TAPI client. `/c /d` clears the list and disables remote-provider use. `/q`
suppresses message boxes, while `/x` selects connection-oriented callbacks for
lossy/high-traffic networks. Administrative/delegated authority is required.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `tcmsetup.exe`: Configure the legacy TAPI client remote-server list and callback mode.

The supplied server list replaces rather than appends to current state.

<!-- mant:entries role=option case=insensitive -->
- `/c`: Select client configuration mode.
- `/d`: Clear the remote TAPI server list and disable remote-provider use.
- `/q`: Suppress message boxes without becoming validation-only.
- `/x`: Select connection-oriented callbacks for supported transports.
- `/?`: Display installed syntax.

## Common mistakes

### Assuming new server names are appended

Microsoft states the supplied list replaces the existing list. Gather and
preserve the complete current configuration, form the full intended list, and
verify every server before applying it.

### Using `/q` as validation or no-change mode

It only hides message boxes. Configuration still changes, and automation may
lose important diagnostics. Capture native output/status and verify clients.

### Clearing the list to troubleshoot one server

`/c /d` disables the TAPI client from using all remote servers. Diagnose DNS,
trust, firewall, TAPI service/provider/line assignment, callback mode, and server
health before a broad disable.

### Treating `/x` as a general reliability switch

It changes callback transport behavior and does not repair poor topology or
incorrect servers. Validate compatibility and measure the stated packet-loss/
traffic condition.

## PowerShell boundaries

This native administrative command has no documented query form. PowerShell DNS
and domain inventory is supporting evidence, not the stored TAPI list. Capture
`$LASTEXITCODE` immediately and verify effective lines/phones in the client.

## Version and platform differences

This is Windows/domain legacy telephony tooling. Client/server domains need the
same domain or a two-way trust; provider, line assignment, callback transport,
firewall, and configuration storage vary by release.

## Related documents

- [tapicfg.exe](tapicfg.exe.md)
- [tsecimp.exe](tsecimp.exe.md)

## Sources and license

Adapted as an original guide from Microsoft's [TcmSetup reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tcmsetup).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
