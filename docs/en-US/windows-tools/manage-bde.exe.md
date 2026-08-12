<!-- mant:tldr:start -->
# manage-bde.exe

> Inspect BitLocker conversion, protection, lock, and protector state before changing encryption or recovery access.
> Run state and protector queries from an elevated administrative shell and protect their output.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/manage-bde.

- Show BitLocker state for every local volume:

`manage-bde.exe -status`

- Show conversion, encryption method, protection, and lock state for one exact volume:

`manage-bde.exe -status "{{C:}}"`

- List protector types, IDs, and any displayed recovery material; protect the output as secret-bearing data:

`manage-bde.exe -protectors -get "{{C:}}"`

- Test protection status through the documented result code and preserve it immediately:

`manage-bde.exe -status "{{C:}}" -protectionaserrorlevel; $protectionExitCode = $LASTEXITCODE`

- Unlock one exact data volume with an interactive password prompt instead of a command-line secret:

`manage-bde.exe -unlock "{{E:}}" -password`
<!-- mant:tldr:end -->

# manage-bde.exe

## Overview

`manage-bde.exe` is the native BitLocker administration tool. It reports
volume encryption state, starts or stops conversion, locks and unlocks data
volumes, manages automatic unlock, and adds, deletes, suspends, resumes, or
escrows key protectors. It can also force recovery, generate key packages,
upgrade BitLocker metadata, and wipe free space.

BitLocker has several independent state dimensions. Record all of them:

- conversion status and encrypted percentage;
- encryption method and BitLocker metadata version;
- protection status (whether protectors are enforced);
- lock status (whether this Windows instance currently has data access);
- exact volume identity and role (OS, fixed data, removable data);
- protector types/IDs and verified recovery escrow locations.

“Fully encrypted” does not by itself mean “protected” or “locked.”

## Command families

<!-- mant:entries role=command case=insensitive -->
- `manage-bde.exe`: Inspect or administer BitLocker state and recovery material.

All documented families use leading hyphens and several perform long-running or
recovery-critical mutations.

<!-- mant:entries role=option case=insensitive -->
- `-status`: Report conversion, method, protection, and lock state.
- `-on`: Start BitLocker encryption on an exact volume.
- `-off`: Start full decryption and eventual protector removal.
- `-pause`: Pause encryption or decryption conversion work.
- `-resume`: Resume paused conversion work.
- `-lock`: Remove current access to an unlocked data volume.
- `-unlock`: Unlock a data volume with an approved protector.
- `-protectors`: Get, add, delete, disable, enable, or escrow key protectors.
- `-autounlock`: Enable, disable, or clear OS-stored auto-unlock keys.
- `-forcerecovery`: Delete TPM-related protectors and require recovery at restart.
- `-wipefreespace`: Overwrite a volume's free space.
- `-changepassword`: Change a data-volume password protector.
- `-changepin`: Change an OS-volume PIN protector.
- `-changekey`: Change an OS-volume startup-key protector.
- `-keypackage`: Generate a key package for damaged-volume recovery.
- `-upgrade`: Upgrade BitLocker metadata on the selected volume.
- `-computername`: Select a remote computer where the family supports it.
- `-protectionaserrorlevel`: Return `0` for protected and `1` for unprotected status.
- `-get`: List protectors and their identifiers.
- `-add`: Add a new exact protector without removing the old one.
- `-delete`: Delete protectors by exact ID or type.
- `-disable`: Suspend protector enforcement without decrypting the volume.
- `-enable`: Re-enable protector enforcement.
- `-adbackup`: Back up one recovery-password protector to Active Directory.
- `-aadbackup`: Back up one recovery-password protector to Microsoft Entra ID.
- `-id`: Select one exact protector GUID.
- `-type`: Select a protector type and potentially broaden impact.
- `-rebootcount`: Bound suspension to a number of restarts; zero is indefinite.
- `-password`: Prompt for or supply a password protector; avoid inline secrets.
- `-recoverypassword`: Select a 48-digit recovery-password protector.
- `-recoverykey`: Select an external `.bek` recovery key.
- `-startupkey`: Select an external startup key.
- `-tpmandpin`: Select a TPM-plus-PIN protector.
- `-tpmandstartupkey`: Select a TPM-plus-startup-key protector.
- `-tpmandpinandstartupkey`: Select TPM, PIN, and startup-key protection.
- `-certificate`: Select a certificate-based data-volume protector.
- `-sid`: Select an AD-account-or-group protector.
- `-?`: Display family-specific installed help.

| Family | Purpose | High-risk boundary |
| --- | --- | --- |
| `-status` | Query volume state | `-protectionaserrorlevel` uses `0` for protected and `1` for unprotected; capture immediately. |
| `-on`, `-off` | Start encryption or full decryption | `-off` eventually removes all protectors; neither is a quick lock/unlock toggle. |
| `-pause`, `-resume` | Pause/resume conversion | Does not mean suspend/resume enforcement of protectors. |
| `-lock`, `-unlock` | Remove or obtain current access to a data volume | Do not place recovery passwords or ordinary passwords on command lines. |
| `-protectors` | Get/add/delete/disable/enable/escrow protectors | Deleting or disabling changes recovery/security posture without decrypting bytes. |
| `-autounlock` | Manage OS-stored keys for data volumes | `-clearallkeys` affects all stored external auto-unlock keys. |
| `-forcerecovery` | Require recovery at restart | Deletes TPM-related protectors; recovery material must already be verified. |
| `-wipefreespace` | Overwrite free space | Long-running whole-volume operation, not secure deletion of one file. |

