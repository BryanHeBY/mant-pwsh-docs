<!-- mant:tldr:start -->
# mapadmin

> Inventory and back up a legacy Microsoft Services for NFS User Name Mapping configuration before migration.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mapadmin.

- Confirm the legacy utility exists and show current local settings without supplying credentials:

`Get-Command mapadmin.exe -ErrorAction SilentlyContinue; mapadmin.exe`

- List all simple and advanced mappings on one approved server, prompting for a password if alternate credentials are truly required:

`mapadmin.exe "{{nfsmap01.contoso.example}}" -u "{{CONTOSO\operator}}" list -all`

- List simple domain-to-NIS/passwd-file mappings:

`mapadmin.exe "{{nfsmap01.contoso.example}}" listdomainmaps`

- Back up mapping data to a protected new file before an approved migration:

`mapadmin.exe "{{nfsmap01.contoso.example}}" backup "{{D:\Protected\unm-backup.map}}"`

- Inventory the current Windows NFS mapping-store configuration separately:

`Get-NfsMappingStore | Format-List *`
<!-- mant:tldr:end -->

# mapadmin

## Overview

`mapadmin.exe` administered the legacy User Name Mapping service used by
Microsoft Services for NFS. It can display/configure the service, start/stop it,
add/delete/list user and group mappings, choose primary mappings, back up or
replace the database, and add/remove simple Windows-domain mappings to NIS or
local passwd/group files.

The legacy tool is not the whole NFS identity story. Protocol version,
authentication, Windows/NFS server implementation, UID/GID source, name/domain,
Kerberos, anonymous/root mapping, export and NTFS permissions all affect the
effective identity. Current Windows NFS deployments use supported PowerShell
cmdlets and mapping-store designs rather than blindly restoring old UNM data.

## Common mistakes

### Passing `-p <password>` on the command line

Omit `-p` after `-u` to request an interactive prompt. A literal password can
leak through history, scripts, process/audit telemetry, screenshots, and logs.
Do not invent a `SecureString` wrapper: native `mapadmin.exe` still receives
plain command-line text if it is placed in arguments.

### Deleting by only one side of a mapping

For users, `delete -wu` alone removes all mappings for that Windows user;
`delete -uu` alone removes all mappings for that UNIX user. The same broadening
applies to groups. Specify both sides for one exact pair, export/list before and
after, and require rollback and owner approval.

### Treating `restore` as a merge

Microsoft says restore replaces configuration and mapping data. It can alter
identity resolution across many exports and clients. Keep the original backup,
validate its host/version/provenance, stage restore in isolation, and test
representative users/groups and file ownership before production use.

### Assuming matching names imply matching identities

NFS authorization ultimately depends on effective identities and protocol-
specific mapping, not a cosmetic name match. Practitioner questions repeatedly
show “nobody” ownership and access failures caused by UID/GID/domain/Kerberos or
mapping-store mismatch. Capture numeric IDs, domains, authentication flavor,
server/export policy, and NTFS ACLs end to end.

### Mixing old UNM with current NFS mapping cmdlets

Microsoft notes that legacy NFS WMI classes were removed as of Windows 8 and
Windows Server 2012, while current Windows Server exposes NFS PowerShell
cmdlets. Do not assume `mapadmin` backup formats, services, or semantics apply to
`Get/Set-NfsMappingStore` and `New-NfsMappedIdentity`. Design a data migration,
not an in-place command substitution.

### Using broad domain-map removal

`removedomainmap -all` removes every simple domain mapping, including passwd/
group-file mappings. Query `listdomainmaps`, identify downstream clients and
exports, preserve a backup, and approve exact removal scope first.

## PowerShell behavior

`mapadmin.exe` emits localized native text and accepts native credential
arguments. Capture raw output, `$LASTEXITCODE`, exact server, tool version, and
timestamp. Use typed NFS cmdlets only if installed on the target version; do not
silently combine their objects with text parsed from a legacy UNM server.

## Version and platform differences

This command targets the legacy Microsoft Services for NFS User Name Mapping
service, locally or remotely. Feature availability and identity architecture
vary substantially across Windows/Windows Server generations. Verify the exact
server role, service, cmdlets, NFS version, store, and client/server support
matrix; a generic Learn banner is not sufficient evidence.

## Related documents

- [nfsadmin](nfsadmin.md)
- [nfsshare](nfsshare.md)
- [mount](mount.md)

## Sources and license

Adapted as an original migration guide from Microsoft's
[mapadmin reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mapadmin)
and [legacy NFS WMI lifecycle note](https://learn.microsoft.com/previous-versions/windows/desktop/nfswmi/msnfs-usernamemapping).
A [Server Fault mapping question](https://serverfault.com/questions/323359/nfs-mounted-on-windows-7-authentication-headache)
was used as a practitioner demand signal for feature/version and identity-
mapping confusion, not as syntax authority. Exact provenance and licenses are
in `upstream/cli.json`. Microsoft material and this adaptation are CC BY 4.0;
the cited Q&A is CC BY-SA 4.0.
