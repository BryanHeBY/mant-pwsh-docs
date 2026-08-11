<!-- mant:tldr:start -->
# windows-tools

> Browse Windows command-line tools, shell builtins, management utilities, and
> graphical entry points commonly used from PowerShell.

- Open this source index:

`mant windows-tools --source windows-tools`

- Open an executable document by its exact registered name on any host:

`mant ipconfig.exe --source windows-tools`

- On Windows, inspect the same document through `PATHEXT` fallback:

`mant ipconfig --source windows-tools --outline`

- Read one section selected from the outline:

`mant {{tool}} --source windows-tools --node={{section-id}}`

- Search within one Windows tool document:

`mant {{tool}} --source windows-tools --search={{pattern}}`
<!-- mant:tldr:end -->

# Windows tools for PowerShell

## Overview

This source documents Windows-native command-line tools, Cmd builtins, shell
and Settings entry points, management consoles, optional components, and
legacy recovery utilities that PowerShell users encounter. It complements the
PowerShell command sources: pages explain each tool and show how resolution,
quoting, pipelines, streams, exit codes, elevation, and interactive boundaries
behave when it is launched from PowerShell.

This source does not install or enable the tools it describes. Availability
depends on Windows product, release, edition, architecture, installed roles,
features, capabilities, and compatibility components. Cross-platform tools
such as Git and curl are documented separately in `cross-platform-tools`.

Documents for Windows entry points retain the actual filename suffix, such as
`winget.exe`, `tree.com`, `services.msc`, or `prncnfg.vbs`. ManT can omit a
suffix only on Windows, where an extensionless query checks exact names and
then the current `PATHEXT` order. Use the full registered name for an exact
query or when reading this source on macOS or Linux. Cmd builtins, URI entries,
and topic or multi-program family pages remain unsuffixed.

## First-release coverage

The first release prioritizes:

- Windows tools and package management, including `winget`, `wsl`, `where`,
  `robocopy`, `schtasks`, `sc`, shell/GUI entry points, registry operations,
  and selected networking commands;
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

- [winget.exe](winget.exe.md): package discovery and lifecycle safety from PowerShell.
- [winget search](winget-search.md): find candidates and exact package IDs.
- [winget show](winget-show.md): inspect package metadata before a change.
- [winget install](winget-install.md): install one reviewed exact package.
- [winget upgrade](winget-upgrade.md): controlled one-package or bulk upgrades.
- [winget uninstall](winget-uninstall.md): exact-package removal safety.
- [winget list](winget-list.md): inventory limits and upgrade-available review.

## Windows system tools

- [wsl.exe](wsl.exe.md): explicit distribution selection and Windows/Linux boundaries.
- [where.exe](where.exe.md): Windows executable lookup versus PowerShell resolution.
- [robocopy.exe](robocopy.exe.md): safe previews, mirror risk, and special exit codes.
- [schtasks.exe](schtasks.exe.md): task definition, principal, trigger, action, and result identity.
- [at.exe](at.exe.md): legacy Schedule-service inventory and explicit Task Scheduler migration.
- [sc.exe](sc.exe.md): SCM runtime, configuration, security, and control boundaries.
- [net.exe](net.exe.md): account, SMB client/server, service, discovery, and legacy command boundaries.

## Windows Remote Desktop session inventory

- [mstsc.exe](mstsc.exe.md): classic Remote Desktop client with identity, credential-mode, RDP-file, redirection, and consent boundaries.
- [query.exe](query.exe.md): user, session, process, and legacy Session Host discovery boundaries.
- [quser.exe](quser.exe.md): searchable `query user` executable alias.
- [qwinsta.exe](qwinsta.exe.md): searchable `query session` executable alias.
- [qprocess.exe](qprocess.exe.md): searchable `query process` executable alias.
- [qappsrv.exe](qappsrv.exe.md): searchable `query termserver` executable alias.
- [msg.exe](msg.exe.md): bounded notification to one verified active session.
- [tsdiscon.exe](tsdiscon.exe.md): disconnect while preserving session processes/state.
- [logoff.exe](logoff.exe.md): normal session termination and data-loss boundary.
- [rwinsta.exe](rwinsta.exe.md): force-reset escalation for a malfunctioning session.
- [tscon.exe](tscon.exe.md): attach/switch sessions with destination and credential boundaries.
- [shadow.exe](shadow.exe.md): consent-governed session viewing or remote control.
- [tskill.exe](tskill.exe.md): exact-PID session process termination after graceful recovery.
- [change.exe](change.exe.md): RD Session Host logon admission, session COM mapping, and application install/execute mode.
- [chglogon.exe](chglogon.exe.md) / [chgport.exe](chgport.exe.md) / [chgusr.exe](chgusr.exe.md): searchable legacy names replaced by the `change` family.
- [flattemp.exe](flattemp.exe.md): per-session temporary-folder isolation and effective-path verification.
- [tsecimp.exe](tsecimp.exe.md): TAPI provider/line inventory and XML validation before assignment import.
- [tsprof.exe](tsprof.exe.md): legacy local/domain RDS profile-field query, update, and copy boundaries.

