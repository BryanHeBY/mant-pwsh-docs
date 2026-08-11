<!-- mant:tldr:start -->
# rpcping

> Test one bounded Microsoft RPC binding or Endpoint Mapper path; this is not ICMP ping or ONC RPC rpcinfo.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rpcping.

- Display the installed tool's protocol, interface, endpoint, and authentication syntax:

`rpcping.exe /?`

- Test TCP reachability to the Microsoft RPC Endpoint Mapper before an RPC call:

`Test-NetConnection "{{server.example.com}}" -Port 135 -InformationLevel Detailed`

- Make one unauthenticated TCP RPC ping to the exact server's Endpoint Mapper with verbose evidence:

`rpcping.exe /t ncacn_ip_tcp /s "{{server.example.com}}" /i 1 /v 2`

- Resolve the target and record all addresses so an address-family mismatch is visible:

`Resolve-DnsName "{{server.example.com}}" | Select-Object Name,Type,IPAddress`
<!-- mant:tldr:end -->

# rpcping

## Overview

`rpcping.exe` exercises Microsoft RPC bindings using protocol sequences such as
`ncacn_ip_tcp`, `ncacn_np`, or `ncacn_http`. Without `/e` or `/f`, it pings the
target Endpoint Mapper. It can bind an exact endpoint or interface UUID and add
RPC/proxy authentication. Its official description is Exchange-oriented, but
the binding concepts are general Microsoft RPC.

## Common mistakes

### Calling it an ICMP ping or confusing it with `rpcinfo`

It makes RPC calls, not ICMP echo. `rpcinfo` is ONC RPC/portmapper; `rpcping`
is Microsoft RPC Endpoint Mapper/interface binding. Results are not comparable.

### Treating TCP 135 success as service success

The Endpoint Mapper returns the endpoint for a registered interface, commonly
in the RPC dynamic-port range. Firewall, interface registration, authentication
and the second connection can still fail. Test the exact interface UUID/version
or known endpoint when diagnosing an application.

### Omitting `/f` and claiming a specific service was tested

A default Endpoint Mapper ping proves only that path. Capture the application's
interface UUID, major version, protocol sequence, SPN/auth requirements and
expected endpoint from authoritative deployment evidence.

### Embedding `/I`, `/P`, or `/A` passwords

Identity syntax can include `user,domain,password`, exposing secrets to process
inspection and logs. Use `*` prompting only in an approved interactive test or
the current identity; avoid Basic auth without protected RPC/HTTP transport.

### Using `/q` or high `/i` values during diagnosis

Quiet mode assumes yes to queries and hides context; repeated calls create load
and misleading latency data. Start with one verbose call and bounded scope.

### Treating certificate subject text as complete TLS identity validation

RPC/HTTP proxy options, SChannel/RPC auth, HTTP proxy auth and backend RPC are
separate layers. Validate chain, hostname, expected publisher/service, proxy and
backend independently; do not disable verification to obtain a response.

## PowerShell behavior

Call `rpcping.exe` explicitly and quote comma-containing identity/binding values
as single arguments. Check `$LASTEXITCODE` immediately. Avoid placing secrets in
variables that transcripts/loggers capture, and preserve verbose native output.

## Version and platform differences

Windows-only. Available auth packages, RPC/HTTP proxy behavior, dynamic-port
policy, endpoint registration and hardening differ by build/domain/service.
Local help and the target application's current interface contract govern.

## Related documents

- [rpcinfo](rpcinfo.md)
- [ping](ping.md)
- [setspn](setspn.md)
- [netstat](netstat.md)

## Sources and license

This original guide was adapted from Microsoft's official
[rpcping reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rpcping),
[RPC firewall guidance](https://learn.microsoft.com/windows/security/threat-protection/windows-firewall/best-practices-configuring)
and [RPC error troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/replication-error-1722-rpc-server-unavailable).
Endpoint/dynamic-port confusion was cross-checked against a
[practitioner RPC port discussion](https://serverfault.com/questions/393674/what-is-the-sequence-of-windows-rpc-ports-135-137-139-and-higher-ports-what).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
