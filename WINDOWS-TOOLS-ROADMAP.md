# Windows tool coverage roadmap

This roadmap prioritizes Windows command documentation by combining user
demand, automation risk, and the likelihood that a shell-aware agent will
produce a plausible but incorrect command. It is a planning document, not a
claim that search results measure the entire Windows user population.

## Official inventory baseline

The locked `windowsserverdocs` revision recorded in `upstream/windows-tools.json`
contains 869 Markdown files below `WindowsServerDocs/administration/windows-commands`.
Its A-Z index contains about 339 top-level entries. Neither number is a useful
target document count by itself:

- many files are subcommands of a single executable, such as BITSAdmin,
  DiskPart, DiskShadow, FSUtil, Netsh, NSLookup, Wbadmin, and Wdsutil;
- generic words such as `add`, `clean`, `create`, `delete`, `list`, `select`,
  and `set` are commands inside an interactive tool, not standalone programs;
- several entries are aliases for the same cmd builtin, such as `cd`/`chdir`,
  `del`/`erase`, `md`/`mkdir`, `rd`/`rmdir`, and `ren`/`rename`;
- some tools require an optional Windows feature or a Windows Server role;
- some pages describe deprecated, removed, or compatibility-only tools;
- GUI executables and URI schemes such as Explorer and `ms-settings:` are
  important to PowerShell users but are not all represented by the Windows
  Commands A-Z index.

The coverage target is therefore one useful lookup page for every supported
command name or command family, plus focused pages for high-demand or
high-risk subcommands. Alias lookup pages can remain concise and point to the
canonical page. The project must not claim that 869 upstream files imply 869
independent installed CLIs.

## Scope classes

Every Windows page will identify one of these availability classes:

1. **Core client and server**: expected on supported Windows 10/11 and current
   Windows Server releases.
2. **Optional Windows component**: requires a feature, capability, RSAT
   package, architecture, or other installed component.
3. **Windows Server role**: available only with a named server role or
   management tool.
4. **Legacy or deprecated**: retained for compatibility or migration; the
   page points to the current replacement when Microsoft identifies one.
5. **Shell builtin**: implemented by `cmd.exe`, not discoverable as a separate
   executable.
6. **Interactive command family**: valid only inside a host such as DiskPart,
   DiskShadow, FTP, NSLookup, or Telnet.
7. **GUI or URI entry point**: starts an interactive surface and does not by
   itself prove that configuration changed.

## Page granularity and filenames

- Use the executable or cmd-builtin spelling for a top-level page, omitting
  `.exe` from the filename.
- Give common aliases their own small lookup page when users are likely to run
  `mant ALIAS`; link to the canonical document instead of duplicating detail.
- Prefix interactive subcommands with the host name, for example
  `diskpart-clean.md`, `diskshadow-expose.md`, and `nslookup-set-type.md`.
- Add separate subcommand pages when an operation is destructive, has a large
  parameter surface, has a distinct success contract, or is commonly queried.
  Summarize the remaining subcommands and parameters in the family overview.
- Use stable semantic names for URI and GUI pages, such as `ms-settings.md` and
  `explorer.md`.
- Keep all published files flat within `docs/en-US/windows-tools` for ManT.

## Required page content

In addition to the repository-wide authoring guide, a Windows page records:

- syntax and the important parameter groups, including less common switches
  that materially change scope or safety;
- command type and unambiguous PowerShell resolution;
- text/object, stdout/stderr, and exact exit-code behavior when documented;
- local versus remote target, elevation, user/session context, architecture,
  and WOW64 or registry-view behavior;
- a read-only query, preview, or backup before destructive examples;
- post-operation verification rather than assuming process launch is success;
- availability class, supported Windows releases, feature/role prerequisites,
  and deprecation status;
- a `Common mistakes` section when recurring errors are known;
- reader-facing official sources and locked page-level provenance.

Community questions, issue reports, and search results may establish demand or
demonstrate a recurring mistake. They do not override Microsoft's current
syntax, support, security, or deprecation guidance.

## Priority model

A command or topic moves earlier when it has one or more of these properties:

- users repeatedly need it for ordinary setup, diagnosis, or administration;
- PowerShell, `cmd.exe`, and the native executable resolve the same spelling
  differently;
- quoting or argument parsing crosses more than one shell;
- success cannot be inferred from exit code zero alone;
- the command changes persistent system state or can delete data;
- it opens a GUI or URI but does not itself verify that a setting changed;
- availability depends on Windows version, edition, installed features, user
  session, architecture, elevation, or organization policy.

## Evidence behind the first priorities

- Opening Explorer from PowerShell is a long-running high-interest task. One
  Stack Overflow question has more than 220,000 views and its leading answer
  uses `Invoke-Item`/`ii`, not an `explorer.exe` switch recipe:
  <https://stackoverflow.com/questions/320509/is-it-possible-to-open-a-windows-explorer-window-from-powershell/321092>.
