<!-- mant:tldr:start -->
# net.exe

> Inventory Windows local accounts, outbound SMB connections, inbound shares and sessions, remotely opened files, and service state before changing any of them.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/net-user.

- List the command families and use target-host help as the syntax contract:

`net.exe help`

- List local user account names; add `/domain` only when the current domain is the intended scope:

`net.exe user`

- List local groups, then query one exact group separately when membership matters:

`net.exe localgroup`

- Display the account and password-policy summary visible to this computer:

`net.exe accounts`

- List outbound network-resource connections for the current logon session:

`net.exe use`

- List SMB shares published by the local Server service:

`net.exe share`

- List clients with inbound SMB sessions to the local server:

`net.exe session`

- List files that remote clients have opened through the local Server service:

`net.exe file`

- List services that `net start` considers started:

`net.exe start`

- List computers or shares visible through legacy network browsing; absence is not proof that a server or share does not exist:

`net.exe view`
<!-- mant:tldr:end -->

# net.exe

## Overview

`net.exe` is a long-lived Windows command dispatcher. Its subcommands span
local and domain accounts, SMB client connections, SMB server shares, sessions,
open files, service control, discovery, statistics, time, and legacy messaging
or printing. Those are different security and state boundaries even though
they share one executable and similar human-readable output.

The TLDR is intentionally inventory-only. Account, share, connection, session,
open-file, service, and policy mutations can deny access, expose data, interrupt
work, invalidate credentials, or affect many computers. Run `net.exe help` and
`net.exe help <command>` on the target build before using a write form.

## Resolvable commands

<!-- mant:entries role=command case=insensitive -->
- `user`: Inspect or manage local accounts, or domain accounts when `/domain` selects that authority.
- `localgroup`: Inspect or manage groups in the target computer's local account database.
- `group`: Inspect or manage domain groups in the selected domain context.
- `accounts`: Display or change selected account/password policy values; effective policy can have additional sources.
- `computer`: Perform legacy domain computer-account operations where supported.
- `use`: Inspect or manage outbound SMB/network-resource connections for the current logon context.
- `share`: Inspect or manage resources published by the local Server service.
- `session`: Inspect or disconnect inbound client sessions to the local Server service.
- `file`: Inspect or close files opened remotely through the local Server service.
- `view`: Query legacy network browse visibility; absence is not proof a host or share is unreachable.
- `config`: Inspect or change Workstation/Server service configuration according to the selected family.
- `statistics`: Display cumulative Workstation or Server service counters.
- `start`, `stop`, `pause`, `continue`: List or control services with less diagnostic detail than `sc.exe`.
- `help`: Display installed syntax and help for a NET command.
- `helpmsg`: Explain one numeric network error using installed localized messages.
- `time`: Use the legacy network-time surface; prefer `w32tm` for Windows Time diagnostics.
- `print`: Inspect or manage legacy network print queues where the subsystem remains available.
- `name`, `send`: Address retired or legacy messaging facilities whose availability varies by build.

## Common scope options

<!-- mant:entries role=option case=insensitive -->
- `/domain`: Direct a supported account/group operation to the computer's primary domain instead of the local database.
- `/delete`: Remove the selected connection, share, account, group membership, or other subcommand-specific object.
- `/persistent:yes`, `/persistent:no`: Set persistence for supported `net use` connections and the default for later connections.
- `/savecred`: Save credentials for reuse; requires a separate credential lifecycle and threat review.
- `/y`, `/yes`: Confirm a supported operation without prompting; exact availability is subcommand-specific.

## Command-family map

