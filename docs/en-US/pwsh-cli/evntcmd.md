<!-- mant:tldr:start -->
# evntcmd

> Review legacy Event-to-SNMP-trap configuration offline before changing destinations or restarting the SNMP service.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/evntcmd.

- Confirm the executable and installed help without applying a file:

`Get-Command evntcmd.exe -ErrorAction SilentlyContinue; evntcmd.exe /?`

- Check whether the legacy SNMP service exists and its current state:

`Get-Service -Name SNMP -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType`

- Review and hash an exact configuration file without applying it:

`Get-Content -LiteralPath "{{C:\Changes\events-to-traps.cnf}}"; Get-FileHash -LiteralPath "{{C:\Changes\events-to-traps.cnf}}" -Algorithm SHA256`

- Inventory the referenced event provider and IDs independently:

`Get-WinEvent -ListProvider "{{Provider name}}" | Select-Object Name, LogLinks`
<!-- mant:tldr:end -->

# evntcmd

## Overview

`evntcmd.exe` applies a configuration file that adds/deletes mappings from
Windows events to SNMP traps and adds/deletes trap destinations. `/s` selects a
computer, `/v 0..10` controls diagnostic verbosity, and `/n` suppresses the
otherwise relevant SNMP service restart. This is mutation-only legacy
integration, not an Event Log query or a modern monitoring pipeline.

## Common mistakes

### Typing `#pragma` lines as shell commands

They are configuration-file records. `add` needs exact log, source, and event
ID; optional count/period changes threshold semantics. Validate current provider
metadata and generate/review the file before application.

### Treating `/n` as no-change mode

It prevents an SNMP restart; configuration is still changed and may not be
effective until the service reloads. Plan service impact and verify end-to-end
trap delivery with a labeled test event.

### Using SNMP community names as secrets

Legacy SNMP community strings are not modern authentication/encryption. Avoid
placing them in broadly readable files/logs and prefer a supported secured
event-forwarding/monitoring design where possible.

### Fan-out without exact target and rollback

The same file can add/delete mappings and destinations across computers.
Preserve existing configuration, ownership, firewall/service state, receiver
identity, and rollback before deployment.

## PowerShell behavior

EvntCmd consumes a file and emits localized native text. Do not pipe pragma
objects to it. Capture stdout/stderr and `$LASTEXITCODE`, then independently
verify service state, configuration, receiver arrival, and source event XML.

## Version and platform differences

This Windows-only command depends on legacy SNMP/Event-to-Trap components that
may be absent. Provider names, event IDs, service installation, firewall,
network policy, and receiver compatibility vary by build and role.

## Related documents

- [wevtutil](wevtutil.md)
- [eventcreate](eventcreate.md)
- [sc](sc.md)

## Sources and license

Adapted as an original guide from Microsoft's [EvntCmd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/evntcmd).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