- A public Codex issue records agents emitting PowerShell syntax into a
  `cmd.exe /c` context and losing quoted multi-word arguments across the shell
  boundary:
  <https://github.com/openai/codex/issues/9581>.
- `sc` is a concrete PowerShell command-resolution trap: in Windows PowerShell
  it can resolve to `Set-Content` instead of the Service Controller executable:
  <https://stackoverflow.com/questions/51062160/sc-create-binpath-error>.
- Robocopy's successful and nonfatal results can be nonzero, which causes
  generic agent and CI success checks to report false failures:
  <https://stackoverflow.com/questions/42165832/get-powershell-to-ignore-exitcode>.
- Microsoft's PowerShell guidance identifies native argument passing, stdout
  and stderr handling, and native exit status as distinct shell boundaries:
  <https://learn.microsoft.com/powershell/scripting/learn/shell/running-commands>.
- Waiting for GUI-subsystem applications is a major recurring question. A
  Stack Overflow thread with more than 700,000 views illustrates why direct
  invocation, pipelines, `Start-Process -Wait`, and process identity must be
  distinguished:
  <https://stackoverflow.com/questions/1741490/how-to-tell-powershell-to-wait-for-each-command-to-end-before-starting-the-next>.
- MSI automation repeatedly combines batch-only variables, nested quoting,
  GUI-process waiting, logs, and nonzero success codes such as 3010:
  <https://stackoverflow.com/questions/73063024/msiexec-powershell-silent-install>.
- Registry automation has a separate 32-bit and 64-bit view problem, which is
  why `reg.exe` parameters such as `/reg:32` and `/reg:64` cannot be omitted
  from a useful PowerShell-facing guide:
  <https://stackoverflow.com/questions/630382/how-to-access-the-64-bit-registry-from-a-32-bit-powershell-instance>.
- Driver-tool failures commonly come from 32-bit process redirection and from
  passing a `FileInfo` object where a native executable needs a pathname:
  <https://stackoverflow.com/questions/53289365/powershell-not-finding-pnputil-when-script-launched-from-shortcut> and
  <https://stackoverflow.com/questions/27324744/powershell-pass-inf-files-to-pnputil>.
- A widely viewed Rundll32 question demonstrates the central compatibility
  trap: Rundll32 cannot call an arbitrary exported DLL function:
  <https://stackoverflow.com/questions/3207365/how-to-use-rundll32-to-execute-dll-function>.
- Microsoft's Windows command index and individual references establish the
  supported command surface; community examples are demand/error signals, not
  the source of truth for syntax:
  <https://learn.microsoft.com/windows-server/administration/windows-commands/windows-commands>.

## P0: shell boundaries and everyday Windows entry points

These pages should be completed before adding a long alphabetical command
catalog.

| Topic | Why it is P0 | Planned location |
| --- | --- | --- |
| `cmd.exe` and `cmd /c` | Agents frequently mix PowerShell and cmd syntax or break nested quoting. | `windows-tools` |
| `start` versus `Start-Process` | `start` is a cmd builtin but a PowerShell alias; quoted paths have different rules. | `windows-tools`, then both PowerShell sources |
| `Invoke-Item` / `ii` | Common, supported way to open a path with its registered GUI handler. | both PowerShell sources |
| `explorer.exe` | High-demand interactive task; Explorer process reuse makes `-Wait` and process identity unreliable. | `windows-tools` |
| `ms-settings:` | Current Windows Settings entry point; opening a page is not configuration automation. | `windows-tools` |
| `control.exe` | Legacy Control Panel entry point with version- and SKU-dependent canonical items. | `windows-tools` |
| `mmc.exe` and `.msc` files | Common administrative GUI host; architecture, snap-in, elevation, and edition matter. | `windows-tools` |
| `reg.exe` | Persistent and potentially destructive state changes; registry view and value type matter. | `windows-tools` |
| `rundll32.exe` | Frequently copied from old recipes, but only documented Rundll32 entry points are valid. | `windows-tools` |

Existing P0 coverage must also remain prominent: `where.exe`, `sc.exe`, native
`curl`, winget lifecycle commands, `schtasks`, and Robocopy's special exit
codes.

## P1: administration with high consequence or unusual contracts

Add focused overview and subcommand pages for:

- `msiexec.exe`: quoting, silent operation, logging, reboot-related success
  codes, and product identity;
- `dism.exe` and `sfc.exe`: image target, online/offline context, restart, and
  repair verification;
- `pnputil.exe`: driver package identity and device-impacting operations;
- `manage-bde.exe`: volume identity, recovery material, protectors, and
  elevation;
- `wevtutil.exe`: log/channel identity, XML queries, export, and clearing risk;
- `icacls.exe` and `takeown.exe`: ACL inheritance, principals, recursion, and
  rollback;
- `netsh.exe`, `ipconfig.exe`, `netstat.exe`, `route.exe`, and `nslookup.exe`:
  network scope, legacy versus current interfaces, parsing, and elevation;
