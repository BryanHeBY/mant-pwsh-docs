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

- Connect using one previously reviewed saved profile name:

`netsh.exe wlan connect name="{{profile-name}}"`

- Disconnect the current wireless interface:

`netsh.exe wlan disconnect`

- Export one profile without exposing its plaintext key material:

`netsh.exe wlan export profile name="{{profile-name}}" folder="{{C:\Evidence\WiFi}}" key=no`

- Delete one exact saved profile after exporting any required recovery copy:

`netsh.exe wlan delete profile name="{{profile-name}}"`
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

## Context parameters

The parameters below are bare equals-bearing Netsh tokens, not PowerShell
named parameters. Pass each complete `name=value` token as one native argument.

### Profile, interface, filter, and export parameters

<!-- mant:entries role=option case=insensitive -->
- `permission=MODE`: Select `allow`, `block`, or `denyall` for a WLAN filter.
- `ssid=SSID`: Select or supply an exact wireless network SSID.
- `networktype=TYPE`: Select `infrastructure` or `adhoc` for a WLAN filter.
- `filename=PATH`: Supply the reviewed WLAN profile XML file to import.
- `interface=NAME`: Select one exact wireless interface; omission can broaden scope.
- `user=SCOPE`: Apply an imported profile to `all` or only the `current` user.
- `name=PROFILE`: Select one exact WLAN profile name; some delete forms accept wildcards.
- `folder=PATH`: Select an existing local export directory; UNC paths are unsupported.
- `key=MODE`: Control profile-export key handling or supply hosted-network key material according to the selected command; `clear` can disclose a secret.
- `data=VALUE`: Supply the hosted-network refresh data requested by the exact installed command.

### WLAN setting parameters

<!-- mant:entries role=option case=insensitive -->
- `allow=STATE`: Allow or deny explicit shared user credentials with `yes` or `no`.
- `enabled=STATE`: Enable or disable the selected autoconfig, profile, or randomization setting.
- `display=STATE`: Show or hide blocked networks.
- `value=MINUTES`: Set the WLAN automatic-connect block period in minutes.
- `mode=MODE`: Select hosted-network or tracing mode; accepted values depend on the selected command.
- `keyUsage=MODE`: Make hosted-network key material `persistent` or `temporary`.
- `priority=NUMBER`: Set a user profile's exact preference position on one interface.
- `SSIDname=SSID`: Change the SSID stored in one selected profile.
- `ConnectionType=TYPE`: Select infrastructure `ESS` or ad-hoc `IBSS` profile behavior.
- `autoSwitch=STATE`: Allow or prevent switching automatically to a more preferred network.
- `ConnectionMode=MODE`: Select `auto` or `manual` connection behavior.
- `nonBroadcast=STATE`: Control connection behavior for a nonbroadcast network.
- `Randomization=STATE`: Enable or disable profile-level MAC-address randomization.
- `authentication=MODE`: Select the profile authentication mechanism supported by the target build.
- `encryption=MODE`: Select the profile encryption mechanism supported by the target build.
- `keyType=TYPE`: Select `networkKey` or `passphrase` for supplied key material.
- `keyIndex=NUMBER`: Select WEP key index 1 through 4 where legacy WEP is applicable.
- `keyMaterial=SECRET`: Supply profile key material; protect it from history, logs, telemetry, and process inspection.
- `PMKCacheMode=STATE`: Enable or disable PMK caching for the selected profile.
- `PMKCacheSize=NUMBER`: Set the supported PMK cache-entry count.
- `PMKCacheTTL=SECONDS`: Set the supported PMK cache lifetime.
- `preAuthMode=STATE`: Enable or disable preauthentication.
- `preAuthThrottle=NUMBER`: Bound preauthentication attempts for neighboring access points.
- `FIPS=STATE`: Enable or disable the profile's FIPS mode where supported.
- `useOneX=STATE`: Enable or disable 802.1X authentication for the profile.
- `authMode=MODE`: Select machine, user, guest, or combined 802.1X authentication context.
- `ssoMode=MODE`: Select pre-logon, post-logon, or no single sign-on behavior.
- `maxDelay=SECONDS`: Bound the single sign-on connection delay.
- `allowDialog=STATE`: Allow or suppress an 802.1X user dialog according to policy.
- `userVLAN=STATE`: Enable or disable user-based VLAN behavior.
- `heldPeriod=SECONDS`: Set the 802.1X supplicant held period.
- `AuthPeriod=SECONDS`: Set the 802.1X authentication response period.
- `StartPeriod=SECONDS`: Set the 802.1X EAPOL start-retry period.
- `maxStart=NUMBER`: Set the maximum EAPOL start-message count.
- `maxAuthFailures=NUMBER`: Set the authentication-failure threshold.
- `cacheUserData=STATE`: Enable or disable caching of user credential data.
- `cost=MODE`: Set the profile's connection-cost classification.
- `profiletype=SCOPE`: Change a profile between `all`-user and `current`-user scope where permitted.

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
