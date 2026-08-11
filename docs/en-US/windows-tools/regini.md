<!-- mant:tldr:start -->
# regini

> Apply a reviewed registry script with no dry-run; export the exact target and preserve ACLs before using RegIni.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/regini.

- Read installed syntax without applying a script:

`regini.exe /?`

- Export an exact target key before a separately approved change:

`reg.exe export "{{HKLM\Software\Vendor\Product}}" "{{C:\Evidence\Product-before.reg}}" /y`

- Preserve the target key's current PowerShell ACL view:

`Get-Acl -LiteralPath "{{Registry::HKEY_LOCAL_MACHINE\Software\Vendor\Product}}" | Format-List *`

- Review and hash the exact RegIni input; do not pipe it directly into RegIni:

`Get-Content -LiteralPath "{{C:\Changes\approved-regini.txt}}"; Get-FileHash -LiteralPath "{{C:\Changes\approved-regini.txt}}" -Algorithm SHA256`

- Apply one approved local script and capture the native result immediately:

`regini.exe "{{C:\Changes\approved-regini.txt}}"; $reginiExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# regini

## Overview

`regini.exe` applies one or more ANSI or Unicode text files that create,
modify, or delete registry data and can replace key permissions. It can target
a remote machine with `-m` or an offline hive file/root with `-h`. It has no
documented dry-run or query mode; use `reg.exe`, the Registry provider, and
ACL tools for inventory and backup.

## Input model

RegIni scripts use kernel registry paths such as `\Registry\Machine`, not
ordinary `HKLM:` PowerShell paths. Indentation describes a key tree; comments
must have a semicolon as the first nonblank character, and a trailing backslash
continues a line. Permissions are numeric identities from the historical
RegIni format.

## Common mistakes

### Treating bracketed permissions as additions

Microsoft warns that RegIni replaces the current key permissions rather than
editing them. A short numeric list can remove inherited or explicit access and
lock out Windows, services, installers, or administrators. Preserve the full
security descriptor and verify recovery access before applying it.

### Mixing HKLM syntax with kernel paths

`HKEY_LOCAL_MACHINE` maps to `\Registry\Machine`; `HKEY_CURRENT_USER` maps to
the current user's SID below `\Registry\User`. Confirm the exact user/security
context and registry view rather than mechanically translating a prefix.

### Assuming the file is declarative and idempotent

Deletes, value types, continuations, indentation, encoding, and ACL replacement
can make repeated runs destructive or context-dependent. Review a rendered
diff against an approved disposable/test hive before production.

### Using `-m` with broad credentials and no recovery channel

Remote registry/service/firewall/authentication state and architecture can
change the target or fail mid-application. Prefer managed configuration with
auditing and rollback; never put credentials in the file or command line.

### Importing untrusted `.reg` or RegIni text because it is readable

Registry changes can establish code execution, disable security, redirect
components, or damage startup. Validate provenance, signature/hash, every key,
value type/data, ACL, view, scope, and rollback.

## PowerShell behavior

RegIni consumes file paths and native text, not pipeline objects. Quote each
path, preserve the exact input hash, stdout/stderr, and `$LASTEXITCODE`, then
query every intended value and ACL through an independent supported interface.

## Version and platform differences

This is Windows-only. Registry redirection, virtualization, protected keys,
service identities, offline-hive roots, remote access, and historical RegIni
permission-number documentation vary by version and architecture.

## Related documents

- [reg](reg.md)
- [regsvr32](regsvr32.md)

## Sources and license

This original guide was adapted from Microsoft's official
[RegIni reference](https://learn.microsoft.com/windows-server/administration/windows-commands/regini)
and current [registry value/permission article](https://learn.microsoft.com/troubleshoot/windows-client/application-management/change-registry-values-permissions).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
