<!-- mant:tldr:start -->
# klist

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

# klist

## Overview

`klist.exe` inspects Kerberos ticket caches, the initial TGT, logon sessions,
constrained-delegation cache, and preferred KDC bindings. It can also request a
ticket, purge tickets, and add or purge bindings. Without `-lh`/`-li`, ticket
operations use the current logon session's LUID.

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

## Version and platform differences

This page documents Windows `klist.exe`. Parameters and visibility depend on
Windows release, domain/Kerberos context, logon session, and privileges; some
operations require Domain Admin or equivalent access.

## Related documents

- [setspn](setspn.md)
- [whoami](whoami.md)
- [gpresult](gpresult.md)

## Sources and license

This original guide was adapted from Microsoft's official
[klist reference](https://learn.microsoft.com/windows-server/administration/windows-commands/klist).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
