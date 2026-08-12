<!-- mant:tldr:start -->
# repadmin.exe

> Inspect Active Directory replication direction, naming context, partner, and
> timestamps before considering any command that forces replication or changes
> topology.
> More information: https://learn.microsoft.com/windows-server/identity/ad-ds/manage/troubleshoot/troubleshooting-active-directory-replication-problems.

- Summarize replication failures and largest deltas involving one exact DC:

`repadmin.exe /replsummary "{{dc01.example.com}}" /bysrc /bydest`

- Show inbound replication partners and status for every naming context on one exact destination DC:

`repadmin.exe /showrepl "{{dc01.example.com}}" /all /verbose`

- Export current inbound replication status for one exact destination DC as CSV for reviewed analysis:

`repadmin.exe /showrepl "{{dc01.example.com}}" /csv | Out-File -LiteralPath "{{showrepl.csv}}" -Encoding utf8 -NoClobber`

- Inspect pending inbound replication work on one exact destination DC:

`repadmin.exe /queue "{{dc01.example.com}}"`

<!-- mant:tldr:end -->

# repadmin.exe

## Overview

`repadmin.exe` diagnoses and administers Active Directory replication. It is
available on domain controllers and through the applicable AD DS RSAT tools.
The current Microsoft AD DS troubleshooting guidance still uses Repadmin,
although its exhaustive command reference is published under previous-version
documentation. Treat local `/help` on the exact Server/RSAT build as the syntax
contract.

Replication evidence is directional and partition-specific. For every result,
record the destination DC, inbound source partner, naming context, DSA object
GUID, invocation ID, transport, last attempt, last success, consecutive failure
count, status code, collection time, and selected DSA list.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `repadmin.exe`: Inspect or administer AD replication on DCs selected by one
  explicit DSA-list scope.

Repadmin spells command families as slash tokens. Inventory and mutation
families share selectors, so identify direction and naming context first.

<!-- mant:entries role=option case=insensitive -->
- `/replsummary`: Summarize replication failures and largest deltas.
- `/showrepl`: Display inbound partners and status by destination/naming context.
- `/queue`: Display pending inbound replication tasks for one destination DC.
- `/showconn`: Display connection objects for selected domain controllers.
- `/showutdvec`: Display one DC's up-to-dateness vector for a naming context.
- `/showobjmeta`: Display replication metadata for one AD object.
- `/showattr`: Display selected object attributes from one DC.
- `/showbridgeheads`: Display bridgehead-server selection for sites/transports.
- `/replicate`: Initiate replication of one naming context from source to destination.
- `/syncall`: Initiate broad replication using selected topology/flags.
- `/kcc`: Trigger KCC topology recalculation on selected DCs.
- `/options`: Query or change NTDS Settings options.
- `/siteoptions`: Query or change site options.
- `/regkey`: Query or change supported Repadmin-related DC registry settings.
- `/removelingeringobjects`: Remove identified lingering objects under an
  incident-specific source/partition procedure.
- `/csv`: Request CSV rendering from a family that supports it.
- `/all`: Expand supported output/operation to all naming contexts or partners.
- `/verbose`: Emit extended result detail.
- `/help`: Display top-level command help.
- `/?`: Display command help.

## Command-family map

- Health inventory: `/replsummary`, `/showrepl`, `/queue`, `/showconn`,
  `/showutdvec`, `/showobjmeta`, `/showattr`, and topology/bridgehead discovery.
- Replication activity: `/replicate`, `/syncall`, `/kcc`, and related commands
  can initiate work or rebuild topology. They are not read-only probes.
- Configuration: `/options`, `/siteoptions`, `/regkey`, connection management,
  and password replication policy can alter AD or DC behavior.
- Recovery: lingering-object removal, rehost, partition synchronization, and
  read-only DC password-policy operations require incident-specific procedures.

Use `repadmin /help:<command>` locally before any family beyond the TLDR. DSA
list selectors such as `*`, site, global-catalog, or wildcard forms can expand a
single command to many domain controllers.

## Common mistakes

