<!-- mant:tldr:start -->
# klist.exe

> Inspect Kerberos tickets and bindings for an explicit Windows logon session.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/klist.

- List cached TGT and service tickets for the current logon session:

`klist.exe tickets`

- Inspect the current session's ticket-granting ticket:

`klist.exe tgt`

- List logon sessions and their LUIDs when authorized:

`klist.exe sessions`

- Show cached preferred domain-controller bindings without changing them:

`klist.exe query_bind`
<!-- mant:tldr:end -->

# klist.exe

## Overview

`klist.exe` inspects Kerberos ticket caches, the initial TGT, logon sessions,
constrained-delegation cache, and preferred KDC bindings. It can also request a
ticket, purge tickets, and add or purge bindings. Without `-lh`/`-li`, ticket
operations use the current logon session's LUID.

## Commands and options

<!-- mant:entries role=command case=insensitive -->
- `klist.exe`: Inspect or deliberately change Windows Kerberos ticket/binding
  state for the current or explicitly selected logon session.
- `tickets`: List cached ticket-granting and service tickets.
- `tgt`: Display the initial ticket-granting ticket for the selected session.
- `sessions`: List logon sessions and LUIDs visible to the caller.
- `kcd_cache`: Display constrained-delegation cache information.
- `get`: Request a service ticket for the following SPN and add it to the cache.
- `purge`: Delete tickets from the selected logon session cache.
- `add_bind`: Add a preferred domain-controller binding for the specified domain.
- `query_bind`: Display cached preferred domain-controller bindings.
- `purge_bind`: Remove preferred domain-controller bindings.
- `cloud_debug`: Installed-build diagnostic subcommand absent from the current
  Microsoft Klist page. Its top-level help does not define output or side
  effects; do not invoke it merely to discover semantics.

The LUID selectors use hexadecimal high/low parts and change which logon
session a ticket operation observes or mutates.

<!-- mant:entries role=option case=insensitive -->
- `-lh`: Select the high part of a target logon session LUID.
- `-li`: Select the low part of a target logon session LUID.
- `-kdcoptions`: With `get`, supply Kerberos KDC option flags for the ticket
  request under the installed syntax and RFC 4120 contract.
- `-cacheoptions`: With `get`, supply installed-build cache options. Current
  top-level help and the Microsoft Klist page do not define the values; do not
  guess them.
- `/?`, `-?`: Display installed command help. The positional `?` spelling also
  printed the same usage and returned `-1`; it is described here instead of as
  a second semantic entry because ManT normalizes the spellings to one selector.

## PowerShell boundaries

`klist.exe` emits authentication-sensitive text and some subcommands mutate
cache/binding state. Pass LUID and SPN as separate native arguments, capture
`$LASTEXITCODE`, and preserve the failing session's tickets/events before
`get` or `purge`. Do not parse principals or times as a stable object schema;
correlate them with the actual process/session and protocol failure.

## Common mistakes

### Purging before capturing the failing ticket

`klist purge` destroys cached tickets for the selected logon session and can
interrupt access until tickets are reacquired or the user signs in again.
Capture ticket client/server principals, encryption, flags, validity, LUID,
time skew, target failure, and relevant events first.

### Inspecting the wrong logon session

Interactive, service, scheduled-task, network, and elevated processes can use
different LUIDs. “Current user” is not sufficient identity evidence. Map the
actual failing process/service to its logon session before using `-lh`/`-li`.

### Treating `get` as a read-only lookup

`klist get SPN` asks the KDC for a service ticket and changes the cache. Query
existing tickets and SPN registration first; use `get` only as an intentional
authentication test whose events and side effects are understood.

### Assuming a cached ticket proves service success

A ticket can be expired, for the wrong SPN/account, use an unsupported
encryption type, or be rejected by service configuration. Correlate DNS,
clock, SPN ownership, KDC/service events, and the actual protocol exchange.

### Sharing ticket output indiscriminately

Ticket and session reports expose principals, domains, service topology,
validity, encryption, and sometimes encoded ticket material. Store and redact
them as authentication-sensitive diagnostics.

### Treating `kdcoptions` as a standalone command

The current Microsoft parameter table labels `kdcoptions` separately, but its
syntax discussion and the installed command both show `get SPN -kdcoptions
OPTIONS`. Use the dashed option only with an intentional ticket request. The
installed `-cacheoptions` follows the same `get` syntax but lacks a current
authoritative value contract; do not invent values.

### Running `cloud_debug` because it appears in help

The recorded build lists `cloud_debug`, while the current Microsoft Klist page
does not. Presence establishes availability only, not safety, privilege,
output sensitivity, or success semantics. Obtain owning-product documentation
and an approved diagnostic scope before invoking it.

## Version and platform differences

This page documents Windows `klist.exe`. Parameters and visibility depend on
Windows release, domain/Kerberos context, logon session, and privileges; some
operations require Domain Admin or equivalent access. On Windows NT
10.0.26200.0, file version 10.0.26100.1 adds `cloud_debug` and
`-cacheoptions` beyond the current Microsoft page; the page records but does
not infer those build-dependent interfaces.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 help returned
-1 for /?, ?, and -?. Installed syntax proves -kdcoptions is a get option
rather than a standalone command and adds -cacheoptions plus cloud_debug beyond
the current Microsoft page. These are indexed without invented values or
semantics. No ticket/session query, request, purge, binding, cloud diagnostic,
SPN, LUID, domain, or KDC was supplied or changed.

## Related documents
- [setspn.exe](setspn.exe.md)
- [whoami.exe](whoami.exe.md)
- [gpresult.exe](gpresult.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[klist reference](https://learn.microsoft.com/windows-server/administration/windows-commands/klist).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