## Windows remote management

- [winrm.exe](winrm.exe.md): WS-Management identity, client/service, listener, authentication, plugin, and shell configuration boundaries.
- [winrs.exe](winrs.exe.md): explicit remote native command execution through an approved WinRM endpoint.

## Windows eventing and forwarding

- [wevtutil.exe](wevtutil.exe.md): channel/provider inventory, bounded XML queries, EVTX evidence export, and destructive configuration boundaries.
- [wecutil.exe](wecutil.exe.md): Event Collector subscription configuration, per-source runtime status, delivery, and scale boundaries.
- [eventcreate.exe](eventcreate.exe.md): explicitly labeled test/operational markers without fabricating audit provenance.

## Windows performance counters and tracing

- [winsat.exe](winsat.exe.md): bounded memory-bandwidth and Media Foundation decode assessments with workload/context controls.
- [logman.exe](logman.exe.md): Data Collector Set and ETW provider inventory before lifecycle changes.
- [typeperf.exe](typeperf.exe.md): target-localized counter discovery and bounded live sampling.
- [relog.exe](relog.exe.md): inspect, select, convert, and resample copied performance logs.
- [tracerpt.exe](tracerpt.exe.md): parse copied ETL/performance traces while preserving source evidence.
- [dtrace.exe](dtrace.exe.md): case-sensitive probe discovery and compile-only review before bounded dynamic tracing.
- [lodctr.exe](lodctr.exe.md): performance-counter provider registration inventory and backup before repair.
- [unlodctr.exe](unlodctr.exe.md): exact provider unregistration only in a supported uninstall or repair workflow.

## Windows packet and security diagnostics

- [sysmon.exe](sysmon.exe.md): built-in-versus-standalone service/driver telemetry, configuration schema, filtering, and event-channel boundaries.
- [pktmon.exe](pktmon.exe.md): filtered, bounded packet counters/capture with component, privacy, lifecycle, and lossy-conversion boundaries.
- [tpmtool.exe](tpmtool.exe.md): TPM information, protected log gathering, and bounded driver tracing without clear/provision confusion.
- [tpmvscmgr.exe](tpmvscmgr.exe.md): TPM virtual smart-card inventory, irreversible lifecycle, public-default-secret, and modern-authentication migration boundaries.

## Windows system diagnostics and maintenance

