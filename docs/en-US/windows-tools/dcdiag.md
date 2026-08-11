<!-- mant:tldr:start -->
# dcdiag

> Diagnose one explicitly named Active Directory domain controller first;
> broad enterprise and repair modes can contact many systems or change the DC
> computer object.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/dcdiag.

- Confirm which DCDiag executable and version PowerShell will run:

`Get-Command dcdiag.exe -ErrorAction Stop | Select-Object Source, Version`

- Test DNS, LDAP, RPC, and ICMP connectivity to one exact domain controller:

`dcdiag.exe /s:"{{dc01.example.com}}" /test:Connectivity /v`

- Run only the basic DNS checks against one exact domain controller:

`dcdiag.exe /s:"{{dc01.example.com}}" /test:DNS /DnsBasic /v`

- Inspect replication connection status for every naming context on one exact domain controller:

`dcdiag.exe /s:"{{dc01.example.com}}" /test:Replications /v`

<!-- mant:tldr:end -->

# dcdiag

## Overview

`dcdiag.exe` runs Active Directory Domain Services health tests against domain
controllers. It is installed on a domain controller or with the AD DS Remote
Server Administration Tools (RSAT), and Microsoft requires an elevated shell.
The target, naming context, test, credentials, site, and enterprise scope are
independent dimensions; record all of them with the output.

Start with one DNS-named DC and one named test. A passing test proves only the
conditions that test observed from the calling host and identity at that time.
It does not establish complete DNS, Kerberos, SYSVOL, replication, application,
or client health.

## Scope and test map

- `/s:<dc>` selects one DC. With no `/s`, DCDiag uses a local/home DC; do not
  let that implicit selection obscure which server was tested.
- `/n:<naming-context>` scopes tests that accept a domain, DNS name, or
  distinguished name. Record the exact value.
- `/a` selects all DCs in the current site; `/e` selects the enterprise and
  overrides `/a`. Both expand network, privilege, output, and WAN scope.
- `/test:<name>` selects a test. Connectivity is required and cannot be skipped.
- `/c` adds non-default tests such as Topology, CutoffServers, and
  OutboundSecureChannels. It is not merely “more verbose.”
- `/q` emits errors only; `/v` provides context needed to identify targets and
  subtests. Preserve full output before reducing it.
- `/f` and DNS `/x` write logs that can expose topology, names, addresses, SPNs,
  accounts, and failures. Protect and retire them as operational evidence.

Important focused tests include Connectivity, Advertising, Services,
Replications, DFSREvent, KccEvent, SystemLog, MachineAccount, NetLogons,
SysVolCheck, and DNS. Read `dcdiag /?` and the official test table for the exact
target build before selecting less common test-specific parameters.

## Common mistakes

### Running `/test:DNS` without understanding its subtests

With no DNS subtest, DCDiag defaults to `/DnsAll`. Delegation, forwarder,
dynamic-update, record-registration, and external-name results answer different
questions and can legitimately differ. Begin with `/DnsBasic`, then add exactly
the subtest that matches the hypothesis. Do not “fix DNS” from an unscoped red
line without identifying the queried zone, resolver, record, and authoritative
server.

### Treating event-window failures as current service failures

Some tests intentionally inspect history: DFSREvent and FrsEvent inspect the
past 24 hours, SystemLog the past 60 minutes, and KccEvent the past 15 minutes.
A service can work now while the test still reports an event in its window.
Correlate event record ID, provider, DC, UTC timestamp, current state, and a
fresh bounded test; do not erase logs to make the result green.

### Expanding to `/a`, `/e`, or `/c` too early

Enterprise scope can contact every DC and cross constrained WAN links.
CutoffServers triggers replication checks, and Intersite can trigger replication
while testing. Topology uses a do-not-sync flag and therefore does not prove
partner availability or schedule health. Approve the exact tests, sites, links,
maintenance window, credentials, and evidence destination before expansion.

### Assuming every pass covers the whole protocol

Advertising can pass without proving that a KDC answers Kerberos over the
required transport. Connectivity checks locator/DNS, ICMP, LDAP, and RPC, but
does not validate every naming context or client path. Combine the smallest
relevant DCDiag test with exact DNS queries, time state, event data, Repadmin
status, and a client-side reproduction.

### Using repair switches during diagnosis

`/fix` changes SPNs for the MachineAccount test. Machine-account repair options
can change the DC object; Microsoft explicitly says recreating only the missing
computer object is not a recommended substitute for restoring its child
relationships. Preserve evidence and use a reviewed AD recovery runbook,
healthy replication evidence, backup/rollback, and independent authorization.

### Putting a password on the command line

Use the current approved identity where possible. If alternate credentials are
necessary, `/p:*` prompts; a literal password can leak through history, process
inspection, transcripts, job logs, and monitoring. Confirm that the account has
only the read/diagnostic rights required by the selected test.

## PowerShell behavior

Invoke `dcdiag.exe` explicitly to avoid command-name ambiguity. Its output is
localized human text, not a stable object or line protocol; do not decide health
with a single `Select-String 'passed'`. Preserve the raw output, target, locale,
start/end time, tool version, and `$LASTEXITCODE`, then parse only a tested
version-specific fixture. Prefer typed AD, DNS, event, and CIM APIs when an
automation contract is required.

## Version and platform differences

DCDiag is Windows-only and requires a DC or the applicable RSAT AD DS tools.
Tests, event providers, SYSVOL replication technology, functional-level
behavior, privileges, and documented applicability vary by Windows/Server
release. Verify local `dcdiag /?`, installed feature provenance, DC/forest
functional levels, and the current Microsoft Learn page on the target estate.

## Related documents

- [repadmin](repadmin.md)
- [nltest](nltest.md)
- [netdom](netdom.md)
- [nslookup](nslookup.md)
- [w32tm](w32tm.md)
- [setspn](setspn.md)

## Sources and license

This original guide was adapted from Microsoft's official
[DCDiag reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dcdiag)
and its linked test descriptions. DNS-subtest and historical-event
interpretation were cross-checked against practitioner questions about
[DCDiag DNS failures](https://serverfault.com/questions/958824/) and
[different results on the same DC](https://serverfault.com/questions/851101/).
Community material identifies recurring mistakes; Microsoft documentation and
target-local help govern supported behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