### Reading `/replsummary` as an instantaneous health check

The summary aggregates failures and largest deltas and can retain evidence of
earlier trouble. Use it to locate candidates, then inspect `/showrepl` for the
exact destination DC and naming context, compare last attempt with last success,
and correlate current Directory Service/DNS/Kerberos events. Never clear the
signal by forcing replication merely to obtain a newer timestamp.

### Reversing source and destination

`/showrepl <DC>` reports that destination DC's inbound neighbors. A source DSA
listed under a naming context is the partner from which that destination pulls.
Write the direction explicitly before diagnosing DNS, RPC, credentials, SPNs,
firewall paths, schedules, or objects.

### Treating one partition as the whole directory

The domain, Configuration, Schema, DomainDnsZones, ForestDnsZones, and
application partitions have distinct replica sets and status. A successful
domain naming context does not erase a DNS-application-partition failure.
Preserve the distinguished name rather than grouping rows only by server.

### Assuming every nonzero status means the same repair

Resolve the numeric status in its documented context. For example, status 8464
can mean that global-catalog partial-attribute synchronization is delayed for a
normal reason. Tombstone-lifetime, lingering-object, DNS, RPC, Kerberos/SPN,
time, and topology errors have different containment and recovery paths.

### Using `/syncall` or `/replicate` as a diagnostic fix

Forced replication can cross sites, consume constrained links, spread an
unwanted change, bypass the intended schedule, or worsen a lingering-object
incident. Establish the authoritative source, data state, naming context,
topology, time/DNS/security health, and recovery gate before initiating work.

### Deleting stale objects or metadata from an error string

A named DC may be offline temporarily, decommissioned incompletely, restored
with a new invocation ID, or still authoritative for a partition. Correlate AD
Sites and Services, DNS, computer/server/NTDS objects, backup/restore history,
and every replica before metadata cleanup or lingering-object operations.

## PowerShell boundaries

Repadmin writes localized text; `/showrepl /csv` is the most useful interchange
form but should first be preserved as raw evidence. Encoding, a preamble, quoted
fields, column names, and diagnostic lines can vary. Validate the exact file
before `Import-Csv`, and never discard an unexpected leading line mechanically.
Invoke `repadmin.exe`, capture `$LASTEXITCODE`, and avoid treating pipeline text
matching as a complete replication monitor.

## Version and platform differences

Repadmin is Windows-only and tied to AD DS/RSAT. The detailed command-reference
page is legacy documentation; current Microsoft AD DS troubleshooting pages
confirm use on supported Windows Server releases. Subcommands, selectors,
privileges, output, status semantics, and AD features vary. Verify target-local
help and current issue-specific Microsoft guidance before operational use.
Exact System32 discovery on the recorded Windows NT `10.0.26200.0` client
found no `repadmin.exe`; no help, replication query, CSV collection, sync,
KCC/topology, lingering-object, password-policy, or directory change ran.

## Runtime evidence

Exact System32 discovery on Windows NT 10.0.26200.0 found no repadmin.exe. It
remains documented as an optional AD DS/RSAT tool; no help, replication query,
CSV collection, sync, replicate, KCC/topology, lingering-object, rehost,
password-policy, credential, or directory operation ran.

## Related documents
- [dcdiag.exe](dcdiag.exe.md)
- [nltest.exe](nltest.exe.md)
- [netdom.exe](netdom.exe.md)
- [setspn.exe](setspn.exe.md)
- [w32tm.exe](w32tm.exe.md)
- [wevtutil.exe](wevtutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[AD replication troubleshooting guide](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/troubleshoot/troubleshooting-active-directory-replication-problems),
its current explanation of
[replication status 8464](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/replication-error-8464),
and the official previous-version
[Repadmin reference](https://learn.microsoft.com/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc770963(v=ws.11)).
The common confusion between summary history and current per-partition status
was cross-checked against a
[Server Fault troubleshooting question](https://serverfault.com/questions/818195/).
Microsoft and target-local help govern behavior; community repair suggestions
are not operational instructions. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
