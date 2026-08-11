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

## Version and platform differences

This Windows-only context requires a supported Wi-Fi interface and WLAN
service. Commands, hosted-network support, MAC randomization, policy, and
visible fields vary by hardware, driver, Windows release, and organization.

## Related documents

- [netsh](netsh.md)
- [getmac](getmac.md)
- [ipconfig](ipconfig.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netsh wlan reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netsh-wlan).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
