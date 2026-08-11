<!-- mant:tldr:start -->
# server-telemetry

> Query legacy Windows Server CEIP and error-reporting choices before changing organization-governed diagnostic data collection.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/serverweroptin.

- Query the legacy Customer Experience Improvement Program setting:

`serverceipoptin.exe /query; $ceipExitCode = $LASTEXITCODE`

- Query the legacy Windows Error Reporting submission setting:

`serverweroptin.exe /query; $werExitCode = $LASTEXITCODE`

- Inventory Windows Error Reporting service state separately:

`Get-Service -Name WerSvc -ErrorAction SilentlyContinue | Select-Object Status, StartType`

- Inspect effective policy paths without changing them:

`reg.exe query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /s`
<!-- mant:tldr:end -->

# server-telemetry

## Overview

This page covers `serverceipoptin` (`/query`, `/enable`, `/disable`) and
`serverweroptin` (`/query`, `/summary`, `/detailed`). They expose historical
Windows Server choices for CEIP participation and automatic Windows Error
Reporting. Effective modern diagnostic-data/error-reporting behavior can also
be governed by edition, policy, servicing, endpoint management, privacy and
network configuration.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `serverceipoptin.exe`: Query or change historical Server CEIP participation.
- `serverweroptin.exe`: Query or configure historical Windows Error Reporting detail.

The similarly named programs expose different modes and policy boundaries.

<!-- mant:entries role=option case=insensitive -->
- `/query`: Display the local tool's current telemetry/reporting setting.
- `/enable`: Enable historical Server CEIP participation.
- `/disable`: Disable historical Server CEIP participation.
- `/summary`: Select summary Windows Error Reporting data.
- `/detailed`: Select detailed Windows Error Reporting data.
- `/?`: Display installed tool-specific syntax.

## Common mistakes

### Treating one local query as effective organization policy

Correlate local state with domain/MDM policy, edition/build, WER service,
corporate error-reporting endpoints, consent, firewall/proxy, and management
baseline. Policy can override or make the legacy switch irrelevant.

### Equating summary/detailed with harmless volume choices

Reports and dumps can contain paths, command lines, memory, documents, identities,
network data, and secrets. Establish legal/privacy purpose, access, retention,
redaction and destination before automatic submission.

### Disabling reporting to fix an application crash

That removes evidence rather than correcting the cause. Preserve events/dumps
under approved policy and diagnose the failing component separately.

### Enabling participation from an isolated script

Telemetry choices are organization-level governance decisions, not an agent's
local optimization. Use managed policy and record authority/change evidence.

## PowerShell boundaries

Both are native query/mutation tools with localized text. Capture
`$LASTEXITCODE` immediately. Registry/service inventory is supporting evidence;
do not infer successful upload or effective policy from one layer.

## Version and platform differences

Windows diagnostic data and WER evolved substantially after these Server-era
commands. Command presence and catalog applicability do not establish that the
switch controls every current collection/submission path.

## Related documents

- [wevtutil.exe](wevtutil.exe.md)
- [sc.exe](sc.exe.md)

## Sources and license

Adapted as an original guide from Microsoft's [ServerCEIPOptin](https://learn.microsoft.com/windows-server/administration/windows-commands/serverceipoptin)
and [ServerWEROptin](https://learn.microsoft.com/windows-server/administration/windows-commands/serverweroptin)
references. Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
