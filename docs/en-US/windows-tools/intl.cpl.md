<!-- mant:tldr:start -->
# intl.cpl

> Open Region for an explicitly identified user or system-locale workflow; distinguish culture, format, region, language, input method, time zone, UTF-8 beta option, welcome screen, new-user defaults, and offline-image settings.
> More information: https://learn.microsoft.com/windows-hardware/manufacture/desktop/configure-international-settings-in-windows.

- Resolve the module without opening it:

`Get-Item -LiteralPath (Join-Path $env:WINDIR 'System32\intl.cpl')`

- Open Region interactively:

`Start-Process intl.cpl`

- Query the current user's culture without changing it:

`Get-Culture; Get-WinSystemLocale; Get-WinUserLanguageList`
<!-- mant:tldr:end -->

# intl.cpl

## Overview

`intl.cpl` opens the classic Region Control Panel module. It exposes selected
format/location and administrative language/locale settings that remain in the
classic interface; other language features have moved to Settings.

International settings have different scopes and effects. Current-user culture,
UI language list, home location, input methods, system locale for non-Unicode
programs, time zone, welcome/system accounts, new-user defaults, and offline
image settings are not interchangeable.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `intl.cpl`: Open the classic Region module in the current interactive user's context.
- `control.exe /name Microsoft.RegionAndLanguage`: Open the canonical Region item where supported.

Use the International PowerShell module for supported online settings, answer
files for deployment, and DISM international options only for an offline image
as documented. Do not automate localized GUI labels.

## Scope and data behavior

Record user SID, target online/offline Windows, culture/locale/language tags,
format overrides, input methods, system locale/code page, region/home location,
time zone, copy-to-welcome/new-user choices, policy, restart/sign-in requirements,
and applications/data affected.

Locale changes can alter parsing, formatting, collation, filenames, legacy byte
decoding, console/application output, and test results without changing the
underlying value. Persist machine data in invariant formats.

## Common mistakes

- Changing display language while intending formats, system locale, keyboard,
  region, or time zone—or the reverse.
- Assuming a current-user change applies to services, system accounts, welcome
  screen, existing users, new users, or an offline image.
- Enabling the UTF-8 beta system-locale option to repair one incorrectly decoded
  file without compatibility testing and rollback.
- Parsing localized native output or formatted dates/numbers in automation.
- Using DISM international commands against the running online installation when
  the documentation requires an offline image.
- Expecting every migrated Settings feature to remain configurable through
  `intl.cpl`.

## PowerShell behavior

`Start-Process intl.cpl` only opens the GUI. International cmdlets return typed
values but affect different scopes; inspect each cmdlet's target and restart/
sign-in behavior. Preserve BCP-47 tags and stable identifiers, not localized
display names or formatted examples.

## Version and platform differences

`intl.cpl` is Windows-only. Settings migration, languages, optional features,
cmdlets, code pages, policies, and restart requirements vary by Windows build,
edition, installed language capabilities, user, and deployment context.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\intl.cpl`. Its fixed numeric file version was
`10.0.26100.8737`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [dism.exe](dism.exe.md)
- [chcp.com](chcp.com.md)
- [tzutil.exe](tzutil.exe.md)
- [control.exe](control.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[international-settings guidance](https://learn.microsoft.com/windows-hardware/manufacture/desktop/configure-international-settings-in-windows),
[International PowerShell module reference](https://learn.microsoft.com/powershell/module/international/),
and [Control Panel canonical names](https://learn.microsoft.com/windows/win32/shell/controlpanel-canonical-names).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
