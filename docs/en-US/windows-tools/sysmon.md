<!-- mant:tldr:start -->
# sysmon

> Inspect Sysmon's implementation, service, schema, configuration, and event channel before any installation or reconfiguration.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/sysmon.

- Resolve the executable and inspect signature/version to distinguish built-in and standalone deployments:

`Get-Command sysmon.exe -All -ErrorAction SilentlyContinue | ForEach-Object { Get-AuthenticodeSignature $_.Source; Get-Item $_.Source | Select-Object FullName, VersionInfo }`

- Check for an installed Sysmon service without installing either implementation:

`Get-Service -Name 'Sysmon*' -ErrorAction SilentlyContinue | Select-Object Name, DisplayName, Status, StartType`

- Print the executable's current configuration without applying a file:

`sysmon.exe -c`

- Print the latest supported configuration schema:

`sysmon.exe -s`

- Read a bounded set of existing events from the operational channel:

`Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-Sysmon/Operational' } -MaxEvents {{20}}`
<!-- mant:tldr:end -->

# sysmon

## Overview

Sysmon installs a Windows service and driver that record selected system
activity to `Microsoft-Windows-Sysmon/Operational`. It produces telemetry; it
does not analyze, alert on, or block activity. Starting in February 2026,
Microsoft provides built-in Sysmon as an optional Windows 11 feature. The
standalone Sysinternals distribution remains a different delivery route, and
Microsoft states that built-in and standalone Sysmon cannot coexist.

## Lifecycle and syntax

<!-- mant:entries role=command case=insensitive -->
- `sysmon.exe`: Install, configure, inspect, or uninstall built-in Windows Sysmon.

This page covers built-in Sysmon and must not be mixed with standalone Sysinternals syntax.

<!-- mant:entries role=option case=insensitive -->
- `-i`: Install Sysmon, optionally with a reviewed configuration file.
- `-c`: Display current configuration or replace/reset it when an operand follows.
- `-s`: Display the current or all supported event schemas.
- `-m`: Install the Sysmon event manifest.
- `-u`: Uninstall Sysmon; optional `force` broadens cleanup.
- `-?`: Display installed built-in syntax.

`-i [config]` installs, `-c` without a file dumps current configuration,
`-c <config>` changes it, `-s [version|all]` prints schemas, `-m` installs the
event manifest, and `-u [force]` uninstalls. `sysmon -c --` resets configuration
to defaults; it is a mutation, not a way to display defaults.

Before choosing built-in or standalone delivery, inventory the exact Windows
build, optional-feature state, executable path/signature/version, service/driver,
event channel, existing configuration, downstream collection, and ownership.

## Common mistakes

### Installing built-in Sysmon over standalone Sysmon

Coexistence is unsupported. Inventory and plan a supported migration including
configuration, event continuity, service/driver removal, validation, and rollback.
Do not decide implementation from the command name alone.

### Installing with defaults and claiming useful coverage

Sysmon is disabled until installed/configured. Useful security telemetry depends
on an intentional XML rule set, event IDs, include/exclude logic, hashes,
environment baselines, storage/forwarding capacity, and detection consumers.

### Reversing include and exclude behavior

A syntactically valid XML file can silently collect too much or too little.
Validate against the executable's schema, review every rule group, test known
positive/negative events, and observe ingestion volume before broad rollout.

### Using `-c --` as a harmless query

That form resets configuration. Use `-c` alone to dump current configuration.
Back up the effective configuration and preserve evidence before any change.

### Treating event absence as proof an action did not occur

Absence can mean the event type was disabled/excluded, the driver/service was
not active, events were dropped/cleared/overwritten, collection lagged, or a
different schema/version applied. Correlate configuration and channel health.

### Forgetting privacy and credential exposure

Process command lines, hashes, network destinations, DNS, clipboard/archive or
file events can contain sensitive data. Apply least collection, access control,
retention, forwarding, and incident-handling policy.

## PowerShell boundaries

Sysmon is a native text command; configuration output is not a PowerShell
object. Preserve stdout/stderr and `$LASTEXITCODE`. Use `Get-WinEvent` for typed
event records and inspect raw XML when fields or schema versions matter.

## Version and platform differences

Built-in Sysmon requires a supported Windows 11 build and optional feature.
Standalone Sysinternals Sysmon has its own version and distribution lifecycle.
Schemas, event IDs/fields, architecture, configuration support, and service
names can vary; record the actual executable and schema with each deployment.

## Related documents

- [wevtutil](wevtutil.md)
- [wecutil](wecutil.md)
- [sc](sc.md)

## Sources and license

This original guide was adapted from Microsoft's current
[built-in Sysmon command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/sysmon),
[enable/configure guide](https://learn.microsoft.com/windows/security/operating-system-security/sysmon/how-to-enable-sysmon),
and [Sysinternals catalog](https://learn.microsoft.com/sysinternals/downloads/).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
