<!-- mant:tldr:start -->
# narrator

> Start Narrator only for the current interactive user and expect immediate speech/Braille interaction; use Ctrl+Windows logo key+Enter or Narrator's Exit command to stop it, and manage automatic startup in Accessibility settings.
> More information: https://learn.microsoft.com/windows/apps/design/accessibility/accessibility-overview.

- Start Narrator:

`narrator.exe`

- Open the documented Narrator settings page:

`Start-Process 'ms-settings:easeofaccess-narrator'`

- Confirm which executable PowerShell will launch:

`Get-Command narrator.exe -All`
<!-- mant:tldr:end -->

# narrator

## Overview

`narrator.exe` starts the built-in Windows screen reader for the current
interactive user. It reads UI through accessibility frameworks and can interact
with speech, Braille, keyboard focus, scan mode and application-specific
accessibility information.

## Common mistakes

- Launching Narrator on another person's session as a harmless test. Speech,
  focus and keyboard commands are immediately user-visible and can disclose
  on-screen content.
- Renaming/deleting the executable, changing its ACL, or adding an Image File
  Execution Options debugger to prevent startup. Use the documented per-user
  shortcut and automatic-start settings instead.
- Confusing Narrator commands with ordinary application shortcuts. The Narrator
  key can be Caps Lock or Insert, and keyboard layout/settings can change
  command behavior.
- Assuming silence means launch failure. Check the intended session, audio
  output/volume, speech resources, Narrator settings and current focus; Braille
  users may intentionally use a different output path.
- Treating screen-reader speech as structured UI automation or complete
  accessibility evidence. Test supported accessibility APIs and representative
  keyboard/screen-reader workflows separately.

## PowerShell behavior

Use `Start-Process narrator.exe` only inside the intended interactive session.
Remote/service launch, process existence and exit status do not prove usable
speech or correct focus. Avoid automated termination while a user depends on
the reader; use its shortcut or Exit control and verify automatic-start settings.

## Version and platform differences

Narrator is Windows-only. Voices, languages, Braille/display support, commands,
scan mode, browser/application behavior and settings vary by Windows build,
installed speech resources, input layout, session and policy.

## Related documents

- [ms-settings](ms-settings.md)
- [magnify](magnify.md)
- [osk](osk.md)
- [taskmgr](taskmgr.md)

## Sources and license

Microsoft's [Accessibility overview](https://learn.microsoft.com/windows/apps/design/accessibility/accessibility-overview)
describes Narrator's role, and the
[Windows Settings URI reference](https://learn.microsoft.com/windows/apps/develop/launch/launch-settings)
documents its settings entry. A
[Microsoft Q&A Narrator question](https://learn.microsoft.com/answers/questions/3861151/how-do-i-get-the-narrator-to-read-each-line-of-a-s)
records a recurring shortcut/navigation need; exact commands must still be
checked on the target build. Exact sources and licenses are in
`upstream/cli.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the Q&A source retains Microsoft web terms.
