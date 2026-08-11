<!-- mant:tldr:start -->
# date

> Read the system date without triggering a prompt; use one typed timestamp for
> automation and change the clock only through an approved time workflow.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/date.

- Display Cmd's current localized date without a change prompt:

`cmd.exe /d /c "date /t"`

- Capture one typed local timestamp and format its date invariantly:

`$now = Get-Date; $now.ToString('yyyy-MM-dd')`

- Capture one UTC timestamp in round-trip ISO 8601 form:

`$now = Get-Date; $now.ToUniversalTime().ToString('o')`

- Inspect time source, last synchronization, offset, and status before any clock intervention:

`w32tm.exe /query /status /verbose`

<!-- mant:tldr:end -->

# date

## Overview

Cmd's `date` displays or sets the local system calendar date. Bare `date`
displays the date and then prompts for a replacement; `date /t` is the read-only
display form. Setting the date requires appropriate privilege and accepts
locale/current-configuration-sensitive input.

For automation, obtain one typed timestamp and format it explicitly. This avoids
regional text parsing and prevents separate date/time reads from straddling
midnight. Clock correction is an infrastructure change: diagnose source,
hierarchy, offset, policy, virtualization, time zone, and service health before
changing wall-clock state.

## Command and option

<!-- mant:entries role=command case=insensitive -->
- `date`: Display and prompt to change the local calendar date, or accept a
  locale-sensitive replacement date when authorized.

The read-only switch avoids the interactive setting prompt.

<!-- mant:entries role=option case=insensitive -->
- `/t`: Display the current local date without prompting for a replacement.

## Common mistakes

### Running bare `date` in unattended work

It prompts for input and can hang or accidentally accept redirected data. Use
`date /t` for human display or `Get-Date` for typed automation.

### Slicing `%DATE%` or `date /t` at fixed positions

Day/month order, separators, weekday text, digits, and spacing depend on regional
settings. Widely copied batch recipes fail when moved between locales. Prefer a
typed timestamp and an invariant explicit format; do not revive deprecated WMIC
solely to avoid locale parsing.

### Reading date and time separately near midnight

Two reads can describe different instants. Capture `Get-Date` once, then derive
all required local/UTC fields and filename-safe strings from that object.

### Using a two-digit year or ambiguous numeric order

Avoid two-digit years entirely. Microsoft documents special 80–99 handling,
and accepted numeric order follows current date configuration. Use a four-digit
year, validate the intended calendar date, and display the parsed result before
an approved change.

### Changing the clock to fix a display or time-zone problem

Date, time of day, time zone, daylight-saving rules, display culture, hardware
clock, and synchronization source are distinct. Changing the wall clock can
invalidate Kerberos authentication, distort event/file/database chronology,
affect certificates/tokens/jobs, and be reverted by Windows Time.

### Correcting production time by hand

Record before-state and authoritative source, assess the offset and backward/
forward jump impact, coordinate dependent systems, use the approved time-service
procedure, and verify convergence and event logs. Never use a copied literal
date against a domain controller, cluster, database host, VM fleet, or evidence
system.

## PowerShell boundaries

Bare `date` is not the Cmd builtin in PowerShell; resolution can differ by
profile and platform. Use `cmd.exe /d /c "date /t"` when the localized Cmd
display is specifically required. `Get-Date` returns a `DateTime`; `-Format` or
`ToString()` returns text. Preserve the typed object until the output boundary.

## Version and platform differences

This Cmd builtin applies to supported Windows client and server releases.
Display and input depend on regional configuration; privilege, Windows Time,
domain hierarchy, policy, virtualization, and host role affect modification.
PowerShell `Get-Date` parameters and convenience formats vary by edition and
version, while the .NET round-trip `o` format is broadly available.

## Related documents

- [time](time.md)
- [w32tm.exe](w32tm.exe.md)
- [tzutil.exe](tzutil.exe.md)
- [cmd.exe](cmd.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Date reference](https://learn.microsoft.com/windows-server/administration/windows-commands/date),
[Get-Date reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-date),
and [Windows Time service overview](https://learn.microsoft.com/windows-server/networking/windows-time-service/windows-time-service).
High-volume locale and midnight-boundary failures were cross-checked against a
[practitioner date/time discussion](https://stackoverflow.com/questions/7727114/batch-command-date-and-time-in-file-name).
Microsoft sources govern supported behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