- [perfmon.exe](perfmon.exe.md): explicit Performance, Resource, Reliability, and bounded System Diagnostics views.
- [msinfo32.exe](msinfo32.exe.md): category-scoped System Information collection and verified NFO/text export.
- [dispdiag.exe](dispdiag.exe.md): display diagnostics captured to a new protected non-text artifact.
- [msdt.exe](msdt.exe.md): deprecated troubleshooting-pack migration to current Settings and Get Help workflows.
- [cleanmgr.exe](cleanmgr.exe.md): interactive Disk Cleanup profiles with all-drive and no-dry-run boundaries.
- [shutdown.exe](shutdown.exe.md): sign-out, power, restart, recovery, remote-target, timeout, and forced-close safety.
- [tzutil.exe](tzutil.exe.md): Windows time-zone ID discovery, DST semantics, and controlled system-zone changes.
- [verifier.exe](verifier.exe.md): query/recovery-first Driver Verifier guidance restricted to test/debug computers.
- [w32tm.exe](w32tm.exe.md): effective Windows Time source, configuration, health, and bounded offset diagnosis.
- [powercfg.exe](powercfg.exe.md): power scheme, sleep-state, blocker, wake, hibernation, and report boundaries.
- [reagentc.exe](reagentc.exe.md): online/offline Windows RE identity and recovery-configuration safeguards.
- [dxdiag.exe](dxdiag.exe.md): DirectX/device diagnostic GUI and waited, verified support-report export.
- [taskmgr.exe](taskmgr.exe.md): live process/performance/startup/session inspection before controlled actions.
- [resmon.exe](resmon.exe.md): direct searchable Resource Monitor entry with sampling and automation boundaries.
- [winver.exe](winver.exe.md): interactive Windows edition/version/build identity with typed CIM and feature-detection alternatives.
- [mrt.exe](mrt.exe.md): current, elevated MSRT scanning with complete switch, antivirus, evidence, and automatic-cleanup boundaries.
- [msra.exe](msra.exe.md): consented classic Remote Assistance with identity, invitation, privacy, control, and session-end safeguards.
- [eventvwr.msc](eventvwr.msc.md): interactive event exploration while preserving raw XML/EVTX provenance.
- [taskschd.msc](taskschd.msc.md): interactive Task Scheduler entry with full-path, principal, XML, ACL, runtime-context, and result boundaries.
- [rsop.msc](rsop.msc.md): interactive Resultant Set of Policy inspection distinct from complete, saved `gpresult` reporting.
- [comexp.msc](comexp.msc.md): Component Services entry with machine/application COM security, identity, architecture, DTC, and recovery boundaries.
- [wmimgmt.msc](wmimgmt.msc.md): WMI Control entry with explicit namespace, ACL, transport, provider, and repository-repair boundaries.
- [printmanagement.msc](printmanagement.msc.md): optional Print Management entry separating servers, queues, drivers, ports, jobs, and typed cmdlet automation.
- [wf.msc](wf.msc.md): advanced firewall console entry with effective policy-store, rule/filter identity, and traffic-verification boundaries.
- [secpol.msc](secpol.msc.md): Local Security Policy entry distinct from effective domain/MDM policy and runtime enforcement.
- [certmgr.msc](certmgr.msc.md): Current User certificate-store entry distinct from Local Computer stores and the SDK `certmgr.exe`.
- [certlm.msc](certlm.msc.md): Local Computer certificate-store entry with machine-wide trust, private-key ACL, binding, and service-impact safeguards.
- [lusrmgr.msc](lusrmgr.msc.md): Local Users and Groups entry with SID, authority, token, edition, and domain-controller boundaries.
- [fsmgmt.msc](fsmgmt.msc.md): Shared Folders entry separating SMB shares, sessions, open files, scopes, and share/file-system permissions.
- [compmgmt.msc](compmgmt.msc.md): Computer Management console entry with per-snap-in target/change boundaries.
- [devmgmt.msc](devmgmt.msc.md): Device Manager entry with exact instance/package/stack identity safeguards.
- [diskmgmt.msc](diskmgmt.msc.md): Disk Management entry with unique disk/volume/boot/recovery identity safeguards.
- [services.msc](services.msc.md): Services console entry with SCM runtime/configuration/security boundaries.
- [optionalfeatures.exe](optionalfeatures.exe.md): classic/Settings feature entry with feature/capability/servicing distinctions.
- [msconfig.exe](msconfig.exe.md): controlled clean-startup isolation with boot and recovery safeguards.
- [gpedit.msc](gpedit.msc.md): Local Group Policy Editor entry with edition, authority, and RSoP boundaries.
- [systempropertiesadvanced.exe](systempropertiesadvanced.exe.md): advanced environment, performance, profile, and recovery settings.
- [magnify.exe](magnify.exe.md): Magnifier launch/settings entry without protected-file disable workarounds.
- [narrator.exe](narrator.exe.md): Narrator launch/settings entry with user, privacy, and input boundaries.
- [osk.exe](osk.exe.md): classic On-Screen Keyboard entry distinct from touch, IME, and secure-desktop input.

## Windows scripting and compatibility hosts

- [setx.exe](setx.exe.md): persistent environment writes with scope, inheritance, expansion, and truncation safeguards.
- [cscript.exe](cscript.exe.md): reviewed Windows Script Host execution with console output, least privilege, and bounded runtime.
- [wscript.exe](wscript.exe.md): interactive GUI script hosting distinct from unattended console automation.
- [regsvr32.exe](regsvr32.exe.md): trusted self-registering COM component lifecycle with code-execution and architecture boundaries.
- [wmic.exe](wmic.exe.md): deprecated/optional compatibility utility and typed CIM migration guidance.
- [sxstrace.exe](sxstrace.exe.md): bounded side-by-side activation tracing and evidence-preserving parse workflow.

## Windows shell, GUI, and settings

- [powershell_ise.exe](powershell_ise.exe.md): Windows PowerShell 5.1-only graphical editor/debugger and PowerShell 7 migration boundary.
- [cmd.exe](cmd.exe.md): cmd builtins, child-shell parsing, AutoRun, and exit status.
- [start](start.md): cmd launch semantics versus PowerShell `Start-Process`.
- [explorer.exe](explorer.exe.md): supported folder opening and interactive-shell limits.
- [ms-settings](ms-settings.md): open documented Windows Settings URI pages.
- [control.exe](control.exe.md): canonical Control Panel names and migration limits.
- [appwiz.cpl](appwiz.cpl.md): classic Programs and Features entry distinct from complete package inventory and unattended deployment.
- [ncpa.cpl](ncpa.cpl.md): Network Connections entry with stable adapter identity, complete network state, and remote-recovery boundaries.
- [sysdm.cpl](sysdm.cpl.md): classic System Properties entry whose pages belong to separate configuration authorities.
- [inetcpl.cpl](inetcpl.cpl.md): Internet Properties entry distinct from WinHTTP, browser, service, and runtime-specific network configuration.
- [mmsys.cpl](mmsys.cpl.md): classic Sound entry with endpoint/PnP identity, audio roles, sessions, driver, and privacy boundaries.
- [powercfg.cpl](powercfg.cpl.md): Power Options entry distinct from the parameterized `powercfg.exe` automation surface.
- [firewall.cpl](firewall.cpl.md): basic firewall applet distinct from advanced WFAS rules, filters, stores, and effective policy.
- [intl.cpl](intl.cpl.md): Region entry separating culture, locale, language, input, code-page, user/system, and offline-image scopes.
- [mmc.exe](mmc.exe.md): saved consoles, author mode, snap-ins, and architecture.

