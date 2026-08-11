<!-- mant:tldr:start -->
# pubprn.vbs

> Prepare exact shared-printer and AD-container identity before publishing a queue in Active Directory.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pubprn.

- Locate every installed language copy of the inbox script:

`Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter pubprn.vbs -Recurse | Select-Object -ExpandProperty FullName`

- Display the selected script's help without publishing anything:

`cscript.exe //NoLogo "{{C:\Windows\System32\Printing_Admin_Scripts\en-US\pubprn.vbs}}" /?`

- Verify the exact shared queue and publication state on its print server:

`Get-Printer -ComputerName "{{PRINT01}}" -Name "{{Queue Name}}" | Format-List Name,ComputerName,ShareName,Shared,Published,DriverName,PortName`

- Resolve the intended AD container to one distinguished name before any publish operation (requires ActiveDirectory):

`Get-ADObject -Identity "{{OU=Printers,DC=example,DC=com}}" | Select-Object DistinguishedName,ObjectClass,ObjectGUID`
<!-- mant:tldr:end -->

# pubprn.vbs

## Overview

`pubprn.vbs` creates printer publication objects in AD DS for all shared
printers on a server or for one UNC printer path. It is a localized VBScript
invoked through `cscript.exe`. The operational form mutates the directory, so
the TLDR stops at identity and prerequisite checks.

## Invocation boundary

<!-- mant:entries role=command case=insensitive -->
- `pubprn.vbs`: Publish one shared printer or all server printers into AD DS.

Both the server/UNC target and exact LDAP container are positional operands;
the server form broadens publication to every qualifying shared printer.

<!-- mant:entries role=option case=insensitive -->
- `/?`: Display installed script syntax.

## Common mistakes

### Passing a server when only one queue was intended

A server argument publishes all qualifying printers on that server; a UNC path
selects one shared queue. Enumerate and approve the expansion before execution.

### Guessing the LDAP container string

Use the exact distinguished name and object GUID. `CN=`, `OU=`, escaping,
domain components, permissions, and delegated administration are not
interchangeable. Preserve existing printQueue objects and collision evidence.

### Confusing queue sharing with AD publication

A local queue must have an appropriate share/UNC identity for clients, while
AD publication is a separate discoverability object. Publication success does
not prove driver deployment, client authorization, Point and Print policy, DNS,
or physical device health.

### Leaving stale directory objects after queue migration

Server/queue rename or replacement can strand duplicate discovery entries.
Define ownership, replication verification, client cutover, and stale-object
cleanup before creating another publication.

### Treating publication metadata as nonsensitive

Names, locations, capabilities, and server topology become searchable. Review
least disclosure and ACLs; do not publish an internal or sensitive device as a
diagnostic test.

## PowerShell boundaries

Invoke the selected `.vbs` with `cscript.exe //NoLogo`; use `$env:WINDIR`.
Quote the full LDAP URI as one argument and check `$LASTEXITCODE`. Prefer typed
AD/PrintManagement queries for pre/post verification.

## Version and platform differences

Windows/AD DS only. Script language path, schema/replication, delegated rights,
print-server roles, client discovery, and Point and Print controls vary by
environment.

## Related documents

- [prnmngr.vbs](prnmngr.vbs.md)
- [prncnfg.vbs](prncnfg.vbs.md)
- [setspn.exe](setspn.exe.md)
- [cscript.exe](cscript.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[pubprn reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pubprn).
Per-user/per-computer and directory-visible printer inventory demand was
cross-checked against a [printer-scope discussion](https://serverfault.com/questions/419866/list-all-printers-using-powershell).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
