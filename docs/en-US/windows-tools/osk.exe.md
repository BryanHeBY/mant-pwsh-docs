<!-- mant:tldr:start -->
# osk.exe

> Start the classic On-Screen Keyboard for the current interactive user; distinguish it from the touch keyboard, sign-in accessibility keyboard and IME before diagnosing input or automating a kiosk.
> More information: https://learn.microsoft.com/windows/apps/design/input/keyboard-interactions.

- Start the classic On-Screen Keyboard:

`osk.exe`

- Open the documented Accessibility keyboard settings page:

`Start-Process 'ms-settings:easeofaccess-keyboard'`

- Confirm which executable PowerShell will launch:

`Get-Command osk.exe -All`
<!-- mant:tldr:end -->

# osk.exe

## Overview

`osk.exe` starts the classic Windows On-Screen Keyboard (OSK), a visual
software keyboard usable with a mouse, touch, pen, switch or other pointing
device. It is not the same component as the touch keyboard, an input method
editor (IME), or the keyboard shown on the secure sign-in desktop.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `osk.exe`: Start classic On-Screen Keyboard for the current interactive desktop.

## Common mistakes

- Assuming `osk.exe` is the touch keyboard and applying touch-keyboard service,
  kiosk or registry guidance to the wrong component.
- Starting OSK from a service, scheduled task or remote noninteractive session
  and expecting it on the intended user's desktop.
- Sending passwords or secrets through UI automation because the keyboard is
  visible. OSK generates input for the focused application; it is not a secure
  credential transport or reliable automation API.
- Force-terminating or disabling OSK while a user depends on it, or modifying
  protected file ACLs instead of using Accessibility/startup settings.
- Treating a visible keyboard as proof the active layout, IME, input scope,
  scan/hover mode, focus and target window are correct.
- Assuming desktop OSK behavior applies to single-app kiosk, Windows IoT,
  Remote Desktop, UAC or the secure sign-in desktop.

## PowerShell boundaries

Use `Start-Process osk.exe` only for an interactive user. Process creation and
`$LASTEXITCODE` do not prove that the keyboard is visible in the intended
desktop or that keystrokes reach the intended control. Do not automate secrets
or use `SendKeys`/window-title matching as a robust CLI interface.

## Version and platform differences

OSK is Windows-only. Layouts, text prediction, input/scan modes, touch-keyboard
interaction, kiosk support and secure-desktop behavior vary by Windows build,
edition, language/input resources, device role, session and policy.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\osk.exe`. Its fixed numeric file version was
`10.0.26100.8875`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [ms-settings](ms-settings.md)
- [magnify.exe](magnify.exe.md)
- [narrator.exe](narrator.exe.md)
- [taskmgr.exe](taskmgr.exe.md)

## Sources and license

Microsoft's [Keyboard interactions guide](https://learn.microsoft.com/windows/apps/design/input/keyboard-interactions)
distinguishes OSK from the touch keyboard, and the
[Windows Settings URI reference](https://learn.microsoft.com/windows/apps/develop/launch/launch-settings)
documents its settings entry. Microsoft's
[On-Screen Keyboard guide](https://learn.microsoft.com/windows/iot/iot-enterprise/os-features/on-screen-keyboard)
describes interactive modes and sign-in considerations. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
