<!-- mant:tldr:start -->
# setspn

> Query Active Directory service-principal-name ownership and duplicates before changing it.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/setspn.

- List all SPNs registered on one exact account:

`setspn.exe -L "{{DOMAIN\account}}"`

- Query the current domain for one exact SPN:

`setspn.exe -Q "{{service/host.example.com}}"`

- Query the forest for one exact SPN:

`setspn.exe -F -Q "{{service/host.example.com}}"`

- Search the current domain for duplicate SPNs:

`setspn.exe -X`
<!-- mant:tldr:end -->

# setspn

## Overview

`setspn.exe` reads and changes the multivalued `servicePrincipalName`
attribute on Active Directory user or computer accounts. `-L`, `-Q`, and `-X`
list an account, query an SPN, and search duplicates. `-S` adds after a
duplicate check; `-D` deletes; `-R` resets default computer SPNs. `-F` extends
query scope from a domain to the forest.

## Common mistakes

### Adding with legacy `-A`

Microsoft recommends `-S`, which verifies duplicates before adding. Still run
an exact domain/forest query, identify the one service account that actually
runs the service, and preserve the pre-change account values. Syntax success
does not prove the service uses the intended identity.

### Deleting the SPN from the wrong account

A duplicate report shows attribute owners, not which deployment is correct.
Map service instance, hostname/alias and port, process identity, cluster or
load-balancer design, and delegation requirements before deleting anything.

### Using a broad wildcard as harmless discovery

Forest-wide wildcard queries can be expensive and produce ambiguous matches.
Construct the exact service class and host/port form the client requests, then
broaden only when the exact query and Kerberos events justify it.

### Confusing SPN presence with Kerberos success

DNS, clock, account keys/encryption, duplicate ownership, client target name,
delegation, service bindings, and ticket caches also matter. Verify with
`klist`, directory replication, KDC/service logs, and the actual protocol.

### Omitting user/computer account type in an ambiguous name

`-U` and `-C` explicitly select user or computer interpretation. Use them when
names could collide; record a stable directory identity rather than relying
on the tool's automatic lookup order.

### Ignoring replication and cross-forest scope

Directory changes replicate asynchronously. Query the intended domain/forest
and relevant domain controllers, and do not create a second change merely
because another controller has not converged yet.

## Version and platform differences

This Windows tool requires AD DS or the relevant management tools, directory
connectivity, elevation, and permissions to read or write target attributes.
Forest/domain topology and replication affect observations.

## Related documents

- [klist](klist.md)
- [nslookup](nslookup.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[setspn reference](https://learn.microsoft.com/windows-server/administration/windows-commands/setspn).
The recurring `-S` versus legacy `-A` question was cross-checked against
[practitioner discussion](https://serverfault.com/questions/488876/setspn-s-vs-setspn-a)
and resolved in favor of Microsoft's current documented guidance. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
