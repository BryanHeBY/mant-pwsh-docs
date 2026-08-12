<!-- mant:tldr:start -->
# netsh wlan

> Inspect Windows Wi-Fi interfaces, visible networks, profiles, and capabilities.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-wlan.

- Show current Wi-Fi interface state and connection details:

`netsh.exe wlan show interfaces`

- Show visible networks and access-point BSSIDs:

`netsh.exe wlan show networks mode=bssid`

- List saved profile names without exposing profile keys:

`netsh.exe wlan show profiles`

- Inspect driver and radio capabilities:

`netsh.exe wlan show drivers`
<!-- mant:tldr:end -->

# netsh wlan

## Overview

`netsh wlan` manages Wi-Fi interfaces, profiles, filters, connection attempts,
autoconfiguration, MAC randomization, reports, and tracing. `show` operations
are safest for first diagnosis. Connect/disconnect, add/delete, set, start,
stop, export, and tracing operations can affect users, connectivity, secrets,
files, or persistent policy.

## Context commands

<!-- mant:entries role=command case=insensitive -->
- `netsh.exe`: Run one fully qualified Windows Netsh command.
- `wlan`: Enter or address the Windows WLAN service context.
- `show`: Display interfaces, networks, profiles, drivers, filters, settings,
  wireless-capability/report state, or tracing state.
- `connect`: Ask one interface to connect using an exact saved profile/name/SSID.
- `disconnect`: Disconnect one selected Wi-Fi interface.
- `add`: Add a reviewed profile or filter from explicit input.
- `delete`: Delete exact profiles, filters, or tracing/report data according to
  the selected object grammar; wildcards can broaden scope.
- `set`: Change autoconfiguration, profile order/parameters, blocked-network
  display, randomization, tracing, or other supported WLAN context state.
- `export`: Export selected profiles to files; `key=clear` can expose secrets.
- `start`: Start a supported hosted-network or tracing operation.
- `stop`: Stop the corresponding hosted-network or tracing operation.
- `IHV`: Address independent-hardware-vendor logging operations; output and
  availability depend on the adapter/driver vendor.
- `refresh`: Refresh hosted-network settings, including security-key material
  where requested; this is not a display operation.
- `reportissues`: Generate a WLAN smart-trace report containing diagnostic
  network and device information.
- `dump`: Emit a replay script for review rather than immediate execution.

Parameters such as `name=`, `interface=`, `ssid=`, and `key=` are bare
equals-bearing Netsh tokens, not PowerShell named parameters.

## PowerShell boundaries

Use fully qualified `netsh.exe wlan ...` commands and pass every
`name=value` token as one native argument. Capture `$LASTEXITCODE`, then query
the exact interface/profile and test DHCP, DNS, route, and application access.
Treat exports/reports/traces as sensitive files; never pipe profile output or
clear keys into logs, transcripts, repositories, or agent conversations.

## Common mistakes

### Exporting keys in clear text

`export profile key=clear` can write a Wi-Fi secret into XML when run with
sufficient rights. Do not use it for ordinary inventory or attach such output
to tickets, logs, repositories, or agent conversations. Limit access and
securely dispose of any approved secret-bearing export.

### Deleting more profiles than intended

Profile deletion accepts wildcards, and omitting `interface=` can broaden the
scope. Query profiles, select one exact name and interface, and verify what
remains.

### Assuming the profile name is the SSID

A profile name and SSID are related but not interchangeable, and one profile
can describe multiple SSIDs. Query the profile and interface; quote names with
spaces and supply an exact interface when more than one exists.

### Treating a successful connect command as working network access

The interface can disconnect from its current network before attempting the
new profile, and success does not validate DHCP, DNS, captive portal, route,
or application access. Re-query interface state and test the required path.

### Enabling persistent tracing casually

Persistent tracing continues across restart and produces diagnostic data.
Record where it writes, reproduce for the minimum interval, stop it, and
handle reports according to privacy and retention policy.

### Calling the diagnostic command `report`

Current official and installed syntax uses `reportissues`; the former generic
`report` selector is not the command name. Generating the report starts a
diagnostic collection and writes sensitive artifacts, so it is not a harmless
read-only substitute for `show`. Preflight the output location, scope, consent,
retention, and redaction workflow before an approved capture.

## Version and platform differences

This Windows-only context requires a supported Wi-Fi interface and WLAN
service. Commands, hosted-network support, MAC randomization, policy, and
visible fields vary by hardware, driver, Windows release, and organization.
On exact System32 Netsh file version `10.0.26100.8457`, `wlan ?` returned 0
with 19 nonempty help lines and exposed `IHV`, `refresh`, and `reportissues`.
Only context help ran; no interface, network, profile, filter, secret, report,
trace, hosted-network, connection, or WLAN policy state was read or changed.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 Netsh file version 10.0.26100.8457
wlan ? returned 0 with 19 nonempty lines and corrected the former report
selector to reportissues while adding IHV and refresh. Only context help ran;
no interface, network, profile, filter, secret, report, trace, hosted-network,
connection, or WLAN policy state was read or changed. Representative
hardware/driver/policy verification remains required.

## Related documents
- [netsh.exe](netsh.exe.md)
- [getmac.exe](getmac.exe.md)
- [ipconfig.exe](ipconfig.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netsh wlan reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-wlan).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
