<!-- mant:tldr:start -->
# macfile.exe

> Inventory a legacy File Server for Macintosh dependency before moving data and permissions to a supported file service.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/macfile.

- Confirm the legacy executable and preserve its identity without changing a server:

`Get-Command macfile.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Inventory the ordinary NTFS tree and ACLs that underlie a legacy volume:

`Get-ChildItem -LiteralPath "{{D:\MacVolume}}" -Force | Select-Object Name, Attributes, Length; Get-Acl -LiteralPath "{{D:\MacVolume}}" | Format-List Owner, AccessToString`

- Hash copied data and resource-fork artifacts before a migration:

`Get-ChildItem -LiteralPath "{{D:\MigrationCopy}}" -File -Recurse | Get-FileHash -Algorithm SHA256`

- Review a proposed 11-bit Macintosh permission mask as labeled fields before applying it:

`$mask = '{{11111011000}}'; $labels = 'OwnerSeeFiles','OwnerSeeFolders','OwnerMakeChanges','GroupSeeFiles','GroupSeeFolders','GroupMakeChanges','WorldSeeFiles','WorldSeeFolders','WorldMakeChanges','Locked','Recurse'; 0..10 | ForEach-Object { [pscustomobject]@{ Position = $_ + 1; Permission = $labels[$_]; Enabled = $mask[$_] -eq '1' } }`
<!-- mant:tldr:end -->

# macfile.exe

## Overview

`macfile.exe` administered the legacy File Server for Macintosh service:

- `directory` changed an existing directory's owner, Macintosh primary group,
  and an 11-digit permission mask;
- `forkize` joined data/resource forks or changed Macintosh creator/type codes;
- `server` changed the sign-in message and simultaneous-session limit;
- `volume /add|/set|/remove` managed Macintosh-accessible volumes, guest/read-
  only policy, passwords, and user limits.

This is preservation/migration documentation for historical servers. Do not
assume modern SMB, NTFS ACLs, Apple metadata, and old Macintosh fork/permission
semantics are interchangeable.

## Command families and parameters

<!-- mant:entries role=command case=insensitive -->
- `macfile.exe`: Administer legacy Services for Macintosh metadata and volumes.
- `directory`: Change an existing directory's Macintosh owner/group/permissions.
- `forkize`: Join resource/data forks or change Macintosh creator/type metadata.
- `server`: Change Macintosh sign-in message or session limit.
- `volume`: Add, change, remove, or list Macintosh-accessible volumes.

Family-specific values must be read from installed help on the preserved host.

<!-- mant:entries role=option case=insensitive -->
- `/server`: Select the exact Services for Macintosh server.
- `/user`: Select an alternate administrative user.
- `/password`: Supply its password inline and expose the secret.
- `/?`: Display installed family syntax.

## Common mistakes

### Assuming `directory` creates a directory

Microsoft explicitly says the directory must already exist. The command changes
metadata/permissions on a Macintosh-accessible volume; it does not create the
tree. Confirm the canonical path and ordinary NTFS ACLs first.

### Miscounting the 11 permission digits

The positions separately govern owner/group/world visibility and changes, then
lock rename/move/delete, then recursive application. A transposed digit can
broaden access or recursively change a tree. Label every position, inventory
children, test on a copied fixture, and preserve rollback metadata.

### Omitting quotes around names and messages

Volume names, paths, owners, groups, and login messages commonly contain spaces.
Quote the complete value. The examples in old material can appear unquoted;
do not copy them into PowerShell without validating native argument boundaries.

### Putting `/password` values in scripts

The volume syntax accepts a password on the command line, exposing it to script
source, history, process/audit telemetry, and logs. Do not use plaintext command-
line credentials. Prefer migration to a supported identity and file-service
model; if historical recovery is unavoidable, use an isolated process approved
by the security owner.

### Losing resource forks or creator/type metadata

Copying only the Windows-visible data fork can make classic Macintosh content
incomplete. Inventory data/resource forks, Finder creator/type codes, names,
timestamps, ACLs, and application-level readability; validate on the target
Mac/software stack before retiring the source.

### Treating a share migration as a permission migration

Macfile masks, guest/password access, NTFS ACLs, SMB identities, and modern macOS
extended attributes have different models. Build an explicit mapping, identify
denies/inheritance/special identities, test with representative accounts, and
retain a reversible copy.

## PowerShell boundaries

Use PowerShell for read-only NTFS inventory, hashes, signatures, and migration
manifests. `macfile.exe` output and arguments are native text. Do not interpolate
untrusted paths, names, masks, or secrets, and do not infer success without
checking both `$LASTEXITCODE` and the service/client-visible result.

## Version and platform differences

File Server for Macintosh is legacy role-dependent Windows Server technology.
Verify the exact historical OS, executable, service, volume format, client
version, and local help. A current Learn banner does not establish that the role
ships or is supported on the target. Prefer current SMB with supported macOS
interoperability for new deployments.

## Related documents

- [icacls.exe](icacls.exe.md)
- [net.exe](net.exe.md)
- [robocopy.exe](robocopy.exe.md)

## Sources and license

Adapted as an original preservation and migration guide from Microsoft's
[macfile reference](https://learn.microsoft.com/windows-server/administration/windows-commands/macfile).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
