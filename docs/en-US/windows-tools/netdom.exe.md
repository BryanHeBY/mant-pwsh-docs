<!-- mant:tldr:start -->
# netdom.exe

> Query one explicit Active Directory domain or verify one explicit member
> computer; most other Netdom families change membership, names, credentials,
> trusts, or reboot state.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/netdom.

- List domain controllers registered for one exact domain:

`netdom.exe query /domain:"{{example.com}}" DC`

- Show the FSMO role holders reported for one exact domain:

`netdom.exe query /domain:"{{example.com}}" FSMO`

- List trust relationships visible from one exact domain:

`netdom.exe query /domain:"{{example.com}}" TRUST`

- Verify, without resetting, the secure connection of one exact member computer:

`netdom.exe verify "{{member01.example.com}}" /domain:"{{example.com}}"`

<!-- mant:tldr:end -->

# netdom.exe

## Overview

`netdom.exe` manages Active Directory computer accounts, membership, names,
secure channels, and domain trusts. It is installed with AD DS or the applicable
RSAT tools, and Microsoft requires an elevated shell. Only `query` and carefully
scoped `verify` belong in a routine diagnostic pass; the rest of the family can
change directory, host, trust, credential, or reboot state.

Name the domain, computer, relationship, direction, calling identity, selected
DC, and expected current state before invoking Netdom. A successful query is
inventory, not proof that all DCs agree or replication has converged.

## Command families and common parameters

<!-- mant:entries role=command case=insensitive -->
- `netdom.exe`: Inspect or administer AD computer membership, names, secure
  channels, machine passwords, and trusts.
- `query`: List selected workstation, server, DC, OU, trust, or FSMO objects.
- `verify`: Verify a member workstation/server secure connection.
- `add`: Add a workstation or server account to a domain.
- `join`: Join a workstation or member server to a domain.
- `move`: Move a workstation/member-server account to a different domain.
- `remove`: Remove a workstation or member server from a domain.
- `renamecomputer`: Rename a workstation or member server.
- `computername`: Manage primary/alternate names for a computer, including DC workflow.
- `reset`: Reset a member workstation/server secure channel.
- `resetpwd`: Reset the local DC's machine-account password under a DC procedure.
- `trust`: Create, verify, reset, remove, or configure a domain/forest trust.
- `movent4bdc`: Perform the historical Windows NT 4.0 BDC migration operation.
- `help`: Display top-level or family-specific help.

Parameters vary by family. Never assume a same-named credential or target
parameter has identical authority and side effects across member, DC, and trust use.

<!-- mant:entries role=option case=insensitive -->
- `/domain`: Select the exact domain for a supported family.
- `/server`: Select a domain controller used for the operation where supported.
- `/userd`: Select an account for the target/destination domain.
- `/passwordd`: Supply or prompt for the destination-domain password.
- `/usero`: Select an account for the origin/trusted domain.
- `/passwordo`: Supply or prompt for the origin-domain password.
- `/securepasswordprompt`: Request the documented protected credential prompt.
- `/verbose`: Emit extended diagnostic output.
- `/reboot`: Restart the target after a supported operation, optionally after a delay.
- `/?`: Display installed family syntax.

## Command-family map

- Inventory: `query` supports domain objects such as workstations, servers,
  DCs, organizational units, trusts, and FSMO holders.
- Verification: `verify` checks a workstation/member-server secure connection;
  trust verification belongs to the separately scoped `trust` family.
- Computer lifecycle: `add`, `join`, `move`, `remove`, `renamecomputer`, and
  `computername` change accounts, membership, or names.
- Secure-channel repair: `reset` targets a member workstation/server;
  `resetpwd` changes a domain controller machine-account password.
- Trust lifecycle: `trust` can create, verify, reset, remove, or configure
  domain/forest trust behavior.
- `movent4bdc` is a Windows NT 4.0 migration operation, not a modern rename
  shortcut.

