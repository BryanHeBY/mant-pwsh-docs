<!-- mant:tldr:start -->
# nfsadmin.exe

> Inspect Windows Server for NFS or Client for NFS configuration and locks before changing services or protocol defaults.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/nfsadmin.

- Confirm the optional tool and its installed version:

`Get-Command nfsadmin.exe -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersionFixed';Expression={$_.FileVersionInfo.FileVersionRaw.ToString()}},@{Name='FileVersionString';Expression={$_.FileVersionInfo.FileVersion}}`

- Display current Server for NFS settings without changing them:

`nfsadmin.exe server config`

- List locks currently held by NFS clients:

`nfsadmin.exe server -l`

- Display current Client for NFS settings without changing them:

`nfsadmin.exe client config`
<!-- mant:tldr:end -->

# nfsadmin.exe

## Overview

`nfsadmin.exe` administers the optional Windows Server for NFS and Client for
NFS components. Bare `server config`/`client config` display current settings;
adding options changes defaults. Server mode also controls services, locks,
auditing, protocols, client groups, mappings, filename behavior, and caches.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `nfsadmin.exe`: Inspect or administer Microsoft Server/Client for NFS.
- `server`: Select Server for NFS configuration and client-lock operations.
- `client`: Select Client for NFS configuration.
- `start`: Start the selected NFS service.
- `stop`: Stop the selected NFS service.
- `config`: Display or change the selected service's configuration fields.
- `creategroup`: Create a Server for NFS client group.
- `listgroups`: List Server for NFS client groups.
- `deletegroup`: Delete one client group.
- `renamegroup`: Rename one client group.
- `addmembers`: Add hosts to a client group.
- `listmembers`: List hosts in one client group.
- `deletemembers`: Remove hosts from one client group.

Server and client configuration fields are native equals-bearing options. A
bare `config` reads current settings; appending any field below changes service
configuration and requires separate authorization and verification.

<!-- mant:entries role=option case=insensitive -->
- `mapsvr= SERVER`: Set the legacy User Name Mapping server for the selected NFS role; Microsoft recommends current identity-mapping tooling instead.
- `auditlocation= LOCATION`: Send Server for NFS auditing to `eventlog`, `file`, `both`, or `none`.
- `fname= FILE`: Set the Server for NFS audit-log file used by file-based auditing.
- `fsize= SIZE`: Set the maximum audit-file size in megabytes.
- `audit= EVENTS`: Enable or disable Server for NFS event families with documented `+` and `-` event tokens; do not combine `all` with another event.
- `lockperiod= SECONDS`: Set how long Server for NFS waits for clients to reclaim locks after reconnect or service restart.
- `portmapprotocol= PROTOCOL`: Select the Portmap `TCP`, `UDP`, or `TCP+UDP` transport set.
- `mountprotocol= PROTOCOL`: Select the mount service `TCP`, `UDP`, or `TCP+UDP` transport set.
- `nfsprotocol= PROTOCOL`: Select the NFS service `TCP`, `UDP`, or `TCP+UDP` transport set.
- `nlmprotocol= PROTOCOL`: Select the Network Lock Manager `TCP`, `UDP`, or `TCP+UDP` transport set.
- `nsmprotocol= PROTOCOL`: Select the Network Status Manager `TCP`, `UDP`, or `TCP+UDP` transport set.
- `enableV3= VALUE`: Enable or disable NFS version 3 support with `yes` or `no`.
- `renewauth= VALUE`: Require or disable periodic client reauthentication with `yes` or `no`.
- `renewauthinterval= SECONDS`: Set the client reauthentication interval used when `renewauth=yes`.
- `dircache= SIZE`: Set the Server for NFS directory-cache size in kilobytes within the documented range and alignment.
- `translationfile= FILE`: Select the filename-character translation map, or omit its value to disable translation; a change requires service restart.
- `dotfileshidden= VALUE`: Choose whether names beginning with a period receive the Windows hidden attribute.
- `casesensitivelookups= VALUE`: Enable or disable exact-case directory lookup; enabling it also requires the documented system-wide kernel setting.
- `ntfscase= MODE`: Return NTFS names as `lower`, `upper`, or `preserve`; it cannot change while case-sensitive lookup is enabled.
- `fileaccess= MODE`: Set the three-digit default UNIX-style permission mode for files created by Client for NFS.
- `mtype= TYPE`: Select `hard` RPC retry-until-success or `soft` bounded-retry mount behavior.
- `retry= COUNT`: Set the Client for NFS retry count for soft mounts within the documented range.
- `timeout= SECONDS`: Set the Client for NFS RPC wait interval within the documented fractional/integer range.
- `protocol= PROTOCOL`: Select the Client for NFS `TCP`, `UDP`, or `TCP+UDP` transport set.
- `rsize= SIZE`: Set the Client for NFS read buffer in kilobytes to one documented discrete value.
- `wsize= SIZE`: Set the Client for NFS write buffer in kilobytes to one documented discrete value.