## Windows registry and compatibility hosts

- [regedit.exe](regedit.exe.md): interactive Registry Editor with exact hive/user/view/type identity and no undocumented switch promise.
- [reg.exe](reg.exe.md): query, views, types, backup, modification, and verification.
- [regini.exe](regini.exe.md): reviewed registry scripts with kernel-path, no-dry-run, backup, and ACL-replacement safeguards.
- [rundll32.exe](rundll32.exe.md): documented entry points and arbitrary-export hazards.

## Cmd batch state and interaction

- [for](for.md): iteration, `/f` parsing, expansion timing, and child shells.
- [if](if.md): conditional tests without ERRORLEVEL or expansion mistakes.
- [set](set.md): cmd environment variables versus PowerShell's `set` alias.
- [setlocal](setlocal.md): localized batch state and delayed expansion.
- [endlocal](endlocal.md): restore a batch scope and safely design returned values.
- [call](call.md): invoke batch files and label subroutines without losing control flow.
- [choice.exe](choice.exe.md): single-character prompts and one-based result handling.
- [timeout.exe](timeout.exe.md): Windows delays, redirected input, and name conflicts.
- [waitfor.exe](waitfor.exe.md): finite named-signal synchronization with explicit target, collision, domain, and delivery boundaries.
- [echo](echo.md): message/command-echo state with empty expansion, metacharacter, block, and shell-resolution boundaries.
- [rem](rem.md): supported batch comments without treating arbitrary disabled code or `::` labels as inert text.
- [goto](goto.md): fixed-label control flow, `:EOF`, subroutine fall-through, and dynamic-label risks.
- [shift](shift.md): destructive `%0`–`%9` parameter shifting, unchanged `%*`, quoting, and termination rules.
- [pause](pause.md): attended any-key wait, distinct from bounded choices, delays, and unattended automation.
- [prompt](prompt.md): session-local Cmd prompt templates distinct from PowerShell and trustworthy context.
- [cls](cls.md): visible-screen clearing distinct from scrollback, logs, history, and secret deletion.
- [color](color.md): session-local accessible presentation with explicit upstream digit-order inconsistency.
- [help](help.md): interpreter-aware Cmd, PowerShell, native-tool, and ManT help discovery.
- [ver](ver.md): compact Cmd version display versus typed product/build/servicing inventory.
- [verify](verify.md): legacy Cmd write setting versus hashes, signatures, comparison, and storage health.
- [break](break.md): no-effect MS-DOS compatibility builtin versus PowerShell control flow and redirection risk.
- [date](date.md) / [time](time.md): prompt-free display, invariant single-instant formatting, and managed-clock safeguards.
- [exit](exit.md): distinguish batch return codes from terminating `cmd.exe`.
- [path](path.md): process search path, resolution order, and safe scoping.
- [pushd](pushd.md) / [popd](popd.md): balanced local/UNC directory stacks.
- [title](title.md): interactive cmd window title and terminal-host limits.
- [assoc](assoc.md) / [ftype](ftype.md): classic file-type mappings versus
  protected modern default apps.
- [doskey.exe](doskey.exe.md): executable-scoped interactive history/macros, distinct from PowerShell aliases and batch automation.
- [chcp.com](chcp.com.md): active console code page versus file, native-pipeline, console, and PowerShell encoding.

## Cmd files and directories

- [dir](dir.md): text listings, attributes, short-name wildcards, and reparse points.
- [cd](cd.md) / [chdir](chdir.md): cmd's per-drive directory model and `/d`.
- [md](md.md) / [mkdir](mkdir.md): directory creation and shell resolution.
- [copy](copy.md): ordinary copies versus concatenation and PowerShell's alias.
- [move](move.md): collision policy, EFS, and PowerShell's `Move-Item` alias.
- [ren](ren.md) / [rename](rename.md): in-place renames and wildcard-mask risks.
- [del](del.md) / [erase](erase.md): permanent file deletion with exact previews.
- [rd](rd.md) / [rmdir](rmdir.md): empty or recursive directory removal.
- [attrib.exe](attrib.exe.md): inspect and change file/directory attributes safely.
- [forfiles.exe](forfiles.exe.md): preview path/mask/date selections before actions.
- [tree.com](tree.com.md): human-readable directory diagrams, not structured inventory.
- [subst.exe](subst.exe.md): session-context virtual drive letters for local paths.
- [mklink](mklink.md): symbolic links, hard links, and directory junctions.
- [xcopy.exe](xcopy.exe.md): previewed legacy directory-tree copies and exit contracts.
- [replace.exe](replace.exe.md): no-dry-run same-name add/replace semantics, destination recursion, timestamp updates, and verification.

