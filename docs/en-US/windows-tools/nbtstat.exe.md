<!-- mant:tldr:start -->
# nbtstat.exe

> Inspect legacy NetBIOS over TCP/IP names, caches, and sessions on Windows.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/nbtstat.

- Show this computer's registered NetBIOS names and their status:

`nbtstat.exe /n`

- Show the local NetBIOS name cache:

`nbtstat.exe /c`

- Query a remote name table by exact IPv4 address; uppercase `/A` matters:

`nbtstat.exe /A {{remote-IPv4-address}}`

- Show current NetBIOS sessions using numeric remote addresses:

`nbtstat.exe /S`
<!-- mant:tldr:end -->

# nbtstat.exe

## Overview

`nbtstat.exe` diagnoses NetBIOS over TCP/IP (NetBT). It displays local and
remote NetBIOS name tables, the local name cache, resolution statistics, and
NetBIOS sessions. Installed help uses `-`, Microsoft's locked page uses `/`,
and the recorded build accepts both. Option letters are case-sensitive:
`-a`/`/a` queries by remote NetBIOS name, while `-A`/`/A` queries by IPv4
address; `-s`/`/s` resolves session names, while `-S`/`/S` keeps numeric
addresses.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `nbtstat.exe`: Inspect NetBIOS-over-TCP/IP name tables, cache statistics, and
  sessions, or request a documented cache/name refresh.

The following option role is case-sensitive because Windows assigns different
behavior to several lowercase and uppercase spellings.

<!-- mant:entries role=option case=sensitive -->
- `-a`, `/a`: Query the NetBIOS name table of the following remote NetBIOS name.
- `-A`, `/A`: Query the NetBIOS name table of the following remote IPv4 address.
- `-c`, `/c`: Display the local NetBIOS name cache and resolved addresses.
- `-n`, `/n`: Display names registered locally by NetBIOS applications.
- `-r`, `/r`: Display name-resolution statistics for broadcast and WINS resolution.
- `-R`, `/R`: Purge the NetBIOS name cache and reload the preloaded `Lmhosts` entries.
- `-RR`, `/RR`: Release and then refresh locally registered NetBIOS names through
  configured WINS servers.
- `-s`, `/s`: Display NetBIOS client/server sessions and try to resolve remote IP
  addresses to names.
- `-S`, `/S`: Display NetBIOS sessions using numeric remote IP addresses.
- `-?`, `/?`: Display installed help. A trailing numeric interval is an operand that
  repeats selected output until interrupted, not another switch.

## PowerShell boundaries

Call `nbtstat.exe` with the exact option case; do not normalize arguments in a
wrapper. Output is legacy localized text. Bound or externally cancel interval
mode, check `$LASTEXITCODE`, and use DNS, SMB, or NetTCPIP interfaces for
automation outside the specific NetBT question.

## Common mistakes

### Changing the case of an option

`/a` and `/A`, `/r` and `/R`, and `/s` and `/S` are different operations.
Copy the intended spelling exactly rather than normalizing option case.

### Using it for DNS or modern SMB discovery

NetBIOS names are not DNS records, host FQDNs, or proof that SMB is reachable.
Many current networks disable NetBT. Use DNS and service-specific tests for
modern application paths.

### Purging evidence as the first step

`/R` purges and reloads the NetBIOS name cache; `/RR` releases and refreshes
locally registered NetBIOS names. Capture `/c`, `/n`, resolution statistics,
adapter configuration, and timestamps before either state-changing action.

### Leaving interval mode unbounded

A trailing numeric interval repeats selected statistics until Ctrl+C. Omit it
in scripts unless the caller intentionally manages duration and cancellation.

## Version and platform differences

This executable is Windows-only and useful only where NetBIOS over TCP/IP is
enabled and relevant. Network policy, node type, WINS, broadcasts, and adapter
configuration affect results. On Windows NT `10.0.26200.0`, installed file
version `10.0.26100.1` printed 20 normalized nonempty help lines and returned 2
for both `/?` and `-?`; Windows PowerShell 5.1 represented that native-error
stream as error records. Read-only local-name-table queries verified `-n` and
`/n` produce equivalent output without purging or refreshing NetBT state.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 /? and -? each
printed 20 normalized native-error-stream lines and returned 2. Locked help
uses slash prefixes, installed help uses dashes, and local-name-table display
proved both forms while preserving case-sensitive pairs. No cache purge,
refresh, WINS, remote, or network mutation ran.

## Related documents
- [nslookup.exe](nslookup.exe.md)
- [ipconfig.exe](ipconfig.exe.md)
- [netstat.exe](netstat.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[nbtstat reference](https://learn.microsoft.com/windows-server/administration/windows-commands/nbtstat).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
