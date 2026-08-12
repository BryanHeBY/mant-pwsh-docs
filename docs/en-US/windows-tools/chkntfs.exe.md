<!-- mant:tldr:start -->
# chkntfs.exe

> Inspect and deliberately schedule automatic filesystem checks at startup; it does not perform the check itself.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/chkntfs.
> Microsoft documents Administrators membership for CHKNTFS. On the recorded
> build an ordinary token could query `/t` but could not query `C:`; treat
> access as form-specific and never report a failed query as clean state.

- Show filesystem, dirty, exclusion, or scheduled-check state for one volume:

`chkntfs.exe "{{C:}}"`

- Show the current Autochk countdown without changing it:

`chkntfs.exe /t`

- Schedule one exact volume to be evaluated at startup:

`chkntfs.exe /c "{{D:}}"`

- Verify the scheduled state for that volume:

`chkntfs.exe "{{D:}}"`
<!-- mant:tldr:end -->

# chkntfs.exe

## Overview

`chkntfs.exe` displays or changes the policy that controls automatic
filesystem checking during startup. Given a volume, it reports filesystem and
whether that volume is dirty, excluded, or manually scheduled. `/c` schedules
volumes, `/x` excludes volumes even when a check is required, `/t` queries or
sets the Autochk countdown, and `/d` restores default settings except the
countdown.

CHKNTFS does not scan or repair a mounted volume. At startup, Autochk/CHKDSK
runs according to dirty state, explicit schedule, exclusions, and policy.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `chkntfs.exe`: Query or change Autochk startup-check policy for named volumes.

With only volume arguments, the command reports their current filesystem and
startup-check state. Microsoft documents an administrative context for the
command, although the recorded ordinary token could read `/t`; mutations and
volume-state queries must not infer access from that exception.

<!-- mant:entries role=option case=insensitive -->
- `/c`: Add one or more volumes to the startup-check schedule; calls accumulate.
- `/x`: Replace the complete startup exclusion list with the named volumes.
- `/d`: Restore default startup-check policy except for the countdown value.
- `/t`: With no value, display the countdown; `/t:seconds` changes it globally.
- `/?`: Display installed syntax; Windows build `10.0.26200` printed complete
  help but returned 2.

## State-change semantics

- `/c` is cumulative: later calls add scheduled volumes.
- `/x` is not cumulative: each call replaces the prior exclusion list, so all
  intended exclusions must appear in one command.
- `/d` resets default checking/exclusion/scheduling state but leaves the
  countdown value unchanged.
- `/t` queries; `/t:seconds` changes a machine-wide startup countdown.
- `/x` can suppress a required check on a dirty volume and must be temporary,
  justified, and followed by an approved repair plan.

After every mutation, query each affected volume and preserve the intended
full policy, not just the last command line.

## Common mistakes

### Treating `/x` as “skip once”

`/x` excludes the volume at startup, including when it is marked for CHKDSK.
It is persistent policy, not a one-boot bypass. Do not hide recurring dirty
state; diagnose the filesystem, storage, shutdown, and workload cause.

### Adding exclusions one command at a time

Because `/x` is noncumulative, the newest call replaces earlier exclusions.
Inventory the existing policy and provide the entire reviewed list in one
operation. `/c` behaves differently and accumulates, which makes generic list-
update code particularly dangerous.

### Setting `/t:0` to speed startup

A zero countdown removes the opportunity to cancel an unexpectedly long
automatic check. Keep a reviewed operational interval, especially on large or
remote systems, and account for unattended recovery requirements.

### Resetting with `/d` without recording custom policy

`/d` is broader than unscheduling one drive: it restores default settings
except the countdown. Capture all affected volume state and the reason for
every exclusion/schedule before resetting.

### Assuming `/c` guarantees repair on the next boot

`/c` schedules evaluation; Microsoft documents that CHKDSK runs for scheduled
volumes that are dirty. Verify dirty and schedule state, boot completion,
Wininit/Chkdsk events, exit/result details, and post-boot volume health.

### Using drive letters without stable volume identity

Mount points and letters can change across recovery, SAN, removable, or
deployment environments. Record volume GUID, disk/partition identity,
filesystem, and role before changing startup policy.

### Treating exit 2 as one documented volume state

On the recorded non-administrative token, `chkntfs C:` returned 2 with
“Cannot query state,” while `chkntfs /?` returned the same code after complete
help and `/t` succeeded with 0. Preserve arguments, output, token, and exit
code; do not map 2 to dirty, excluded, scheduled, or help without the matching
text and command form.

## PowerShell boundaries

CHKNTFS emits localized native text. Quote mount points, specify exact volumes,
check `$LASTEXITCODE`, and do not parse a single English sentence as policy.
Use structured storage inventory to bind the displayed letter/mount point to a
stable volume identity. Query-time access is form-specific on the recorded
build: an ordinary `/t` success does not prove volume queries or mutations are
authorized.

## Version and platform differences

This Windows-only administrative command applies to supported Windows client
and server releases. Startup behavior depends on filesystem, dirty state,
boot volume role, encryption, clustered/storage-stack ownership, policy, and
the actual restart path.

## Runtime evidence

Under the recorded ordinary token, `chkntfs.exe /t` returned the countdown and
status `0`; a `C:` state query and complete `/?` help each returned `2` for
different reasons, with help producing 23 lines. Status must therefore be
interpreted with the exact form and payload. No schedule, exclusion, default,
countdown value, boot, volume, or filesystem state changed; elevated
exact-volume verification remains pending.

## Related documents

- [chkdsk.exe](chkdsk.exe.md)
- [bcdedit.exe](bcdedit.exe.md)
- [defrag.exe](defrag.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[CHKNTFS reference](https://learn.microsoft.com/windows-server/administration/windows-commands/chkntfs).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
