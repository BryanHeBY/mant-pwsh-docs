<!-- mant:tldr:start -->
# Get-WinEvent

> Query Windows event logs with bounded, source-side filters; inspect channel state before treating an empty result as evidence.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.6.

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
returns structured `EventLogRecord` objects, normally newest first. It is
Windows-only, and some logs require elevation or a specific channel ACL.

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-ListLog LOG`: Return channel configuration objects, including `IsEnabled`, retention mode, size, and record metadata; it does not read event records.
- `-ListProvider PROVIDER`: Return registered event-provider metadata.
- `-LogName LOG`: Read event records from one or more matching channel names.
- `-ProviderName PROVIDER`: Select events from one or more provider names in the supported parameter set.
- `-FilterHashtable TABLE`: Apply structured log, provider, ID, level, time, user, data, or named-data constraints at the event service.
- `-FilterXPath QUERY`: Apply an XPath event query to the selected channel.
- `-FilterXml XML`: Apply a structured XML query that can select or suppress events across channels.
- `-Path PATH`: Read reviewed `.evtx`, `.evt`, or `.etl` files rather than live channels.
- `-MaxEvents COUNT`: Bound the number of records returned; combine it with a selective filter for predictable cost.
- `-Oldest`: Return oldest-first ordering and satisfy event-trace log formats that require it.
- `-ComputerName COMPUTER`: Query a remote Windows host using Event Log remoting; authorization, firewall, and service policy still apply.
- `-Credential CREDENTIAL`: Supply credentials for the remote query parameter set; avoid embedding secrets.
- `-Force`: Include debug and analytic logs during wildcard discovery; it does not enable a disabled channel or bypass its ACL.

## Query workflow

First inspect the exact channel configuration:

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

PowerShell 6 and later also accept a named event-data field as a
`FilterHashtable` key. The field name is case-sensitive because it refers to
the event XML. Verify the provider schema before relying on it.

## Result interpretation

`Message` is rendered provider text and can be localized, missing, or changed
between versions. Use `LogName`, `ProviderName`, `Id`, `Level`, `TimeCreated`,
`RecordId`, `UserId`, `Properties`, and `ToXml()` for durable correlation.
Event presence proves that the provider recorded an event, not that a child
process or business operation reached its intended postcondition.

## Common mistakes

### Treating a disabled channel as an empty history

Check `-ListLog` and `IsEnabled` before interpreting zero records. Preserve the
channel state in incident notes, and do not enable or clear a log merely to make
a read-only query work.

### Filtering message text before structured fields

Message rendering is localized and can be expensive. Filter by log, provider,
ID, level, time, user, or event data first; use message text only as supporting
display evidence.

### Starting an unbounded query

Large Security, System, operational, or archived logs can consume substantial
time and memory. Set a time/ID/provider filter and `-MaxEvents`, then widen the
window deliberately if needed.

## Platform and version differences

This cmdlet is Windows-only. Channel names, providers, IDs, ACLs, schemas,
retention, message resources, remote access, and enabled state vary by host.
Named event-data keys in `-FilterHashtable` require PowerShell 6 or later.

## Runtime evidence

PowerShell 7.6.4 on Windows exposed every parameter documented above through
live command metadata. The fixture did not read event records or change a log,
retention setting, provider, remote host, or task.

## Related documents

- [Where-Object](Where-Object.md)
- [Select-Object](Select-Object.md)
- [about_Pipelines](about_Pipelines.md)

## Sources and license

This original ManT-oriented page was adapted from Microsoft's official
[Get-WinEvent reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.6)
and [FilterHashtable query guide](https://learn.microsoft.com/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable?view=powershell-7.6).
Exact upstream revision and paths are recorded in `upstream/pwsh7.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
