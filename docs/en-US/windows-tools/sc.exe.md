<!-- mant:tldr:start -->
# sc.exe

> Query Windows Service Control Manager (SCM) runtime, configuration, process, dependency, failure, trigger, identity, and security state before controlling or changing a service.
> More information: https://learn.microsoft.com/windows/win32/services/configuring-a-service-using-sc.

- Show every command named `sc`; Windows PowerShell commonly resolves bare `sc` to `Set-Content`:

`Get-Command sc -All -ErrorAction SilentlyContinue`

- Query runtime state, exit codes, checkpoint, and wait hint by service key name:

`sc.exe query "{{service-name}}"`

- Query start type, binary command line, dependencies, and service account:

`sc.exe qc "{{service-name}}"`

- Include the hosting process ID and service flags in a runtime query:

`sc.exe queryex "{{service-name}}"`

- List services that depend on the exact service:

`sc.exe enumdepend "{{service-name}}"`

- Query configured recovery actions:

`sc.exe qfailure "{{service-name}}"`

- Query trigger-start configuration:

`sc.exe qtriggerinfo "{{service-name}}"`

- Query one service on a remote server; the SC server operand uses a UNC-style name:

`sc.exe "{{\\server}}" query "{{service-name}}"`
<!-- mant:tldr:end -->

# sc.exe

## Overview

`sc.exe` queries and modifies the Service Control Manager database and sends
control requests to Win32 services and driver services. It can enumerate
runtime state, inspect configuration/security/failure/trigger metadata, start
or stop services, create/delete registrations, change accounts and binary
paths, and operate against a remote SCM.

SCM identity is the service key name, not necessarily the localized display
name, executable filename, process name, or product name. Resolve and preserve
all of them before a change. Prefer structured `Get-Service`, `Get-CimInstance
Win32_Service`, and supported product/service APIs for automation; use SC when
its lower-level fields or controls are required.

## Resolvable commands

<!-- mant:entries role=command case=insensitive -->
- `query`, `queryex`: Query service or driver runtime state; `queryex` also exposes process identifiers and flags.
- `qc`: Query core service configuration such as binary path, account, dependencies, and start type.
- `qdescription`, `qfailure`, `qfailureflag`: Query description and recovery configuration.
- `qprivs`, `qsidtype`, `qtriggerinfo`: Query required privileges, service SID type, or trigger-start metadata.
- `qpreferrednode`, `qmanagedaccount`, `qprotection`: Query preferred NUMA node, LSA-managed service-account password state, or process-protection level where the service/build supports it.
- `quserservice`: Query the local per-user service instance associated with a user-service template where supported.
- `sdshow`: Show the service security descriptor in SDDL form; protect captured security metadata.
- `start`, `stop`, `pause`, `continue`, `interrogate`, `control`: Send one supported control to an exact service key name.
- `create`: Create an SCM registration; it does not safely install all product files or dependencies.
- `config`: Change selected service configuration using SC's required `name= value` spacing.
- `description`: Change the service description.
- `delete`: Mark a service registration for deletion; open handles can delay removal.
- `failure`, `failureflag`: Configure failure actions and whether non-crash failures trigger them.
- `triggerinfo`: Configure service triggers that can start or stop a service.
- `privs`, `sidtype`, `sdset`: Change privileges, SID behavior, or the security descriptor.
- `preferrednode`, `managedaccount`: Change preferred NUMA-node or LSA-managed-password metadata where supported.
- `GetDisplayName`, `GetKeyName`: Translate between display and key names; neither alone verifies product identity.
- `EnumDepend`: Enumerate services that depend on an exact service.
- `showsid`: Calculate and display the service SID for a name.
- `Lock`, `QueryLock`: Lock or inspect the SCM database lock; avoid locks in ordinary automation.
- `boot`: Indicate whether the last boot should be saved as the last-known-good configuration.

## Common query and configuration options

<!-- mant:entries role=option case=insensitive -->
- `type= TYPE`: Restrict query or set a service/driver type; the space after `=` is required before the value.
- `state= STATE`: For query operations, select active, inactive, or all states.
- `bufsize= BYTES`: Set enumeration buffer size for a query.
- `ri= INDEX`: Resume enumeration from an index returned by an earlier query.
- `group= GROUP`: Restrict enumeration to one load-order group.
- `binpath= PATH`: Set a service binary command line; quoting and executable identity are security-critical.
- `start= MODE`: Set boot, system, automatic, demand, disabled, or delayed-auto behavior where supported.
- `error= MODE`: Set boot error-control behavior for the service or driver.
- `obj= ACCOUNT`: Set the service logon account; changing identity also requires credential and rights planning.
- `depend= SERVICES`: Set dependencies using SC's documented separator grammar.
- `displayname= NAME`: Set the localized display name, not the stable service key name.
- `/?`: Top-level `sc.exe /?` prints the installed command list on the recorded build but returns native exit code 1639; it is not a successful SCM query.

