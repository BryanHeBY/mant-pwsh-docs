<!-- mant:tldr:start -->
# Get-WinEvent

> Query Windows event logs with bounded, source-side filters; inspect channel state before treating an empty result as evidence.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-5.1.

- Inspect one exact event-log channel without changing it:

`Get-WinEvent -ListLog '{{Microsoft-Windows-Provider/Operational}}' | Select-Object LogName, IsEnabled, RecordCount, LastWriteTime`

- Read a bounded number of the newest events from one enabled channel:

`Get-WinEvent -LogName '{{log-name}}' -MaxEvents {{50}}`

- Filter by channel, event ID, and start time before events are materialized:

`Get-WinEvent -FilterHashtable @{ LogName = '{{log-name}}'; Id = {{event-id}}; StartTime = (Get-Date).AddHours(-{{24}}) } -MaxEvents {{100}}`

- Preserve structured event identity instead of parsing localized message text:

`Get-WinEvent -FilterHashtable @{ LogName = '{{log-name}}'; StartTime = (Get-Date).AddDays(-{{1}}) } -MaxEvents {{100}} | Select-Object TimeCreated, Id, Level, ProviderName, RecordId, Properties`
<!-- mant:tldr:end -->

# Get-WinEvent

## Synopsis

```powershell
Get-WinEvent [-ListLog] <string[]> [-ComputerName <string>] [-Force]
Get-WinEvent [-LogName] <string[]> [-MaxEvents <long>] [-ComputerName <string>]
Get-WinEvent -FilterHashtable <hashtable[]> [-MaxEvents <long>]
Get-WinEvent -FilterXPath <string> [-LogName <string[]>] [-MaxEvents <long>]
Get-WinEvent -FilterXml <xml> [-MaxEvents <long>]
Get-WinEvent -Path <string[]> [-MaxEvents <long>] [-Oldest]
```

`Get-WinEvent` reads Windows Event Log channels and archived event files. It
returns structured `EventLogRecord` objects, normally newest first. Some logs
require elevation or a specific channel ACL.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-ListLog LOG`: Return channel configuration objects, including `IsEnabled`, retention mode, size, and record metadata; it does not read event records.
- `-ListProvider PROVIDER`: Return registered event-provider metadata.
- `-LogName LOG`: Read event records from one or more matching channel names.
- `-ProviderName PROVIDER`: Select events from one or more provider names in the supported parameter set.
- `-FilterHashtable TABLE`: Apply structured log, provider, ID, level, time, user, or data constraints at the event service.
- `-FilterXPath QUERY`: Apply an XPath event query to the selected channel.
- `-FilterXml XML`: Apply a structured XML query that can select or suppress events across channels.
- `-Path PATH`: Read reviewed `.evtx`, `.evt`, or `.etl` files rather than live channels.
- `-MaxEvents COUNT`: Bound the number of records returned; combine it with a selective filter for predictable cost.
- `-Oldest`: Return oldest-first ordering and satisfy event-trace log formats that require it.
- `-ComputerName COMPUTER`: Query a remote Windows host using Event Log remoting; authorization, firewall, and service policy still apply.
- `-Credential CREDENTIAL`: Supply credentials for the remote query parameter set; avoid embedding secrets.
- `-Force`: Include debug and analytic logs during wildcard discovery; it does not enable a disabled channel or bypass its ACL.

## Query workflow

Inspect the exact channel before reading records:

```powershell
$logName = 'Microsoft-Windows-TaskScheduler/Operational'
$log = Get-WinEvent -ListLog $logName
$log | Select-Object LogName, IsEnabled, RecordCount, LastWriteTime
```

If `IsEnabled` is false, an empty record query does not prove the monitored
activity never occurred. Enabling a channel is a separate state-changing
decision and generally supplies future evidence; it cannot recreate events
that were never recorded.

Prefer source-side filtering to retrieving a whole log and then using
`Where-Object`:

```powershell
$start = (Get-Date).AddHours(-24)
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-TaskScheduler/Operational'
    StartTime = $start
} -MaxEvents 200 |
    Select-Object TimeCreated, Id, Level, ProviderName, RecordId, Properties
```

Windows PowerShell 5.1 does not support the PowerShell 6+ extension that uses
a named event-data field directly as a `FilterHashtable` key. Use the supported
keys or a reviewed XPath/XML query for that case.

## Result interpretation

`Message` is rendered provider text and can be localized, missing, or changed
between versions. Use `LogName`, `ProviderName`, `Id`, `Level`, `TimeCreated`,
`RecordId`, `UserId`, `Properties`, and `ToXml()` for durable correlation.
Event presence proves that the provider recorded an event, not that a child
process or business operation reached its intended postcondition.

## Common mistakes

- Treating a disabled channel as empty history without checking `IsEnabled`.
- Filtering localized `Message` text before structured log/provider/ID/time data.
- Reading an unbounded live or archived log instead of using a selective filter
  and `-MaxEvents`.
- Assuming a non-elevated access error proves that a log or event is absent.
- Enabling or clearing a channel merely to make a diagnostic read succeed.

## Version and availability

This cmdlet is Windows-only. Channel names, providers, IDs, ACLs, schemas,
retention, message resources, remote access, and enabled state vary by host.
The named event-data `FilterHashtable` extension is not available in 5.1.

## Runtime evidence

Windows PowerShell 5.1.26100.9168 exposed every parameter documented above
through live command metadata. The fixture did not read event records or change
a log, retention setting, provider, remote host, or task.

## Related documents

- [Where-Object](Where-Object.md)
- [Select-Object](Select-Object.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from Microsoft's official
[Get-WinEvent reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-5.1)
and [FilterHashtable query guide](https://learn.microsoft.com/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable?view=powershell-7.6).
Exact upstream revision and paths are recorded in `upstream/pwsh51.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
