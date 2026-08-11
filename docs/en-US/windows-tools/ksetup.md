<!-- mant:tldr:start -->
# ksetup

> Inspect and configure the Windows Kerberos client for non-AD realms and cross-realm interoperability.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ksetup.

- Dump the effective Kerberos realm, KDC, password-server, flag, and host-mapping state on the local computer:

`ksetup.exe /dumpstate`

- List the realm flags that this Windows build understands, without changing a realm:

`ksetup.exe /listrealmflags`

- Read the configured encryption-type trust attribute for one exact domain or realm:

`ksetup.exe /getenctypeattr "{{REALM.EXAMPLE.COM}}"`

- Correlate the configuration with tickets in the current logon session:

`klist.exe`
<!-- mant:tldr:end -->

# ksetup

## Overview

`ksetup.exe` maintains the Windows Kerberos Security Support Provider's realm
configuration. It is mainly relevant when Windows must locate and use a
non-Microsoft Kerberos realm, or when an AD domain has a cross-realm trust.
Unlike a typical `krb5.conf`, Windows stores these mappings in the registry.

`/dumpstate`, `/listrealmflags`, and `/getenctypeattr` are diagnostic forms.
`/setrealm`, `/addkdc`, `/addkpasswd`, `/mapuser`, realm/host mapping changes,
flag changes, and password operations mutate local or trust-related state.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `ksetup.exe`: Inspect or change Windows Kerberos realm interoperability state.

Most operations modify the selected Windows computer, not the named KDC. Use
`/server` only with commands whose local help documents remote targeting.

<!-- mant:entries role=option case=insensitive -->
- `/dumpstate`: Display effective realm, KDC, password server, flags, and mappings.
- `/listrealmflags`: List realm flags understood by this Windows build.
- `/setrealm`: Set the computer's default Kerberos realm.
- `/mapuser`: Map a Kerberos principal to a Windows account name.
- `/addkdc`: Add a static KDC entry for one realm.
- `/delkdc`: Delete one or all static KDC entries for a realm.
- `/addkpasswd`: Add a Kerberos password-change server for one realm.
- `/delkpasswd`: Delete one or all password-change servers for a realm.
- `/addhosttorealmmap`: Add a host/domain suffix to realm mapping.
- `/delhosttorealmmap`: Delete a host/domain suffix to realm mapping.
- `/setrealmflags`: Replace the complete flag set for a realm.
- `/addrealmflags`: Add selected flags to a realm.
- `/delrealmflags`: Remove selected flags from a realm.
- `/getenctypeattr`: Display configured encryption-type trust attributes.
- `/setenctypeattr`: Set encryption-type trust attributes for a domain/realm.
- `/setcomputerpassword`: Change the local computer account/realm password.
- `/changepassword`: Change a mapped user's Kerberos password.
- `/server`: Select a remote Windows computer for supported KSetup operations.
- `/?`: Display installed syntax.

## Common mistakes

### Treating `ksetup` as an AD-domain configuration tool

`ksetup` primarily changes how one Windows computer locates Kerberos realms
and KDCs. It does not create an AD trust, register a service SPN, generate a
keytab, or prove that a service can decrypt a ticket. Use the matching AD,
DNS, `setspn`, `ktpass`, and service-side evidence for those tasks.

### Mixing a DNS domain, Kerberos realm, and Windows domain name

They can look similar but have different roles. Kerberos realm names are
conventionally uppercase and principal text can be case-sensitive outside
Windows. Preserve the administrator-provided realm exactly; do not derive it
by merely uppercasing an arbitrary host suffix.

### Adding a KDC before checking DNS discovery

Kerberos can discover KDCs through DNS SRV records. A static `/addkdc` entry
is local configuration that can become stale, bypass site-aware discovery,
or mask DNS and trust defects. Capture `/dumpstate`, DNS records, route, time,
and the expected realm design before adding or deleting a server.

### Assuming a successful mapping creates a usable ticket

Realm discovery is only one layer. Time, name canonicalization, cross-realm
trust direction, encryption types, account mapping, SPNs, credentials, and
service keys still determine success. Correlate `klist` with KDC/client event
logs and an exact service request.

### Enabling delegation as a generic connectivity fix

The `delegate` realm flag changes whether credentials can be forwarded. It is
a security decision, not a harmless troubleshooting switch. Require a defined
multi-hop use case and limit delegation through the appropriate identity and
service controls.

### Changing the computer or user password in command history

`/setcomputerpassword` and `/changepassword` accept secret text. They can
invalidate an existing trust or session and expose secrets through process
inspection, transcripts, logs, or shell history. Use an approved secret-safe
workflow with rollback and recovery access.

## PowerShell boundaries

Call `ksetup.exe` explicitly. PowerShell passes `/...` arguments as strings,
but quoting still matters for names containing spaces. Check `$LASTEXITCODE`
and preserve text output; `ksetup.exe` does not emit PowerShell objects.

## Version and platform differences

The command is Windows-only. Supported switches and encryption policies vary
with Windows build, domain/forest level, trust type, and hardening policy.
Remote selection with `/server` changes the target computer; it is not a KDC
selector for an otherwise local query. Check local help and test changes on a
representative disposable client before deployment.

## Related documents

- [klist](klist.md)
- [setspn](setspn.md)
- [ktpass](ktpass.md)
- [w32tm](w32tm.md)
- [nslookup](nslookup.md)

## Sources and license

This original guide was adapted from Microsoft's official
[ksetup reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ksetup).
Operational demand and recurring DNS-discovery, non-AD-realm, host-mapping,
and delegation confusion were cross-checked against a
[practitioner interoperability discussion](https://serverfault.com/questions/1169586/is-there-a-way-to-set-openssh-and-mit-kerberos-on-windows-without-putty).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
