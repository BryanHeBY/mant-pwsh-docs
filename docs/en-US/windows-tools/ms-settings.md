<!-- mant:tldr:start -->
# ms-settings

> Open a specific page in the Windows Settings application through its URI scheme.
> More information: https://learn.microsoft.com/windows/apps/develop/launch/launch-settings.

- Open the Settings home page:

`Start-Process 'ms-settings:'`

- Open Display settings:

`Start-Process 'ms-settings:display'`

- Open Windows Update settings:

`Start-Process 'ms-settings:windowsupdate'`
<!-- mant:tldr:end -->

# ms-settings

## Overview

`ms-settings:` is a Windows URI scheme, not an executable or a configuration
language. It asks the Windows shell to open the Settings application at a
particular page. Use it to guide an interactive user, not to assert or change
configuration silently.

## Syntax

```text
ms-settings:PAGE
ms-settings:PAGE?QUERY
```

From PowerShell, pass the complete URI as one string:

```powershell
$uri = 'ms-settings:network-status'
Start-Process $uri
```

The official URI reference groups pages for accounts, apps, devices,
accessibility, gaming, network, personalization, privacy, sound, system, time
and language, and updates. Use the current Microsoft table rather than guessing
a URI from the localized page title.

## Useful page identifiers

- `ms-settings:`: Settings home.
- `ms-settings:display`: Display settings.
- `ms-settings:network-status`: Network and Internet status.
- `ms-settings:appsfeatures`: Installed apps and app features where supported.
- `ms-settings:privacy`: Privacy settings home where supported.
- `ms-settings:windowsupdate`: Windows Update.

Availability of an identifier can depend on Windows release, SKU, hardware,
installed apps, policy, and feature state.

## Common mistakes

### Treating the URI as a command that changes a setting

`Start-Process 'ms-settings:display'` only opens a page. It does not select a
value, return the current setting, or confirm that the user changed anything.

### Converting a visible Settings title into a URI

Page titles are localized and can change. URI identifiers are fixed strings
listed in the official reference; paths such as
`ms-settings:Devices\Pen & Windows Ink` are not valid merely because they
resemble the navigation labels.

### Assuming every documented URI exists everywhere

Some pages require particular Windows versions, editions, hardware, packages,
or policy. Handle failure and provide a fallback instructions page rather than
assuming launch success.

### Using it without an interactive desktop

A service, background agent, remote noninteractive task, or Windows container
cannot rely on a visible Settings window.

## Version and platform differences

The scheme applies to supported Windows client releases and selected Windows
Server desktop experiences. The official table is updated as Settings evolves;
the page identifier must be checked for the target version and SKU.

## Related documents

- [control](control.md)
- [explorer](explorer.md)
- [start](start.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Launch Windows Settings](https://learn.microsoft.com/windows/apps/develop/launch/launch-settings)
reference. The distinction between opening a page and changing a setting is
also motivated by the community question
[Open and Change Windows Settings via PowerShell](https://stackoverflow.com/questions/53938350/open-and-change-windows-settings-via-powershell).
The exact checked pages and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
