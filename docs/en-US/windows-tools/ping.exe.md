<!-- mant:tldr:start -->
# ping.exe

> Test bounded ICMP reachability and latency on Windows.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ping.

- Send four IPv4 probes with a one-second wait for each reply:

`ping.exe /4 /n 4 /w 1000 {{host-or-address}}`

- Separate name-resolution trouble from basic IP reachability:

`ping.exe /4 /n 4 {{IPv4-address}}; ping.exe /4 /n 4 {{host-name}}`

- Test the TCP service that the application actually needs:

`Test-NetConnection -ComputerName {{host-name}} -Port {{443}} -InformationLevel Detailed`

- Probe an IPv4 path-MTU hypothesis without allowing fragmentation:

`ping.exe /4 /n 4 /f /l {{payload-bytes}} {{host-or-address}}`
<!-- mant:tldr:end -->

# ping.exe

## Overview

`ping.exe` sends ICMP echo requests and reports replies and round-trip times.
It can help separate addressing, name resolution, and basic IP reachability,
but it does not exercise an application's TCP or UDP protocol. `/n` bounds
the count, `/w` sets the per-reply timeout in milliseconds, and `/4` or `/6`
removes address-family ambiguity.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `ping.exe`: Send Windows ICMP echo probes to one host name or IP address.

Several uppercase/lowercase pairs have different meanings, so this option
index preserves the spelling in Microsoft's Windows syntax.

<!-- mant:entries role=option case=sensitive -->
- `/t`: Continue sending probes until interrupted; Ctrl+Break shows statistics
  without stopping, while Ctrl+C terminates the command.
- `/a`: Attempt reverse name resolution for a destination IP address.
- `/n`: Send the following number of echo requests instead of the default four.
- `/l`: Set the ICMP echo-request data payload size in bytes.
- `/f`: Set IPv4 Don't Fragment on the echo request for path-MTU diagnosis.
- `/I`: Set the IPv4 time-to-live value.
- `/v`: Set the IPv4 type-of-service field; modern networks may ignore it.
- `/r`: Record the IPv4 route for the following number of hops, up to the
  command's documented limit.
- `/s`: Add a timestamp for the following number of IPv4 hops.
- `/j`: Use the following loose IPv4 source-route host list.
- `/k`: Use the following strict IPv4 source-route host list.
- `/w`: Wait the following number of milliseconds for each reply.
- `/R`: Use the IPv6 routing-header test to trace the reverse route where the
  target and path support it; this is not lowercase `/r`.
- `/S`: Use the following IPv6 source address.
- `/4`: Force IPv4.
- `/6`: Force IPv6.
- `/?`: Display installed command help.

## PowerShell boundaries

PowerShell receives formatted text from `ping.exe`; a reply line is not a
typed reachability object. Always bound `/n` and `/w` in automation, check
`$LASTEXITCODE`, and use `Test-NetConnection` or an application-specific probe
when the actual requirement is a TCP service rather than ICMP.

## Common mistakes

### Equating ping with application health

A reply proves that one ICMP exchange succeeded. It does not prove that a web,
database, or remote-management port is listening or that authentication and
the application protocol work. Test the required port and then the protocol.

### Declaring a host down after an ICMP timeout

Hosts and network devices can block or deprioritize ICMP while permitted
services continue to work. Treat a timeout as one observation and compare it
with DNS, route, port, and service-specific tests.

### Leaving an unbounded probe running

`/t` continues until interrupted. Prefer an explicit `/n` in automation and
an explicit `/w`; the timeout is per request, so it contributes repeatedly to
the total duration.

### Using `/f` or packet size without the protocol boundary

`/f` is IPv4-only, and `/l` is the ICMP data size rather than the complete IP
packet size. Change one value at a time and account for headers when
investigating path MTU.

## Version and platform differences

This page documents Windows `ping.exe`; option spelling differs from common
Unix implementations. Firewalls and network policy determine whether ICMP is
observable.

## Related documents

- [tracert.exe](tracert.exe.md)
- [pathping.exe](pathping.exe.md)
- [nslookup.exe](nslookup.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[ping reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ping).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
