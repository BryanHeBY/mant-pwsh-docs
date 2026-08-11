<!-- mant:tldr:start -->
# tpmvscmgr

> Inventory TPM virtual smart cards and migration prerequisites before creating or irrecoverably destroying one.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tpmvscmgr.

- Read installed syntax without creating a credential:

`tpmvscmgr.exe /?`

- Inventory TPM readiness without clearing or provisioning it:

`tpmtool.exe getdeviceinformation`

- Inventory virtual smart-card reader device instances and preserve exact IDs:

`Get-PnpDevice -Class SmartCardReader -PresentOnly:$false | Select-Object Status, FriendlyName, InstanceId`

- Check certificate stores separately; reader presence does not prove enrollment:

`Get-ChildItem Cert:\CurrentUser\My | Select-Object Subject, Thumbprint, NotAfter, HasPrivateKey`
<!-- mant:tldr:end -->

# tpmvscmgr

## Overview

`tpmvscmgr.exe` creates and securely deletes TPM virtual smart cards. Creation
requires a name and administrator-key policy and can define a PIN, PUK, local
filesystem, remote machine, PIN policy, and attestation. Destruction uses the
exact `ROOT\SMARTCARDREADER\...` instance ID and cannot be recovered.

Microsoft encourages existing virtual-smart-card customers to migrate to
Windows Hello for Business or FIDO2 and recommends those technologies for new
deployments. Treat TpmVscMgr as lifecycle tooling for an established design,
not the default for a new authentication architecture.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `tpmvscmgr.exe`: Create or destroy legacy TPM virtual smart cards.
- `create`: Create one TPM-backed virtual smart-card instance.
- `destroy`: Permanently remove one selected virtual smart-card instance.

Creation parameters determine secrets, management, and recoverability.

<!-- mant:entries role=option case=insensitive -->
- `/name`: Set the virtual smart-card display name.
- `/pin`: Supply or prompt for the user PIN; avoid inline secrets.
- `/adminkey`: Select a supplied, default, or random administrative key.
- `/generate`: Permit supported key generation needed by standard management.
- `/?`: Display installed syntax.

## Common mistakes

### Using DEFAULT secrets outside an isolated demonstration

Microsoft documents fixed default administrator key, PIN, and PUK values. They
are publicly known and unsuitable for production. Use an approved credential
provisioning/escrow/reset design; never place PINs or keys in command history.

### Choosing RANDOM without accepting loss of management

`/AdminKey RANDOM` discards the generated key, so standard management tools may
not reset a forgotten PIN. Confirm replacement/re-enrollment and recovery policy.

### Omitting `/generate` without a management system

Without the generated card filesystem, the card needs a smart-card management
system. Creation success does not mean the card is enrollable or useful.

### Destroying the wrong instance or the last usable credential

Friendly name is not sufficient identity. Map instance ID to user, certificates,
relying services, alternate sign-in, recovery, and enrollment authority. Deletion
is irreversible and can strand the user.

### Clearing or reinitializing the TPM as troubleshooting

TPM reset, OS reinstall, or ownership/provisioning changes can invalidate virtual
cards and other protected keys. Inventory BitLocker, Windows Hello, certificates,
attestation, recovery keys, and organizational ownership first.

## PowerShell boundaries

TpmVscMgr is native and administrative. Prompt modes require an interactive
secure console; they are not suitable for unattended remoting. Capture the
created instance ID and `$LASTEXITCODE` without logging secrets. PowerShell PnP
and certificate inventory describes different layers and must be correlated.

## Version and platform differences

This is Windows-only and depends on a supported/provisioned TPM, administrative
rights, smart-card services, certificate enrollment, domain/DCOM for remote
creation, and organizational authentication policy. Current Microsoft guidance
favors Windows Hello for Business or FIDO2 for new installations.

## Related documents

- [tpmtool](tpmtool.md)
- [certutil](certutil.md)
- [manage-bde](manage-bde.md)

## Sources and license

This original guide was adapted from Microsoft's official
[TpmVscMgr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tpmvscmgr)
and current [Windows TPM guidance](https://learn.microsoft.com/windows/security/hardware-security/tpm/how-windows-uses-the-tpm).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
