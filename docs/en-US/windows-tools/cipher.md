<!-- mant:tldr:start -->
# cipher

> Inspect NTFS Encrypting File System state and recovery identity before changing encryption.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cipher.

- Show EFS status for the current directory and its immediate entries:

`cipher.exe`

- Show EFS certificate and recovery information for one encrypted file:

`cipher.exe /C "{{encrypted-file}}"`

- Find encrypted files on local drives without updating their keys:

`cipher.exe /U /N`

- Show the thumbprint of the current user's EFS certificate:

`cipher.exe /Y`
<!-- mant:tldr:end -->

# cipher

## Overview

`cipher.exe` displays and changes Encrypting File System (EFS) state on NTFS.
It encrypts/decrypts, inspects file certificates, enumerates encrypted files,
backs up or creates EFS keys, manages recovery/user certificates, rekeys files,
and overwrites unused logical space on a selected local volume. EFS is
file-level encryption tied to certificates and keys, not BitLocker volume
encryption.

## Common mistakes

### Encrypting before backing up the EFS key

Loss of the private key or recovery path can make data unrecoverable. Identify
the current certificate with `/Y`, inspect representative files with `/C`, and
perform an approved `/X` backup to protected removable or managed key storage
before encryption or rekeying. Never commit or transmit the PFX casually.

### Running `/U` without `/N`

`/U` searches local drives and, without `/N`, can update encrypted files to a
changed current/recovery key. Use `/U /N` for inventory. Record runtime and
scope because a full local-drive search can be expensive.

### Treating `/W:path` as deletion of that path

`/W` ignores other options and overwrites available unused space on the entire
local volume containing the specified directory. It can consume free space and
run for a long time; it does not target one named file, and other copies may
remain in snapshots, backups, caches, or storage layers.

### Encrypting only a file in an unencrypted parent

Microsoft warns that modifying an encrypted file under an unencrypted parent
can result in decryption. Encrypt and verify the intended parent policy, and
test the actual application's save/replace behavior on disposable data.

### Confusing directory marking with every descendant's current state

An encrypted directory is marked so new files are encrypted, while existing
entries and subdirectories still need explicit scope verification. Use `/S`
only after enumerating descendants and confirming links, hidden/system files,
errors, and recovery coverage.

### Assuming EFS follows data to every destination

Copy/move tools, target filesystem, shares, archives, applications, and user
identity can change encryption or access behavior. Verify the destination file
with `/C` and test recovery from a different approved identity.

## Version and platform differences

This Windows-only command requires NTFS and an edition/configuration that
supports EFS. Certificate policy, recovery agents, smart cards, domain policy,
filesystem destination, and user context determine availability and recovery.

## Related documents

- [icacls](icacls.md)
- [takeown](takeown.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[cipher reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cipher).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