## Windows text pipelines

- [type](type.md): display text while distinguishing PowerShell `Get-Content`.
- [find.exe](find.exe.md) / [findstr.exe](findstr.exe.md): literal and limited-regex searches.
- [fc.exe](fc.exe.md): text/binary comparison and its three-way exit contract.
- [sort.exe](sort.exe.md): locale-sensitive line sorting versus `Sort-Object`.
- [clip.exe](clip.exe.md): deliberate transfer of text into the Windows clipboard.
- [more.com](more.com.md): explicit native forward-only paging with PowerShell resolution, interactivity, and encoding limits.
- [comp.exe](comp.exe.md): interactive byte comparison, prompt-suppression/version gaps, prefix and wildcard traps.

## Windows process and host inventory

- [tasklist.exe](tasklist.exe.md): filtered process snapshots and typed alternatives.
- [taskkill.exe](taskkill.exe.md): exact-PID termination with force/tree escalation.
- [systeminfo.exe](systeminfo.exe.md): host and operating-system configuration snapshots.
- [whoami.exe](whoami.exe.md): current access-token identity, groups, and privileges.
- [openfiles.exe](openfiles.exe.md): shared-file queries and controlled disconnects.
- [driverquery.exe](driverquery.exe.md): installed driver inventory boundaries.

## Windows network diagnosis

- [ipconfig.exe](ipconfig.exe.md): adapter, DHCP, DNS-server, and resolver-cache state.
- [ping.exe](ping.exe.md): bounded ICMP reachability without service-health confusion.
- [tracert.exe](tracert.exe.md): ICMP-visible paths, timeouts, and topology limits.
- [pathping.exe](pathping.exe.md): sampled hop latency and loss with rate-limit caveats.
- [hostname.exe](hostname.exe.md): short host identity versus DNS and cluster names.
- [nslookup.exe](nslookup.exe.md): direct DNS queries versus application resolution.
- [netstat.exe](netstat.exe.md): sockets, listeners, owning PIDs, and exact-port queries.
- [route.exe](route.exe.md): IPv4 route inspection and high-risk mutation boundaries.
- [arp.exe](arp.exe.md): per-interface IPv4 neighbor-cache evidence.
- [getmac.exe](getmac.exe.md): physical and virtual adapter MAC inventory.
- [nbtstat.exe](nbtstat.exe.md): legacy NetBIOS name, cache, and session diagnosis.
- [netsh.exe](netsh.exe.md): installed context discovery and safe family boundaries.
- [netsh-interface](netsh-interface.md): IP, interface, tunnel, and proxy state.
- [netsh-wlan](netsh-wlan.md): Wi-Fi interfaces, networks, and profile safety.
- [netsh-winsock](netsh-winsock.md): provider catalog and autotuning evidence.
- [netcfg.exe](netcfg.exe.md): network component and binding inventory before install, uninstall, or all-device cleanup.
- [cmstp.exe](cmstp.exe.md): reviewed Connection Manager INF deployment with scope, trust, and rollback boundaries.

## Windows optional and legacy network clients

- [atmadm.exe](atmadm.exe.md): legacy ATM connection, NSAP, call, and ILMI counter inventory.
- [ipxroute.exe](ipxroute.exe.md): obsolete NWLink IPX binding/SAP discovery and TCP/IP migration boundaries.
- [irftp.exe](irftp.exe.md): legacy infrared transfer identity, integrity, UI, and supported-channel migration.
- [ftp.exe](ftp.exe.md): plaintext legacy FTP, interpreter/script boundaries, active data channels, and artifact verification.
- [tftp.exe](tftp.exe.md): unauthenticated/unencrypted optional provisioning transfer with explicit octet-mode and trust boundaries.
- [telnet.exe](telnet.exe.md): optional plaintext terminal client separated from safe TCP reachability and SSH.
- [tlntadmn.exe](tlntadmn.exe.md): query-first inventory of a legacy Telnet Server without enabling or reconfiguring it.
- [finger.exe](finger.exe.md): privacy-bounded legacy user-information discovery without enumeration or identity trust.
- [rexec.exe](rexec.exe.md) / [rsh.exe](rsh.exe.md): deprecated or retired remote-command clients, source verification, and encrypted migration paths.

## Windows NFS and RPC interoperability