| Boundary | Subcommands | What they address |
| --- | --- | --- |
| Local/domain identity and policy | `user`, `localgroup`, `group`, `accounts`, `computer` | Accounts, memberships, password/account policy, and legacy domain computer-account operations; local and domain scope differ. |
| Outbound client connections | `use` | Connections from the current logon session to SMB shares and compatible network resources, including drive mappings and persistence. |
| Inbound file-server state | `share`, `session`, `file`, `config server`, `statistics server` | Resources the local Server service publishes and clients/files currently using them. |
| Client/server discovery | `view`, `config workstation`, `statistics workstation` | Legacy browse visibility plus Workstation/Server service configuration and counters; not an authoritative inventory. |
| Service control | `start`, `stop`, `pause`, `continue` | SCM-backed service listing and controls with less diagnostic detail than `sc.exe`. |
| Help and errors | `help`, `helpmsg` | Installed command syntax and a localized explanation for a numeric network error. |
| Legacy facilities | `print`, `time`, `name`, `send` | Print-queue, clock, and old messaging operations whose availability and relevance vary sharply by build and role. |

Do not infer that every name in a historical family list exists on every
supported client/server build. Installed help, executable behavior, edition,
role/features, domain membership, and Microsoft lifecycle documentation form
the target-host contract.

## Safe inventory workflow

1. Record computer name, Windows edition/build, domain/workgroup role, shell,
   token/elevation, logon identity, and whether the Server and Workstation
   services are present and running.
2. Name the direction: `use` is client/outbound; `share`, `session`, and `file`
   are server/inbound. Capture each separately at the same timestamp.
3. Name the identity scope: local SAM, the current Active Directory domain,
   another directory/service, or a cloud identity. Do not add `/domain` until
   the intended directory and authoritative controller are established.
4. Resolve friendly names to stable objects where possible: account/group SID,
   share name and local path, UNC server/share, SMB session/client address,
   open-file identity, service key name, and process/event evidence.
5. For a proposed change, preserve current configuration and ACLs, identify
   active users and dependencies, use a disposable fixture where possible,
   and define rollback and post-change verification before execution.

## Account and group boundaries

### `user`, `localgroup`, and `group`

`net.exe user` without `/domain` addresses the local account database on a
member computer; `/domain` directs the operation to a controller in the
computer's primary domain. On a domain controller, local-account assumptions
do not carry over because the security-account database and role are different.
Neither form is a general Microsoft Entra ID administration interface.

`localgroup` works with groups local to the target computer and can contain
local or domain principals. `group` is for domain groups and requires the
appropriate domain context. A displayed name is not a stable identity:
resolve the SID and source authority, account state, nesting, and resulting
access token before changing membership. Existing sessions/tokens may not
reflect a membership change until reauthentication.

### `accounts`

`net.exe accounts` reports a compact, localized policy view. It is useful for
orientation, but it is not a complete effective-policy explanation. Local
security policy, domain Group Policy, domain password policy, fine-grained
password policies, user-specific state, and cached/replicated policy can differ.
Correlate the intended account with its authority and appropriate policy tools;
do not treat one line of `net accounts` as proof of every enforced rule.

### Secrets and destructive account options

For password-taking forms, an asterisk requests an interactive prompt. A
literal password in an argument can leak through history, transcripts, process
telemetry, logs, screen sharing, and automation configuration. Account
creation, deletion, activation, expiry, logon-hours, password-policy, and
membership changes require an approved identity workflow and a tested recovery
administrator; they do not belong in generic setup snippets.

## SMB client connections: `net use`

Used without parameters, `net.exe use` lists network-resource connections
visible in the current logon session. A drive letter is only a session-specific
name for a UNC resource; it is not the share, server, credential, or filesystem
itself. For unattended code, prefer the exact UNC path under the task/service's
runtime identity and explicitly validate authentication and authorization.

When a different credential is genuinely required, use `*` for the password
prompt rather than putting the password on the command line. `/savecred`
creates durable credential state and needs a separate security/lifecycle review.
`/persistent:yes` or `/persistent:no` is sticky: Microsoft documents that the
last setting becomes the default for subsequent connections. Deviceless
connections are not persistent, and deleting a connection can fail while it is
the current drive or an active process uses it.

## SMB server state: `share`, `session`, and `file`

