<!-- mant:tldr:start -->
# nfsadmin

> Inspect Windows Server for NFS or Client for NFS configuration and locks before changing services or protocol defaults.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/nfsadmin.

- Confirm the optional tool and its installed version:

`Get-Command nfsadmin.exe -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Display current Server for NFS settings without changing them:

`nfsadmin.exe server config`

- List locks currently held by NFS clients:

`nfsadmin.exe server -l`

- Display current Client for NFS settings without changing them:

`nfsadmin.exe client config`
<!-- mant:tldr:end -->

# nfsadmin

## Overview

`nfsadmin.exe` administers the optional Windows Server for NFS and Client for
NFS components. Bare `server config`/`client config` display current settings;
adding options changes defaults. Server mode also controls services, locks,
auditing, protocols, client groups, mappings, filename behavior, and caches.

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

## PowerShell behavior

Call `nfsadmin.exe` explicitly and check `$LASTEXITCODE`. Its output is
localized text, not objects. Quote `DOMAIN\user` and paths; PowerShell can
interpret `+`, `-`, commas and wildcard characters before a native tool when
they are not kept in one argument.

## Version and platform differences

Windows-only and feature-dependent. Learn applicability banners do not prove
that Client/Server for NFS is installed on a given edition. Options include
legacy NFSv3-era services and mapping mechanisms; local help, installed NFS
PowerShell cmdlets and target-build behavior govern.

## Related documents

- [nfsshare](nfsshare.md)
- [nfsstat](nfsstat.md)
- [showmount](showmount.md)
- [rpcinfo](rpcinfo.md)

## Sources and license

This original guide was adapted from Microsoft's official
[nfsadmin reference](https://learn.microsoft.com/windows-server/administration/windows-commands/nfsadmin)
and current [NFS mapped-identity cmdlet reference](https://learn.microsoft.com/powershell/module/nfs/get-nfsmappedidentity).
Identity-mapping failures were cross-checked against a
[Windows Client for NFS practitioner case](https://serverfault.com/questions/917449/nfs-mapall-doesnt-include-anonymous-clients).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
