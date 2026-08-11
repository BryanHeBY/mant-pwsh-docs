<!-- mant:tldr:start -->
# wecutil

> Inventory Windows Event Collector subscriptions, exact XML configuration, per-source runtime status, service state, and received events before quick-configuring or changing delivery.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/wecutil.

- Enumerate subscription IDs; account for the documented BOM when scripting output:

`wecutil.exe enum-subscription`

- Export one exact subscription's configuration as Unicode XML:

`wecutil.exe get-subscription "{{subscription-id}}" /f:XML /uni:true`

- Query runtime status for the subscription and all known event sources:

`wecutil.exe get-subscriptionruntimestatus "{{subscription-id}}"`

- Narrow runtime status to one exact source identity:

`wecutil.exe get-subscriptionruntimestatus "{{subscription-id}}" "{{source.example.com}}"`

- Query the collector service without starting or reconfiguring it:

`sc.exe query Wecsvc`

- Inspect recent received events and retain their original source-computer fields:

`wevtutil.exe query-events ForwardedEvents /c:{{20}} /rd:true /f:RenderedXml /e:Events`
<!-- mant:tldr:end -->

# wecutil

## Overview

`wecutil.exe` manages Windows Event Forwarding subscriptions backed by the
Windows Event Collector service and WS-Management. It can enumerate, get,
runtime-check, create, set, delete, retry subscriptions, and quick-configure the collector.
Configuration existence is not delivery success: `gr` runtime status and actual
destination events must be checked per source.

## Subscription dimensions

<!-- mant:entries role=command case=insensitive -->
- `wecutil.exe`: Inspect or administer Windows Event Collector subscriptions.
- `es`: Enumerate configured subscription names.
- `gs`: Get one subscription's stored configuration.
- `gr`: Get one subscription's runtime source status.
- `cs`: Create a subscription from reviewed XML.
- `ss`: Set one subscription from switches or reviewed XML.
- `ds`: Delete one subscription.
- `rs`: Retry one subscription against an exact source.
- `qc`: Quick-configure the collector service and channel ACLs; state-changing.
- `enum-logs`: Enumerate forwarding-related logs where supported.
- `get-log`: Read one forwarding log's configuration.
- `set-log`: Change one forwarding log's configuration.

Switches are command-specific; credentials and XML can contain secrets.

<!-- mant:entries role=option case=insensitive -->
- `/c`: Read subscription configuration from a reviewed XML file.
- `/f`: Select terse or XML output where supported.
- `/q`: Suppress prompts for a state-changing operation.
- `/rd`: Select whether existing events are read when activating a source.
- `/up`: Supply an alternate subscription username.
- `/cup`: Supply or prompt for its password; prefer `*` console input.
- `/?`: Display command-specific installed help.

Preserve subscription ID/type (collector- or source-initiated), enabled/source
state, source addresses/authorization, QueryList and URI/dialect, destination
log/publisher, content/locale, read-existing policy/bookmarks, delivery mode/
batch/latency/heartbeat, transport/port/SPN hostname, credential type/certificate
issuers/SDDL, expiration, and collector/service/channel configuration.

Use source FQDN and event `Computer`/provider/channel/record/time/bookmark fields
to prove provenance. A source can be configured yet inactive, delayed, denied,
backlogged, filtered, or writing to a different log.

## Common mistakes

### Treating create/set success as working collection

Microsoft documents that incorrect credentials may not surface until `gr`
runtime status. Always check each source, collector operational events, WinRM/
WEC events, destination events, bookmarks/latency, source generation, and
end-to-end test evidence after a controlled change.

### Running `quick-config` as a query

`wecutil qc` enables ForwardedEvents if needed, changes Wecsvc to delayed start,
and starts it. It does not design subscriptions, source policy, transport,
authorization, capacity, retention, or monitoring. Inventory and use approved
central configuration/change control; never run it merely to clear an error.

### Starting Wecsvc because RPC/interface errors appear

The official page points to a stopped collector service for certain errors, but
starting it is a state change and may activate existing subscriptions. Query
service/config/dependencies/policy/events and intended collector role first;
coordinate startup and observe the resulting ingestion load.

### Ignoring the BOM and localized/terse output

Microsoft notes `wecutil es` can begin with UTF-8 BOM bytes that break scripts.
Prefer XML/Unicode where available, strip BOM deliberately, keep IDs exact, and
do not parse localized name-value output with whitespace assumptions.

### Confusing source- and collector-initiated authorization

Who initiates, push/pull delivery, source list, computer-group SDDL, allowed/
denied names, issuer certificates, hostname/SPN, and credential ownership differ.
Do not copy settings or wildcard allowed sources between models; model mutual
identity and least privilege explicitly.

### Putting subscription passwords on the command line

`/up:` and `/cup:` can leak through history, process telemetry, logs, and XML/
automation artifacts. Microsoft supports `*` console input for `/cup`; prefer
managed/default computer identities and protected policy. Rotate and contain any
legacy credential and verify runtime status after change.

### Misreading `ReadExistingEvents`

Enabling existing-event reads can create a large historical backlog/duplicates;
future-only can omit the history an investigator expected. Bookmarks, recreation,
source retention, query changes, and subscription identity affect replay. Define
start semantics, deduplication keys, capacity, and acceptance evidence before use.

### Tuning latency/batch/heartbeat without capacity evidence

MinLatency, MinBandwidth, Normal, and Custom combine delivery parameters. Low
latency/high heartbeat increases connections/overhead; large batches/latency
delay visibility and amplify backlog. Measure source rate/size, collector CPU/
memory/disk, queue/retention, network, and downstream ingestion before changes.

### Scaling by modifying internal registry ACLs

Practitioner reports show lifetime source metadata can make Event Viewer slow at
scale. Do not deny or edit internal subscription registry keys from a workaround.
Use supported WEC sizing/sharding, stale-source lifecycle, `wecutil`, monitoring,
backup, and Microsoft guidance; preserve bookmarks needed for correctness.

## PowerShell boundaries

Use `wecutil.exe` explicitly with scalar subscription/source identifiers.
Capture stdout/stderr and `$LASTEXITCODE`; preserve XML and runtime status before
parsing. Do not interpolate passwords or QueryList XML into an expression. Use
an XML file and schema-aware review for create/set operations.

## Version and platform differences

`wecutil.exe` is Windows-only. Subscription options, credential/certificate
models, WSMan/WinRM policy, Wecsvc, Event Log channels, output encoding, scale,
and access vary by Windows/WMF build, edition, domain/workgroup, role, and policy.

## Related documents

- [wevtutil](wevtutil.md)
- [winrm.exe](winrm.md)
- [eventcreate](eventcreate.md)
- [sc.exe](sc.md)

## Sources and license

This original guide was adapted from Microsoft's official
[wecutil command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/wecutil)
and detailed [WEC API utility reference](https://learn.microsoft.com/windows/win32/wec/wecutil).
Scale/operability demand was cross-checked against a practitioner report of
[Event Viewer degradation with lifetime WEF sources](https://serverfault.com/questions/1148013/windows-event-collector-wef-event-viewer-unresponsive).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
