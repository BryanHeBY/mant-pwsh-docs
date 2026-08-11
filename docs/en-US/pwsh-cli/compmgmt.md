<!-- mant:tldr:start -->
# compmgmt

> Open Computer Management for deliberate interactive administration; resolve the local/remote target and use the dedicated CLI page for each change so scope, status, rollback, and verification stay explicit.
> More information: https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/error-connect-device-manager-remotely.

- Open the Computer Management MMC console for the local computer:

`compmgmt.msc`

- Launch the console explicitly through Microsoft Management Console:

`mmc.exe compmgmt.msc`
<!-- mant:tldr:end -->

# compmgmt

## Overview

Computer Management is an MMC console aggregating Task Scheduler, Event Viewer,
Shared Folders, local users/groups, performance, Device Manager, Disk Management,
services and other snap-ins. It is a broad administrative surface, not one atomic
command; permissions and targets can differ between contained snap-ins.

## Common mistakes

- Connecting the console to one remote computer and assuming every snap-in uses
  that target, identity, transport, firewall path, feature set and authorization.
- Making a disk/service/account/share/task/event change without a dedicated
  preflight, exact object identity, backup/rollback, native result and re-query.
- Treating a GUI success dialog or refreshed tree as proof the underlying change
  completed, persisted, replicated, or affected the intended runtime object.
- Launching from a service/noninteractive session and expecting a usable desktop,
  or using UAC elevation without recording the resulting token and target.
- Scripting MMC window titles, tree paths or localized text as an automation API.

## PowerShell behavior

Use `Start-Process mmc.exe -ArgumentList 'compmgmt.msc'` for interactive launch.
For automation, choose the specific PowerShell cmdlet/native CLI and preserve the
resolved machine/object identity, before/after state, exit status and rollback.

## Version and platform differences

`compmgmt.msc` is Windows-only. Included snap-ins, remote support, permissions,
features and UI vary by edition/build, installed roles and management policy.

## Related documents

- [mmc](mmc.md)
- [schtasks](schtasks.md)
- [wevtutil](wevtutil.md)
- [sc.exe](sc.md)
- [diskpart](diskpart.md)

## Sources and license

This original guide was adapted from Microsoft's
[remote Device Manager guidance](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/error-connect-device-manager-remotely),
which identifies `compmgmt.msc` as the Computer Management entry point.
Exact sources and licenses are recorded in `upstream/cli.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
