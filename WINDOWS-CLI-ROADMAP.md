# Windows CLI coverage roadmap

This roadmap prioritizes Windows command documentation by combining user
demand, automation risk, and the likelihood that a shell-aware agent will
produce a plausible but incorrect command. It is a planning document, not a
claim that search results measure the entire Windows user population.

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
- Microsoft's Windows command index and individual references establish the
  supported command surface; community examples are demand/error signals, not
  the source of truth for syntax:
  <https://learn.microsoft.com/windows-server/administration/windows-commands/windows-commands>.

## P0: shell boundaries and everyday Windows entry points

These pages should be completed before adding a long alphabetical command
catalog.

| Topic | Why it is P0 | Planned location |
| --- | --- | --- |
| `cmd.exe` and `cmd /c` | Agents frequently mix PowerShell and cmd syntax or break nested quoting. | `pwsh-cli` |
| `start` versus `Start-Process` | `start` is a cmd builtin but a PowerShell alias; quoted paths have different rules. | `pwsh-cli`, then both PowerShell sources |
| `Invoke-Item` / `ii` | Common, supported way to open a path with its registered GUI handler. | both PowerShell sources |
| `explorer.exe` | High-demand interactive task; Explorer process reuse makes `-Wait` and process identity unreliable. | `pwsh-cli` |
| `ms-settings:` | Current Windows Settings entry point; opening a page is not configuration automation. | `pwsh-cli` |
| `control.exe` | Legacy Control Panel entry point with version- and SKU-dependent canonical items. | `pwsh-cli` |
| `mmc.exe` and `.msc` files | Common administrative GUI host; architecture, snap-in, elevation, and edition matter. | `pwsh-cli` |
| `reg.exe` | Persistent and potentially destructive state changes; registry view and value type matter. | `pwsh-cli` |
| `rundll32.exe` | Frequently copied from old recipes, but only documented Rundll32 entry points are valid. | `pwsh-cli` |

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
