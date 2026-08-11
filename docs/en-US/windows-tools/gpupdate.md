<!-- mant:tldr:start -->
# gpupdate

> Refresh Windows Group Policy with explicit user/computer scope and completion wait.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/gpupdate.

- Preserve the current user and computer RSoP before refreshing policy:

`gpresult.exe /scope user /r; gpresult.exe /scope computer /r`

- Refresh only changed user policy and wait up to ten minutes:

`gpupdate.exe /target:user /wait:600`

- Refresh only changed computer policy and wait up to ten minutes:

`gpupdate.exe /target:computer /wait:600`

- Re-query the relevant RSoP after processing completes:

`gpresult.exe /scope {{user-or-computer}} /r`
<!-- mant:tldr:end -->

# gpupdate

## Overview

`gpupdate.exe` refreshes local and Active Directory Group Policy processing on
the current computer. By default it processes user and computer policy that
changed. `/target:user|computer` narrows scope, `/force` reapplies every
setting, `/wait:seconds` bounds the foreground wait, `/logoff` and `/boot` may
end the session or restart, and `/sync` makes the next foreground application
synchronous.

## Common mistakes

### Running refresh before collecting evidence

A refresh changes timestamps, policy state, caches, and diagnostic events.
Capture `gpresult`, Group Policy events, network/DC/DNS state, target identity,
and the original symptom first.

### Treating `/force` as a stronger fix

`/force` reapplies all settings instead of only changed settings. It does not
repair DNS, replication, permissions, filters, disabled links, unreachable
domain controllers, or invalid policy. Use it only when reapplication is the
tested hypothesis, because it increases work and side effects.

### Using `/wait:0` and immediately validating

Zero returns without waiting while policy processing continues. A timeout also
returns control when processing can still be active. Use a finite wait, check
the result and events, then verify RSoP and the effective setting.

### Adding `/boot` or `/logoff` casually

Those switches can restart the computer or sign out the user when an extension
requires foreground processing. Save work, notify affected users, use a
maintenance window and recoverable access, and never add them to a generic
remote repair command.

### Misunderstanding `/sync`

`/sync` schedules the next boot/logon foreground policy application to run
synchronously; it is not “wait for this refresh.” With `/sync`, `/force` and
`/wait` are ignored.

### Assuming refresh proves enforcement

Successful processing does not prove that one GPO won precedence or that a
non-Group-Policy setting changed. Re-query RSoP, processing events, pending
restart/sign-in, and the actual effective configuration.

## Version and platform differences

This executable is Windows-only. Policy extensions, domain membership,
network/DC reachability, permissions, elevation, foreground requirements, and
restart/sign-in behavior vary by policy and environment.

## Related documents

- [gpresult](gpresult.md)
- [auditpol](auditpol.md)
- [systeminfo](systeminfo.md)

## Sources and license

This original guide was adapted from Microsoft's official
[gpupdate reference](https://learn.microsoft.com/windows-server/administration/windows-commands/gpupdate).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