- [mapadmin.exe](mapadmin.exe.md): legacy User Name Mapping inventory, backup, identity, credential, and current-store migration.
- [nfsadmin.exe](nfsadmin.exe.md): Server/Client for NFS configuration and lock inventory before global changes.
- [nfsshare.exe](nfsshare.exe.md): NFS export, client, root/anonymous mapping, and NTFS authorization boundaries.
- [nfsstat.exe](nfsstat.exe.md): cumulative NFS/ONC RPC counters and mounts without destroying the baseline.
- [showmount.exe](showmount.exe.md): exact-server MOUNT/export discovery with NFSv4 and sensitive-client caveats.
- [mount.exe](mount.exe.md): Windows Client for NFS export-to-drive mounting with identity, security, locking, and outage semantics.
- [rpcinfo.exe](rpcinfo.exe.md): ONC RPC portmapper programs, versions, transports, and dynamic-service discovery.
- [rpcping.exe](rpcping.exe.md): Microsoft RPC Endpoint Mapper/interface binding distinct from ICMP and ONC RPC.

## Windows background transfer

- [bitsadmin.exe](bitsadmin.exe.md): GUID-bound BITS job lifecycle, completion, ownership, security, and artifact-trust boundaries.

## Windows devices and printing

- [mode.com](mode.com.md): query-first serial, console, code-page, typematic, and legacy printer-device management.
- [print.exe](print.exe.md): reviewed text-file submission with exact queue, rendering, spool, and physical-output boundaries.
- [lpq.exe](lpq.exe.md) / [lpr.exe](lpr.exe.md): exact legacy LPD queue inspection and reviewed text or binary submission.
- [prncnfg.vbs](prncnfg.vbs.md): exact-queue configuration inventory through a localized inbox VBScript.
- [prndrvr.vbs](prndrvr.vbs.md): printer-driver inventory with INF model, signature, architecture, and broad-removal safeguards.
- [prnjobs.vbs](prnjobs.vbs.md) / [prnqctl.vbs](prnqctl.vbs.md): exact job evidence separated from queue-wide pause, purge, and physical test output.
- [prnmngr.vbs](prnmngr.vbs.md) / [prnport.vbs](prnport.vbs.md): user/machine queue/connection and logical TCP/IP port identity.
- [pubprn.vbs](pubprn.vbs.md): AD printer publication gated by exact shared queue and directory-container identity.
- [pushprinterconnections.exe](pushprinterconnections.exe.md): startup/logon policy processing diagnosed through RSoP rather than manual replay.
- [rundll32 printui](rundll32-printui.md): case-sensitive PrintUI entry point, per-computer connections, drivers, and settings boundaries.

## Windows installation, servicing, and drivers

- [msiexec.exe](msiexec.exe.md): package identity, logging, waiting, and restart codes.
- [dism.exe](dism.exe.md): explicit online/offline Windows image inventory and servicing.
- [sfc.exe](sfc.exe.md): protected-system-file verification and scoped repair.
- [pnputil.exe](pnputil.exe.md): Driver Store, device, and interface identity safety.
- [pnpunattend.exe](pnpunattend.exe.md): search-only unattended driver audit that avoids implicit online installation.
- [wdsutil.exe](wdsutil.exe.md): WDS device, driver, image, PXE, transport, multicast, lifecycle, boot-image support, and unattended-security boundaries.
- [fondue.exe](fondue.exe.md): single-feature enablement and source-policy boundaries.

## Windows security policy and authentication diagnosis

- [auditpol.exe](auditpol.exe.md): effective advanced audit policy and stable GUID identity.
- [gpresult.exe](gpresult.exe.md): exact user/computer RSoP and report protection.
- [klist.exe](klist.exe.md): Kerberos tickets, logon sessions, and binding evidence.
- [setspn.exe](setspn.exe.md): AD SPN ownership, duplicates, and safe registration boundaries.
- [ksetup.exe](ksetup.exe.md): Windows realm/KDC mappings, flags, encryption attributes, and non-AD Kerberos boundaries.
- [ktpass.exe](ktpass.exe.md): AD service mapping and keytab rotation with SPN/UPN, password, salt, KVNO, and crypto safeguards.
- [rdpsign.exe](rdpsign.exe.md): trial-first RDP-file publisher signing separated from client trust and server TLS identity.
- [scwcmd.exe](scwcmd.exe.md): SCW compliance analysis/rendering separated from server apply, rollback, database, and GPO mutation.
- [cmdkey.exe](cmdkey.exe.md): exact credential targets without inline secret exposure.
- [gpupdate.exe](gpupdate.exe.md): scoped policy refresh after preserving RSoP evidence.
- [secedit.exe](secedit.exe.md): validate/export/analyze security templates before apply.
- [icacls.exe](icacls.exe.md): DACL display, verification, backup, and inheritance safety.
- [cacls.exe](cacls.exe.md): deprecated ACL syntax and ICACLS migration without inheritance/lockout mistakes.
- [takeown.exe](takeown.exe.md): exact-object ownership recovery separate from access.
- [cipher.exe](cipher.exe.md): EFS identity, recovery, scope, and free-space boundaries.
- [certreq.exe](certreq.exe.md): explicit certificate request and acceptance lifecycle.
- [certutil.exe](certutil.exe.md): certificate, store, chain, and hash diagnostics.

