<!-- mant:tldr:start -->
# mmsys.cpl

> Open classic Sound for interactive audio-endpoint inspection; preserve endpoint/PnP identity, role, format, mode, enhancements, communications behavior, application routing, driver, and privacy state before changing it.
> More information: https://learn.microsoft.com/windows/win32/coreaudio/using-the-communication-device.

- Resolve the module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\mmsys.cpl')`

- Open classic Sound interactively:

`Start-Process mmsys.cpl`

- Discover audio endpoint devices without scraping the dialog:

`Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue`
<!-- mant:tldr:end -->

# mmsys.cpl

## Overview

`mmsys.cpl` opens the classic Sound Control Panel module for playback, recording,
sound-scheme, and communications settings where available. Endpoint properties
can include level/balance, format, exclusive mode, enhancements, spatial sound,
device use, and driver/vendor extensions.

Display names can be duplicated and change after driver, port, dock, Bluetooth,
USB, or device reinstall. Preserve endpoint and underlying PnP identities rather
than selecting by friendly name alone.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `mmsys.cpl`: Open the classic Sound module in the current interactive user's session.
- `control.exe /name Microsoft.Sound`: Open the canonical Sound Control Panel item where supported.

This page does not treat remembered positional tokens such as `sounds` as a
stable automation contract. Use Core Audio, device, driver, application, policy,
or vendor interfaces for repeatable management.

## Audio state boundaries

Record endpoint ID, PnP instance/container, render/capture direction, console/
multimedia/communications role, default state, sample format, exclusive/shared
mode, level/mute, enhancements, spatial processing, communications attenuation,
application routing/session, privacy permission, service, driver, and hardware.

Changing a default endpoint does not move every existing application session;
applications may pin a device, cache state, or require restart.

## Common mistakes

- Selecting the first same-named speaker/microphone instead of exact endpoint,
  direction, role, transport, and physical port.
- Treating Default Device and Default Communications Device as one role.
- Disabling/removing an endpoint before recording how to show/re-enable it and
  preserving driver, privacy, service, application, and hardware evidence.
- Changing format/exclusive mode/enhancements globally to fix one application
  without checking its own device/session settings.
- Confusing device volume, application-session volume, hardware gain/mute, and
  communications attenuation.
- Automating localized dialogs instead of using documented APIs or vendor tools.

## PowerShell behavior

`Start-Process mmsys.cpl` only launches the GUI. Inbox PowerShell does not expose
every Core Audio endpoint/session setting as a universal cmdlet. `Get-PnpDevice`
helps identify hardware/endpoints but is not an audio routing or volume API.

Use an approved Core Audio/vendor interface for automation and verify from the
real application, user session, endpoint role, and physical device.

## Version and platform differences

`mmsys.cpl` is Windows-only. Tabs, endpoint roles, Settings migration, drivers,
extensions, enhancements, privacy, Bluetooth/USB behavior, and available APIs
vary by build, hardware, user session, policy, and installed software.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\mmsys.cpl`. Its fixed numeric file version was
`10.0.26100.8737`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [devmgmt.msc](devmgmt.msc.md)
- [services.msc](services.msc.md)
- [ms-settings](ms-settings.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[communication-device guidance](https://learn.microsoft.com/windows/win32/coreaudio/using-the-communication-device)
and [Control Panel canonical names](https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