## Command-family map

| Family | Representative commands | Boundary |
| --- | --- | --- |
| Runtime inventory | `query`, `queryex`, `EnumDepend`, `GetDisplayName`, `GetKeyName` | Query may require enumeration resume; `queryex` PID can host several services. |
| Configuration inventory | `qc`, `qdescription`, `qfailure`, `qfailureflag`, `qprivs`, `qsidtype`, `qtriggerinfo`, `qpreferrednode`, `qmanagedaccount`, `qprotection`, `quserservice`, `showsid` | Installed help is authoritative; fields have separate security/lifecycle meaning and some apply only to particular service/build types. |
| Security inventory | `sdshow`, `QueryLock` | Security descriptors reveal control rights; protect captured output. |
| Control | `start`, `stop`, `pause`, `continue`, `interrogate`, `control` | Changes availability; not every service accepts every control. |
| Registration/configuration | `create`, `config`, `description`, `delete` | Changes SCM/registry state; it does not install/uninstall product files safely. |
| Recovery/trigger/security | `failure`, `failureflag`, `triggerinfo`, `privs`, `sidtype`, `sdset`, `preferrednode`, `managedaccount` | Can alter restart programs, privileges, identity/password management, NUMA placement, SID/access behavior, and attack surface. |
| Driver/boot/SCM internals | `boot`, `Lock`, server operand | Boot-driver and database-lock operations can affect system startup and management. |

Use top-level `sc.exe` output to discover the installed command list, then use
the matching Microsoft reference and a safe, exact query on the target. Do not
generate `sc.exe <command> /?` mechanically: SC's subcommand parsers are
inconsistent. On the recorded build, `config` without a service printed usage,
`query` without a service enumerated active services, and `query /?` plus
`qmanagedaccount /?` treated `/?` as a service name and failed with exit 123.

## Common mistakes

### Treating displayed SC help as a successful command

On the recorded build, both bare `sc.exe` and `sc.exe /?` printed the command
list but returned 1639 (`ERROR_INVALID_COMMAND_LINE`). Conversely, some
subcommands interpret `/?` as a service name. Capture help text and
`$LASTEXITCODE` separately, never use a generated help probe as proof that a
service query succeeded, and do not suppress all nonzero codes merely because
one help form is intentionally nonzero.

### Typing bare `sc` in Windows PowerShell

Windows PowerShell commonly defines `sc` as an alias for `Set-Content`. A line
such as `sc delete service` can therefore write a file named `delete` instead
of contacting SCM, with no “command not found” warning. Always call `sc.exe`
and use `Get-Command sc -All` when diagnosing shell-specific behavior. Do not
assume the same alias set in PowerShell 7 or another host.

### Omitting the required space after an equals-bearing option

SC syntax intentionally uses `start= auto`, `state= all`, and `binpath= value`:
the equals sign belongs to the option name and Microsoft requires a space
before the value. `start=auto` fails. Preserve each argument explicitly rather
than applying ordinary `name=value` conventions.

### Using a display name where a service key name is required

Display names can contain spaces, be localized, or change across releases.
Query by key name or use `GetKeyName`, then corroborate display name, binary
path, product/vendor, service DLL, process, account, and registry location.
Never select a service for deletion from a fuzzy display-name match.

### Treating `RUNNING` or one PID as application health

SCM runtime state only says what the service reported. It does not validate the
service's listener, dependencies, database, queue, or business transaction.
Shared-process services can have the same PID, and a PID can be recycled. Bind
PID to service name, process creation time/path, service DLL, ports, and
application health at the same timestamp.

### Killing a process during `START_PENDING` or `STOP_PENDING`

Checkpoint and wait hint show progress expectations; initialization, recovery,
dependency shutdown, and workload drain can take time. Preserve service and
application events, re-query at bounded intervals, and follow product guidance.
Terminating a shared host can take down unrelated services and corrupt work.

