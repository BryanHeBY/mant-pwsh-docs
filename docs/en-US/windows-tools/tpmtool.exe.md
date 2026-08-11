<!-- mant:tldr:start -->
# tpmtool.exe

> Inspect Trusted Platform Module state and collect protected diagnostic evidence; this tool does not clear, initialize, or take ownership of a TPM.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tpmtool.

- Display basic TPM device and readiness information without changing TPM state:

`tpmtool.exe getdeviceinformation`

- Display installed syntax before relying on a subcommand from another Windows build:

`tpmtool.exe /?`

- Collect TPM event, information, and measured-boot logs into a new access-controlled case directory:

`tpmtool.exe gatherlogs "{{C:\Support\Case-123\TPM}}"`

- Start driver tracing only for one approved reproduction; run the matching stop command even when reproduction fails:

`tpmtool.exe drivertracing start`

- Stop driver tracing and then protect the `TPMTRACE.etl` created in the current directory:

`tpmtool.exe drivertracing stop`

<!-- mant:tldr:end -->

# tpmtool.exe

## Overview

`tpmtool.exe` reports basic Trusted Platform Module information, gathers TPM
and measured-boot logs, and starts/stops TPM driver tracing. Its documented
surface is diagnostic: it does not clear, initialize, provision, take ownership
of, or change firmware settings for the TPM.

TPM state is part of BitLocker, Windows Hello, measured boot, attestation, and
other security workflows, but one status flag is not a diagnosis of all of
them. Record Windows/build, firmware, physical or virtual TPM identity,
virtualization/security policy, boot mode, recent changes, and the failing
workload together with the output.

## Output and evidence

<!-- mant:entries role=command case=insensitive -->
- `tpmtool.exe`: Query TPM device information or gather TPM diagnostic logs/traces.
- `getdeviceinformation`: Display TPM readiness and device information.
- `gatherlogs`: Collect TPM logs into an explicit protected output directory.
- `drivertracing`: Start or stop TPM driver tracing according to the supplied mode.

The tool exposes diagnostics, not clear/initialize ownership operations.

`getdeviceinformation` displays readiness fields whose bit meanings are defined
by the `Win32_Tpm::IsReadyInformation` contract. Preserve the raw output; do
not infer undocumented flag names or remediation from a numeric value.

`gatherlogs` creates the requested directory if it does not exist. Depending on
the machine, output can include `TpmEvents.evtx`, `TpmInformation.txt`, and SRTM
or DRTM boot/resume data. Driver tracing writes `TPMTRACE.etl` to the current
directory, making the launch location part of the evidence and capacity plan.

These artifacts can reveal device identity, security posture, measured-boot
state, event timing, and configuration. Store them in a newly created,
least-privilege directory; hash, transmit, retain, and delete them according to
the incident/support policy.

## Common mistakes

### Searching for a clear or initialize option in `tpmtool`

Those are not documented `tpmtool` operations. Do not substitute firmware UI,
WMI, PowerShell, or vendor commands without a separate recovery plan. Clearing
a TPM can make protected data or credentials unavailable; escrow BitLocker and
other recovery material and follow the owning product's supported procedure.

### Treating one readiness value as a complete health result

Decode flags using the exact Microsoft contract and applicable build. Correlate
event logs, firmware/BIOS state, TPM specification/version, driver, attestation,
BitLocker/Hello state, virtualization, and a fresh reproduction.

### Gathering into the current or public directory

The default destination is the current directory, and Microsoft's example of a
public path is not a data-protection recommendation. Use a new access-controlled
case directory with sufficient capacity and verify every generated artifact.

### Leaving driver tracing active

Trace sessions consume resources and can capture security-sensitive details.
Use a short reproduction, execute `drivertracing stop` in cleanup, verify the
ETL timestamp/size, and escalate through supported tracing controls if normal
stop fails rather than repeatedly starting sessions.

### Assuming absence means no TPM

Command availability, elevation, edition, firmware settings, remote context,
virtual TPM configuration, and device policy can all affect results. Record the
exact executable and error; do not tell a user to clear or replace hardware
from one missing command or empty field.

### Collecting after state-changing remediation

Firmware updates, TPM clear/provision, credential reset, BitLocker protector
changes, and reboot can erase or transform the evidence. Gather read-only state
and recovery material before approved changes whenever possible.

## PowerShell boundaries

Invoke `tpmtool.exe` explicitly and capture raw native output plus
`$LASTEXITCODE`; the output is not documented as a stable structured schema.
Create the destination with explicit ACLs before collection when possible, and
use a controlled current directory for driver tracing because its filename is
fixed by the utility.

## Version and platform differences

This Windows-only utility applies to supported Windows client and server
releases where it is present. Output, fields, elevation, virtual TPM behavior,
measured-boot files, and trace support depend on Windows, firmware, hardware,
boot mode, virtualization, and policy.

## Related documents

- [manage-bde.exe](manage-bde.exe.md)
- [eventvwr.msc](eventvwr.msc.md)
- [wevtutil.exe](wevtutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[TPMTool reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tpmtool)
and the linked
[Win32_Tpm readiness contract](https://learn.microsoft.com/windows/win32/secprov/win32-tpm-isreadyinformation).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
