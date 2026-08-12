<!-- mant:tldr:start -->
# cipher.exe

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

# cipher.exe

## Overview

`cipher.exe` displays and changes Encrypting File System (EFS) state on NTFS.
It encrypts/decrypts, inspects file certificates, enumerates encrypted files,
backs up or creates EFS keys, manages recovery/user certificates, rekeys files,
and overwrites unused logical space on a selected local volume. EFS is
file-level encryption tied to certificates and keys, not BitLocker volume
encryption.

## Commands and options

<!-- mant:entries role=command case=insensitive -->
- `cipher.exe`: Inspect or change NTFS EFS state, manage EFS certificate/key
  workflows, or overwrite unused space on one selected local volume.

Many modes are mutually exclusive or ignore other switches. Query state and
recovery identity before selecting any mutation.

<!-- mant:entries role=option case=insensitive -->
- `/e`: Encrypt named files or mark named directories so newly added files are
  encrypted.
- `/d`: Decrypt named files or directories.
- `/c`: Display certificate and recovery-agent information for one encrypted
  file.
- `/s`: Apply the selected operation to subdirectories under the following
  colon-delimited directory.
- `/b`: Abort the operation when an error is encountered instead of continuing.
- `/h`: Include hidden/system entries that are otherwise omitted.
- `/k`: Create a new EFS certificate and key for the current user; all other
  switches are ignored except the supported `/ecc` selector.
- `/r`: Generate a recovery-agent certificate and key using the following
  colon-delimited base filename, producing `.cer` and protected `.pfx` output.
- `/smartcard`: With `/r`, write the recovery key/certificate to a smart card
  and do not generate a `.pfx` file.
- `/ecc`: With `/k` or `/r`, request an ECC key size supported by the installed
  command (`256`, `384`, or `521` in current installed help).
- `/p`: Convert the following `.cer` recovery certificate to a Base64-encoded
  recovery-policy blob for an MDM deployment.
- `/u`: Search local drives for encrypted files and update them to current
  user/recovery keys unless `/n` is also present.
- `/n`: With `/u`, perform inventory without updating encrypted files.
- `/w`: Overwrite available unused space on the entire local volume containing
  the following colon-delimited directory; all other options are ignored.
- `/x`: Back up the current user's EFS certificate and private keys, or the
  certificate used by a specified EFS file, to protected output.
- `/y`: Display the thumbprint of the current user's EFS certificate.
- `/adduser`: Add an EFS user certificate to the selected encrypted files.
- `/removeuser`: Remove the certificate identified by `/certhash` from selected
  encrypted files.
- `/certhash`: Select a certificate by SHA-1 thumbprint for add/remove modes.
- `/certfile`: Select a certificate from the following file for `/adduser`.
- `/user`: With `/adduser`, select the EFS user by the following user name.
- `/flushcache`: Clear the calling user's EFS key cache locally or on the
  server selected by `/server`.
- `/server`: With `/flushcache`, select the following server instead of the
  local machine.
- `/rekey`: Update selected encrypted files to the currently configured EFS key.
- `/?`: Display installed command help; on the recorded Windows build it
  printed complete help and returned exit code 1.

## PowerShell boundaries

`cipher.exe` emits localized text and several successful modes create or
change security-sensitive state. Pass colon-bound values as one native
argument, capture `$LASTEXITCODE`, and re-query representative literal paths.
Protect any `.pfx`/recovery output as credentials; do not pipe it through text
formatting or assume PowerShell object semantics. On Windows build
`10.0.26200`, `cipher.exe /?` printed complete usage but returned 1 under both
installed PowerShell editions; help text and process status are separate
signals. On the same host, `/Y` returned 1 with no output because the current
user had no available EFS certificate, which is not an empty thumbprint.

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

### Treating `/P` as a private-key backup

`/P:certificate.cer` creates an MDM recovery-policy blob from a public recovery
certificate. It does not replace `/X` backup of a user's EFS certificate and
private key, `/R` recovery-agent key generation, protected key custody, or a
tested recovery procedure.

### Flushing the key cache as a harmless query

`/FLUSHCACHE` changes the calling user's EFS key-cache state, and `/SERVER`
can direct that operation to another machine. It can affect subsequent access
and authentication behavior. Do not run it for inventory or help discovery;
identify the user/server and obtain operational approval first.

## Version and platform differences

This Windows-only command requires NTFS and an edition/configuration that
supports EFS. Certificate policy, recovery agents, smart cards, domain policy,
filesystem destination, and user context determine availability and recovery.
Current installed help additionally exposes `/ECC`, `/P`, `/USER`,
`/FLUSHCACHE`, and `/SERVER`, while Microsoft's current online command page
does not list those forms. Treat them as installed-version capabilities and
gate automation on local help or command-specific testing. On Windows NT
`10.0.26200.0`, installed file version `10.0.26100.1` printed 88 nonempty
help lines and returned 1 for `/?`; the indexed selector surface matched that
help. This help-specific status is not an EFS, file, certificate, key,
smart-card, server, or volume operation result.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 ordinary-token
/? printed 88 nonempty complete-help lines and returned 1; its selector surface
matched the index. No path, EFS state, certificate, key, smart card, user,
server, cache, recovery artifact, or volume operation was supplied or changed.

## Related documents
- [icacls.exe](icacls.exe.md)
- [takeown.exe](takeown.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[cipher reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cipher).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
