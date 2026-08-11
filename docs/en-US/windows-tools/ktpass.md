<!-- mant:tldr:start -->
# ktpass

> Prepare AD-to-MIT Kerberos service mappings and keytabs; inspect every identity and key input before this mutating operation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ktpass.

- Display the installed tool's syntax without changing Active Directory or creating a keytab:

`ktpass.exe /?`

- Read the exact account UPN, SPNs, encryption types, and key version before planning a keytab rotation (requires the ActiveDirectory module):

`Get-ADUser -Identity "{{service_account}}" -Properties userPrincipalName,servicePrincipalName,msDS-SupportedEncryptionTypes,msDS-KeyVersionNumber | Select-Object SamAccountName,UserPrincipalName,ServicePrincipalName,msDS-SupportedEncryptionTypes,msDS-KeyVersionNumber`

- Check whether the intended service principal already has an owner in the current domain:

`setspn.exe -Q "{{HTTP/service.example.com}}"`

- Search the current domain for duplicate service principals before any mapping change:

`setspn.exe -X`
<!-- mant:tldr:end -->

# ktpass

## Overview

`ktpass.exe` maps a Kerberos service principal to an AD DS account and creates
an MIT-compatible keytab containing the service's shared secret key. It exists
for interoperability with services on non-Windows systems.

There is no general read-only "export the existing key" operation: AD does not
store a retrievable plaintext password from which an arbitrary old keytab can
be reconstructed. A real `ktpass` run can change SPN/UPN attributes, account
password/key material, encryption settings, and the output secret. For that
reason the TLDR stops at prerequisite inventory.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `ktpass.exe`: Map an AD account to a Kerberos service principal and create
  or transform MIT-compatible keytab key material.

Many options change the directory account or secret as well as the output
file. Principal case is significant even though option names are not.

<!-- mant:entries role=option case=insensitive -->
- `/out`: Select the secret keytab output file.
- `/princ`: Set the exact case-sensitive service principal stored in the keytab.
- `/mapuser`: Select the AD account whose attributes/key material are affected.
- `/mapop`: Select additive or replacing principal-to-account mapping behavior.
- `/pass`: Set or prompt for the account/key password; literal values are exposed.
- `/crypto`: Select the explicit Kerberos encryption type and avoid stale defaults.
- `/ptype`: Select the principal type stored in the keytab.
- `/kvno`: Set the key version number only when it matches the KDC/account state.
- `/target`: Select the domain controller used for the directory operation.
- `/in`: Read and modify an existing keytab rather than starting a new file.
- `/setupn`: Control whether the selected account UPN is changed.
- `/setpass`: Control whether the selected account password is changed.
- `/rawsalt`: Supply an explicit salt only for a reviewed interoperability need.
- `/dumpsalt`: Display the salt that the selected inputs would use.
- `/answer`: Suppress prompts according to the documented Yes/No behavior.
- `/?`: Display installed syntax and build-specific crypto choices.

## Common mistakes

### Assuming `/out` only writes a local file

When `/mapuser`, `/pass`, `/mapop`, `/setupn`, or `/setpass` participate, the
operation can modify the directory account as well as create a keytab. Review
the exact local-build help, preserve the account attributes, select one domain
controller, plan replication, and treat the run as a credential rotation.

### Losing exact principal case or using the wrong identity form

Microsoft documents `/princ` as case-sensitive and does not validate it
against the exact UPN case. Record service class, fully qualified host, port if
used, and uppercase realm from the real service configuration. Do not confuse
`HTTP/host@REALM`, the account UPN, and `DOMAIN\account`.

### Using `/mapop set` without understanding replacement scope

`add` and `set` do not mean "safe" and "force." A set-style mapping or UPN
setup can replace directory attribute values that other service instances
need. Export and compare the account's UPN and complete multivalued SPN list;
use `setspn -Q`/`-X` to reject duplicate ownership.

### Putting the password on the command line

Inline passwords leak through process inspection, transcripts, automation
logs, command history, and job metadata. Prompting avoids some exposure but
does not make the directory/key change harmless. Prefer a dedicated service
account and an approved rotation procedure; never publish the generated
keytab or leave it with inherited broad ACLs.

### Reusing a keytab after password, salt, name, or KVNO changes

The keytab and AD account must agree on principal-derived salt, password/key,
encryption type, and key version. Renaming the identity or rotating its
password can invalidate deployed keytabs. Coordinate one rotation window,
securely distribute the new artifact, restart/reload the service if required,
test it, and retire the old keytab.

### Accepting old crypto defaults

Microsoft recommends specifying `/crypto`; old examples frequently select DES
or RC4 for compatibility. Choose only encryption types supported and permitted
by the KDC, account, client, and service. Do not enable deprecated encryption
globally to rescue one unexplained keytab failure.

### Treating file creation as proof of Kerberos success

A generated keytab can still contain the wrong principal, case, salt, key,
KVNO, or crypto. Inspect it with the target platform's Kerberos tools, protect
the artifact, request the exact SPN from a test client, and correlate AD/KDC
and service logs. Do not infer success from exit code alone.

## PowerShell boundaries

Call `ktpass.exe` explicitly and check `$LASTEXITCODE`. PowerShell interpolation
can alter `$`, backticks, quotes, and other password characters, which is one
more reason not to embed secrets. Output is text and warnings may matter even
when a file was created.

## Version and platform differences

`ktpass.exe` is a Windows/AD administrative tool; the resulting keytab is for a
Kerberos implementation on another platform. Switch behavior and defaults have
changed across Windows releases. Cryptographic support also depends on domain
policy, account attributes, installed service stack, and client libraries.
Use the tool version belonging to the managed Windows generation and verify its
local help before a controlled rotation.

## Related documents

- [setspn](setspn.md)
- [ksetup](ksetup.md)
- [klist](klist.md)

## Sources and license

This original guide was adapted from Microsoft's official
[ktpass reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ktpass).
Recurring password/UPN side effects and salt/keytab invalidation were
cross-checked against practitioner discussions of
[password authentication after ktpass](https://stackoverflow.com/questions/64459376/is-the-ktpass-command-disable-password-authentication/64467431)
and [principal salt changes](https://stackoverflow.com/questions/40760205/how-and-when-does-ktpass-set-the-salt).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
