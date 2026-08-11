# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to use semantic versioning for published document
bundles.

## [Unreleased]

### Added

- First English release inventory: 318 reviewed ManT pages across `pwsh7`,
  `pwsh51`, and `pwsh-cli`.
- Broad `pwsh7` and `pwsh51` shell manuals, focused language/command pages,
  compatibility guides, and custom `irx` shorthand resolution guidance.
- Native CLI coverage for Microsoft Learn MCP discovery, winget, Windows system
  tools, Git, OpenSSH, curl, tar, and .NET.
- Windows shell, GUI, Settings, Control Panel, MMC, Registry, and Rundll32
  entry-point guides, plus matching `Start-Process`, `start`, `Invoke-Item`,
  and `ii` pages for PowerShell 7 and Windows PowerShell 5.1.
- Cmd batch-state and interaction guides for `set`, `setlocal`, `endlocal`,
  `call`, `choice`, `timeout`, and `exit`.
- Cmd control-flow, search-path, directory-stack, title, and classic file-
  association guides for `for`, `if`, `path`, `pushd`, `popd`, `title`,
  `assoc`, and `ftype`.
- Cmd directory listing, file copy, permanent file deletion, and recursive
  directory removal guides, including `erase` and `rmdir` lookup aliases.
- Cmd directory navigation, creation, move, and rename guides, including
  `chdir`, `mkdir`, and `rename` lookup pages and PowerShell resolution notes.
- Windows text display, literal/limited-regex search, file comparison, line
  sorting, and clipboard guides for `type`, `find`, `findstr`, `fc`, `sort`,
  and `clip`, including exit-code and PowerShell alias boundaries.
- Windows attribute, date-selected traversal, directory diagram, substituted
  drive, link, and legacy tree-copy guides for `attrib`, `forfiles`, `tree`,
  `subst`, `mklink`, and `xcopy`.
- Windows process listing/termination, host, effective-token identity, open-
  file, and driver inventory guides for `tasklist`, `taskkill`, `systeminfo`,
  `whoami`, `openfiles`, and `driverquery`.
- Expanded Service Control Manager and Task Scheduler family guides for
  `sc.exe` and SchTasks, including PowerShell alias, scheduled-principal,
  quoting, security, and runtime-context traps.
- Windows Net command-family coverage for local/domain identity, outbound SMB
  connections, inbound shares/sessions/open files, services, discovery,
  statistics, help, and legacy printing/messaging surfaces.
- Windows Remote Desktop query-family coverage for user sessions, all session
  objects/listeners, session-owned processes, legacy Session Host discovery,
  and the `quser`, `qwinsta`, `qprocess`, and `qappsrv` lookup aliases.
- Remote Desktop session notification and lifecycle guides for `msg`,
  `tsdiscon`, `logoff`, and `rwinsta`, with explicit owner warning, session-ID
  revalidation, privilege, persistence, and data-loss boundaries.
- Remote Desktop attach, consent-governed shadowing, and session-process
  termination guides for `tscon`, `shadow`, and `tskill`, including console/
  physical-access, password, privacy, wildcard, PID, and session-ID traps.
- Windows remote-management guides for `winrm` WS-Management configuration and
  `winrs` remote native command execution, including TrustedHosts direction,
  authentication/encryption, HTTPS certificate, delegation, endpoint, quoting,
  remote-context, and second-hop boundaries.
- Windows Event Log and forwarding guides for `wevtutil`, `wecutil`, and
  `eventcreate`, including bounded XML/XPath queries, EVTX evidence, channel/
  manifest/clear risks, subscription runtime status, WEF delivery/scale, and
  explicitly labeled non-audit test markers.
- Windows performance-counter and ETW diagnostic guides for `logman`,
  `typeperf`, `relog`, `tracerpt`, `lodctr`, and `unlodctr`, including localized
  counter discovery, bounded sampling, evidence-preserving conversion, and
  provider-registration repair boundaries.
- Windows system diagnosis and maintenance guides for `perfmon`, `msinfo32`,
  `cleanmgr`, `shutdown`, `tzutil`, and `verifier`, including verified report
  export, cleanup profile scope, implicit forced close, Windows/IANA time-zone
  distinctions, and test-only Driver Verifier recovery requirements.
- Windows Connection Manager profile, display capture, DTrace, deprecated MSDT,
  network-component/binding, and unattended-driver guides for `cmstp`,
  `dispdiag`, `dtrace`, `msdt`, `netcfg`, and `pnpunattend`, with inspect/compile/
  search-first TLDRs and explicit active-INF, binary-artifact, destructive-
  probe, retired-pack, all-adapter cleanup, and accidental-driver-install traps.