## Protector workflow

For rotation, first inventory exact IDs and policy. Add the new approved
protector, escrow it to the required authority, independently verify retrieval,
test recovery in an approved manner, and only then delete the old exact ID.
Re-query conversion/protection/lock state and every protector afterward.

Protector terminology matters:

- a numerical recovery password is the 48-digit dashed value;
- an external recovery/startup key is a `.bek` file;
- a normal data-volume password, OS preboot PIN, startup key, TPM, certificate,
  and AD identity protector have different input and threat models;
- the protector unlocks a copy of the volume encryption key; it is not the raw
  volume encryption key itself.

## Common mistakes

### Treating encrypted percentage as protection status

A volume can be 100% encrypted while protection is suspended or no protector
is enforced. Conversely, conversion can still be running while protectors are
active. Check every status field and the actual recovery design.

### Confusing pause, suspend, decrypt, lock, and unlock

`-pause` stops conversion work; `-protectors -disable` suspends enforcement by
placing access material unsecured on the volume; `-off` decrypts; `-lock`
removes current access to a data volume; `-unlock` restores current access.
Never substitute one based on a similar English verb.

### Deleting the old recovery protector first

If the new protector or escrow fails, recovery can be lost. Deleting without
`-id` or `-type` is especially broad; deleting the last protector disables
BitLocker protection so data access is not inadvertently lost. Follow add,
escrow, verify, test, exact-delete, re-query order.

### Assuming directory or cloud escrow succeeded

`-adbackup` and `-aadbackup` require an exact recovery protector ID and the
right connectivity, identity, policy, and permissions. A successful local
command is not proof that help-desk or disaster-recovery identities can locate
and retrieve the expected key. Verify in the authoritative directory/portal.

### Putting recovery material in commands or logs

A 48-digit recovery password, PIN/password, `.bek`, key package, and protector
inventory are sensitive. Prefer interactive prompts or secure supported APIs,
disable shell history/transcripts only through approved policy, and protect
support bundles. Never store recovery material on the encrypted volume alone.

### Using `-protectors -disable -rebootcount 0` without tracking it

Zero suspends indefinitely; omitting the count normally resumes after restart.
Record reason, owner, expected boots, and deadline, then explicitly verify
protection after servicing. Encryption remaining at 100% does not mitigate an
indefinitely suspended protector.

### Running `-forcerecovery` before proving recovery access

The command removes TPM-related protectors and requires recovery at restart.
If the recovery password/key cannot be retrieved and entered, the OS may be
unavailable. Test the full people/process/media path before forcing recovery.

### Treating BitLocker as recoverable without any credential

There is no supported bypass for lost protectors; that is the purpose of
encryption. If storage is damaged but valid recovery material exists, use an
approved BitLocker recovery process such as `repair-bde` with a separate
output volume. Do not destroy the source or promise recovery from metadata
alone.

### Assuming drive letters are stable in recovery environments

WinRE/WinPE and attached disks can assign different letters. Bind the command
to volume GUID, size, filesystem, label, disk/partition identity, and known
BitLocker metadata before unlocking or changing anything.

### Clearing auto-unlock keys as a single-drive action

`-autounlock -clearallkeys` removes all stored external keys from the OS volume,
not merely one data drive's preference. Inventory every dependent data volume
and recovery path first.

## PowerShell boundaries

Manage-bde emits native, localized, recovery-sensitive text. Quote volume
arguments and `{protector-guid}` values, capture output securely, and check
`$LASTEXITCODE` immediately. The `-protectionaserrorlevel` `0/1` contract is
status data, not generic success/failure. For structured automation, evaluate
the supported BitLocker PowerShell cmdlets and management APIs for the target
Windows version and policy.

Read-only status is not an assurance that an ordinary token can read BitLocker
state. On the recorded non-elevated host, `-status` returned
`0x80041003` (`WBEM_E_ACCESS_DENIED`) and explicitly requested administrative
rights. Treat that as an access failure, not as an unprotected or absent
volume, and preserve the actual code before interpreting
`-protectionaserrorlevel`.

## Version and platform differences

This Windows-only administrative command applies to supported Windows client
and server releases where BitLocker components and the relevant edition/role
are available. TPM generation/state, Secure Boot, Modern Standby, device
encryption, domain/MDM policy, recovery environment, protector type, and OS
versus data volume determine valid operations.

## Runtime evidence

On the recorded ordinary token, `manage-bde.exe -status` returned
`0x80041003` (`WBEM_E_ACCESS_DENIED`) and explicitly required administrator
rights. This is query-time access evidence, not an empty BitLocker inventory.
No volume identity, protector, recovery material, conversion, protection,
lock, unlock, suspension, or auto-unlock state was exposed or changed;
approved elevated/disposable-volume verification remains pending.

## Related documents

- [mountvol.exe](mountvol.exe.md)
- [cipher.exe](cipher.exe.md)
- [bcdedit.exe](bcdedit.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[manage-bde overview](https://learn.microsoft.com/windows-server/administration/windows-commands/manage-bde),
[status reference](https://learn.microsoft.com/windows-server/administration/windows-commands/manage-bde-status),
and [protector reference](https://learn.microsoft.com/windows-server/administration/windows-commands/manage-bde-protectors).
Questions about lost recovery credentials and protector rotation were used as
discovery signals; the documented sequence follows Microsoft's current
protector and escrow semantics. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
