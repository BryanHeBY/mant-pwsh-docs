<!-- mant:tldr:start -->
# printmanagement.msc

> Open Print Management for an explicitly identified print server, queue, driver, port, or job; use PrintManagement cmdlets for typed, repeatable inventory and changes.
> More information: https://learn.microsoft.com/powershell/module/printmanagement/.

- Resolve the console file when the component is installed:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\printmanagement.msc') -ErrorAction Stop`

- Open Print Management in the current interactive session:

`Start-Process printmanagement.msc`

- Inventory queues as objects without changing print state:

`Get-Printer | Select-Object ComputerName, Name, DriverName, PortName, Shared, Published`
<!-- mant:tldr:end -->

# printmanagement.msc

## Overview

`printmanagement.msc` opens the Print Management MMC console where available.
It can manage local or remote print servers, queues, drivers, ports, forms,
filters, deployment, and jobs. The console/component is not present on every
Windows edition, installation option, role, or capability state.

Printing objects have distinct identities and blast radii. A queue is not its
driver package, port, device, share, published directory object, current job,
Spooler service, or client connection.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `printmanagement.msc`: Open Print Management for an explicitly identified local or remote print-server scope.

No supported parameter interface is documented here. Do not infer that a
missing file is Spooler corruption; first inventory edition, roles, features,
capabilities, RSAT/management tools, and installation option.

## What to preserve

Before a change, record the server, queue/share names, driver name/version/
architecture/package/signature, port/monitor/address/protocol, processor and
data type, configuration/defaults, permissions, deployment/publishing owner,
dependent clients, active jobs, Spooler/events, and tested export or rollback.

Driver removal, queue deletion, port changes, job cancellation, and Spooler
restart are disruptive operations, not diagnostic prerequisites.

## Common mistakes

- Removing a driver package while queues or clients still depend on it, or
  confusing a similarly named v3/v4, architecture, model, or vendor package.
- Deleting/recreating a queue before preserving its share, ACLs, defaults,
  forms, ports, deployment policy, jobs, and client dependencies.
- Treating restart of the Print Spooler as harmless; it affects every queue/job
  served by that service and can destroy transient evidence.
- Assuming network discovery identifies the intended device securely; verify
  address, protocol, certificate/identity, port monitor, driver, and scope.
- Parsing localized console rows or `Win32_Printer` text instead of using typed
  PrintManagement cmdlets and exact names.
- Copying an optional-capability installation command from a forum without
  checking edition/build applicability, source policy, elevation, and servicing
  state first.

## PowerShell behavior

`Start-Process printmanagement.msc` launches the console and returns no printer
objects. Use `Get-Printer`, `Get-PrinterDriver`, `Get-PrinterPort`, and
`Get-PrintJob` for typed inventory. Mutation cmdlets require an exact target,
authorization, dependency review, rollback, and post-change verification.

## Version and platform differences

`printmanagement.msc` is Windows-only and may be absent. Console, Print Server
role, management tools, optional capability, cmdlets, remote behavior, and
driver model support vary by client/server edition, build, installation option,
architecture, policy, and installed roles/features.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` did not resolve the exact
`printmanagement.msc` entry point. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. Local absence is availability evidence for this
host, not proof that the documented component is unavailable on another Windows
edition, role, or optional-feature set; it does not prove that the UI loads,
the current user is authorized, an optional snap-in or component is functional,
or any displayed or requested operation succeeds.

## Related documents
- [prnmngr.vbs](prnmngr.vbs.md)
- [prndrvr.vbs](prndrvr.vbs.md)
- [prnport.vbs](prnport.vbs.md)
- [rundll32 printui](rundll32-printui.md)

## Sources and license

This original guide was adapted from Microsoft's
[PrintManagement module reference](https://learn.microsoft.com/powershell/module/printmanagement/),
[Print Management console troubleshooting](https://learn.microsoft.com/troubleshoot/windows-client/printing/cannot-install-secure-web-services-on-devices),
and [Server Core roles/features matrix](https://learn.microsoft.com/windows-server/administration/server-core/server-core-roles-and-services).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