- Windows Deployment Services family coverage for `wdsutil` device, driver,
  image, server/transport, multicast/namespace, and lifecycle subcommands, with
  exact-server query-first TLDRs plus current boot.wim support and April 2026
  hands-free Unattend/RPC hardening boundaries.
- Windows time-service, power/sleep, recovery-environment, and DirectX diagnostic
  guides for `w32tm`, `powercfg`, `reagentc`, and `dxdiag`, including bounded
  offset sampling, effective policy, protected report export, and boot/recovery
  identity and rollback constraints.
- Searchable Windows GUI management entries for `taskmgr`, `resmon`, `eventvwr`,
  and `compmgmt`, with live-snapshot, raw-event, per-snap-in target, and
  structured-automation boundaries.
- Searchable Device Manager, Disk Management, Services, and Optional Features
  entries, with device-instance, unique-disk, SCM identity, and feature-versus-
  capability safeguards.
- Searchable System Configuration, Local Group Policy Editor, Advanced System
  Properties, Magnifier, Narrator, and On-Screen Keyboard entries, with
  resultant-policy, environment-scope, startup/recovery, assistive-technology,
  session, privacy, and protected-system-file safeguards.
- Windows persistent-environment, Windows Script Host, COM self-registration,
  deprecated WMIC/CIM migration, classic Remote Desktop client, and side-by-side
  activation diagnostic guides for `setx`, `cscript`, `wscript`, `regsvr32`,
  `wmic`, `mstsc`, and `sxstrace`, including high-frequency data-loss,
  privilege, credential, architecture, dialog, deprecation, and trace-lifecycle
  mistakes drawn from official documentation and community demand signals.
- Windows filesystem formatting, single-file sector salvage, bounded packet
  monitoring, TPM diagnosis, and Cabinet packaging/extraction guides for
  `format`, `recover`, `pktmon`, `tpmtool`, `makecab`, `diantz`, and `expand`,
  with list/query-first TLDRs and explicit identity, evidence, privacy,
  lifecycle, alias, artifact, collision, and destructive-operation boundaries.
- Windows console-code-page, interactive history/macro, forward-paging,
  byte-comparison, same-name replacement, volume-label/serial, and named-signal
  guides for `chcp`, `doskey`, `more`, `comp`, `replace`, `label`, `vol`, and
  `waitfor`, prioritizing high-demand encoding, prompt, command-resolution,
  wildcard, recursion, mutable-identity, timeout, and broadcast mistakes.
- Searchable Cmd message/comment, label control-flow, argument shifting,
  attended pause, prompt, clear-screen, and color guides for `echo`, `rem`,
  `goto`, `shift`, `pause`, `prompt`, `cls`, and `color`, including empty-
  expansion, parse-layer, subroutine, unattended-hang, trust/accessibility, and
  upstream-documentation inconsistency traps.
- Cmd help-context, compact Windows version, legacy write-verification and
  MS-DOS BREAK compatibility guides plus query-first system date/time guides,
  with explicit PowerShell/native resolution, Windows 11 detection, invariant
  timestamp, rollover, redirection, synchronization, and Kerberos safeguards.
- Legacy AT scheduler, deprecated CACLS, and Boot.ini-era BOOTCFG migration
  guides plus a current BITSAdmin family guide, with query-only TLDRs and
  explicit task principal, ACL inheritance, BCD identity, GUID/job completion,
  delayed execution, ownership, credential, and artifact-trust boundaries.
- Windows MODE device-family and PRINT text-submission guides with query-only
  TLDRs and explicit serial framing/ownership, console-host, encoding, legacy
  LPT, exact queue, rendering, spool-completion, duplicate and physical-output
  boundaries.
- Windows localized Printing Administration script, deployed-connection, and
  PrintUI guides for `prncnfg`, `prndrvr`, `prnjobs`, `prnmngr`, `prnport`,
  `prnqctl`, `pubprn`, `pushprinterconnections`, and `rundll32 printui`, with
  query/prerequisite-first TLDRs and script-host, language-path, user/machine,
  queue/job/driver/port/device, AD publication, policy, INF, bitness, credential,
  purge, physical-output, and settings-restore boundaries.
- Windows optional NFS administration/export/statistics/mount-discovery and
  ONC/Microsoft RPC diagnostic guides for `nfsadmin`, `nfsshare`, `nfsstat`,
  `showmount`, `rpcinfo`, and `rpcping`, with query-only TLDRs and explicit
  UID/GID/root/anonymous, export/NTFS, NFS version/MOUNT, cumulative-counter,
  portmapper/Endpoint Mapper, dynamic-port, interface, credential, broadcast,
  lock-release, and counter-reset boundaries.
- Windows Client for NFS mounting, LPR/LPD queue inspection/submission, Telnet
  Server inventory, and deprecated Rexec/RSH migration guides for `mount`,
  `lpq`, `lpr`, `tlntadmn`, `rexec`, and `rsh`, with prerequisite-first TLDRs
  and explicit identity, locking, print-rendering, duplicate-job, plaintext,
  command-resolution, retired-feature, and safer-transport boundaries.