- `tasklist.exe`, `taskkill.exe`, `systeminfo.exe`, `shutdown.exe`, and
  `powercfg.exe`: remote scope, filters, session impact, and exit status.

## P2: specialized and legacy tools

Cover tools such as `certutil.exe`, `fsutil.exe`, `bcdedit.exe`, `diskpart.exe`,
`lodctr.exe`, `typeperf.exe`, `driverquery.exe`, and role-specific server tools
only after their safety model and authoritative versioned sources are clear.
Some are powerful compatibility or recovery tools, not recommended general
automation interfaces; their pages must say so explicitly.

## Delivery batches and commits

Each batch is validated, committed, and pushed before the next large batch so
it can be tested through a local ManT source.

1. **Inventory and conventions**: record the official baseline, scope classes,
   naming rules, acceptance criteria, demand evidence, and batch plan.
2. **Shell, GUI, settings, and registry**: `cmd`, `start`, `explorer`,
   `ms-settings`, `control`, `mmc`, `reg`, and `rundll32`; add PowerShell
   companion pages for `Start-Process`/`start` and `Invoke-Item`/`ii`.
3. **Cmd builtins and shell state**: file/directory aliases, `assoc`, `ftype`,
   `call`, `choice`, `for`, `if`, `set`, `setlocal`, `path`, `pushd`, `popd`,
   `timeout`, `title`, redirection, and nested-shell quoting.
4. **Everyday files, text, and processes**: `attrib`, `clip`, `comp`, `fc`,
   `find`, `findstr`, `forfiles`, `mklink`, `openfiles`, `sort`, `subst`,
   `tree`, `xcopy`, `tasklist`, `taskkill`, `systeminfo`, and `whoami`.
5. **Network diagnosis and configuration**: `arp`, `getmac`, `hostname`,
   `ipconfig`, `nbtstat`, `netstat`, `nslookup`, `pathping`, `ping`, `route`,
   `tracert`, and focused Netsh contexts.
6. **Installation, servicing, and drivers**: `msiexec`, DISM, `sfc`, `fondue`,
   `pnputil`, `pnpunattend`, and `driverquery`, including synchronous GUI
   process behavior, reboot-success codes, and Sysnative redirection.
7. **Security, identity, policy, and certificates**: `auditpol`, `certreq`,
   `certutil`, `cipher`, `cmdkey`, `gpresult`, `gpupdate`, `icacls`, `klist`,
   `secedit`, `setspn`, and `takeown`.
8. **Storage, boot, encryption, backup, and recovery**: `bcdboot`, `bcdedit`,
   `chkdsk`, `chkntfs`, `compact`, `defrag`, DiskPart, DiskShadow, FSUtil,
   `manage-bde`, `mountvol`, ReFSUtil, `repair-bde`, Vssadmin, and Wbadmin.
9. **Events, performance, and diagnostics**: `eventcreate`, `lodctr`, `logman`,
   `msinfo32`, `perfmon`, `pktmon`, `relog`, `sxstrace`, `tracerpt`, `typeperf`,
   `unlodctr`, `verifier`, `wecutil`, and `wevtutil`.
10. **Services, tasks, remoting, and sessions**: expand `sc` and `schtasks`;
    cover `logoff`, `msg`, `mstsc`, `quser`, `qwinsta`, `rwinsta`, `shutdown`,
    `tscon`, `tsdiscon`, `waitfor`, and `winrs`.
11. **Windows Server roles and optional components**: Active Directory, DNS,
    DFS, NFS, printing, Remote Desktop Services, WDS, messaging, clustering,
    and other role-bound families, split into reviewable sub-batches.
12. **Legacy and compatibility audit**: document or explicitly index every
    remaining A-Z entry, including replacements, removal status, and why it is
    not a recommended new automation interface.
13. **Final coverage audit**: reconcile every official top-level entry and
    every family subcommand to a ManT page, a family section, an alias target,
    or an explicit out-of-scope/deprecated record; update release metadata and
    runtime evidence.

The first pass should favor accurate family overviews over hundreds of thin
subcommand stubs. Focused subcommand pages are added after the family page
exposes the full official parameter surface and identifies which operations
need more depth.

## Authoring rules for agent-resistant pages

Each Windows native-command page should make the following explicit when
applicable:

1. the actual command type and the result of `Get-Command NAME -All`;
2. whether the operation runs in PowerShell, `cmd.exe`, a GUI process, or a URI
   handler;
3. one-shell examples before any nested-shell example;
4. quoting rules at every shell boundary;
5. output streams and the exact exit-code success contract;
6. destructive scope, elevation, remote target, architecture, and registry
   view;
7. a read-only inspection or preview before state change;
8. post-operation verification rather than assuming process launch means the
   requested state changed;
9. Windows release, edition, installed-feature, and session constraints;
10. an official source of record, with community reports used only to explain
    demand and recurring mistakes.
