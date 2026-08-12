<!-- mant:tldr:start -->
# regini.exe

> Apply a reviewed registry script with no dry-run; export the exact target and preserve ACLs before using RegIni.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/regini.

- Capture installed usage without applying a script; the recorded build has no documented help switch and returns exit code 1 after printing usage:

`$reginiUsage = @(regini.exe 2>&1); $reginiUsageExitCode = $LASTEXITCODE; $reginiUsage; $reginiUsageExitCode`

- Export an exact target key to a new protected path before a separately approved change:

`$backup = "{{C:\Evidence\Product-before.reg}}"; if (Test-Path -LiteralPath $backup) { throw "Refusing to replace $backup" }; reg.exe export "{{HKLM\Software\Vendor\Product}}" $backup; if ($LASTEXITCODE -ne 0) { throw "Registry export failed: $LASTEXITCODE" }; Get-Item -LiteralPath $backup`

- Preserve the target key's current PowerShell ACL view:

`Get-Acl -LiteralPath "{{Registry::HKEY_LOCAL_MACHINE\Software\Vendor\Product}}" | Format-List *`

- Review and hash the exact RegIni input; do not pipe it directly into RegIni:

`Get-Content -LiteralPath "{{C:\Changes\approved-regini.txt}}"; Get-FileHash -LiteralPath "{{C:\Changes\approved-regini.txt}}" -Algorithm SHA256`

- Apply one approved local script and capture the native result immediately:

`regini.exe "{{C:\Changes\approved-regini.txt}}"; $reginiExitCode = $LASTEXITCODE`
<!-- mant:tldr:end -->

# regini.exe

## Overview

`regini.exe` applies one or more ANSI or Unicode text files that create,
modify, or delete registry data and can replace key permissions. It can target
a remote machine with `-m` or an offline hive file/root with `-h`. It has no
documented dry-run or query mode; use `reg.exe`, the Registry provider, and
ACL tools for inventory and backup.

## Input model

<!-- mant:entries role=command case=insensitive -->
- `regini.exe`: Apply a line-oriented registry mutation script.

RegIni has no dry-run mode; bracketed permissions replace ACL state rather than
adding to it.

<!-- mant:entries role=option case=insensitive -->
- `-m`: Select a remote computer for registry mutation.
- `-h`: Select an offline hive file and root mapping.
- `-i N`: Set the output indentation multiple; the default is four.
- `-o WIDTH`: Set output width; redirected output otherwise defaults to 240 characters on the recorded build.
- `-b`: Enable legacy RegIni parser compatibility, including older continuation and quoted-string behavior; this is not a backup, preview, or safety mode.

RegIni scripts can use kernel registry paths such as `\Registry\Machine` and
the complete user-mode prefixes `HKEY_LOCAL_MACHINE`, `HKEY_USERS`,
`HKEY_CURRENT_USER`, and `USER:` exposed by installed help. They do not consume
PowerShell Registry-provider syntax such as `HKLM:\Software`. Indentation
describes a key tree; comments must have a semicolon as the first nonblank
character, and a trailing backslash continues a line. Permissions are numeric
identities from the historical RegIni format.

## Common mistakes

### Treating bracketed permissions as additions

Microsoft warns that RegIni replaces the current key permissions rather than
editing them. A short numeric list can remove inherited or explicit access and
lock out Windows, services, installers, or administrators. Preserve the full
security descriptor and verify recovery access before applying it.

### Mixing PowerShell provider paths, user-mode roots, and kernel paths

`HKEY_LOCAL_MACHINE` maps to `\Registry\Machine`; `HKEY_CURRENT_USER` maps to
the caller's SID below `\Registry\User`. Current RegIni accepts those complete
user-mode prefixes, but not PowerShell's `HKLM:\` drive syntax. Confirm the
exact caller/security context, root spelling, remote/offline mapping, and
registry view rather than mechanically translating or shortening a prefix.

### Treating usage output as successful help

On the recorded build, bare `regini.exe` or `regini.exe /?` prints usage to the
native error stream and exits 1 because no help switch is documented. Preserve
the text and status separately. Do not normalize every exit 1 to success, and
never pass a placeholder text file merely to obtain more parser details.

An exact asynchronous raw-stream capture on Windows NT `10.0.26200.0`,
System32 file version `10.0.26100.5074`, found 127 nonempty standard-error
usage lines, zero standard-output lines, and exit 1 for a bare invocation. No
script path, registry root, remote computer, offline hive, key, value, ACL, or
mutation was supplied. Counts taken after PowerShell `2>&1` can differ because
native diagnostics may be wrapped as PowerShell error records.

### Assuming `-b`, `-i`, or `-o` reduces mutation risk

`-i` and `-o` affect presentation. `-b` relaxes parsing for older RegIni input,
including continuation and quoting rules. None provides a dry run, transaction,
backup, narrower registry target, or permission safeguard.

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

## PowerShell boundaries

RegIni consumes file paths and native text, not pipeline objects. Quote each
path, preserve the exact input hash, stdout/stderr, and `$LASTEXITCODE`, then
query every intended value and ACL through an independent supported interface.

## Version and platform differences

This is Windows-only. Registry redirection, virtualization, protected keys,
service identities, offline-hive roots, remote access, and historical RegIni
permission-number documentation vary by version and architecture.

## Runtime evidence

On Windows NT 10.0.26200.0, bare regini.exe and regini.exe /? returned 1; no
documented help switch exists. A concurrent raw-stream capture of exact
System32 file version 10.0.26100.5074 bare usage found 127 nonempty stderr
lines and zero stdout lines. The earlier 153 count came from
PowerShell-merged/rendered diagnostics and is not a raw logical-line count.
Installed usage exposed -i, -o and -b plus HKEY_LOCAL_MACHINE, HKEY_USERS,
HKEY_CURRENT_USER and USER: prefixes.

## Related documents
- [reg.exe](reg.exe.md)
- [regsvr32.exe](regsvr32.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[RegIni reference](https://learn.microsoft.com/windows-server/administration/windows-commands/regini)
and current [registry value/permission article](https://learn.microsoft.com/troubleshoot/windows-client/application-management/change-registry-values-permissions).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
