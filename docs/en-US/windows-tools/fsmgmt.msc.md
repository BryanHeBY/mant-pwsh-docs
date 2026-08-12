<!-- mant:tldr:start -->
# fsmgmt.msc

> Open Shared Folders for interactive inspection of an explicitly identified SMB server; preserve share, session, open-file, client, user, scope, cluster, and permission identity before disconnecting or changing anything.
> More information: https://learn.microsoft.com/powershell/module/smbshare/.

- Resolve the console file without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\fsmgmt.msc')`

- Open the Shared Folders console:

`Start-Process fsmgmt.msc`

- Query SMB shares, sessions, and open files as separate typed inventories:

`Get-SmbShare; Get-SmbSession; Get-SmbOpenFile`
<!-- mant:tldr:end -->

# fsmgmt.msc

## Overview

`fsmgmt.msc` opens the Shared Folders MMC snap-in. It can display and manage SMB
shares, current client sessions, and files opened on behalf of SMB clients for a
local or connected remote computer when authorized.

These are distinct object types. A share maps a name/scope to a path and share
security; a session represents a client/user connection; an open file has its
own file/session identity. Do not identify any of them by a truncated GUI label.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `fsmgmt.msc`: Open the Shared Folders MMC snap-in for an explicitly identified local or remote SMB server.

The console file exposes no supported parameter interface documented here. Use
the SmbShare PowerShell module, SMB/WMI/CIM APIs, or reviewed `net.exe` families
for repeatable discovery and changes.

## Objects and permissions

For a share, record server, scope/cluster instance, name, local path, description,
special/hidden state, availability, encryption/caching settings, share ACL, and
the underlying file-system ACL. Effective access combines multiple controls;
changing only the share permission does not replace NTFS authorization.

For sessions/open files, preserve session/file IDs, client address/name, user
identity, dialect/encryption/signing, share/path, locks, application/owner,
cluster node/scope, timestamps, and business impact before a close operation.

## Common mistakes

- Treating share permissions and NTFS permissions as the same ACL, or assuming
  the more permissive one alone determines effective access.
- Deleting/recreating a share to repair access without preserving its ACL,
  caching, encryption, scope, cluster, special-share, and availability settings.
- Closing a session/open file by display name without exact ID and application
  owner, causing data loss, lock breakage, retry storms, or service failure.
- Removing administrative shares as routine hardening without understanding
  management, backup, deployment, cluster, and product dependencies.
- Concluding the console is hung or the server is unavailable while it performs
  slow client-name resolution or remote enumeration.
- Querying the local computer while intending a remote/clustered file server, or
  ignoring SMB instance and scope names.
- Scraping localized MMC tables instead of typed SMB objects.

## PowerShell behavior

`Start-Process fsmgmt.msc` only launches the GUI. `Get-SmbShare`,
`Get-SmbSession`, and `Get-SmbOpenFile` return different CIM object types; keep
their stable IDs and use `-CimSession`, scope, and SMB instance explicitly.

Close/remove cmdlets can disrupt clients and data. Use their confirmation and
WhatIf support where provided, capture before/after inventories, coordinate with
owners, and verify both SMB and underlying file-system access afterward.

## Version and platform differences

`fsmgmt.msc` is Windows-only. Snap-in presence, SmbShare cmdlets, remote access,
firewall rules, SMB dialect/features, clustering/scopes, and management rights
vary by Windows build, edition, server role, installed tools, and policy.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\fsmgmt.msc`. It exposed no nonzero four-part
fixed file version through `FileVersionInfo`; the audit retains that as absent
rather than inventing `0.0.0.0`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [net.exe](net.exe.md)
- [compmgmt.msc](compmgmt.msc.md)
- [icacls.exe](icacls.exe.md)
- [mmc.exe](mmc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[SmbShare module reference](https://learn.microsoft.com/powershell/module/smbshare/),
[Shared Folders snap-in description](https://learn.microsoft.com/previous-versions/windows/desktop/mmc/extending-the-shared-folders-extension),
and [remote MMC management guidance](https://learn.microsoft.com/windows-server/administration/server-core/server-core-manage).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
