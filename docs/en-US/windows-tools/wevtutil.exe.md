<!-- mant:tldr:start -->
# wevtutil.exe

> Inventory Windows Event Log channels/providers, query bounded events as XML, and export EVTX evidence before changing channel policy, manifests, or clearing logs.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/wevtutil.

- Enumerate exact channel names; access denied and disabled channels are distinct from absence:

`wevtutil.exe enum-logs`

- Inspect one channel's enabled, retention, size, file, isolation, and access configuration as XML:

`wevtutil.exe get-log "{{System}}" /f:xml`

- Query the newest bounded events and wrap RenderedXml in one root element:

`wevtutil.exe query-events "{{System}}" /c:{{20}} /rd:true /f:RenderedXml /e:Events`

- Query a bounded recent UTC-relative window using the Event Log XPath subset:

`wevtutil.exe query-events "{{System}}" '/q:*[System[TimeCreated[timediff(@SystemTime) <= {{3600000}}]]]' /rd:true /f:RenderedXml /e:Events`

- Export one exact channel to a new EVTX file without silently overwriting evidence:

`wevtutil.exe export-log "{{System}}" "{{C:\Evidence\System.evtx}}" /ow:false`

- Query a copied EVTX file rather than the live channel:

`wevtutil.exe query-events "{{C:\Evidence\System.evtx}}" /lf:true /c:{{20}} /rd:true /f:RenderedXml /e:Events`

- Enumerate publisher names before retrieving one exact publisher's metadata:

`wevtutil.exe enum-publishers`
<!-- mant:tldr:end -->

# wevtutil.exe

## Overview

`wevtutil.exe` enumerates channels/publishers, retrieves configuration/metadata,
queries events, inspects log-file information, exports/archives EVTX, installs/
uninstalls event manifests, changes channel configuration, and clears logs. The
last four categories can alter evidence, collection, provider registration,
retention, access, and system behavior. The TLDR is query/export-only.

## Commands

<!-- mant:entries role=command case=insensitive -->
- `el`, `enum-logs`: Enumerate event-log channel names visible to the caller.
- `gl`, `get-log`: Retrieve configuration and status for one exact channel.
- `sl`, `set-log`: Change one channel's enablement, retention, size, file, isolation, or access settings.
- `ep`, `enum-publishers`: Enumerate registered event publishers.
- `gp`, `get-publisher`: Retrieve one publisher's metadata and resources.
- `im`, `install-manifest`: Register channels and publishers from a reviewed product manifest.
- `um`, `uninstall-manifest`: Unregister a reviewed manifest and its provider/channel definitions.
- `qe`, `query-events`: Query bounded events from a channel, log file, or structured query.
- `gli`, `get-log-info`: Retrieve status information for a channel or log file.
- `epl`, `export-log`: Export a channel or filtered events to a new EVTX file.
- `al`, `archive-log`: Archive a log with locale resources, protecting the output path from replacement and reparse attacks.
- `cl`, `clear-log`: Clear one live channel, optionally requesting a backup; this destroys live evidence.

## Common query and export options

<!-- mant:entries role=option case=insensitive -->
- `/q:QUERY`: Apply an Event Log XPath or structured-query expression as one quoted argument.
- `/c:COUNT`: Limit the maximum number of returned events.
- `/rd:VALUE`: Select reverse direction when true so newest matching events are returned first.
- `/f:FORMAT`: Select text, XML, or rendered XML according to the command's supported formats.
- `/e:ELEMENT`: Wrap XML results in one root element so the output can form a complete XML document.
- `/lf:VALUE`: Treat the path as a log file rather than a live channel when true.
- `/sq:VALUE`: Treat the input as a structured query file where supported.
- `/ow:VALUE`: Allow or refuse overwriting an export/archive output; default to a new evidence path.
- `/r:COMPUTER`: Target a remote computer for commands that support remoting.
- `/u:USER`, `/p:PASSWORD`: Select remote credentials; use approved secret handling instead of an inline password.
- `/a:AUTH`: Select the supported remote authentication type.
- `/uni:VALUE`: Request Unicode output for a supported remote operation.
- `/bu:FILE`: Back up a log before a clear operation; verify the artifact independently before approved clearing.

## Safe evidence workflow

1. Record host, build, time/timezone/clock source, caller/token, channel name,
   query/XPath, direction/count, locale/rendering mode, and collection time.
2. Capture channel configuration and status, then export the relevant full or
   filtered log to a new access-controlled local volume. Hash and preserve the
   EVTX plus command/output/metadata under the evidence procedure.
