<!-- mant:tldr:start -->
# dfsdiag.exe

> Diagnose DFS Namespaces—not DFS Replication—using an exact domain, machine,
> namespace root, or folder path before expanding recursive/full tests.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/dfsdiag.

- Check the DFS Namespace site association for one exact machine:

`dfsdiag.exe /testsites /machine:"{{fileserver01.example.com}}"`

- Validate the configuration of one exact domain-based namespace root:

`dfsdiag.exe /testdfsconfig /DFSRoot:"{{\\example.com\shares}}"`

- Validate the non-recursive integrity of one exact namespace root:

`dfsdiag.exe /testdfsintegrity /DFSRoot:"{{\\example.com\shares}}"`

- Request and diagnose a referral for one exact DFS folder path:

`dfsdiag.exe /testreferral /DFSPath:"{{\\example.com\shares\team}}" /full`

<!-- mant:tldr:end -->

# dfsdiag.exe

## Overview

`dfsdiag.exe` diagnoses DFS Namespaces (DFSN): domain-controller configuration,
site associations, namespace configuration/integrity, and referrals. It does
not measure DFS Replication (DFSR) file convergence, backlog, conflicts, or
SYSVOL migration. Install the applicable DFS Namespaces management tools and
run from an identity allowed to query every explicit target.

## Tests and parameters

<!-- mant:entries role=command case=insensitive -->
- `dfsdiag.exe`: Run one DFS Namespaces diagnostic test against an explicit scope.

The primary test is expressed as a slash option. Other parameters are valid
only with tests whose official syntax includes them.

<!-- mant:entries role=option case=insensitive -->
- `/testdcs`: Check domain-controller configuration for DFS Namespaces.
- `/testsites`: Check server or DFS target site associations.
- `/testdfsconfig`: Check configuration for one domain-based namespace root.
- `/testdfsintegrity`: Check metadata integrity for one namespace root.
- `/testreferral`: Request and validate referrals for one exact DFS path.
- `/domain`: Select the AD domain used by `/testdcs`.
- `/machine`: Select one server for the site-association test.
- `/dfspath`: Select a namespace root or DFS folder path.
- `/dfsroot`: Select the namespace root used by configuration/integrity tests.
- `/recurse`: Expand a supported test through child namespace folders.
- `/full`: Request extended result detail for a supported test.
- `/?`: Display the installed DFS diagnostic syntax.

## Test map

- `/testdcs /domain:<domain>` checks DC configuration and can contact multiple
  DCs; approve the domain-wide scope before use.
- `/testsites /machine:<server>` checks the server-to-site association.
- `/testsites /DFSPath:<path>` checks sites for namespace targets; `/recurse`
  expands through child folders and `/full` increases detail.
- `/testdfsconfig /DFSRoot:<root>` checks namespace configuration.
- `/testdfsintegrity /DFSRoot:<root>` checks consistency; `/recurse` can expand
  through the namespace.
- `/testreferral /DFSPath:<path>` exercises the referral path that a client
  needs, with `/full` detail.

## Common mistakes

### Confusing namespace availability with replicated data health

A healthy referral can point to a target whose share, ACL, storage, application,
or DFSR data is unhealthy. Conversely, DFSR can be healthy while DNS, AD, site
cost, namespace metadata, SMB, or client referral cache makes the path fail.
Test each layer separately.

### Testing only from a server

Referrals depend on the caller's DNS, domain/site, network, identity, client
cache, and reachable DC/namespace server. Reproduce from the affected client
and compare with an approved management host, preserving both UTC timestamps,
sites, chosen DC, referral target, and path.

### Using `/recurse /full` as the first step

Large namespaces can create extensive AD/SMB/RPC queries, output, and load.
Start with one exact root or leaf; expand only after identifying the failing
branch and approving the target count, time window, and evidence handling.

### Assuming a UNC path identifies one server

A domain-based namespace name is resolved through AD/DNS and referrals; it is
not a physical share. Record namespace root, folder, returned target UNC,
target state/priority, site/cost, TTL, namespace server, and DC separately.

### Flushing caches before collecting them

Client referral, domain, site, and DNS caches can explain intermittent delay or
wrong-target selection. Preserve `dfsutil cache`/DNS/site evidence before any
flush, service restart, target disablement, priority change, or metadata edit.

### Treating one successful referral as end-to-end access

Verify exact SMB target resolution, TCP/authentication, share and NTFS effective
access, file/path existence, storage health, and expected data version. Do not
change namespace targets to mask an authorization or replication problem.

## PowerShell boundaries

Invoke `dfsdiag.exe` explicitly and capture `$LASTEXITCODE` with the full
localized output. Avoid success/failure parsing by English phrase alone. Use
the DFSN module for typed namespace, folder, target, and client-configuration
inventory, while retaining Dfsdiag for its diagnostic tests.

## Version and platform differences

Dfsdiag is Windows-only and feature/RSAT-dependent. DFSN mode, domain/forest
state, site topology, client/server version, SMB policy, privileges, and test
output vary. Check target-local help and current DFSN documentation; do not
infer DFSR availability from Dfsdiag presence.

## Related documents

- [dfsrmig.exe](dfsrmig.exe.md)
- [ntfrsutl.exe](ntfrsutl.exe.md)
- [dcdiag.exe](dcdiag.exe.md)
- [nslookup.exe](nslookup.exe.md)
- [net.exe](net.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Dfsdiag reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dfsdiag)
and its linked per-test pages. Client referral-cache and layer confusion were
cross-checked against a practitioner question about
[long DFS Namespace pauses](https://serverfault.com/questions/50789/).
Microsoft documentation governs test behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