- Windows FTP, optional TFTP/Telnet, and legacy Finger client guides with
  connection-free TLDRs and explicit plaintext, passive/active data-channel,
  script credential, binary integrity, unauthenticated provisioning, feature-
  installation, terminal/logging, user-enumeration and remote-text boundaries.
- Windows adapter/DHCP/DNS inspection, bounded ICMP reachability, path tracing,
  path sampling, host identity, and direct DNS-query guides for `ipconfig`,
  `ping`, `tracert`, `pathping`, `hostname`, and `nslookup`.
- Windows socket/PID, IPv4 routing, per-interface neighbor cache, and adapter
  MAC inventory guides for `netstat`, `route`, `arp`, and `getmac`.
- Legacy NetBIOS diagnosis and Netsh family guides for context discovery,
  interface/IP state, Wi-Fi inventory, and Winsock provider inspection.
- Windows Installer, DISM image servicing, protected-file verification,
  Driver Store/device management, and optional-feature enablement guides for
  `msiexec`, DISM, `sfc`, `pnputil`, and `fondue`.
- Advanced audit policy, Group Policy RSoP, Kerberos ticket/session, and
  Active Directory SPN diagnosis guides for `auditpol`, `gpresult`, `klist`,
  and `setspn`.
- Active Directory DC health, directional per-partition replication, client
  site/DC Locator, member secure-channel, FSMO, and trust diagnosis guides for
  `dcdiag`, `repadmin`, `nltest`, and `netdom`, with single-target read-only
  TLDRs and explicit event-history, scope-expansion, replication-trigger,
  credential, rename, reset, and trust-direction boundaries.
- Windows Kerberos realm/keytab interoperability, RDP-file publisher signing,
  and Security Configuration Wizard guides for `ksetup`, `ktpass`, `rdpsign`,
  and `scwcmd`, with query/trial-first TLDRs and explicit realm, SPN/UPN,
  password/key, salt/KVNO, certificate-fingerprint/trust, overwrite, apply,
  rollback, fan-out, credential, and GPO-creation boundaries.
- Active Directory schema/forest/domain preparation, legacy DC promotion and
  demotion migration, default-GPO disaster recovery, and post-domain-rename GPO
  rewrite guides for `adprep`, `dcpromo`, `dcgpofix`, and `gpfixup`, with
  inventory/backup-only TLDRs and explicit media, FSMO, convergence, secret,
  replication, rollback, and workload-compatibility gates.
- Windows DNS Server, DFS Namespace, SYSVOL FRS-to-DFSR migration, and legacy
  FRS diagnostic guides for `dnscmd`, `dfsdiag`, `dfsrmig`, and `ntfrsutl`,
  with exact-target query TLDRs and explicit export-versus-backup, namespace-
  versus-replication, convergence, irreversible-state, stale-member, and
  recovery-authority boundaries.
- Stored credential target, scoped Group Policy refresh, and security-template
  validation/export/analysis guides for `cmdkey`, `gpupdate`, and `secedit`.
- Windows DACL/inheritance, ownership recovery, and EFS encryption/recovery
  guides for `icacls`, `takeown`, and `cipher`.
- Windows certificate request lifecycle and certificate/store/chain diagnostic
  guides for `certreq` and `certutil`.
- Windows boot-file repair and BCD store/firmware configuration guides for
  `bcdboot` and `bcdedit`.
- Windows filesystem checking/startup scheduling, media-aware optimization,
  and NTFS/CompactOS compression guides for `chkdsk`, `chkntfs`, `defrag`,
  and `compact`.
- Windows BitLocker state/protector/recovery and volume GUID/mount-point guides
  for `manage-bde` and `mountvol`.
- Windows focus-driven disk/partition/VHD and advanced filesystem behavior,
  link, sparse-file, volume, and journal family guides for DiskPart and FSUtil.
- Windows VSS writer/provider/shadow, DiskShadow transaction/transport, and
  Windows Backup version/catalog/recovery guides for VssAdmin, DiskShadow, and
  WBAdmin.
- Legacy BitLocker system-partition preparation and advanced ReFS query,
  diagnosis, repair, and salvage family guides for BdeHdCfg and RefsUtil.
- Per-page locked provenance catalogs, reader-facing source/license sections,
  and an optional upstream accessibility audit.
- Portable Node.js validation with ManT JSON diagnostics and a v1 release gate.

### Changed

- CI is manual-only until ManT 0.6.0 is publicly installable.

### Pending release verification

- Runtime verification on Windows, macOS, and Linux remains required before
  creating the final v1 tag; see [release/v1-runtime.md](release/v1-runtime.md).
