<!-- mant:tldr:start -->
# showmount.exe

> Query an approved NFS server's exported filesystems and mountd view without mounting anything.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/showmount.

- Confirm that the optional Windows client tool is installed:

`Get-Command showmount.exe -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersionFixed';Expression={$_.FileVersionInfo.FileVersionRaw.ToString()}},@{Name='FileVersionString';Expression={$_.FileVersionInfo.FileVersion}}`

- List exports advertised by one exact NFS server:

`showmount.exe -e "{{nfs01.example.com}}"`

- List directories currently reported as mounted (sensitive server-wide metadata):

`showmount.exe -d "{{nfs01.example.com}}"`

- Test only the well-known NFS TCP endpoint separately from mountd/RPC discovery:

`Test-NetConnection "{{nfs01.example.com}}" -Port 2049 -InformationLevel Detailed`
<!-- mant:tldr:end -->

# showmount.exe

## Overview

`showmount.exe` queries the NFS MOUNT protocol: `-e` lists exports, `-d` lists
mounted directories, and `-a` lists clients plus directories. It does not mount
a filesystem or prove data access. The client/directory views can reveal
sensitive topology and should be queried only on approved servers.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `showmount.exe`: Query NFSv3 MOUNT-protocol export or client/mount information.

Always provide the exact server even though some builds default to the local
host; no option mounts a filesystem or proves file access.

<!-- mant:entries role=option case=insensitive -->
- `-e`: List filesystems exported by the server.
- `-a`: List every reported NFS client and its mounted directories.
- `-d`: List server directories currently reported as mounted by clients.

## Common mistakes

### Treating `showmount -e` failure as proof NFS is down

NFSv4 can operate without the separate NFSv3 MOUNT protocol that `showmount`
expects. Also distinguish DNS, portmapper/mountd, firewall, protocol version,
transport and export-policy failures from TCP 2049 reachability.

### Assuming a listed export is authorized and usable

Listing does not validate client host scope, Kerberos/AUTH_SYS, UID/GID mapping,
NTFS permissions, root/anonymous behavior, locking or file operations. Test the
real client identity and exact version through an approved mount workflow.

### Running `-a` as harmless discovery

It enumerates client-to-directory relationships and may be expensive or
restricted. Start with `-e`; protect mount/client inventory and avoid broad
probing of third-party infrastructure.

### Omitting the server

The command can default to the local computer, hiding a targeting mistake.
Always use an exact FQDN/IP and record DNS resolution, address family and time.

## PowerShell boundaries

Invoke `showmount.exe` explicitly and check `$LASTEXITCODE`. Its output is
remote-provided text; do not parse fixed column widths without retaining raw
evidence. Quote IPv6/name inputs and do not confuse it with a PowerShell cmdlet.

## Version and platform differences

The Windows tool is optional/feature-dependent. Remote NFS implementations and
versions differ; a Unix `showmount` man page is not proof of identical Windows
options. NFSv4-only servers may intentionally expose no mountd result.
Exact System32 discovery on the recorded Windows NT `10.0.26200.0` Home China
client found no `showmount.exe`; do not substitute a PATH match or contact a
remote server merely for documentation evidence.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found showmount.exe absent; no PATH substitute or remote request ran.
Exact approved-server -e and controlled -d/-a data-handling verification remain
pending where the optional client exists.

## Related documents
- [rpcinfo.exe](rpcinfo.exe.md)
- [nfsstat.exe](nfsstat.exe.md)
- [nfsshare.exe](nfsshare.exe.md)
- [mountvol.exe](mountvol.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[showmount reference](https://learn.microsoft.com/windows-server/administration/windows-commands/showmount).
The common mountd/firewall/version failure was cross-checked against a
[showmount troubleshooting question](https://serverfault.com/questions/749788/showmount-e-fails-from-one-node).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
