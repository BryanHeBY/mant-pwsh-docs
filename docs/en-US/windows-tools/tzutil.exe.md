<!-- mant:tldr:start -->
# tzutil.exe

> Discover target-installed Windows time-zone IDs, preserve the current ID, and only set an exact reviewed ID after checking DST, scheduling, policy, application-cache, and audit effects.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/tzutil.

- Display the current Windows time-zone ID:

`tzutil.exe /g`

- List target-installed display names followed by their valid Windows IDs:

`tzutil.exe /l`

- Set one exact ID copied from the target's list, preserving normal DST rules:

`tzutil.exe /s "{{Pacific Standard Time}}"`

- Only where policy explicitly requires fixed standard time, disable DST adjustments for that zone:

`tzutil.exe /s "{{Pacific Standard Time_dstoff}}"`
<!-- mant:tldr:end -->

# tzutil.exe

## Overview

`tzutil.exe` gets, lists, and sets the Windows system time-zone ID. Changing the
zone changes how UTC instants are represented locally and how future local-time
schedules are interpreted; it does not set the clock, configure time service,
or enable automatic time-zone detection.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `tzutil.exe`: Get, list, or set the Windows system time-zone identifier.

Use an exact ID emitted by `/l`, not the localized display name above it. Quote
IDs because they normally contain spaces.

<!-- mant:entries role=option case=insensitive -->
- `/g`: Display the current Windows time-zone ID.
- `/l`: List installed display names followed by their usable Windows IDs.
- `/s`: Set an exact Windows ID; append `_dstoff` only to disable DST adjustments.
- `/?`: Display installed TZUTIL syntax.

## Common mistakes

- Passing an IANA ID (`America/Los_Angeles`), abbreviation (`PST`), display name,
  or fixed UTC offset where a target-installed Windows ID is required.
- Assuming one Windows ID maps one-to-one to IANA geography. Mapping can depend
  on territory, and abbreviations/offsets are not stable identifiers.
- Reading “Standard Time” in a Windows ID as “DST disabled.” Normal IDs can apply
  DST rules; the `_dstoff` suffix explicitly disables adjustments where supported.
- Setting a zone instead of fixing time synchronization, clock drift, regional
  formats, location/automatic-zone policy, firmware clock, or application logic.
- Ignoring scheduled jobs, logs, certificates, tokens, databases, distributed
  systems, ambiguous/nonexistent DST times, and cached process time-zone data.
- Changing many hosts inside a loop while passing the whole host array, or
  allowing Group Policy/management to revert an unmanaged local change.

## PowerShell boundaries

Use `tzutil.exe` explicitly and quote the full ID. Capture `/g` before and after,
native status, UTC/local timestamps, policy source, DST requirement, and affected
services. PowerShell 5.1+ also provides `Get-TimeZone`/`Set-TimeZone`; long-lived
.NET processes can cache time-zone information and may need supported refresh or
restart behavior. Do not parse localized `/l` display text as a fixed two-line API.

## Version and platform differences

`tzutil.exe` is Windows-only. Installed IDs and historical/dynamic DST rules are
serviced data and vary by Windows build/update and territory. Privilege/policy,
automatic detection, containers, and application cache behavior also vary.
On exact System32 file version `10.0.26100.2161`, `/?` returned 0 with 20
nonempty stdout lines and no PowerShell error records. No current/list query,
time-zone ID, DST suffix, policy, clock, service, or system setting changed.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 TZUtil file version 10.0.26100.2161
/? returned 0 with 20 nonempty stdout lines and no PowerShell error records. No
current/list query or time-zone/DST/system mutation ran; /g and /l plus
disposable setting verification remain pending.

## Related documents
- [systeminfo.exe](systeminfo.exe.md)
- [wevtutil.exe](wevtutil.exe.md)
- [schtasks.exe](schtasks.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[tzutil reference](https://learn.microsoft.com/windows-server/administration/windows-commands/tzutil).
ID discovery and mapping pitfalls were cross-checked against practitioner
questions about [setting Windows time zones](https://stackoverflow.com/questions/4235243/how-to-set-timezone-using-powershell)
and [Windows/IANA mappings and abbreviations](https://stackoverflow.com/questions/64467722/timezones-abbreviations).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