### Using `config` as a partial merge

Some SC settings replace an entire value or list. Dependencies use
slash-separated service/group names; account, binary path, required privileges,
failure actions, SID type, and triggers interact. Export every relevant query
and security descriptor first, make one reviewed change, and verify both SCM
configuration and resulting service/application behavior.

### Misquoting `binpath=` or creating an unquoted service path

The stored binary path is a Windows command line, potentially containing both
an executable and arguments. PowerShell parsing, SC parsing, SCM process
creation, environment expansion, and the child program are separate layers.
An unquoted path with spaces can also create a privilege-escalation condition.
Prefer the product installer; otherwise validate the exact stored `qc` value,
file ACL/owner/signature, arguments, working assumptions, and service startup.

### Putting a service-account password on the command line

`password=` can leak through history, transcripts, process telemetry, logs, and
automation configuration. Prefer virtual accounts, managed service accounts,
or a supported secret/installer workflow. Account changes also require
logon-as-service rights, resource ACLs, SPNs, profiles, network identity, and recovery
planning.

### Assuming `delete` uninstalls a product or driver

SC delete removes—or marks for deletion—the SCM registration. It does not stop
all users, remove binaries/drivers, clean devices, revoke credentials, delete
firewall rules, or run vendor cleanup. Open SCM/service handles can defer final
deletion. Use the supported uninstaller and verify dependencies, driver/device
state, files, registry, services, and restart requirements.

### Disabling a service from a generic hardening list

Start type is only one activation path; trigger-start, dependencies, protected
services, servicing, role ownership, and recovery actions matter. Disabling a
security, networking, update, backup, storage, or authentication service can
break recovery and patching. Establish product/role support and test rollback.

### Applying `sdset`, privileges, or SID-type changes from another host

Security descriptors contain host/domain SIDs and fine-grained SCM rights.
Required privileges and service SID type affect resource access and isolation.
A syntactically valid copied value can lock out administrators or weaken the
service. Preserve `sdshow`, owner/DACL/SACL context, current privileges/SID,
and an out-of-band recovery path; use supported security tooling.

### Assuming remote SC uses PowerShell remoting

The `\\server` operand opens the remote SCM through Windows service-management
RPC and its authentication/firewall policy; it is not WinRM. Record source and
target identities, network path, name resolution, token/UAC context, SCM ACL,
and target events. Avoid inline remote credentials and broad firewall changes.

## PowerShell behavior

Use `sc.exe` explicitly. Pass scalar service key names and keep the option and
value as separate arguments where SC requires `name= value`. Capture native
stdout/stderr and `$LASTEXITCODE` immediately, but independently verify with
structured service/CIM data and application evidence. SC output is localized
human text and numeric fields can include Win32- and service-specific codes.
Help-like output is not an exception to native status handling: preserve 1639
from the recorded top-level help case rather than normalizing it to success.

## Version and platform differences

SC is Windows-only. Commands and fields vary with Windows build, service versus
driver type, local/remote SCM support, protection level, trigger configuration,
and privileges. Windows PowerShell alias behavior is not evidence for
PowerShell 7. Use target-host resolution and installed SC help.

## Runtime evidence

The protected local-help fixture resolved exact System32 `sc.exe` under both
installed PowerShell editions. `sc.exe /?` produced 84 nonempty stdout lines,
no stderr, and status `1639` in each collector. The nonzero status is part of
this top-level help contract, not evidence of a service query failure. No
server, service, driver, database, control, configuration, credential, or
security descriptor was supplied or changed; subcommand parser and operational
behavior remain separately bounded.

## Related documents

- [schtasks.exe](schtasks.exe.md)
- [tasklist.exe](tasklist.exe.md)
- [taskkill.exe](taskkill.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[SCM/SC family reference](https://learn.microsoft.com/windows/win32/services/configuring-a-service-using-sc),
[query](https://learn.microsoft.com/windows-server/administration/windows-commands/sc-query),
[config](https://learn.microsoft.com/windows-server/administration/windows-commands/sc-config),
[create](https://learn.microsoft.com/windows-server/administration/windows-commands/sc-create),
and [delete](https://learn.microsoft.com/windows-server/administration/windows-commands/sc-delete)
references. The silent PowerShell alias failure was cross-checked against
[a widely viewed practitioner question](https://stackoverflow.com/questions/76074/how-can-i-delete-a-service-in-windows),
then resolved by requiring explicit executable resolution. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
