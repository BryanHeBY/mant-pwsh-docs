<!-- mant:tldr:start -->
# eventvwr

> Open Event Viewer for interactive exploration while preserving raw event identity, XML, channel, provider, record ID, timestamps and query direction; use Wevtutil or WinEvent for reproducible automation.
> More information: https://learn.microsoft.com/troubleshoot/windows-client/system-management-components/delete-saved-log-from-event-viewer.

- Open the Event Viewer MMC snap-in:

`eventvwr.msc`

- Launch Event Viewer through its executable entry point:

`eventvwr.exe`
<!-- mant:tldr:end -->

# eventvwr

## Overview

Event Viewer is an MMC interface for Windows Logs, Applications and Services
Logs, subscriptions, saved logs, filters and event details. Rendered text is a
view over provider metadata; raw XML and EVTX provenance remain essential.

## Common mistakes

- Searching only rendered messages and losing provider GUID/name, channel,
  record ID, UTC/SystemTime, activity/process/thread/user IDs and event XML.
- Assuming GUI filter time direction, level, keyword or Event ID semantics match
  an XPath/WinEvent query, or that “no events” means a successful empty result.
- Clearing, overwriting, archiving, attaching a task, changing channel retention/
  size/access, or managing subscriptions during an investigation without custody.
- Opening an EVTX copy with mismatched provider resources and treating missing or
  differently rendered messages as corrupted/missing raw events.
- Automating localized tree labels/UI instead of bounded `wevtutil`,
  `Get-WinEvent`, Windows Event Log APIs, or an approved collector query.

## PowerShell behavior

Use `Start-Process eventvwr.msc` for interactive launch. For automation, use
`Get-WinEvent -FilterHashtable`/XPath or `wevtutil.exe`, capture native errors,
and preserve raw XML/EVTX plus query, clock, locale and artifact hashes.

## Version and platform differences

`eventvwr.msc`/`eventvwr.exe` are Windows-only. Channels, providers, rendering,
permissions, subscriptions, views and UI vary by build and installed products.

## Related documents

- [wevtutil](wevtutil.md)
- [wecutil](wecutil.md)
- [eventcreate](eventcreate.md)
- [mmc](mmc.md)

## Sources and license

This original guide was adapted from Microsoft's
[Event Viewer saved-log guide](https://learn.microsoft.com/troubleshoot/windows-client/system-management-components/delete-saved-log-from-event-viewer).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
