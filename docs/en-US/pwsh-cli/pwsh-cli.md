<!-- mant:tldr:start -->
# pwsh-cli

> Browse documentation for native command-line tools commonly used from
> PowerShell.

- Open this source index:

`mant pwsh-cli --source pwsh-cli`

- Inspect the sections and options in a CLI document:

`mant {{command}} --source pwsh-cli --outline`

- Explain a command-line option:

`mant {{command}} --source pwsh-cli --explain={{option}}`

- Search within one CLI document:

`mant {{command}} --source pwsh-cli --search={{pattern}}`
<!-- mant:tldr:end -->

# Command-line tools for PowerShell

## Overview

This source documents native command-line tools that PowerShell users
commonly install or encounter. It complements the PowerShell command sources:
pages explain the native tool and also show how quoting, pipelines, streams,
structured output, and exit codes behave when the tool is called from
PowerShell.

The source covers tools shipped with Windows, cross-platform developer tools,
package managers such as `winget`, and selected cloud or system-management
CLIs. A command qualifies by practical usefulness, not by vendor.

## First-release coverage

The first release prioritizes:

- Windows tools and package management, including `winget`, `wsl`, `where`,
  `robocopy`, `schtasks`, `sc`, shell/GUI entry points, registry operations,
  and selected networking commands;
- cross-platform development tools, including `git`, `ssh`, `curl`, `tar`,
  `dotnet`, and container tooling;
- JSON and text-processing tools commonly composed in automation;
- subcommand pages for large CLIs when one overview would be too broad;
- PowerShell command-resolution conflicts such as an alias and an executable
  sharing the same name.

Destructive or administrative commands require explicit safety notes and
examples with narrowly scoped targets.

## PowerShell interoperability

Native tools exchange text and byte streams rather than PowerShell objects.
Their pages should explain the details that commonly cause automation bugs:

- quoting and argument passing;
- executable discovery and alias precedence;
- standard output, standard error, and progress output;
- `$LASTEXITCODE` and nonzero exit codes;
- structured formats such as JSON and their conversion to PowerShell objects;
- operating-system and tool-version differences.

## Optional Microsoft Learn MCP queries

Microsoft's official Microsoft Learn MCP server can provide current product
documentation to compatible AI clients. Installing it remains optional: every
ManT page stands on its own, and the MCP service is an additional discovery
channel rather than a runtime dependency. See
[microsoft-learn-mcp](microsoft-learn-mcp.md) for focused queries and
provenance rules.

Information found through MCP must still be checked against the returned
Microsoft Learn page. Record that page, its applicable version, and its
license in the document's provenance catalog before adapting material.

## Documentation discovery

- [microsoft-learn-mcp](microsoft-learn-mcp.md): optional live queries for
  current Microsoft CLI documentation, without making MCP a ManT dependency.

## Windows Package Manager

- [winget](winget.md): package discovery and lifecycle safety from PowerShell.
- [winget search](winget-search.md): find candidates and exact package IDs.
- [winget show](winget-show.md): inspect package metadata before a change.
- [winget install](winget-install.md): install one reviewed exact package.
- [winget upgrade](winget-upgrade.md): controlled one-package or bulk upgrades.
- [winget uninstall](winget-uninstall.md): exact-package removal safety.
- [winget list](winget-list.md): inventory limits and upgrade-available review.

## Windows system tools

- [wsl](wsl.md): explicit distribution selection and Windows/Linux boundaries.
- [where](where.md): Windows executable lookup versus PowerShell resolution.
- [robocopy](robocopy.md): safe previews, mirror risk, and special exit codes.
- [schtasks](schtasks.md): task definition, principal, trigger, action, and result identity.
- [sc.exe](sc.md): SCM runtime, configuration, security, and control boundaries.
- [net.exe](net.md): account, SMB client/server, service, discovery, and legacy command boundaries.

## Windows Remote Desktop session inventory

