<!-- mant:tldr:start -->
# nslookup

> Query DNS records directly from Windows without confusing them with the full client resolver path.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/nslookup.

- Query IPv4 address records non-interactively:

`nslookup.exe -type=A {{host.example.com}}`

- Query IPv6 address records from one explicit DNS server:

`nslookup.exe -type=AAAA {{host.example.com.}} {{dns-server-address}}`

- Query a typed record with PowerShell's Windows DNS client cmdlet:

`Resolve-DnsName -Name {{host.example.com.}} -Type {{A}} -Server {{dns-server-address}} -DnsOnly`

- Compare the local DNS cache before assuming a direct DNS answer is what an application used:

`Get-DnsClientCache | Where-Object Entry -EQ '{{host.example.com}}'`
<!-- mant:tldr:end -->

# nslookup

## Overview

`nslookup.exe` asks a DNS server for records. In non-interactive form the first
argument is the name or address and an optional second argument selects the
server. Options such as `-type=A`, `-type=AAAA`, `-debug`, and `-nosearch`
control the query. It does not reproduce every source and policy used by a
Windows application resolver.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `nslookup.exe`: Query DNS interactively or perform one non-interactive query
  against the default or an explicitly named DNS server.

Use `nslookup [options] NAME [SERVER]` for automation. Starting it without a
name enters a stateful interactive command interpreter whose `set` commands
are outside this non-interactive option summary.

<!-- mant:entries role=option case=insensitive -->
- `-type`: Select the record type, for example `-type=A`, `-type=AAAA`,
  `-type=MX`, or `-type=ANY`; `-querytype` is the equivalent long name.
- `-querytype`: Select the DNS record type; it is equivalent to `-type`.
- `-class`: Select the DNS query class; the normal default is `IN`.
- `-port`: Select a DNS server port instead of the normal DNS port.
- `-timeout`: Set the initial response timeout in seconds.
- `-retry`: Set how many times a request is retried.
- `-debug`: Enable debugging output for the query and response packets.
- `-d2`: Enable exhaustive debugging output.
- `-domain`: Set the default DNS domain used by lookup policy.
- `-search`: Use the DNS suffix search list for a name that is not absolute.
- `-nosearch`: Do not append suffixes from the DNS search list.
- `-recurse`: Ask the selected DNS server to recurse when it supports recursion.
- `-norecurse`: Request a non-recursive answer, commonly for authoritative
  server diagnosis.
- `-vc`: Use a virtual circuit (TCP) for the DNS request.
- `-novc`: Use the normal datagram behavior unless truncation/retry requires
  otherwise.

## PowerShell boundaries

Arguments beginning with `-` go to the native executable when it is invoked
as `nslookup.exe`; they are not PowerShell parameters. Output and diagnostic
labels are text. For typed scripts prefer `Resolve-DnsName`, or otherwise
check `$LASTEXITCODE`, the requested record, response status, and selected
server instead of matching one success-looking line.

## Common mistakes

### Expecting nslookup and an application to return the same address

Applications may use the Hosts file, resolver cache, suffix policy, multiple
DNS answers, or another name-resolution mechanism. A direct query to one DNS
server is evidence about that server's answer, not proof of the address an
application selected.

### Letting the DNS suffix search change the queried name

A name without a trailing dot can be expanded according to client search
settings. Use a fully qualified name with a trailing dot when the exact DNS
name matters, and preserve both the query name and selected server.

### Automating interactive mode

With no lookup name, `nslookup` enters a stateful prompt whose server and
options can change. Use one complete non-interactive invocation per scripted
query and check `$LASTEXITCODE` together with the requested record in output.

### Treating “non-authoritative” as a failed lookup

Recursive resolvers normally return cached, non-authoritative answers. Check
the response record, status, server, TTL, and whether an authoritative query
was actually required instead of classifying the label alone as failure.

## Version and platform differences

This page documents Windows `nslookup.exe`. `Resolve-DnsName` belongs to the
Windows DnsClient module. DNS results vary by queried server, network, policy,
record TTL, and time.

## Related documents

- [ipconfig](ipconfig.md)
- [ping](ping.md)
- [hostname](hostname.md)

## Sources and license

This original guide was adapted from Microsoft's official
[nslookup reference](https://learn.microsoft.com/windows-server/administration/windows-commands/nslookup).
High-frequency resolver misunderstandings were cross-checked against
[practitioner discussion](https://stackoverflow.com/questions/40865612/why-ip-of-nslookup-and-ping-is-not-the-same)
and then verified against the official command boundary. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
