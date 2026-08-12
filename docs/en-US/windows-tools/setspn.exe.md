<!-- mant:tldr:start -->
# setspn.exe

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

# setspn.exe

## Overview

`setspn.exe` reads and changes the multivalued `servicePrincipalName`
attribute on Active Directory user or computer accounts. `-L`, `-Q`, and `-X`
list an account, query an SPN, and search duplicates. `-S` adds after a
duplicate check; `-D` deletes; `-R` resets default computer SPNs. `-F` extends
query scope from a domain to the forest.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `setspn.exe`: Query or deliberately change Active Directory
  `servicePrincipalName` values on exact user/computer accounts.

Query exact ownership and duplicates before a write, then account for
replication before concluding that a second change is needed.

<!-- mant:entries role=option case=insensitive -->
- `-L`: List every SPN registered on the following exact account.
- `-Q`: Query for owners of the following SPN; wildcards broaden scope.
- `-X`: Search for duplicate SPNs.
- `-S`: Add the following SPN to an account after checking for duplicates;
  prefer this over legacy `-A`.
- `-A`: Add an SPN without the recommended duplicate-check safeguard.
- `-D`: Delete the following exact SPN from the following exact account.
- `-R`: Reset the default SPN registrations for the following computer account.
- `-F`: Use forest scope instead of the current domain for `-Q` or `-X`.
- `-T`: Use the following domain/forest scope instead of the current context.
- `-U`: Interpret the supplied account as a user account.
- `-C`: Interpret the supplied account as a computer account.
- `-P`: Suppress progress to the console (quiet mode); it does not make a
  directory mutation safer.
- `/?`, `-?`: Display installed command help. On the recorded Windows build
  either documented spelling printed help and returned exit code 2; the help
  body did not list the help spellings themselves.

## PowerShell boundaries

`setspn.exe` returns directory query/mutation results as text. Pass the SPN and
account as separate native arguments, capture `$LASTEXITCODE`, and preserve
pre-change account values. For typed automation use Active Directory APIs or
cmdlets with an explicit server/domain and stable distinguished identity; still
verify forest uniqueness, replication, tickets, and the actual service protocol.

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
Forest/domain topology and replication affect observations. On Windows NT
`10.0.26200.0`, installed file version `10.0.26100.8115` printed 59 nonempty
help lines for `/?` and returned 2; a separate `-?` probe produced the same
help-specific status. Do not interpret that nonzero help status as an AD DS,
account, SPN, connectivity, or authorization failure.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8115
ordinary-token /? printed 59 nonempty help lines and returned 2; the official
-? spelling separately returned 2. Both are indexed in one help entry, and
their nonzero help status is not classified as an AD DS, SPN, connectivity,
account, or authorization failure. No domain, account, SPN, wildcard, ticket,
directory, credential, or network target was supplied or queried.

## Related documents
- [klist.exe](klist.exe.md)
- [nslookup.exe](nslookup.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[setspn reference](https://learn.microsoft.com/windows-server/administration/windows-commands/setspn).
The recurring `-S` versus legacy `-A` question was cross-checked against
[practitioner discussion](https://serverfault.com/questions/488876/setspn-s-vs-setspn-a)
and resolved in favor of Microsoft's current documented guidance. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
