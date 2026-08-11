<!-- mant:tldr:start -->
# pktmon

> Inspect Windows networking components and run a bounded, filtered Packet Monitor session while protecting captured traffic.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pktmon.

- Check whether the system-wide Packet Monitor session is already running:

`pktmon.exe status`

- Inventory every monitorable component as structured data; do not persist component IDs across boots or topology changes:

`pktmon.exe list --json | ConvertFrom-Json`

- Review every active packet filter before starting a capture:

`pktmon.exe filter list`

- During an approved session, display current counters and drop reasons as structured data:

`pktmon.exe counters --json | ConvertFrom-Json`

- Convert a copied ETL to PCAPNG at an explicit destination, remembering that conversion loses component-flow and drop-report semantics:

`pktmon.exe etl2pcap "{{capture.etl}}" --out "{{capture.pcapng}}"`

<!-- mant:tldr:end -->

# pktmon

## Overview

`pktmon.exe` is Windows Packet Monitor. It inventories networking-stack
components, applies packet filters, collects flow/drop counters or packet and
ETW data, and converts ETL captures to text or PCAPNG. It observes packets at
multiple components inside the host, so one network packet can appear several
times as it moves through the stack.

Packet captures can contain credentials, tokens, cookies, addresses, payloads,
tenant data, and network topology. Obtain authorization, minimize scope and
packet length, use a protected output directory, bound time and size, and
define retention/deletion before capture.

## Commands and shared parameters

<!-- mant:entries role=command case=insensitive -->
- `pktmon.exe`: Inspect or control Windows Packet Monitor.
- `filter`: List, add, or remove packet filters.
- `list`: List current packet-processing components.
- `start`: Start packet capture, counters, and/or ETW event collection.
- `stop`: Stop the shared Packet Monitor collection session.
- `status`: Display current collection and logging state.
- `unload`: Unload the Packet Monitor driver after an approved recovery decision.
- `counters`: Display current flow and drop counters.
- `reset`: Reset packet counters to zero.
- `etl2txt`: Convert a copied Packet Monitor ETL to text.
- `etl2pcap`: Convert a copied Packet Monitor ETL to PCAPNG.
- `hex2pkt`: Decode packet bytes supplied in hexadecimal form.
- `help`: Display top-level or subcommand-specific installed help.

Long-option support varies substantially by Windows build and subcommand.
These entries expose the options used in the bounded workflow above.

<!-- mant:entries role=option case=insensitive -->
- `--json`: Emit documented structured output for supported inventory/counter commands.
- `--capture`: Enable packet capture rather than only event collection.
- `--counters-only`: Collect counters without logging packet bytes.
- `--trace`: Enable ETW provider event collection.
- `--pkt-size`: Set captured bytes per packet; zero requests full packets.
- `--file-name`: Select an explicit protected ETL destination.
- `--file-size`: Set the per-file size limit for supported log modes.
- `--log-mode`: Select circular, multi-file, real-time, or memory logging behavior.
- `--comp`: Select packet-monitor component IDs after fresh discovery.
- `--type`: Select packet/counter category or component type as documented by
  the exact subcommand.
- `--flags`: Select the packet-capture metadata/raw-packet bitmask.
- `--provider`: Select an ETW provider name or GUID; repeat it for more providers.
- `--keywords`: Select an ETW provider keyword mask.
- `--level`: Select ETW event level where documented.
- `--drop-only`: Restrict supported output/conversion to dropped packets.
- `--component-id`: Restrict PCAPNG conversion to one component ID.
- `--out`: Select a new text or PCAPNG conversion destination.
- `--stats-only`: Display only ETL statistics during text conversion.
- `--timestamp-only`: Use only a timestamp as the converted text event prefix.
- `--metadata`: Include ETW event level and keyword metadata in converted text.
- `--tmfpath`: Select trusted TMF search paths for WPP decoding.
- `--brief`: Use compact supported text rendering.
- `--verbose`: Include extended supported text fields.
- `--hex`: Include packet bytes in supported text output.
- `--no-ethernet`: Omit Ethernet headers from converted text packet rendering.
- `--vxlan`: Select a custom VXLAN port for converted text decoding.
- `--zero`: Include counters that are zero in both directions.
- `--include-hidden`: Include counters from normally hidden components.
- `--drop-reason`: Include the most recent reason for each drop counter.
- `--live`: Continuously refresh counter output until interrupted.
- `--refresh-rate`: Set live counter refreshes per second from 1 through 30.

## A bounded capture lifecycle

Use separate, reviewed commands so each state transition can be verified:

1. Run `pktmon status`, `pktmon list --json`, and `pktmon filter list`.
2. Remove stale filters only after recording them, then add a narrow named
   filter, for example `pktmon filter add Dns53 -p 53`.