## Windows Active Directory diagnosis

- [dcdiag.exe](dcdiag.exe.md): exact-DC health tests with test, naming-context, event-window, and repair boundaries.
- [repadmin.exe](repadmin.exe.md): directional, partition-specific replication evidence before any synchronization or topology change.
- [nltest.exe](nltest.exe.md): site, DC Locator, trust, and secure-channel query semantics distinct from verification and reset.
- [netdom.exe](netdom.exe.md): domain/DC/FSMO/trust inventory and member verification separated from membership, name, credential, and trust mutation.
- [adprep.exe](adprep.exe.md): installation-media, FSMO, schema-version, convergence, and forest/domain/RODC preparation boundaries.
- [dcpromo.exe](dcpromo.exe.md): legacy DC promotion/demotion syntax with modern ADDSDeployment discovery and secret-safe migration guidance.
- [dcgpofix.exe](dcgpofix.exe.md): disaster-only recovery of the two default GPOs after inventory and protected backup.
- [gpfixup.exe](gpfixup.exe.md): GPO dependency rewriting only inside a complete supported domain-rename workflow.
- [dnscmd.exe](dnscmd.exe.md): exact-server/zone/node DNS inventory before record, zone, server, DNSSEC, or partition changes.
- [dfsdiag.exe](dfsdiag.exe.md): DFS Namespace site/configuration/integrity/referral diagnosis distinct from DFS Replication.
- [dfsrmig.exe](dfsrmig.exe.md): PDC-governed FRS-to-DFSR SYSVOL migration state and irreversible elimination boundary.
- [ntfrsutl.exe](ntfrsutl.exe.md): legacy FRS internal inventory only after proving exact replica-set participation.

## Windows legacy server roles

- [append.exe](append.exe.md): unsupported DOS data-search-path recognition and explicit-path migration.
- [edit.exe](edit.exe.md): legacy interactive MS-DOS Editor recognition, encoding preservation, and supported-editor migration.
- [gettype.exe](gettype.exe.md): deliberately evidence-only treatment of a deprecated Server 2003 command with no current syntax contract.
- [graftabl.exe](graftabl.exe.md): legacy graphics character set distinguished from console and file encodings.
- [macfile.exe](macfile.exe.md): File Server for Macintosh volume, fork, permission, credential, and preservation boundaries.
- [winnt](winnt.md): Windows Server 2003 Winnt/Winnt32/RIS Setup/SysOcMgr artifact interpretation and current deployment migration.
- [ntbackup.exe](ntbackup.exe.md): preserved BKF recovery with the required legacy restore utility, explicitly separate from WbAdmin.
- [servermanagercmd.exe](servermanagercmd.exe.md): deprecated role/feature automation migration to typed Server Manager cmdlets.
- [server-telemetry](server-telemetry.md): legacy Server CEIP/WER query state versus managed diagnostic-data and privacy policy.
- [helpctr.exe](helpctr.exe.md): deprecated Server 2003 Help Center recognition and current help discovery.
- [ntcmdprompt.exe](ntcmdprompt.exe.md): NTVDM-era Command.com-to-Cmd compatibility distinct from a modern shell launch.
- [evntcmd.exe](evntcmd.exe.md): file-driven Event-to-SNMP trap mappings and destinations without confusing `/n` for a dry run.
- [jetpack.exe](jetpack.exe.md): offline WINS/DHCP database compaction with service, backup, free-space, and unique-temporary-file gates.
- [msmq](msmq.md): Message Queuing service/trigger executables plus destructive, service-stopping backup and restore boundaries.
- [nlbmgr.exe](nlbmgr.exe.md): deprecated NLB GUI target-list, polling, WMI, replication, and modern-alternative boundaries.
- [pbadmin.exe](pbadmin.exe.md): deprecated Phone Book Administrator discovery and Connection Manager migration.
- [tapicfg.exe](tapicfg.exe.md): domain TAPI directory-partition/SCP discovery before forest-wide changes.
- [tcmsetup.exe](tcmsetup.exe.md): replacement-not-append TAPI client server lists and complete-list validation.

## Windows storage, boot, and recovery

