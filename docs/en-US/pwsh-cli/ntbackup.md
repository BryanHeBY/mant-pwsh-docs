<!-- mant:tldr:start -->
# ntbackup

> Preserve and recover legacy NTBackup artifacts with the NT Backup Restore utility; `wbadmin` cannot restore them.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ntbackup.

- Inventory and hash a copied legacy backup without opening or restoring it:

`Get-Item -LiteralPath "{{D:\Legacy\server.bkf}}" | Select-Object FullName, Length, LastWriteTime; Get-FileHash -LiteralPath "{{D:\Legacy\server.bkf}}" -Algorithm SHA256`

- Confirm whether the legacy executable exists without launching it:

`Get-Command ntbackup.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Inventory current Windows Backup versions separately:

`wbadmin.exe get versions`

- Preserve file-system ACL evidence for the copied backup:

`Get-Acl -LiteralPath "{{D:\Legacy\server.bkf}}" | Format-List Owner, AccessToString`
<!-- mant:tldr:end -->

# ntbackup

## Overview

`ntbackup.exe` created/restored legacy Windows NT Backup artifacts. Microsoft
replaced it with `wbadmin` but explicitly warns that WbAdmin cannot recover
NTBackup-created backups; the Windows NT Backup Restore utility is required.
Treat legacy backups as protected evidence requiring a compatible isolated
recovery environment.

## Common mistakes

### Trying to restore BKF media with WbAdmin

The formats/tools are not interchangeable. Preserve the original and hashes,
identify creating OS/tool/media/catalog, and obtain the supported legacy restore
utility rather than converting or modifying the only copy.

### Restoring directly onto a production host

Backups can overwrite files/ACLs/system state and reintroduce vulnerable
binaries, secrets, identities, malware, or obsolete configuration. Restore to
an isolated compatible system, scan and validate extracted data, then migrate
only reviewed content.

### Calling readable files a successful recovery

Verify catalog completeness, expected paths, timestamps, ACLs, hashes or
application-level consistency, encryption/compression, and recovery objectives.

### Installing random copies of NtBackup

Executable, DLL, removable-storage, catalog and OS dependencies matter. Verify
Microsoft provenance/signatures and licensing; never download an unknown bundle.

## PowerShell behavior

PowerShell should inventory copied artifacts and orchestrate a controlled lab,
not parse BKF as ordinary archives. `wbadmin get versions` inventories its own
catalog only and says nothing about an NTBackup file.

## Version and platform differences

NTBackup is legacy Windows tooling. Recovery depends on compatible OS/restore
utility, architecture, media, catalogs, encryption and system-state components.
Modern Windows Backup does not supply format compatibility.

## Related documents

- [wbadmin](wbadmin.md)

## Sources and license

Adapted as an original recovery guide from Microsoft's [NTBackup catalog entry](https://learn.microsoft.com/windows-server/administration/windows-commands/ntbackup).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