- [query.exe](query.md): user, session, process, and legacy Session Host discovery boundaries.
- [quser](quser.md): searchable `query user` executable alias.
- [qwinsta](qwinsta.md): searchable `query session` executable alias.
- [qprocess](qprocess.md): searchable `query process` executable alias.
- [qappsrv](qappsrv.md): searchable `query termserver` executable alias.
- [msg.exe](msg.md): bounded notification to one verified active session.
- [tsdiscon](tsdiscon.md): disconnect while preserving session processes/state.
- [logoff](logoff.md): normal session termination and data-loss boundary.
- [rwinsta](rwinsta.md): force-reset escalation for a malfunctioning session.
- [tscon](tscon.md): attach/switch sessions with destination and credential boundaries.
- [shadow](shadow.md): consent-governed session viewing or remote control.
- [tskill](tskill.md): exact-PID session process termination after graceful recovery.

## Windows remote management

- [winrm.exe](winrm.md): WS-Management identity, client/service, listener, authentication, plugin, and shell configuration boundaries.
- [winrs](winrs.md): explicit remote native command execution through an approved WinRM endpoint.

## Windows eventing and forwarding

- [wevtutil](wevtutil.md): channel/provider inventory, bounded XML queries, EVTX evidence export, and destructive configuration boundaries.
- [wecutil](wecutil.md): Event Collector subscription configuration, per-source runtime status, delivery, and scale boundaries.
- [eventcreate](eventcreate.md): explicitly labeled test/operational markers without fabricating audit provenance.

## Windows performance counters and tracing

- [logman](logman.md): Data Collector Set and ETW provider inventory before lifecycle changes.
- [typeperf](typeperf.md): target-localized counter discovery and bounded live sampling.
- [relog](relog.md): inspect, select, convert, and resample copied performance logs.
- [tracerpt](tracerpt.md): parse copied ETL/performance traces while preserving source evidence.
- [lodctr](lodctr.md): performance-counter provider registration inventory and backup before repair.
- [unlodctr](unlodctr.md): exact provider unregistration only in a supported uninstall or repair workflow.

## Windows system diagnostics and maintenance

- [perfmon](perfmon.md): explicit Performance, Resource, Reliability, and bounded System Diagnostics views.
- [msinfo32](msinfo32.md): category-scoped System Information collection and verified NFO/text export.
- [cleanmgr](cleanmgr.md): interactive Disk Cleanup profiles with all-drive and no-dry-run boundaries.
- [shutdown](shutdown.md): sign-out, power, restart, recovery, remote-target, timeout, and forced-close safety.
- [tzutil](tzutil.md): Windows time-zone ID discovery, DST semantics, and controlled system-zone changes.
- [verifier](verifier.md): query/recovery-first Driver Verifier guidance restricted to test/debug computers.
- [w32tm](w32tm.md): effective Windows Time source, configuration, health, and bounded offset diagnosis.
- [powercfg](powercfg.md): power scheme, sleep-state, blocker, wake, hibernation, and report boundaries.
- [reagentc](reagentc.md): online/offline Windows RE identity and recovery-configuration safeguards.
- [dxdiag](dxdiag.md): DirectX/device diagnostic GUI and waited, verified support-report export.

## Windows shell, GUI, and settings

- [cmd](cmd.md): cmd builtins, child-shell parsing, AutoRun, and exit status.
- [start](start.md): cmd launch semantics versus PowerShell `Start-Process`.
- [explorer](explorer.md): supported folder opening and interactive-shell limits.
- [ms-settings](ms-settings.md): open documented Windows Settings URI pages.
- [control](control.md): canonical Control Panel names and migration limits.
- [mmc](mmc.md): saved consoles, author mode, snap-ins, and architecture.

## Windows registry and compatibility hosts

- [reg](reg.md): query, views, types, backup, modification, and verification.
- [rundll32](rundll32.md): documented entry points and arbitrary-export hazards.

## Cmd batch state and interaction

