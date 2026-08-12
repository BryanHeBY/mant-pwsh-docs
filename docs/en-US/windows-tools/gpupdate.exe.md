<!-- mant:tldr:start -->
# gpupdate.exe

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

# gpupdate.exe

## Overview

`gpupdate.exe` refreshes local and Active Directory Group Policy processing on
the current computer. By default it processes user and computer policy that
changed. `/target:user|computer` narrows scope, `/force` reapplies every
setting, `/wait:seconds` bounds the foreground wait, `/logoff` and `/boot` may
end the session or restart, and `/sync` makes the next foreground application
synchronous.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `gpupdate.exe`: Refresh changed local/domain Group Policy for the current
  computer and/or user, with explicit wait and foreground-action behavior.

Colon-bound values remain one native argument, for example `/wait:600`.

<!-- mant:entries role=option case=insensitive -->
- `/target`: Restrict refresh to `COMPUTER` or `USER`; default processes both.
- `/force`: Reapply every setting instead of only settings considered changed.
- `/wait`: Wait the following number of seconds for policy processing; `0`
  returns immediately and `-1` waits indefinitely.
- `/logoff`: Sign out when a client-side extension requires foreground user
  policy processing.
- `/boot`: Restart when a client-side extension requires foreground computer
  policy processing.
- `/sync`: Make the next foreground boot/logon policy application synchronous;
  `/force` and `/wait` are ignored in this mode.
- `/?`: Display installed command help; on the recorded Windows build it
  printed complete help and returned exit code -1.

## PowerShell boundaries

`gpupdate.exe` changes diagnostic state and may outlive the native process when
`/wait:0` or a timeout is used. Capture pre-refresh RSoP/events, pass colon
arguments intact, and read `$LASTEXITCODE`; then verify completion, RSoP, events,
effective configuration, and any pending sign-out/restart. Do not add `/boot`
or `/logoff` to unattended PowerShell merely to silence incomplete processing.

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
restart/sign-in behavior vary by policy and environment. On Windows NT
`10.0.26200.0`, installed file version `10.0.26100.8115` printed 44 nonempty
help lines for `/?` and returned -1. This help-specific status says nothing
about policy reachability or refresh success; never normalize it into the
result of a real refresh.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8115
ordinary-token /? printed 44 nonempty help lines and returned -1. The page
separates this help-specific status from a real refresh result; no target,
force, wait, logoff, boot, sync, policy, domain, or network operation ran.

## Related documents
- [gpresult.exe](gpresult.exe.md)
- [auditpol.exe](auditpol.exe.md)
- [systeminfo.exe](systeminfo.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[gpupdate reference](https://learn.microsoft.com/windows-server/administration/windows-commands/gpupdate).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
