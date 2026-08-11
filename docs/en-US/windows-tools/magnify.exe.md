<!-- mant:tldr:start -->
# magnify.exe

> Start Windows Magnifier for the current interactive session; use Windows logo key+Esc or its Close control to exit, and change startup/shortcut behavior in Accessibility settings instead of modifying the protected executable.
> More information: https://learn.microsoft.com/windows/apps/develop/launch/launch-settings.

- Start Magnifier:

`magnify.exe`

- Open the documented Magnifier settings page:

`Start-Process 'ms-settings:easeofaccess-magnifier'`

- Confirm which executable PowerShell will launch:

`Get-Command magnify.exe -All`
<!-- mant:tldr:end -->

# magnify.exe

## Overview

`magnify.exe` starts the built-in Windows Magnifier assistive technology in the
current interactive desktop. Magnifier can enlarge all or part of the display
and follows its per-user Accessibility settings.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `magnify.exe`: Start Windows Magnifier using the intended interactive user's
  per-user Accessibility settings.

## Common mistakes

- Taking ownership, changing ACLs, renaming or deleting `Magnify.exe` to disable
  a shortcut. This damages a protected accessibility component and can break
  servicing or recovery scenarios; use Magnifier settings instead.
- Force-killing the process before trying Windows logo key+Esc or the Close
  control, especially when a user depends on Magnifier to navigate.
- Assuming an unexpectedly enlarged display proves DPI, graphics-driver or
  application zoom failure. First identify whether Magnifier is active and its
  full-screen, lens or docked view.
- Starting it from a service, remoting or other noninteractive session and
  expecting it to appear on a user's desktop. Session and desktop identity
  matter.
- Treating Magnifier as a screenshot, OCR, UI-automation or evidence-capture
  API. Use supported tools for those jobs.

## PowerShell boundaries

Run `magnify.exe` or `Start-Process magnify.exe` only for the intended
interactive user. Native launch success does not prove that a usable window
appeared in the intended session. Do not use `Stop-Process -Force`, ACL changes
or Image File Execution Options as a normal configuration interface.

## Version and platform differences

Magnifier is Windows-only. Views, reading support, shortcuts, settings and
multi-monitor behavior vary by Windows build, display topology, input hardware,
session type and policy.

## Related documents

- [ms-settings](ms-settings.md)
- [narrator.exe](narrator.exe.md)
- [osk.exe](osk.exe.md)
- [taskmgr.exe](taskmgr.exe.md)

## Sources and license

Microsoft's [Accessibility overview](https://learn.microsoft.com/windows/apps/design/accessibility/accessibility-overview)
describes Magnifier as assistive technology, and the
[Windows Settings URI reference](https://learn.microsoft.com/windows/apps/develop/launch/launch-settings)
documents its settings entry. A
[Microsoft Q&A report about an unexpectedly active Magnifier](https://learn.microsoft.com/answers/questions/2803825/windows-magnifier-stuck-on-everything-enlarged-can)
captures the frequent close-shortcut problem; community answers are not a basis
for modifying protected files. Exact sources and licenses are in
`upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the Q&A source retains Microsoft web terms.