- [for](for.md): iteration, `/f` parsing, expansion timing, and child shells.
- [if](if.md): conditional tests without ERRORLEVEL or expansion mistakes.
- [set](set.md): cmd environment variables versus PowerShell's `set` alias.
- [setlocal](setlocal.md): localized batch state and delayed expansion.
- [endlocal](endlocal.md): restore a batch scope and safely design returned values.
- [call](call.md): invoke batch files and label subroutines without losing control flow.
- [choice](choice.md): single-character prompts and one-based result handling.
- [timeout](timeout.md): Windows delays, redirected input, and name conflicts.
- [exit](exit.md): distinguish batch return codes from terminating `cmd.exe`.
- [path](path.md): process search path, resolution order, and safe scoping.
- [pushd](pushd.md) / [popd](popd.md): balanced local/UNC directory stacks.
- [title](title.md): interactive cmd window title and terminal-host limits.
- [assoc](assoc.md) / [ftype](ftype.md): classic file-type mappings versus
  protected modern default apps.

## Cmd files and directories

- [dir](dir.md): text listings, attributes, short-name wildcards, and reparse points.
- [cd](cd.md) / [chdir](chdir.md): cmd's per-drive directory model and `/d`.
- [md](md.md) / [mkdir](mkdir.md): directory creation and shell resolution.
- [copy](copy.md): ordinary copies versus concatenation and PowerShell's alias.
- [move](move.md): collision policy, EFS, and PowerShell's `Move-Item` alias.
- [ren](ren.md) / [rename](rename.md): in-place renames and wildcard-mask risks.
- [del](del.md) / [erase](erase.md): permanent file deletion with exact previews.
- [rd](rd.md) / [rmdir](rmdir.md): empty or recursive directory removal.
- [attrib](attrib.md): inspect and change file/directory attributes safely.
- [forfiles](forfiles.md): preview path/mask/date selections before actions.
- [tree](tree.md): human-readable directory diagrams, not structured inventory.
- [subst](subst.md): session-context virtual drive letters for local paths.
- [mklink](mklink.md): symbolic links, hard links, and directory junctions.
- [xcopy](xcopy.md): previewed legacy directory-tree copies and exit contracts.

## Windows text pipelines

- [type](type.md): display text while distinguishing PowerShell `Get-Content`.
- [find](find.md) / [findstr](findstr.md): literal and limited-regex searches.
- [fc](fc.md): text/binary comparison and its three-way exit contract.
- [sort](sort.md): locale-sensitive line sorting versus `Sort-Object`.
- [clip](clip.md): deliberate transfer of text into the Windows clipboard.

## Windows process and host inventory

- [tasklist](tasklist.md): filtered process snapshots and typed alternatives.
- [taskkill](taskkill.md): exact-PID termination with force/tree escalation.
- [systeminfo](systeminfo.md): host and operating-system configuration snapshots.
- [whoami](whoami.md): current access-token identity, groups, and privileges.
- [openfiles](openfiles.md): shared-file queries and controlled disconnects.
- [driverquery](driverquery.md): installed driver inventory boundaries.

## Windows network diagnosis

- [ipconfig](ipconfig.md): adapter, DHCP, DNS-server, and resolver-cache state.
- [ping](ping.md): bounded ICMP reachability without service-health confusion.
- [tracert](tracert.md): ICMP-visible paths, timeouts, and topology limits.
- [pathping](pathping.md): sampled hop latency and loss with rate-limit caveats.
- [hostname](hostname.md): short host identity versus DNS and cluster names.
- [nslookup](nslookup.md): direct DNS queries versus application resolution.
- [netstat](netstat.md): sockets, listeners, owning PIDs, and exact-port queries.
- [route](route.md): IPv4 route inspection and high-risk mutation boundaries.
- [arp](arp.md): per-interface IPv4 neighbor-cache evidence.
- [getmac](getmac.md): physical and virtual adapter MAC inventory.
- [nbtstat](nbtstat.md): legacy NetBIOS name, cache, and session diagnosis.
- [netsh](netsh.md): installed context discovery and safe family boundaries.
- [netsh-interface](netsh-interface.md): IP, interface, tunnel, and proxy state.
- [netsh-wlan](netsh-wlan.md): Wi-Fi interfaces, networks, and profile safety.
- [netsh-winsock](netsh-winsock.md): provider catalog and autotuning evidence.

