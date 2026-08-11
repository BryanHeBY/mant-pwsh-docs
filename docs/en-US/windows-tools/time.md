<!-- mant:tldr:start -->
# time

> Read the system time without prompting; capture one typed instant for scripts
> and diagnose synchronization before any privileged clock change.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/time.

- Display Cmd's current localized time without a change prompt:

`cmd.exe /d /c "time /t"`

- Capture one local timestamp with offset in round-trip ISO 8601 form:

`$now = Get-Date; $now.ToString('o')`

- Capture the same instant in UTC rather than relabeling local time:

`$now = Get-Date; $now.ToUniversalTime().ToString('o')`

- Inspect effective Windows Time synchronization state before intervention:

`w32tm.exe /query /status /verbose`

<!-- mant:tldr:end -->

# time

## Overview

Cmd's `time` displays or sets the local system time of day. Bare `time` displays
the current value and prompts for a replacement; `time /t` is the read-only
display form. A change requires appropriate privilege. The command is not a
time-zone editor, synchronization client, elapsed-time clock, or timestamp
formatting API.

For scripts, capture one `DateTime` and retain its offset/UTC meaning when
formatting. For clock incidents, diagnose the authoritative source, hierarchy,
offset, Windows Time service, policy, VM host integration, and time zone before
deciding whether a correction is needed.

## Common mistakes

### Running bare `time` in unattended work

It prompts and may hang or consume redirected input. Use `time /t` only for
human-readable local display; use `Get-Date` for typed automation.

### Parsing `%TIME%` or `time /t` as a stable format

12/24-hour form, AM/PM designators, digits, separators, leading spaces, and
precision depend on settings and command form. Use an explicit invariant format.
For a filename, remove characters forbidden by the filesystem deliberately
rather than applying an unexplained string-replacement recipe.

### Combining independently read date and time values

The instant can cross midnight between expansions. Capture once and derive all
components from the same object. Do the same when generating a correlation ID,
log prefix, archive path, or expiry comparison.

### Confusing local time, UTC, offset, and time zone

Appending `Z` does not convert local time to UTC. A numeric offset does not fully
identify a time zone or its daylight-saving rules. Use `ToUniversalTime()` for
conversion and query the configured Windows time-zone ID separately.

### Measuring elapsed duration with wall-clock time

Synchronization can step or slew the system clock forward or backward. Use
`[System.Diagnostics.Stopwatch]` or a documented monotonic timer for durations,
timeouts, and performance measurements.

### Setting time manually on managed systems

A clock jump can break Kerberos's skew tolerance and disrupt certificates,
tokens, logs, scheduled work, databases, replication, clusters, and forensic
ordering. Record before-state, coordinate the change, use the approved time-
service workflow, and verify source/offset/events afterward. Do not solve a
timezone or formatting issue by changing the instant.

### Guessing boundary syntax

Microsoft documents hours, minutes, seconds, optional hundredths, and optional
AM/PM, including an unusual upper hour boundary. Do not rely on edge inputs or
locale parsing. If a legacy workflow must set time, validate a four-part change
plan on a disposable representative system before production approval.

## PowerShell behavior

Bare `time` does not invoke this Cmd builtin in PowerShell. Use
`cmd.exe /d /c "time /t"` for its display. `Measure-Command` measures a script
block but includes its own overhead; `Stopwatch` supports explicit monotonic
elapsed measurements. Neither changes system time.

## Version and platform differences

This Cmd builtin applies to supported Windows client and server releases.
Regional settings control display/input, while privilege, domain policy,
Windows Time topology, virtualization, and host role control safe correction.
PowerShell formatting capabilities vary by edition/version; explicit .NET
round-trip formatting is broadly portable.

## Related documents

- [date](date.md)
- [w32tm](w32tm.md)
- [tzutil](tzutil.md)
- [logman](logman.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Time reference](https://learn.microsoft.com/windows-server/administration/windows-commands/time),
[Get-Date reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-date),
[Windows Time service overview](https://learn.microsoft.com/windows-server/networking/windows-time-service/windows-time-service),
and [Kerberos troubleshooting guidance](https://learn.microsoft.com/troubleshoot/windows-server/windows-security/kerberos-authentication-troubleshooting-guidance).
Locale and multi-read rollover failures were cross-checked against a
[high-demand practitioner discussion](https://stackoverflow.com/questions/203090/how-do-i-get-current-date-time-on-the-windows-command-line-in-a-suitable-format).
Microsoft sources govern supported behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
