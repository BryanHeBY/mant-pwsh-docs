<!-- mant:tldr:start -->
# nltest.exe

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

# nltest.exe

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

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `nltest.exe`: Query or change Netlogon locator, site, trust, secure-channel,
  DNS-registration, and debug state according to installed syntax.

These slash forms are top-level operation selectors, not interchangeable
read-only flags. Query, verify, reset, and password-change semantics differ.

<!-- mant:entries role=option case=insensitive -->
- `/dsgetsite`: Display the AD site selected for the current computer.
- `/dsgetdc`: Ask DC Locator for a DC matching a domain and optional flags.
- `/dclist`: List discovered domain controllers for one domain.
- `/parentdomain`: Display the parent of one named domain.
- `/domain_trusts`: Enumerate domain trust relationships and selected attributes.
- `/query`: Query the selected server's Netlogon service.
- `/dcname`: Return the PDC name for the following domain.
- `/dnsgetdc`: Enumerate domain controllers through the DNS DC-open/next/close
  interface with explicit capability flags.
- `/dsgetfti`: Return interforest trust information; combining it with
  `/update_tdo` changes the locally stored trust information.
- `/lsaqueryfti`: Query locally stored forest-trust information for one exact
  trusted forest.
- `/dsgetsitecov`: Display sites covered by the selected domain controller.
- `/dsaddresstosite`: Map one machine/address list to AD site names.
- `/finduser`: Find which trusted domain would authenticate the named user.
- `/whowill`: Ask which domain controller would log on the following user.
- `/logon_query`: Query cumulative NTLM logon-attempt counts.
- `/dsquerydns`: Query the status of the last DC-specific DNS update.
- `/sc_query`: Display the last-used secure-channel state without live repair.
- `/sc_verify`: Verify and potentially rebuild a broken secure channel.
- `/sc_reset`: Reset the selected secure channel to an explicit DC where supplied.
- `/sc_change_pwd`: Change the local member computer secure-channel password.
- `/server`: Select a remote Windows computer's Netlogon service for supported forms.
- `/user`: Display SAM attributes for the following user on the selected
  server; it is not an alternate-credential selector and does not query an AD
  account.
- `/force`: Bypass cached DC Locator results and perform new discovery.
- `/dsregdns`: Trigger Netlogon DNS registration.
- `/dsderegdns`: Deregister selected DC-specific DNS records; exact DNS host,
  domain, domain GUID, and DSA GUID scope matters.
- `/transport_notify`: Notify Netlogon of a new transport; this changes service
  observation state and is not an inventory query.
- `/dbflag`: Query or change Netlogon debug flags.
- `/pdc_repl`: Force a historical UAS change message from the selected PDC.
- `/bdc_query`: Query historical BDC replication status for a domain.
- `/list_deltas`: Display the following legacy change-log file.
- `/cdigest`: Compute the client digest for a supplied message/domain.
- `/sdigest`: Compute the server digest for a supplied message/RID.
- `/time`: Convert two hexadecimal Windows NT GMT words to text.
- `/shutdown`: Request shutdown of the selected server with a reason and
  optional delay; never use it for discovery or generic validation.
- `/shutdown_abort`: Abort a pending shutdown on the selected server; this is
  also a lifecycle change, not a query.
- `/repl`: Invoke historical NT 4.0 BDC replication behavior, not AD replication.
- `/sync`: Invoke historical NT 4.0 BDC synchronization behavior.
- `/update_tdo`: With `/dsgetfti`, update locally stored interforest-trust
  information instead of only reporting it.
- `/addresses`: Supply the comma-separated addresses for `/dsaddresstosite`.
- `/dom`, `/domguid`, `/dsaguid`: Narrow `/dsderegdns` to the intended DNS
  domain, domain GUID, and DSA GUID.
- `/rid`: Supply the hexadecimal RID required by `/sdigest`.
- `/domain`: Supply the exact domain for `/cdigest`.
- `/primary`, `/forest`, `/direct_out`, `/direct_in`, `/all_trusts`, `/v`:
  Filter or expand `/domain_trusts` output.
- `/pdc`, `/ds`, `/dsp`, `/gc`, `/kdc`, `/timeserv`, `/gtimeserv`, `/ws`,
  `/writable`, `/ldaponly`: Require matching DC capabilities during locator
  operations.
- `/netbios`, `/dns`, `/ip`, `/ret_dns`, `/ret_netbios`: Select locator input
  or returned name/address forms; they do not validate the returned endpoint.
- `/site`, `/sitespec`, `/try_next_closest_site`, `/avoidself`, `/backg`:
  Control locator site preference/filtering and background/cache behavior.
- `/ds_6`, `/ds_8`, `/ds_9`, `/ds_10`, `/ds_13`: Require the corresponding
  installed DC-generation capability; treat these as build-specific flags.
- `/keylist`, `/account`: Request the installed key-list/account locator forms;
  verify build-specific semantics before use.
- `/?`, `/help`: Display exact target-build syntax. On the recorded build both
  forms wrote help to the native error stream and returned exit code 1.

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

## PowerShell boundaries

Invoke `nltest.exe` explicitly and capture `$LASTEXITCODE`. Output is localized
human text and is not a stable parser contract. Do not infer success from a DC
name alone or from a single English phrase. For automation, prefer supported
typed directory APIs/cmdlets and keep raw NLTest output as diagnostic evidence.

On Windows PowerShell 5.1, the recorded build wrote all `/?` and `/help` text
to the native error stream. Merging `2>&1` therefore produced `ErrorRecord`
objects even though their text was ordinary help. Convert deliberately when
rendering (`ForEach-Object { "$_" }`), retain the original stream/status as
evidence, and do not classify `NativeCommandError` alone as an NLTest failure.

## Version and platform differences

NLTest is Windows-only and feature/RSAT-dependent. Its comprehensive Microsoft
reference is labeled for older Windows Server releases, while the executable
continues to appear in Microsoft troubleshooting workflows. Options, required
elevation, flags, cache behavior, output, and support boundaries vary. Target-
local help and current issue-specific Microsoft guidance take precedence.
On Windows NT `10.0.26200.0`, installed file version `10.0.26100.8115`
printed 56 nonempty help lines and returned 1 for both `/?` and `/help`.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8115
ordinary-token /? and /help each printed 56 nonempty lines to the native error
stream and returned 1. Windows PowerShell 5.1 therefore wraps merged help items
as NativeCommandError. Installed and historical official syntax prove /user is
a SAM query rather than alternate credentials and expose no /password; the page
now indexes the complete installed operation/modifier surface with update, DNS
deregistration, notification/debug, legacy replication, digest, and shutdown
boundaries. No target or operational state was queried or changed.

## Related documents
- [dcdiag.exe](dcdiag.exe.md)
- [repadmin.exe](repadmin.exe.md)
- [netdom.exe](netdom.exe.md)
- [nslookup.exe](nslookup.exe.md)
- [w32tm.exe](w32tm.exe.md)
- [klist.exe](klist.exe.md)

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