3. Prefer counters-only diagnosis first: `pktmon start --capture
   --counters-only`. If bytes are essential, use an explicit protected ETL,
   circular mode, bounded size, and the minimum `--pkt-size`.
4. Reproduce one approved scenario for a fixed time and inspect counters.
5. Run `pktmon stop` in normal and failure cleanup. Recheck `pktmon status`.
6. Preserve the original ETL and metadata before converting a copied file.

The CLI can normally affect a shared system-wide session. Coordinate with
other diagnostics instead of resetting, unloading, or replacing their state.

## Filters and component identity

Up to 32 filters can be active. Conditions within one filter are combined;
packets are reported when every condition in at least one filter matches.
When two MAC addresses, IP addresses, or ports are specified, matching does
not distinguish source from destination. Do not describe `-i` or `-p` as a
directional source/destination selector.

`pktmon list --json` includes all and hidden components. Component IDs describe
the current networking stack and are not stable inventory keys; rediscover
them after reboot, driver, adapter, virtual-switch, container, VPN, filter, or
binding changes.

## Counters, capture, and conversion

Counters provide a lower-disclosure first view of flows and drops. JSON output
implies hidden components and drop reasons. A zero counter can mean no matching
traffic, the wrong component/filter, offload or encapsulation effects, or a
capture that was not active; it is not proof that the application sent nothing.

Packet logging defaults to a truncated packet size rather than full payload.
`--pkt-size 0` records complete packets and sharply raises privacy, size, and
secret-exposure risk. Circular logging overwrites the oldest events at the
limit; multi-file mode keeps creating files and is not bounded by file count.
Real-time mode creates no log, while memory mode writes its buffer when stopped.

PCAPNG conversion is convenient for analyzers but discards Packet Monitor's
component path and packet-drop report semantics. Dropped packets are excluded
by default. When those distinctions matter, retain and analyze the original
ETL/text evidence and create purpose-specific PCAPNG copies with component or
drop-only filtering.

## Common mistakes

### Capturing everything before adding a filter

An unfiltered, full-packet capture can expose unrelated users and fill or
overwrite storage. Confirm the active filter list, capture the smallest header
slice and duration that answers the question, and prefer counters-only mode.

### Reading a port or IP filter as directional

Packet Monitor matches either source or destination. Two supplied values mean
the packet contains both, not “source then destination.” Validate against test
traffic and use component context or later analysis for direction.

### Counting the same packet as several network packets

Snapshots at several stack components can share a packet group/number. Use
Packet Monitor correlation fields and component path to reconstruct flow;
do not sum every row as independent wire traffic.

### Leaving a session, trace, or live display running

Always include `pktmon stop` in cleanup and verify status afterward. A stale
session changes later filters/counters and can continue collecting sensitive
data or consuming storage and memory.

### Using `reset` or `unload` as routine cleanup

These operations can disrupt shared diagnostic state or unload the driver.
Use status, filter inventory, and normal stop first; reserve stronger actions
for an approved recovery procedure with console access and ownership.

### Converting to PCAPNG and deleting the ETL

Conversion is lossy for Packet Monitor-specific flow and drop information.
Hash and retain the original under the evidence policy, record conversion
options/tool version, and analyze a copy.

### Copying syntax from a newer Windows build

Subcommands such as PCAPNG conversion and option spellings have varied. Query
`pktmon help` and subcommand help on the target; an “unknown command” can be a
version mismatch rather than corrupt capture data.

## PowerShell boundaries

`pktmon` is a native application. Invoke `pktmon.exe`, parse only documented
JSON modes with `ConvertFrom-Json`, preserve raw output and `$LASTEXITCODE`,
and treat long-running/live commands as lifecycle-managed processes. Do not
parse localized tables when structured output exists.

## Version and platform differences

This command is Windows-only. Availability, options, capture flags, component
types, conversion support, elevation, and multi-session capabilities vary by
Windows build. Installed subcommand help is the runtime authority alongside
the applicable Microsoft Learn page.

## Related documents

- [netsh](netsh.md)
- [netstat](netstat.md)
- [tracerpt](tracerpt.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Packet Monitor command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pktmon),
[Packet Monitor overview](https://learn.microsoft.com/windows-server/networking/technologies/pktmon/pktmon),
[command-format guide](https://learn.microsoft.com/windows-server/networking/technologies/pktmon/pktmon-syntax),
[filter syntax](https://learn.microsoft.com/windows-server/administration/windows-commands/pktmon-filter-add),
[capture syntax](https://learn.microsoft.com/windows-server/administration/windows-commands/pktmon-start),
and [PCAPNG conversion reference](https://learn.microsoft.com/windows-server/administration/windows-commands/pktmon-etl2pcap).
A practitioner question about an unavailable `pcapng` subcommand was used as
a version-mismatch demand signal; current syntax follows Microsoft Learn.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