3. Query a copy for analysis. Retain raw XML fields—provider GUID/name, channel,
   record ID, event ID/version/level/task/opcode/keywords, UTC SystemTime,
   computer, user SID, correlation/activity, execution process/thread, and data.
4. Rendered messages are useful but depend on provider resources and locale;
   never discard raw event XML because a message is missing.

## Common mistakes

### Using general XPath instead of the Event Log subset

Windows Event Log supports a limited XPath/query dialect and returns whole
events rather than arbitrary selected nodes. Validate on representative logs,
quote the expression as one PowerShell argument, reject query errors, and use a
structured QueryList file for complex multi-channel selections.

### Mixing local time with event `SystemTime`

Event XML records `SystemTime` in UTC. Locale-formatted rendered text, host clock
skew, daylight-saving transitions, collection delay, and ingestion time differ.
Use explicit UTC bounds or the documented `timediff` function, record clock
quality, and include boundary overlap rather than truncating exact incidents.

### Forgetting `/reverse:true` or `/count:`

Default direction and an unbounded query can return old/huge data, consume CPU/
I/O, or hide the incident tail. Set direction/count/time/provider/event filters
deliberately. A count is a maximum result size, not proof that fewer events
exist outside the filter or were never overwritten/dropped.

### Treating rendered text as canonical evidence

Message resources may be absent on another host, differ by provider version/
locale, or fail to render. Export EVTX and preserve RenderedXml/raw fields. Do
not parse a localized message string as the sole detection/control signal.

### Clearing logs as cleanup

`clear-log` destroys live records and can impair investigation/audit even when
`/backup:` is supplied. A backup path can fail, be incomplete, or be stored on
the same compromised/volatile system. Clear only under explicit retention/
incident policy after verified export, hash, access control, off-host custody,
and approval; never loop over `enum-logs` to clear all channels.

### Overwriting or archiving into an unsafe path

`/overwrite:true` replaces an existing export. Microsoft warns archive output
can overwrite locale-specific files and must not target a location containing
untrusted symlinks/junctions. Resolve the destination, require a new filename,
verify filesystem/reparse/ACL/free space, hash results, and protect them.

### Changing retention, size, enablement, isolation, or SDDL independently

These settings interact: retention may discard incoming events at full size,
overwrite mode loses old events, auto-backup requires retention, and access/
isolation affects writers/readers. Export current XML, calculate capacity/rate,
confirm collector policy and service ownership, stage one reviewed change, and
verify generation, collection, rollover, access, and rollback.

### Installing or uninstalling an untrusted manifest

Manifest operations register/unregister providers/channels and resource/message
paths. A path or binary can be malicious or break rendering/collection. Use the
signed product installer and vendor manifest lifecycle; verify signatures,
paths, architecture, publisher GUID/name, channel ownership, and rollback.

### Putting a remote password on the command line

`/remote:` selects a host; `/username:` and `/password:` can expose credentials.
Prefer the caller's approved identity/management channel; if an interactive
prompt is required, use the supported `*` behavior and protect the console.
Differentiate remote transport/auth/firewall failure from empty results.

## PowerShell behavior

Call `wevtutil.exe` explicitly. Quote each channel/path/query as a scalar; single
quotes conveniently protect XPath `$`, brackets, comparison characters, and
quotes from PowerShell, but the Event Log engine still validates the expression.
Capture streams and `$LASTEXITCODE` immediately. XML output becomes parseable as
one document only when a root element is requested.

For structured analysis, `Get-WinEvent` often provides typed records and FilterXml/
FilterHashtable, but it retains the same channel/provider/permission/time/query
boundaries. EVTX export and provenance remain separate from formatted objects.

## Version and platform differences

`wevtutil.exe` is Windows-only. Channels/providers, access, manifests, rendering,
query support, remote behavior, retention policy, and event schema vary by build,
edition, installed roles/products, language packs, policy, and caller rights.

## Related documents

- [wecutil.exe](wecutil.exe.md)
- [eventcreate.exe](eventcreate.exe.md)
- [winrm.exe](winrm.exe.md)
- [certutil.exe](certutil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[wevtutil reference](https://learn.microsoft.com/windows-server/administration/windows-commands/wevtutil).
XPath/time demand was cross-checked against a practitioner question on the
[Event Log XPath subset and UTC bounds](https://stackoverflow.com/questions/36789558/how-to-use-xpath-in-wevtutil-to-retrieve-events-since-a-specific-time).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