Read `netdom help <family>` locally for that exact Server/RSAT build. Generic
options such as credentials, `/verbose`, `/reboot`, and `/securepasswordprompt`
do not make a mutating family safe.

## Common mistakes

### Confusing `reset` with `resetpwd`

`netdom reset` repairs the secure connection of a member workstation or server.
`netdom resetpwd` resets a domain controller's machine-account password and is
run locally on the affected DC under a DC-specific Microsoft procedure. Mixing
them can deepen authentication and replication failure.

### Renaming a domain controller with the member command

`renamecomputer` is for domain workstations and member servers. Microsoft
directs domain-controller renames through `computername`, which manages primary
and alternate names and requires the full DC rename workflow. Validate DNS,
SPNs, certificates, services, clients, replication, backup, and rollback.

### Getting trust direction backwards

A one-way trust has a trusting side and a trusted side; the side that accepts
the other domain's identities is not interchangeable with the account-holding
side. Write the resource domain, account domain, incoming/outgoing direction,
transitivity, forest scope, selective authentication, SID filtering, DNS path,
and both administrative identities before a trust operation.

### Supplying passwords inline

Use current credentials or `*` prompt forms approved by the procedure. Literal
passwords can leak through history, process inspection, transcripts, job logs,
and monitoring. `/securepasswordprompt` is not a general secret vault and only
affects the documented prompt form.

### Forgetting that a family may reboot the target

Operations that accept `/reboot` can restart a computer after completion; the
documented default delay is 20 seconds. Never carry `/reboot` from an example
into diagnosis. Require workload ownership, drain/cluster procedure,
maintenance window, independent target confirmation, and cancellation plan.

### Repairing before checking replication and identity

A secure-channel failure can be caused or obscured by DNS, time, stale computer
objects, duplicate SPNs, snapshots/restores, replication divergence, wrong DC
selection, or a decommissioned host. Preserve DCDiag/Repadmin/NLTest evidence
and identify the authoritative account state before any reset, join, remove,
move, rename, password, or trust change.

## PowerShell boundaries

Invoke `netdom.exe` explicitly, quote DNS names, capture `$LASTEXITCODE`, and
preserve the full localized output. Avoid parsing success from one English
sentence. Prefer typed AD cmdlets/APIs for repeatable inventory, but do not
mechanically replace a Netdom recovery procedure with a similarly named cmdlet;
member, DC, and trust credentials have different lifecycle semantics.

## Version and platform differences

Netdom is Windows-only and AD DS/RSAT-dependent. Current Microsoft Learn lists
supported Windows Server releases, but families and options still vary with
Server/RSAT build, domain/forest functional level, trust type, privilege, and
policy. Verify local family help and the current family-specific Microsoft page.
Exact System32 discovery on the recorded Windows NT `10.0.26200.0` client
found no `netdom.exe`; no help, domain query, membership, verify, rename,
reset, password, trust, reboot, credential, or directory operation ran.

## Runtime evidence

Exact System32 discovery on Windows NT 10.0.26200.0 found no netdom.exe. It
remains documented as an optional AD DS/RSAT tool; no help, domain query,
membership, verify, account, join/move/remove, rename/name, reset/password,
trust, credential, reboot, or directory operation ran.

## Related documents
- [nltest.exe](nltest.exe.md)
- [dcdiag.exe](dcdiag.exe.md)
- [repadmin.exe](repadmin.exe.md)
- [setspn.exe](setspn.exe.md)
- [w32tm.exe](w32tm.exe.md)
- [gpresult.exe](gpresult.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Netdom overview](https://learn.microsoft.com/windows-server/administration/windows-commands/netdom)
and its linked family pages, including the distinct
[domain-controller password-reset procedure](https://learn.microsoft.com/windows-server/administration/windows-commands/netdom-resetpwd).
Secure-channel troubleshooting demand was cross-checked against a
[Server Fault question](https://serverfault.com/questions/430042/), but its
repair suggestions are not treated as a runbook. Microsoft documentation and
target-local help govern supported behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
