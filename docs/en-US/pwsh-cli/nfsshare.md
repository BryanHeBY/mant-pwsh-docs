<!-- mant:tldr:start -->
# nfsshare

> Inventory Windows Server for NFS exports and their host, identity, root, and access scope before changing them.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/nfsshare.

- List every NFS share exported by the local Server for NFS:

`nfsshare.exe`

- Display the properties of one exact NFS share:

`nfsshare.exe "{{ShareName}}"`

- Get typed NFS share configuration when the NFS PowerShell module is installed:

`Get-NfsShare -Name "{{ShareName}}" | Format-List *`

- Correlate the exported path with its NTFS owner and ACL without changing either:

`Get-Acl -LiteralPath "{{D:\Exports\Data}}" | Format-List Owner,AccessToString,Sddl`
<!-- mant:tldr:end -->

# nfsshare

## Overview

`nfsshare.exe` lists, creates, configures, or deletes Server for NFS exports.
No arguments lists all exports; one share name displays its properties. An
assignment such as `name=drive:path`, `-o`, or `/delete` mutates service state.

## Common mistakes

### Omitting both `ro` and `rw`

Microsoft documents that the resulting default is read/write for all clients.
Never rely on omission as least privilege. Specify reviewed host/client-group
scope and verify the effective export after creation.

### Granting `root` or anonymous UID/GID to solve an ACL error

Client root access and anonymous mapping are authorization boundaries. UID/GID
mapping, AUTH_SYS/Kerberos identity, export rules and NTFS ACLs all participate;
setting UID/GID 0 can turn broad unmapped access into administrative file access.

### Treating a client IP/hostname list as strong identity

Host scope depends on DNS/network controls and is not user authentication.
Use supported Kerberos and identity mapping where the threat model requires it,
and keep firewall/export/NTFS controls aligned.

### Using `* /delete` as cleanup

The wildcard removes every local NFS export. Capture exact share/path/client
dependencies, active mounts and recovery configuration before deleting one
named export; never use the wildcard as a probe.

### Confusing an NFS export with an SMB share

They can expose the same NTFS path through different authentication, locking,
name, caching and permission semantics. Inventory both protocols and application
writers before changing either.

## PowerShell behavior

Use `nfsshare.exe` explicitly. Quote the entire `name=drive:path` and each
`option=value` token in change workflows so PowerShell parsing cannot split
spaces or special characters. Check `$LASTEXITCODE`; prefer `Get-NfsShare` for
structured queries.

## Version and platform differences

Windows Server for NFS is optional and edition/role dependent. NFS version,
authentication methods, mapping stores, clusters and available cmdlets vary by
release. The legacy command's encoding options do not replace an end-to-end
filename compatibility test.

## Related documents

- [nfsadmin](nfsadmin.md)
- [nfsstat](nfsstat.md)
- [showmount](showmount.md)
- [icacls](icacls.md)

## Sources and license

This original guide was adapted from Microsoft's official
[nfsshare reference](https://learn.microsoft.com/windows-server/administration/windows-commands/nfsshare).
Anonymous/root mapping and Windows export failures were cross-checked against
practitioner discussions of [UID/GID privilege risk](https://serverfault.com/questions/539267/nfs-share-with-root-for-anonuid-anongid)
and [Windows NFS access errors](https://serverfault.com/questions/761071/input-output-error-when-attempting-to-mount-a-windows-nfs-share).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