The performance reset is a fixed equals-bearing option, not a field that
accepts an arbitrary value.

<!-- mant:entries role=option case=insensitive attached=fixed -->
- `perf=default`: Restore the documented Client for NFS performance fields.

The following traditional dash options select credentials or lock operations
outside the equals-bearing `config` field grammar.

<!-- mant:entries role=option case=insensitive -->
- `-u`: Select an alternate remote administrative identity.
- `-p`: Supply that account's password inline; omit it to prompt instead.
- `-l`: List all client locks held by Server for NFS.
- `-r`: Release locks for one client or all clients and therefore mutate state.

## Common mistakes

### Mixing server and client state

The two roles have separate services and settings. Record installed features,
host role, NFS version, exact endpoint and whether Windows exports or consumes
the filesystem before interpreting output.

### Treating `-r` as a read or refresh switch

Server `-r client|all` releases locks and can permit conflicting writers. Use
`-l` for evidence; coordinate application quiescence and recovery before any
lock release or service restart.

### Appending a setting to a diagnostic command

`nfsadmin ... config` reads, but `config option=value` mutates global service
behavior. Hard/soft retry, buffers, transports, NFSv3, audit, case and mapping
changes can affect every mount/share and may require restart.

### Enabling case-sensitive lookup as a local NFS tweak

Microsoft's documented workflow also involves a system-wide kernel registry
setting. Case collisions can make Windows applications address different
objects unexpectedly. Inventory names and test complete workloads first.

### Reusing obsolete identity-mapping advice

Legacy `mapsvr` remains for compatibility. Determine the supported AD/LDAP/
NFS mapping design, UID/GID ownership and anonymous behavior for the target
release instead of copying Services for UNIX-era commands.

### Supplying `-p` inline

Passwords can leak in process listings, transcripts and logs. Prefer the
current authorized identity or omit `-p` for a protected prompt where supported.

## PowerShell boundaries

Call `nfsadmin.exe` explicitly and check `$LASTEXITCODE`. Its output is
localized text, not objects. Quote `DOMAIN\user` and paths; PowerShell can
interpret `+`, `-`, commas and wildcard characters before a native tool when
they are not kept in one argument.

## Version and platform differences

Windows-only and feature-dependent. Learn applicability banners do not prove
that Client/Server for NFS is installed on a given edition. Options include
legacy NFSv3-era services and mapping mechanisms; local help, installed NFS
PowerShell cmdlets and target-build behavior govern.
Exact System32 discovery on the recorded Windows NT `10.0.26200.0` Home China
client found no `nfsadmin.exe`; do not substitute a PATH match or install NFS
components merely for documentation evidence.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found nfsadmin.exe absent; no PATH substitute or NFS query/mutation ran.
Help, config display and lock listing remain pending only where the optional
feature is already installed.

## Related documents
- [nfsshare.exe](nfsshare.exe.md)
- [nfsstat.exe](nfsstat.exe.md)
- [showmount.exe](showmount.exe.md)
- [rpcinfo.exe](rpcinfo.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[nfsadmin reference](https://learn.microsoft.com/windows-server/administration/windows-commands/nfsadmin)
and current [NFS mapped-identity cmdlet reference](https://learn.microsoft.com/powershell/module/nfs/get-nfsmappedidentity).
Identity-mapping failures were cross-checked against a
[Windows Client for NFS practitioner case](https://serverfault.com/questions/917449/nfs-mapall-doesnt-include-anonymous-clients).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
