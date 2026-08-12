<!-- mant:tldr:start -->
# dsregcmd.exe

> Inspect Microsoft Entra device registration, user, SSO, and join diagnostics.
> More information: https://learn.microsoft.com/entra/identity/devices/troubleshoot-device-dsregcmd.

- Show registration state in the affected user's session:

`dsregcmd.exe /status`

- Include diagnostic context while reproducing a join problem:

`dsregcmd.exe /status /debug`

- Refresh the current user's Primary Refresh Token when instructed by identity support:

`dsregcmd.exe /refreshprt`
<!-- mant:tldr:end -->

# dsregcmd.exe

## Overview

`dsregcmd.exe` diagnoses and manages Windows device registration with Microsoft
Entra ID. Its `/status` report combines device, tenant, current-user, SSO,
diagnostic, and Windows Hello prerequisite state. Values depend on user,
elevation, network, join type, and whether the command runs interactively or as
SYSTEM.

## Common switches

<!-- mant:entries role=option case=insensitive -->
- `/status`: Display device, tenant, user, SSO, diagnostic, and NGC prerequisite sections.
- `/debug`: Add detailed diagnostic messages to a supported operation.
- `/join`: Trigger a device-registration join attempt; normally orchestration and scheduled tasks own this mutation.
- `/leave`: Remove the local device registration; this is disruptive and requires an approved rejoin/recovery plan.
- `/refreshprt`: Request refresh of the current user's Primary Refresh Token.
- `/forcerecovery`: Start an interactive registration recovery flow where supported.
- `/?`: Display the switches implemented by this Windows build.

Microsoft's troubleshooting reference primarily documents `/status` output.
Mutation and recovery switches are build- and workflow-sensitive; use local
help plus the applicable Entra deployment runbook before invoking them.

## Read `/status` in context

Run it in the affected user's interactive session for user and SSO evidence:

```powershell
$report = dsregcmd.exe /status
$code = $LASTEXITCODE
if ($code -ne 0) { throw "dsregcmd status failed: $code" }
$report | Set-Content -LiteralPath .\dsregcmd-status.txt -Encoding utf8
```

Key sections include:

- Device State: `AzureAdJoined`, `EnterpriseJoined`, and `DomainJoined` combine
  to describe Entra joined, hybrid joined, domain joined, or on-premises DRS
  state; no single flag tells the whole story.
- Device Details and Tenant Details: device ID, certificate, tenant identity,
  endpoints, and authentication metadata.
- User State and SSO State: Windows Hello and PRT-related state for the current
  user. An elevated prompt can represent a different user context.
- Diagnostic Data and NGC Prerequisite Check: join-phase errors and prerequisite
  evaluations whose applicability depends on current state.

The report is human-readable and changes across Windows builds. For durable
fleet automation, use supported Entra/Graph, MDM, event, or registry contracts
rather than parsing headings and spacing.

## Privacy and sharing

The output can contain tenant and device identifiers, certificate thumbprints,
user/domain identity, URLs, correlation IDs, timestamps, and diagnostic error
context. Store it as support data, redact only after preserving a protected
original, and do not paste an unreviewed report into public issues or prompts.

## Join and recovery boundaries

`/join`, `/leave`, and `/forcerecovery` change registration or authentication
state and can disrupt conditional access, SSO, management, certificate, and
Windows Hello workflows. Prefer the supported scheduled task, Settings flow,
Autopilot/MDM process, or administrator runbook. Capture existing state and
ensure the exact rejoin path and credentials are available before leaving.

## PowerShell considerations

Output is native localized text, not objects. Capture stdout and
`$LASTEXITCODE` immediately; avoid `Select-String` as the sole compliance
decision. `Start-Process -Verb RunAs` changes user/elevation context and can
make a comparison invalid unless that context is the point of the test.

## Common mistakes

### Running elevated and interpreting the current user's SSO state

Elevation can switch the effective interactive context. Reproduce in the
affected user's ordinary session, then use an administrator/SYSTEM capture
only for the fields that explicitly require it.

### Treating `AzureAdJoined : YES` as the complete join classification

Interpret it together with `DomainJoined` and `EnterpriseJoined`, plus tenant
and diagnostic evidence.

### Using `/leave` as first-line troubleshooting

It destroys registration state and can make access worse. Diagnose error phase,
network, discovery, certificates, policy, time, and scheduled-task evidence
before an approved leave/rejoin procedure.

## Version and availability

`dsregcmd.exe` ships with supported Windows client and server builds, but output
fields and recovery switches evolve. Entra join type, Windows edition, account,
policy, network, Web Account Manager, and management stack change results.
Record OS build, command context, timestamp, and `dsregcmd.exe /?` output.

## Verification boundary

Official output-field semantics and common switch roles were reviewed. No
device or tenant report was collected, no identifier was handled, and no join,
leave, PRT refresh, recovery UI, scheduled task, or identity mutation ran.

## Related documents

- [whoami.exe](whoami.exe.md)
- [gpresult.exe](gpresult.exe.md)
- [certutil.exe](certutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[dsregcmd troubleshooting reference](https://learn.microsoft.com/entra/identity/devices/troubleshoot-device-dsregcmd)
and related Microsoft Entra device-registration guidance. Exact upstream
revision and paths are recorded in `upstream/windows-tools.json`.

The cited documentation repository is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
