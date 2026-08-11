<!-- mant:tldr:start -->
# tsecimp.exe

> Inventory TAPI providers/line assignments and validate a reviewed XML file before importing any server-security changes.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tsecimp.

- Resolve the exact command without changing TAPI security:

`Get-Command tsecimp.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Display installed providers, line devices, addresses, and assigned users:

`tsecimp.exe /d`

- Hash and parse the exact XML locally before tool validation:

`Get-FileHash -LiteralPath "{{C:\Tapi\assignments.xml}}" -Algorithm SHA256; [xml]$xml = Get-Content -LiteralPath "{{C:\Tapi\assignments.xml}}" -Raw; $xml.UserList.User | Select-Object DomainUserName,FriendlyName`

- Validate XML structure without importing it:

`tsecimp.exe /f "{{C:\Tapi\assignments.xml}}" /v; $LASTEXITCODE`
<!-- mant:tldr:end -->

# tsecimp.exe

## Overview

`tsecimp.exe` imports XML user-to-TAPI-line assignment information into the
TAPI server security file (`Tsec.ini`). `/d` inventories providers/devices and
assignments; `/f <file> /v` validates XML structure without import; `/f <file>
/u` checks domain membership and may be slow. Plain `/f <file>` is a mutation.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `tsecimp.exe`: Display or import TAPI server security assignments from XML.

Plain `/f` imports; only `/f` combined with `/v` is validation-only.

<!-- mant:entries role=option case=insensitive -->
- `/d`: Display current TAPI providers, devices, and assignments.
- `/f`: Select the XML security file and import unless `/v` is also present.
- `/v`: Validate selected XML structure without importing assignments.
- `/u`: Check referenced domain users and potentially contact domain services.
- `/?`: Display installed syntax.

## Common mistakes

### Running `/f` after “just checking” the XML

Only `/v` is documented as validation without import. Perform independent XML
parsing and diff, then `/v`; never drop `/v` until assignment changes, rollback,
service impact and affected users are approved.

### Overlooking `NoMerge` or an absent `LineList`

`NoMerge` removes a user's current assignments before applying the file. A User
element without `LineList` removes all line devices for that user. Produce an
explicit per-user before/after set; visual indentation is not a safety check.

### Treating an Address, PermanentID, friendly name, and provider as interchangeable

Bind each line to its provider, stable PermanentID where available, addresses,
current users and physical/telephony owner. Microsoft notes that unavailable
devices can fail without an error, so import success is not assignment health.

### Using `/u` as a cheap offline syntax check

It checks domain membership and requires network connectivity; large input can
be slow. DNS/DC reachability, trusts and stale users affect results. Use `/v`
for structure and a separately bounded directory inventory for identities.

### Publishing `/d` output or XML casually

Provider, line, address and domain-user mappings are sensitive communications
topology. Protect collection, restrict access/retention and redact only copies
while preserving original evidence.

## PowerShell boundaries

Call `tsecimp.exe` explicitly and capture `$LASTEXITCODE`. `[xml]` proves XML
well-formedness, not TSec schema semantics or safe intent. Use `-LiteralPath`,
raw reads and a recorded SHA-256; do not generate XML with string concatenation
from untrusted identity/device data.

## Version and platform differences

Windows-only legacy TAPI server administration. Provider/device availability,
domain behavior and whether the role is meaningful vary by server build and
installed telephony software. Validate installed help and product support.

## Related documents

- [sc.exe](sc.exe.md)
- [certutil.exe](certutil.exe.md)
- [whoami.exe](whoami.exe.md)
- [netdom.exe](netdom.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tsecimp reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tsecimp).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
