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

## Command-family map

| Family | Representative commands | Boundary |
| --- | --- | --- |
| Runtime inventory | `query`, `queryex`, `EnumDepend`, `GetDisplayName`, `GetKeyName` | Query may require enumeration resume; `queryex` PID can host several services. |
| Configuration inventory | `qc`, `qdescription`, `qfailure`, `qfailureflag`, `qprivs`, `qsidtype`, `qtriggerinfo`, `showsid` | Installed help is authoritative; fields have separate security/lifecycle meaning. |
| Security inventory | `sdshow`, `QueryLock` | Security descriptors reveal control rights; protect captured output. |
| Control | `start`, `stop`, `pause`, `continue`, `interrogate`, `control` | Changes availability; not every service accepts every control. |
| Registration/configuration | `create`, `config`, `description`, `delete` | Changes SCM/registry state; it does not install/uninstall product files safely. |
| Recovery/trigger/security | `failure`, `failureflag`, `triggerinfo`, `privs`, `sidtype`, `sdset` | Can alter restart programs, privileges, SID/access behavior, and attack surface. |
| Driver/boot/SCM internals | `boot`, `Lock`, server operand | Boot-driver and database-lock operations can affect system startup and management. |

Use `sc.exe` with no arguments and `sc.exe <command> /?` on the target because
the complete command list is broader than the four pages in the Windows command
index and varies across builds.

## Common mistakes

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

## Version and platform differences

SC is Windows-only. Commands and fields vary with Windows build, service versus
driver type, local/remote SCM support, protection level, trigger configuration,
and privileges. Windows PowerShell alias behavior is not evidence for
PowerShell 7. Use target-host resolution and installed SC help.

## Related documents

- [schtasks](schtasks.md)
- [tasklist](tasklist.md)
- [taskkill](taskkill.md)

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