`net.exe share` inventories share definitions exposed by the local Server
service. A share name maps network clients to a local path and has a share ACL;
the underlying filesystem has its own ACL. Network access must pass both layers,
while local access does not traverse the share layer. Also inspect inherited
filesystem ACEs, group nesting, owner, privileges, Access-Based Enumeration,
SMB encryption/signing policy, and the exact client identity rather than
assuming one displayed grant explains effective access.

`net.exe session` lists inbound client sessions to the local server. It is not
the same state as that user's `net use` output on a client. Deleting a session
disconnects a client and can interrupt multiple shares or open files.

`net.exe file` lists files opened remotely through the local Server service;
it is not a general local process-handle enumerator. Paths can be abbreviated
in legacy output and one open-file ID is transient. Closing an entry can lose
unsaved work or corrupt an application transaction. On supported systems,
correlate structured `Get-SmbSession` and `Get-SmbOpenFile` results with client,
user, share, path, application owner, and timestamp before any action.

## Service, discovery, statistics, and legacy families

`net start`, `stop`, `pause`, and `continue` send service controls, but their
success does not prove application health. Use the service key name, inspect
dependencies, startup/configuration, PID, pending state, exit codes, events,
and an application-level check. Prefer `Get-Service` for structured inventory
and `sc.exe` for lower-level SCM fields.

`net view` depends on legacy discovery and browse mechanisms, network profile,
firewall, name resolution, SMB configuration, and permissions. A server/share
can be reachable by exact UNC yet absent from `view`, or visible but inaccessible.
Do not use it as a security scanner or complete asset inventory.

`net config` and `net statistics` expose localized Workstation/Server service
state and counters. Counter start time, reset/restart events, and workload
context matter; a cumulative count alone is not a rate or root cause.

`net time` is a legacy view/set surface, not a complete Windows Time diagnostic.
Use `w32tm` and event/configuration evidence for W32Time troubleshooting, and
never change a production clock from a generic fix: time jumps affect Kerberos,
TLS, logs, databases, schedulers, and distributed systems. `print`, `name`, and
`send` reflect older printing or messaging facilities; verify installed help
and supported replacements rather than copying historical commands.

## Common mistakes

### Confusing connection direction

`net use` shows outbound client connections in the caller's logon session.
`net share`, `session`, and `file` show local server publication and inbound
use. Running the wrong side's command can produce a valid empty list that says
nothing about the state being investigated. Record source/target host and
client/server direction beside every capture.

### Deleting all connections to fix system error 1219

Error 1219 concerns conflicting authenticated sessions to one server, not a
limit of one mapped drive. Existing deviceless connections, DFS referrals,
saved credentials, server aliases, printers, services, or another logon token
can participate. Inventory the exact identity, server names/aliases and all
affected contexts first. Do not default to `net use * /delete /y`, service
restarts, fake aliases, or a reboot: they can disconnect unrelated work and
hide the identity/configuration error without fixing it.

### Expecting a mapped drive in an elevated shell, task, or service

Drive mappings are scoped to logon sessions. UAC can give elevated and
unelevated processes separate contexts, and a scheduled task or service has
its own runtime identity/session. Persistence does not make a mapping globally
visible. Use an exact UNC path and grant that runtime identity the necessary
rights; diagnose token and credential context before considering system-wide
policy or registry changes.

### Assuming `/persistent` describes only the current mapping

Microsoft documents `/persistent` as both a connection choice and a default
for subsequent connections, with the previous setting reused. Record the
setting before and after a controlled fixture. Do not add persistence to a
one-off troubleshooting connection or assume a deviceless connection will be
restored.

### Granting broad share access without checking filesystem access

Share and filesystem ACLs are layered for network access. An inherited ACE,
nested group, explicit deny, or share-level restriction can change the result.
Conversely, `Everyone,FULL` at the share layer can unnecessarily expand the
outer gate if NTFS assumptions later change. Model the approved principals and
least privileges at both layers and test effective access as representative
identities; never use a broad grant as a blind connectivity test.

