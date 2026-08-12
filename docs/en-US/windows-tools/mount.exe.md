<!-- mant:tldr:start -->
# mount.exe

> Inspect and mount Windows Client for NFS exports; this is unrelated to local-volume `mountvol`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mount.

- List all NFS filesystems currently mounted by Windows Client for NFS:

`mount.exe`

- Verify that Client for NFS and the exact native command are already installed:

`Get-Command mount.exe -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersionFixed';Expression={$_.FileVersionInfo.FileVersionRaw.ToString()}},@{Name='FileVersionString';Expression={$_.FileVersionInfo.FileVersion}}`

- Discover exports from one approved server before choosing a path:

`showmount.exe -e "{{nfs01.example.com}}"`

- Mount one reviewed export on an unused drive with a hard mount and Kerberos privacy:

`mount.exe -o mtype=hard sec=krb5p "{{nfs01.example.com:/exports/data}}" "{{Z:}}"`
<!-- mant:tldr:end -->

# mount.exe

## Overview

Windows `mount.exe` belongs to the optional Client for NFS feature. With no
arguments it lists NFS mounts; otherwise it creates a connection from a server
export to a drive letter. It is not Unix `mount`, DiskPart, or `mountvol.exe`.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `mount.exe`: List or create Windows Client for NFS drive mappings.

The launcher options and fixed `-o` value names have distinct selectors.

<!-- mant:entries role=option case=insensitive -->
- `-o`: Supply one or more NFS mount option/value tokens.
- `-u`: Select an alternate NFS username.
- `-p`: Supply its password inline or use `*` to prompt.
- `rsize=KILOBYTES`: Set the NFS read buffer to a supported size from 1 through 32 KiB.
- `wsize=KILOBYTES`: Set the NFS write buffer to a supported size from 1 through 32 KiB.
- `timeout=SECONDS`: Set the RPC timeout within the documented fractional or 1–60 second range.
- `retry=COUNT`: Set the number of retries for a soft mount within the documented 1–10 range.
- `mtype=MODE`: Select a soft or hard mount and its corresponding outage behavior.
- `lang=ENCODING`: Select the one legacy filename encoding used for the mount.
- `fileaccess=MODE`: Set the three-digit owner/group/world mode assigned to newly created files.
- `sec=MODE`: Select `sys`, `krb5`, `krb5i`, or `krb5p` security semantics.
- `/?`: Display installed Windows Client for NFS syntax.

The value-less `-o` suboptions `anon`, `nolock`, and `casesensitive` select
anonymous identity, disable remote locking, and force case-sensitive server
lookups respectively.

## Common mistakes

### Copying Unix syntax or targeting an SMB share

Windows accepts `\\server\share` or `server:/share` plus a drive designator.
Confirm the remote protocol/export with `showmount`; SMB UNC availability does
not prove NFS export identity or permissions.

### Embedding `-p:password`

Passwords leak through process inspection, logs, transcripts, and history.
Use `-p:*` for an approved prompt, integrated Kerberos, or supported identity
mapping. A username/password is not a substitute for correct NFS UID/GID rules.

### Treating `sec=sys` or `anon` as secure authentication

Microsoft documents `sec=sys` as providing no authentication/security checks
and no encryption. Prefer the server-supported Kerberos mode: `krb5` authenticates,
`krb5i` adds integrity, and `krb5p` adds privacy. Verify SPNs, tickets, mapping,
clock, DNS, export rules, and filesystem ACLs.

### Adding `nolock` to silence an error

Disabling remote locking can allow applications/clients to make conflicting
updates and changes reboot-recovery semantics. Use it only when the workload
owner has proved locking is unnecessary.

### Choosing soft/hard or buffers as generic performance fixes

Soft mounts can return failures; hard mounts can block callers during outages.
Buffer, retry and timeout choices affect correctness and recovery, not just
speed. Test the real application and failure mode.

### Reusing a drive letter or assuming mount completion proves access

Resolve the chosen drive across user/session contexts, then verify effective
identity, root/anonymous mapping, read/write/lock behavior and reconnect.

## PowerShell boundaries

Call `mount.exe` explicitly because other environments may provide a same-name
command. Quote export and drive arguments and check `$LASTEXITCODE`. `*` asks
the native tool to choose a drive only if passed literally; PowerShell globbing
and alias/function precedence should be ruled out with `Get-Command -All`.

## Version and platform differences

Windows-only and Client-for-NFS dependent. NFS/security/version support varies
by Windows edition/build and server implementation. The command's file mode,
language and NFSv3-era options are not equivalent to modern Unix clients.
Exact System32 discovery on the recorded Windows NT `10.0.26200.0` Home China
client found neither `mount.exe` nor companion `umount.exe`; do not substitute
a PATH match or install NFS components merely for documentation evidence.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found mount.exe and its companion umount.exe absent; no PATH substitute,
inventory, mapping, export, credential, mount, lock, ACL, service, feature, or
firewall action ran. No-argument inventory remains pending where NFS is
installed.

## Related documents
- [showmount.exe](showmount.exe.md)
- [nfsadmin.exe](nfsadmin.exe.md)
- [nfsstat.exe](nfsstat.exe.md)
- [mountvol.exe](mountvol.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[mount reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mount).
Windows identity/path failures and locking tradeoffs were cross-checked against
practitioner discussions of [Windows Client for NFS configuration](https://serverfault.com/questions/878130/configuring-windows-client-for-nfs)
and [NFS remote locking](https://serverfault.com/questions/989907/nfs-what-is-remote-locking-and-do-i-need-it).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