## Windows installation, servicing, and drivers

- [msiexec](msiexec.md): package identity, logging, waiting, and restart codes.
- [dism](dism.md): explicit online/offline Windows image inventory and servicing.
- [sfc](sfc.md): protected-system-file verification and scoped repair.
- [pnputil](pnputil.md): Driver Store, device, and interface identity safety.
- [fondue](fondue.md): single-feature enablement and source-policy boundaries.

## Windows security policy and authentication diagnosis

- [auditpol](auditpol.md): effective advanced audit policy and stable GUID identity.
- [gpresult](gpresult.md): exact user/computer RSoP and report protection.
- [klist](klist.md): Kerberos tickets, logon sessions, and binding evidence.
- [setspn](setspn.md): AD SPN ownership, duplicates, and safe registration boundaries.
- [cmdkey](cmdkey.md): exact credential targets without inline secret exposure.
- [gpupdate](gpupdate.md): scoped policy refresh after preserving RSoP evidence.
- [secedit](secedit.md): validate/export/analyze security templates before apply.
- [icacls](icacls.md): DACL display, verification, backup, and inheritance safety.
- [takeown](takeown.md): exact-object ownership recovery separate from access.
- [cipher](cipher.md): EFS identity, recovery, scope, and free-space boundaries.
- [certreq](certreq.md): explicit certificate request and acceptance lifecycle.
- [certutil](certutil.md): certificate, store, chain, and hash diagnostics.

## Windows storage, boot, and recovery

- [bcdboot](bcdboot.md): explicit Windows/system partition boot-file repair.
- [bcdedit](bcdedit.md): BCD store, entry, firmware, and backup boundaries.
- [chkdsk](chkdsk.md): filesystem scan, repair mode, and result-code handling.
- [chkntfs](chkntfs.md): startup check scheduling and exclusion policy.
- [defrag](defrag.md): media-aware optimization, retrim, tiers, and scope.
- [compact](compact.md): NTFS, executable, and CompactOS compression boundaries.
- [manage-bde](manage-bde.md): BitLocker state, protectors, escrow, and access.
- [mountvol](mountvol.md): volume GUID, mount-point, automount, and ESP safety.
- [diskpart](diskpart.md): focus-driven disk, partition, volume, and VHD safety.
- [fsutil](fsutil.md): advanced filesystem, journal, link, and behavior state.
- [vssadmin](vssadmin.md): VSS writer, provider, shadow, and diff-area evidence.
- [diskshadow](diskshadow.md): scripted VSS backup, restore, and transport boundaries.
- [wbadmin](wbadmin.md): Windows Backup catalog, version, target, and recovery identity.
- [bdehdcfg](bdehdcfg.md): legacy BitLocker boot-partition preparation boundaries.
- [refsutil](refsutil.md): ReFS query, diagnosis, repair, and salvage family safety.

## Cross-platform developer tools

- [git](git.md): repository context, configuration, and native exit codes.
- [ssh](ssh.md): host identity, remote-command parsing, and key safety.
- [curl](curl.md): native executable resolution, HTTP failure handling, and downloads.
- [tar](tar.md): implementation-aware archive inspection and safe extraction.
- [dotnet](dotnet.md): SDK selection, project context, and build process handling.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, use commands such as:

```text
mant winget --source pwsh-cli
mant winget-install --source pwsh-cli --outline
mant winget-install --source pwsh-cli --explain=--id
mant git --source pwsh-cli --search=LASTEXITCODE
```

## Sources and license

This source contains original ManT-oriented documentation informed by each
tool vendor's official documentation and source repositories, including the
[Windows Package Manager documentation](https://learn.microsoft.com/windows/package-manager/winget/).
Exact upstream revisions and page-level provenance are recorded in the
repository's `upstream/cli.json` catalog.

The documentation in this source is licensed under CC BY 4.0. Product names
and trademarks belong to their respective owners.