### Closing a session or file from incomplete output

Session deletion can drop several connections; file close can discard remote
writes. User/client/path text can be shared, truncated, stale, or ambiguous.
Confirm the current structured SMB object, application/owner coordination, file
identity, backup/transaction state, and recovery plan immediately before a
targeted action.

### Treating `net file` as a local lock detector

It covers remote opens served by the local Server service, not every handle
held by a local process, minifilter, filesystem, container, or another protocol.
Use purpose-built handle/process and application diagnostics for local locks;
do not close an SMB open just because a pathname resembles the blocked file.

### Mixing local, domain, and cloud identity scope

Omitting or adding `/domain` can target a different authority. `group` and
`localgroup` are not interchangeable, a domain controller is not a member
workstation, and Entra identities are not fully administered through this
family. Resolve authority and SID, identify the writable source of truth, and
use the supported directory/identity API before mutation.

### Using localized text as a stable data format

Spacing, headings, dates, names, and messages can vary by language and release.
Native success also resides in `$LASTEXITCODE`, not `$?` alone on every
PowerShell edition. Prefer structured LocalAccounts, ActiveDirectory, SmbShare,
ScheduledTasks, Service, CIM, or event APIs where applicable; otherwise preserve
raw output with locale/build and parse conservatively.

### Treating service control success as application recovery

Stopping a dependency or shared service can affect unrelated workloads, and a
successful start can still leave a degraded application. Preserve events and
configuration, observe pending/checkpoint state, test the actual service
endpoint, and follow product guidance rather than cycling services from a
generic troubleshooting list.

## PowerShell behavior

Call `net.exe` explicitly so resolution is visible and native semantics remain
clear. Pass each argument as a scalar string; PowerShell does not turn a
pipeline object into a valid account, share, or service identity automatically.
Capture stdout/stderr and `$LASTEXITCODE` immediately. Output is localized text,
so prefer structured cmdlets when they expose the same supported operation.

Do not interpolate passwords into a command string or invoke the command
through `Invoke-Expression`. For a controlled interactive legacy operation,
use the command's `*` prompt. For automation, choose a managed runtime identity,
credential mechanism, and API that do not expose reusable secrets in arguments.

## Version and platform differences

`net.exe` is Windows-only. Available subcommands, switches, output, service and
protocol dependencies, local/domain behavior, and privilege requirements vary
by client/server build, edition, installed role/features, domain membership,
and security policy. Historical Learn pages are useful for semantics such as
`net use`, but their old applicability list is not evidence of current support.
Confirm target-host help and current Microsoft lifecycle/support guidance.

## Related documents

- [sc.exe](sc.md)
- [schtasks](schtasks.md)
- [openfiles](openfiles.md)
- [reg](reg.md)
- [cmd](cmd.md)

## Sources and license

This original guide was adapted from Microsoft's current
[net user reference](https://learn.microsoft.com/windows-server/administration/windows-commands/net-user),
[Net command family overview](https://learn.microsoft.com/troubleshoot/windows-server/networking/net-commands-on-operating-systems),
archived [net use reference](https://learn.microsoft.com/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/gg651155(v=ws.11)),
[mapped-drive/UAC explanation](https://learn.microsoft.com/troubleshoot/windows-client/networking/mapped-drives-not-available-from-elevated-command),
and the Sysinternals [PsFile comparison](https://learn.microsoft.com/sysinternals/downloads/psfile).
Practitioner demand and failure modes were cross-checked against questions on
[system error 1219](https://serverfault.com/questions/57877/system-error-1219-has-occurred),
[mapped drives in scheduled tasks](https://stackoverflow.com/questions/60119716/powershell-script-cant-see-mapped-drive-when-run-as-scheduled-task),
and [share versus filesystem permissions](https://serverfault.com/questions/624934/how-do-share-permissions-and-security-permissions-cooperate-with-each-other-for).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Exchange contributions are licensed under CC BY-SA 4.0.
