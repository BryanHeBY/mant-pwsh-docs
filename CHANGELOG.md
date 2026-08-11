# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to use semantic versioning for published document
bundles.

## [Unreleased]

### Added

- First English release inventory: 228 reviewed ManT pages across `pwsh7`,
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
