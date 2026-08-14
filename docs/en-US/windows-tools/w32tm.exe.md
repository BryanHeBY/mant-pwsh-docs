<!-- mant:tldr:start -->
# w32tm.exe

> Inspect Windows Time service source, effective configuration, synchronization health, and a bounded offset sample before changing peers, hierarchy, service registration, or the system clock.
> More information: https://learn.microsoft.com/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings.

- Show detailed local synchronization status, last good sync, source, errors, poll interval, and offset:

`w32tm.exe /query /status /verbose`

- Show the source currently reported by the local Windows Time service:

`w32tm.exe /query /source`

- Show effective configuration and whether each value comes from policy or local configuration:

`w32tm.exe /query /configuration`

- Show configured time peers and their current states:

`w32tm.exe /query /peers`

- Measure five offsets to one approved NTP endpoint without changing synchronization:

`w32tm.exe /stripchart /computer:"{{time-source.example.com}}" /samples:{{5}} /dataonly`

- Capture one NTP response with packet details:

`w32tm.exe /stripchart /computer:"{{time-source.example.com}}" /packetinfo /samples:1`

- Request an immediate synchronization attempt from an elevated shell:

`w32tm.exe /resync /force`
<!-- mant:tldr:end -->

# w32tm.exe

## Overview

`w32tm.exe` configures, monitors, and troubleshoots Windows Time (`W32Time`).
Domain members normally follow the AD domain hierarchy; the forest-root PDC
emulator is the usual external-time boundary. Querying an NTP endpoint and using
that endpoint as the system's effective synchronization source are distinct.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `w32tm.exe`: Configure, monitor, or troubleshoot Windows Time service state.

Most secondary parameters are valid only under one primary mode. Preserve the
complete primary-mode context when using `mant --explain` as a locator.

<!-- mant:entries role=option case=insensitive -->
- `/query`: Enter local or remote W32Time query mode.
- `/status`: Display synchronization status; add `/verbose` for more fields.
- `/source`: Display the synchronization source reported by W32Time.
- `/configuration`: Display effective configuration and value provenance.
- `/peers`: Display the configured peer set and peer state.
- `/computer`: Select a remote computer for modes that support it.
- `/config`: Change W32Time configuration on the local or selected computer.
- `/update`: Notify W32Time to apply changed configuration.
- `/manualpeerlist`: Set a quoted, space-delimited list of manual NTP peers.
- `/syncfromflags`: Select manual peers, domain hierarchy, or all supported sources.
- `/localclockdispersion`: Set dispersion advertised when the local clock is used.
- `/reliable`: Mark or unmark the selected computer as a reliable time source.
- `/largephaseoffset`: Set the spike-detection phase-offset threshold in milliseconds.
- `/resync`: Ask the selected computer to resynchronize its clock.
- `/rediscover`: Redetect network configuration and sources before resynchronizing.
- `/soft`: Resynchronize while respecting existing phase-correction limits.
- `/monitor`: Monitor domain controllers or an explicit computer list.
- `/domain`: Select the domain used by monitor mode.
- `/computers`: Supply a comma-separated explicit monitor target list.
- `/nowarn`: Suppress monitor warnings for non-authoritative sources.
- `/stripchart`: Measure offset to one computer without selecting it as a source.
- `/period`: Set the strip-chart interval in seconds.
- `/samples`: Bound the number of strip-chart samples.
- `/dataonly`: Suppress strip-chart graphics and show sample data only.
- `/packetinfo`: Display NTP packet details for strip-chart samples.
- `/ipprotocol`: Force IPv4 or IPv6 where the selected mode supports it.
- `/ntte`: Convert a Windows NT system-time value to readable form.
- `/ntpte`: Convert an NTP timestamp to readable form.
- `/tz`: Display current time-zone settings.
- `/register`: Register W32Time as a service with default configuration.
- `/unregister`: Remove W32Time service registration and configuration.
- `/debug`: Configure private W32Time diagnostic logging.
- `/enable`: Enable private debug logging with reviewed file/size/entry arguments.
- `/disable`: Disable private debug logging.
- `/file`: Select a protected debug-log path.
- `/size`: Set the maximum debug-log size.
- `/entries`: Select debug categories by numeric flags.
- `/truncate`: Clear an existing debug log when enabling it.
- `/?`: Display installed W32Time help.

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

## PowerShell boundaries

Invoke `w32tm.exe` explicitly and preserve stdout plus `$LASTEXITCODE`; output is
localized text, not a stable object schema. Bound `/stripchart` with `/samples`.
Record caller/target, domain role, PDC/VM provider, source IP/name/mode, UTC time,
offset/delay/dispersion, last error/good sync, configuration provenance and events.

## Version and platform differences

`w32tm.exe` is Windows-only. Algorithms, defaults, audit settings, precision,
virtualization providers, policy, domain roles, and available parameters vary by
Windows build. Remote queries also require the documented administrative rights.

On Windows NT `10.0.26200.0`, exact System32 file version `10.0.26100.1`
printed 130 nonempty standard-output help lines for `/?`, no standard-error
lines, and returned 0. No peer, domain controller, remote computer, credential,
sample, resync, registration, service, clock, policy, or time configuration was
queried or changed by this help-only probe.

## Runtime evidence

The protected local-help fixture resolved exact System32 `w32tm.exe` and
captured `/?` under both installed PowerShell editions. Each returned status
`0`, 130 nonempty stdout lines, and no stderr. No computer, peer, domain,
source, sample, registry path, query, resync, registration, or configuration
operation was supplied; time topology, offsets, rights, and service health
remain outside this help-only evidence.

## Related documents

- [tzutil.exe](tzutil.exe.md)
- [systeminfo.exe](systeminfo.exe.md)
- [wevtutil.exe](wevtutil.exe.md)
- [sc.exe](sc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Windows Time service tools and settings](https://learn.microsoft.com/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings)
and [no-time-data troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/error-message-run-w32tm-resync-no-time-data-available).
Operational demand was cross-checked against a practitioner question about
[confirming a PDC time source](https://serverfault.com/questions/704219/how-do-i-confirm-what-my-pdc-is-using-for-its-time-source).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
