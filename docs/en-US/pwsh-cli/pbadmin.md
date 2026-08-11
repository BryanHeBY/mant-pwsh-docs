<!-- mant:tldr:start -->
# pbadmin

> Recognize the deprecated Phone Book Administrator GUI and inventory legacy Connection Manager dependencies before migration.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pbadmin.

- Confirm whether the deprecated executable is present without launching it:

`Get-Command pbadmin.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Search an approved package tree for phone-book artifacts before migration:

`Get-ChildItem -LiteralPath "{{C:\LegacyConnectionManager}}" -File -Recurse | Select-Object FullName, Length, LastWriteTime`

- Hash copied artifacts before inspecting them in an isolated environment:

`Get-FileHash -LiteralPath "{{C:\Evidence\phonebook.pbk}}" -Algorithm SHA256`
<!-- mant:tldr:end -->

# pbadmin

## Overview

`pbadmin.exe` is the deprecated Phone Book Administrator. With no parameters it
starts a GUI used by historical Connection Manager/phone-book workflows. This
page supports discovery and migration of old packages; it does not recommend a
new dial-up/VPN provisioning design.

## Common mistakes

### Opening an untrusted legacy package on a production endpoint

Phone books and related profiles can contain endpoints, routing, scripts,
credentials assumptions, and executable hooks. Copy and hash evidence, inspect
offline, and validate every dependency before import or connection.

### Assuming executable presence means the workflow is supported

Microsoft marks the command deprecated. Determine the owning product, server,
authentication/protocol, client population, security policy, and supported
replacement rather than merely preserving the editor.

### Migrating addresses but not behavior

DNS names, certificates, tunneling/authentication, proxy/routing, scripts,
branding, update channels, and secret storage can be integral. Build a tested
replacement and retire old endpoints/configuration deliberately.

## PowerShell behavior

This is a GUI entry point, not an object-producing CLI. `Start-Process` only
opens it; it cannot prove an artifact was safely parsed, saved, or deployed.

## Version and platform differences

This Windows-only command is deprecated and may be absent. Historical Resource
Kit/Connection Manager documentation and current Windows catalog presence do
not establish support for a particular deployment.

## Related documents

- [cmstp](cmstp.md)

## Sources and license

Adapted as an original retirement guide from Microsoft's [PbAdmin catalog entry](https://learn.microsoft.com/windows-server/administration/windows-commands/pbadmin).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
