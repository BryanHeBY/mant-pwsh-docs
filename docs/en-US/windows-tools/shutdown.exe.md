<!-- mant:tldr:start -->
# shutdown.exe

> Inspect Windows shutdown syntax, cancel a pending timer when safe, and only schedule restart/shutdown after checking every user, workload, target, recovery path, reason, and the implicit forced-close behavior of nonzero timeouts.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/shutdown.

- Display target-build actions, combinations, reason codes, timeout range, and warnings:

`shutdown.exe /?`

- Cancel a pending shutdown during its timeout window from a separate process:

`shutdown.exe /a`

- After explicit user/workload approval, schedule a planned local restart in ten minutes with a reason and auditable comment:

`shutdown.exe /r /t {{600}} /d p:4:1 /c "{{Approved maintenance change CHG-1234}}"`

- After preserving work and confirming hibernation support/policy, hibernate the local computer:

`shutdown.exe /h`

- After preserving work, restart the local computer immediately:

`shutdown.exe /r /t 0`

- Schedule a local shutdown after a chosen number of seconds:

`shutdown.exe /s /t {{seconds}}`

- Log off the current interactive user:

`shutdown.exe /l`

- After remote authorization and workload approval, schedule a remote shutdown with a cancellation window:

`shutdown.exe /s /m "{{\\computer-name}}" /t {{600}} /d p:4:1 /c "{{Approved maintenance change CHG-1234}}"`
<!-- mant:tldr:end -->

# shutdown.exe

## Overview

`shutdown.exe` signs out, shuts down, restarts, hibernates, enters recovery or
firmware flows, annotates unexpected shutdowns, and targets local or remote
computers. Scheduling acceptance means the request was registered—not that
applications, sessions, clustering, replication, updates, or recovery are safe.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `shutdown.exe`: Request a local or remote Windows sign-out, power transition,
  restart, recovery boot, or shutdown-reason annotation.

Choose one primary action unless the official syntax documents a combination.
A nonzero `/t` timeout implies forced application closure even without `/f`.

<!-- mant:entries role=option case=insensitive -->
- `/i`: Open Remote Shutdown UI; it must be first and other CLI options are ignored.
- `/l`: Sign out the current user immediately; it cannot be combined with options.
- `/s`: Shut down the selected computer.
- `/sg`: Shut down, then use Automatic Restart Sign-On and registered-app restart
  on the next boot where configured.
- `/r`: Shut down and restart the selected computer.
- `/g`: Fully restart, then use Automatic Restart Sign-On and registered-app restart.
- `/a`: Abort a pending timed shutdown from a separate invocation.
- `/p`: Power off the local computer immediately with no warning or timeout.
- `/h`: Hibernate the local computer when hibernation is enabled.
- `/e`: Record a reason for an unexpected shutdown of the local computer.
- `/o`: Open Advanced startup after restart; use with `/r`.
- `/hybrid`: Prepare a local shutdown for Fast Startup; use with `/s`.
- `/soft`: Installed-build modifier whose spelling appears only in the Usage
  line on the recorded host. Neither that help text nor the locked/current
  Microsoft page defines its behavior; do not infer semantics from its name.
- `/fw`: Make the next restart enter firmware UI; combine only as documented.
- `/f`: Force running applications to close without warning users.
- `/m`: Select one remote computer by UNC-style name.
- `/t`: Set the delay in seconds before shutdown or restart.
- `/d`: Record planned/unplanned, major, and minor shutdown reason codes.
- `/c`: Attach a reason comment of the documented maximum length.
- `/?`: Display syntax, constraints, and reason codes for the installed build.

## Common mistakes

- Missing that `/t` greater than zero implies `/f`: applications can be forced
  closed with unsaved data loss even when `/f` is absent from the command line.
- Using `/p`, `/f`, `/t 0`, or remote `/m` before checking active/disconnected
  sessions, jobs, services, transactions, cluster/drain state, and console access.
- Combining `/l` with other options; sign-out works independently and ignores
  combinations. `/i` must be first and causes other command options to be ignored.
- Treating `/m` as a credential option. Remote rights, identity/token, firewall,
  RPC/service/policy, target resolution, and audit must be established separately.
- Confusing `/r` with `/g`, or `/s` with `/sg`: `/g`/`/sg` can use Automatic
  Restart Sign-On and restart registered apps under the last interactive user.
- Using `/o`, `/fw`, or `/hybrid` without firmware/recovery/Fast Startup context;
  these change the next boot path and have strict valid combinations.
- Treating `/soft` as a graceful-close guarantee. It is present only in the
  installed Usage line and absent from the locked/current Microsoft Shutdown
  page; until authoritative semantics exist for the target build, do not use it
  merely because feature detection finds the token.
- Assuming `/a` can cancel after timeout/commit, or that a zero exit code proves
  restart completion. Verify target, notification, events, uptime, and health.

## PowerShell boundaries

Call `shutdown.exe` explicitly and capture `$LASTEXITCODE`; the command returns
before a delayed lifecycle operation completes. PowerShell `Restart-Computer`,
`Stop-Computer`, and `Stop-Computer -Force` have different remoting and force
semantics. Never interpolate an untrusted hostname, timeout, reason, or comment.

## Version and platform differences

`shutdown.exe` is Windows-only. Options, timeout limits, Fast Startup, firmware/
recovery flows, Automatic Restart Sign-On, reason policy, remote administration,
privileges, and application restart behavior vary by Windows generation/build.
On Windows NT 10.0.26200.0, file version 10.0.26100.8457 exposes `/soft` while
Microsoft's locked/current page omits it.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8457 /? returned
1 and exposed /soft only in the Usage line; the locked and current Microsoft
page omits it. The page indexes the token but does not infer or recommend its
semantics. Runtime verification remains help-only; no lifecycle or cancellation
action may be performed merely for evidence.

## Related documents
- [query.exe](query.exe.md)
- [msg.exe](msg.exe.md)
- [logoff.exe](logoff.exe.md)
- [schtasks.exe](schtasks.exe.md)
- [wevtutil.exe](wevtutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[shutdown reference](https://learn.microsoft.com/windows-server/administration/windows-commands/shutdown).
The timeout/force and cancellation risks were cross-checked against practitioner
questions about [canceling a delayed UPS shutdown](https://serverfault.com/questions/652725/cancel-block-a-task-triggered-with-delay-by-windows-task-scheduler)
and [scheduling a server restart](https://serverfault.com/questions/515427/how-can-i-schedule-a-server-restart-from-command-line-on-windows-2012).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
