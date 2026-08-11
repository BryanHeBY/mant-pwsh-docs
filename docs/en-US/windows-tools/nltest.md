<!-- mant:tldr:start -->
# nltest

> Query the current computer's AD site, DC locator result, and last secure-
> channel state; verification and reset switches can perform additional work or
> change credentials.
> More information: https://learn.microsoft.com/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc731935(v=ws.11).

- Show the Active Directory site selected for the current computer:

`nltest.exe /dsgetsite`

- Ask DC Locator for one domain and preserve the returned DC flags and site:

`nltest.exe /dsgetdc:"{{example.com}}"`

- List discovered domain controllers for one exact domain:

`nltest.exe /dclist:"{{example.com}}"`

- Query the last secure-channel state for the local member computer and one exact domain:

`nltest.exe /sc_query:"{{example.com}}"`

<!-- mant:tldr:end -->

# nltest

## Overview

`nltest.exe` queries Netlogon, DC Locator, domain/trust, site, and secure-channel
state and also exposes repair/debug operations. It is installed with AD DS,
AD LDS, or the applicable RSAT tools rather than being guaranteed on every
Windows client. The official exhaustive reference is a previous-version page;
verify the exact target build with `nltest /?`.

The calling computer, local/remote Netlogon service, DNS configuration, site,
domain, cached locator state, flags, credentials, and time all affect results.
Record that context instead of treating a returned DC name as a forest-wide
truth.

## Command-family map

- Site and locator discovery: `/dsgetsite`, `/dsgetdc:<domain>`,
  `/dclist:<domain>`, and locator flags for writable DC, GC, KDC, time service,
  site, force/cache, and DNS-name requirements.
- Trust/domain discovery: `/domain_trusts`, `/trusted_domains`, and related
  enumeration. Results can disclose sensitive topology.
- Secure-channel state: `/sc_query`, `/sc_verify`, `/sc_reset`, and
  `/sc_change_pwd` have increasingly active semantics.
- Netlogon operation/debugging: `/dsregdns`, `/dbflag`, log controls, and other
  maintenance families can change registration, logging, or credentials.
- `/repl` and `/sync` in the historical reference concern Windows NT 4.0 BDC
  behavior; they are not general AD DS replication commands. Use Repadmin for
  AD replication diagnosis.

## Common mistakes

### Treating `/sc_query` as a live end-to-end proof

The command reports the secure channel that was last used and its state; it does
not prove that the same DC, DNS path, Kerberos path, clock, and credentials will
work for the next operation. Correlate a current authentication failure with
DC Locator output, time, DNS, Netlogon events, and the exact member account.

### Using `/sc_verify` as if it were query-only

Microsoft's reference states that verification checks the channel and, when
broken, can remove and rebuild it. Keep it out of read-only evidence sessions.
`/sc_reset` and `/sc_change_pwd` are explicitly corrective. Establish the
affected member, domain, selected DC, replication health, account state,
cluster/workload constraints, credential owner, rollback, and authorization
before repair.

### Running member-computer advice on a domain controller

Member secure channels, DC machine-account passwords, and inter-domain trusts
are different relationships. Do not apply `Test-ComputerSecureChannel` member
recipes or NLTest reset recipes to a DC. Use DC-specific diagnostics and the
supported Microsoft recovery procedure for that failure mode.

### Mistaking a reachable port for a valid DC

DC Locator evaluates DNS records, flags, site, domain, availability, and cached
state. A TCP connection to LDAP or SMB alone does not establish that the server
is the right writable DC, GC, KDC, time source, or trusted-domain endpoint.
Preserve the flags and client/DC site reported by `/dsgetdc`.

### Clearing caches or resetting Netlogon before preserving evidence

`/force`, DNS cache changes, service restarts, `/dsregdns`, and secure-channel
repairs change what the next lookup observes. First capture local DNS servers,
suffixes, site, locator result, logon server, time, channel query, relevant event
records, and exact UTC timestamps.

### Exposing topology or debug logs

Trust enumeration, DC lists, Netlogon debug output, account names, sites, and
domain relationships are security-sensitive. Bound collection, protect files,
avoid literal passwords, and disable only logging that the approved procedure
enabled after preserving required evidence.

## PowerShell behavior

Invoke `nltest.exe` explicitly and capture `$LASTEXITCODE`. Output is localized
human text and is not a stable parser contract. Do not infer success from a DC
name alone or from a single English phrase. For automation, prefer supported
typed directory APIs/cmdlets and keep raw NLTest output as diagnostic evidence.

## Version and platform differences

NLTest is Windows-only and feature/RSAT-dependent. Its comprehensive Microsoft
reference is labeled for older Windows Server releases, while the executable
continues to appear in Microsoft troubleshooting workflows. Options, required
elevation, flags, cache behavior, output, and support boundaries vary. Target-
local help and current issue-specific Microsoft guidance take precedence.

## Related documents

- [dcdiag](dcdiag.md)
- [repadmin](repadmin.md)
- [netdom](netdom.md)
- [nslookup](nslookup.md)
- [w32tm](w32tm.md)
- [klist](klist.md)

## Sources and license

This original guide was adapted from Microsoft's official previous-version
[NLTest reference](https://learn.microsoft.com/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc731935(v=ws.11))
and current AD DS troubleshooting material. Repair demand and the recurring
confusion between query, verify, and reset were cross-checked against a
[Server Fault secure-channel question](https://serverfault.com/questions/430042/).
That discussion is a problem signal, not a repair runbook; Microsoft guidance
and target-local help govern supported behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
