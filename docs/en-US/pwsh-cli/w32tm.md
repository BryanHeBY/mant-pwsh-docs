<!-- mant:tldr:start -->
# w32tm

> Inspect Windows Time service source, effective configuration, synchronization health, and a bounded offset sample before changing peers, hierarchy, service registration, or the system clock.
> More information: https://learn.microsoft.com/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings.

- Show detailed local synchronization status, last good sync, source, errors, poll interval, and offset:

`w32tm.exe /query /status /verbose`

- Show the source currently reported by the local Windows Time service:

`w32tm.exe /query /source`

- Show effective configuration and whether each value comes from policy or local configuration:

`w32tm.exe /query /configuration`

- Measure five offsets to one approved NTP endpoint without changing synchronization:

`w32tm.exe /stripchart /computer:"{{time-source.example.com}}" /samples:{{5}} /dataonly`
<!-- mant:tldr:end -->

# w32tm

## Overview

`w32tm.exe` configures, monitors, and troubleshoots Windows Time (`W32Time`).
Domain members normally follow the AD domain hierarchy; the forest-root PDC
emulator is the usual external-time boundary. Querying an NTP endpoint and using
that endpoint as the system's effective synchronization source are distinct.

## Common mistakes

- Treating a successful `/stripchart` as proof W32Time uses that host or is
  healthy. Correlate `/source`, `/status /verbose`, `/configuration`, and events.
- Running `/resync` repeatedly when peer mode, DNS, UDP 123, service state,
  domain hierarchy, policy, virtualization, reachability, or source quality fails.
- Replacing domain hierarchy on ordinary domain members with a copied public NTP
  list, or marking a non-authoritative machine `/reliable:yes`.
- Omitting peer flags/mode context. Microsoft documents `0x8` as client mode and
  recommends three or more peers when configuring multiple time servers.
- Stepping time without reviewing Kerberos, certificates/tokens, logs, databases,
  schedulers, replication, monitoring, and the allowed correction thresholds.
- Editing W32Time registry values directly or confusing seconds, milliseconds,
  100-nanosecond ticks, and log-base-2 poll intervals. Policy can override them.
- Using `/unregister` as repair: it removes service registration/configuration.

## PowerShell behavior

Invoke `w32tm.exe` explicitly and preserve stdout plus `$LASTEXITCODE`; output is
localized text, not a stable object schema. Bound `/stripchart` with `/samples`.
Record caller/target, domain role, PDC/VM provider, source IP/name/mode, UTC time,
offset/delay/dispersion, last error/good sync, configuration provenance and events.

## Version and platform differences

`w32tm.exe` is Windows-only. Algorithms, defaults, audit settings, precision,
virtualization providers, policy, domain roles, and available parameters vary by
Windows build. Remote queries also require the documented administrative rights.

## Related documents

- [tzutil](tzutil.md)
- [systeminfo](systeminfo.md)
- [wevtutil](wevtutil.md)
- [sc.exe](sc.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Windows Time service tools and settings](https://learn.microsoft.com/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings)
and [no-time-data troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/error-message-run-w32tm-resync-no-time-data-available).
Operational demand was cross-checked against a practitioner question about
[confirming a PDC time source](https://serverfault.com/questions/704219/how-do-i-confirm-what-my-pdc-is-using-for-its-time-source).
Exact sources and licenses are recorded in `upstream/cli.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