- [bcdboot.exe](bcdboot.exe.md): explicit Windows/system partition boot-file repair.
- [bcdedit.exe](bcdedit.exe.md): BCD store, entry, firmware, and backup boundaries.
- [bootcfg.exe](bootcfg.exe.md): legacy Boot.ini families versus modern BCD identity and recovery.
- [pwlauncher.exe](pwlauncher.exe.md): retired Windows To Go USB-first startup behavior and firmware/removable-media risk.
- [chkdsk.exe](chkdsk.exe.md): filesystem scan, repair mode, and result-code handling.
- [chkntfs.exe](chkntfs.exe.md): startup check scheduling and exclusion policy.
- [autochk.exe](autochk.exe.md): startup-only NTFS checking through supported dirty-state, policy, and event inspection.
- [autoconv.exe](autoconv.exe.md): internal startup FAT/FAT32-to-NTFS worker and supported Convert front-end boundary.
- [autofmt.exe](autofmt.exe.md): internal recovery formatter recognition without unsupported direct invocation.
- [defrag.exe](defrag.exe.md): media-aware optimization, retrim, tiers, and scope.
- [diskcomp.exe](diskcomp.exe.md) / [diskcopy.exe](diskcopy.exe.md): floppy-only track comparison and destructive same-type media copying.
- [diskperf.exe](diskperf.exe.md): physical/logical disk-counter configuration, restart, localization, and sampling boundaries.
- [diskraid.exe](diskraid.exe.md): focus-driven VDS hardware RAID, HBA, iSCSI, LUN, path, cache, and destructive lifecycle boundaries.
- [freedisk.exe](freedisk.exe.md): explicit-unit installation-space gates and the 0-enough/1-insufficient exit contract.
- [compact.exe](compact.exe.md): NTFS, executable, and CompactOS compression boundaries.
- [label.exe](label.exe.md) / [vol](vol.md): mutable labels and filesystem serial display correlated with durable volume/disk identity.
- [format.exe](format.exe.md): destructive filesystem creation gated by durable volume identity, restore, and media-aware sanitization limits.
- [recover.exe](recover.exe.md): single-file readable-sector salvage on an imaged/clone copy, distinct from filesystem and disk recovery.
- [makecab.exe](makecab.exe.md) / [diantz.exe](diantz.exe.md): explicit Cabinet builds, directive-file review, artifact verification, and searchable compatibility naming.
- [expand.exe](expand.exe.md): list-first, isolated Cabinet extraction with path, collision, signature, and format boundaries.
- [extract](extract.md): modern `extrac32.exe` replacement, silent-output handling, and non-executing Cabinet inspection/extraction.
- [manage-bde.exe](manage-bde.exe.md): BitLocker state, protectors, escrow, and access.
- [fveupdate.exe](fveupdate.exe.md): Windows Setup-owned internal BitLocker metadata updater recognition.
- [mountvol.exe](mountvol.exe.md): volume GUID, mount-point, automount, and ESP safety.
- [diskpart.exe](diskpart.exe.md): focus-driven disk, partition, volume, and VHD safety.
- [fsutil.exe](fsutil.exe.md): advanced filesystem, journal, link, and behavior state.
- [ktmutil.exe](ktmutil.exe.md): Kernel Transaction Manager inspection with owner-controlled recovery decisions.
- [pagefileconfig.exe](pagefileconfig.exe.md): deprecated paging-file CLI migration and configuration-versus-runtime state.
- [pentnt.exe](pentnt.exe.md): deprecated historical Pentium FDIV workaround discovery and retirement.
- [vssadmin.exe](vssadmin.exe.md): VSS writer, provider, shadow, and diff-area evidence.
- [diskshadow.exe](diskshadow.exe.md): scripted VSS backup, restore, and transport boundaries.
- [wbadmin.exe](wbadmin.exe.md): Windows Backup catalog, version, target, and recovery identity.
- [bdehdcfg.exe](bdehdcfg.exe.md): legacy BitLocker boot-partition preparation boundaries.
- [refsutil.exe](refsutil.exe.md): ReFS query, diagnosis, repair, and salvage family safety.

## Query with ManT

After adding this repository to `sources.toml` and running
`mant --update-docs`, use commands such as:

```text
mant winget --source windows-tools
mant winget-install --source windows-tools --outline
mant winget-install --source windows-tools --search=--id
mant reg --source windows-tools --search=registry
```

## Related documents

- [Microsoft Learn MCP queries](microsoft-learn-mcp.md)
- [cmd.exe](cmd.exe.md)
- [Windows Package Manager](winget.exe.md)
- [Registry command](reg.exe.md)
- [Windows event log utility](wevtutil.exe.md)

## Sources and license

This source contains original ManT-oriented documentation informed by each
tool vendor's official documentation and source repositories, including the
[Windows Package Manager documentation](https://learn.microsoft.com/windows/package-manager/winget/).
Exact upstream revisions and page-level provenance are recorded in the
repository's `upstream/windows-tools.json` catalog.

The documentation in this source is licensed under CC BY 4.0. Product names
and trademarks belong to their respective owners.
