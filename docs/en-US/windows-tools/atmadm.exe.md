<!-- mant:tldr:start -->
# atmadm.exe

> Inventory a legacy Asynchronous Transfer Mode (ATM) adapter and its active calls without changing network state.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/atmadm.

- Confirm that the executable and ATM-era device support exist:

`Get-Command atmadm.exe -ErrorAction SilentlyContinue; Get-NetAdapter -IncludeHidden | Select-Object Name, InterfaceDescription, Status`

- Display current ATM connections:

`atmadm.exe /c`

- Display each ATM adapter's registered NSAP address:

`atmadm.exe /a`

- Display active-call and signaling statistics:

`atmadm.exe /s`
<!-- mant:tldr:end -->

# atmadm.exe

## Overview

`atmadm.exe` is a read-only diagnostic for the Windows ATM Call Manager. `/c`
lists current connections and their VPI/VCI, direction, call type, remote NSAP,
and media rates; `/a` lists registered ATM Network Service Access Point
addresses; `/s` reports current, successful, failed, closed, signaling, and
ILMI packet counters.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `atmadm.exe`: Display legacy ATM Call Manager connection, address, or counter data.

All modes are read-only and meaningful only when a compatible ATM stack and
adapter are present.

<!-- mant:entries role=option case=insensitive -->
- `/c`: Display every current ATM connection and its VPI/VCI and media data.
- `/a`: Display the registered ATM NSAP address for each installed adapter.
- `/s`: Display cumulative ATM Call Manager and ILMI statistics.
- `/?`: Display installed syntax.

## Common mistakes

### Reading an empty result as a network failure

The command is meaningful only when a compatible ATM adapter, driver, Call
Manager, and ATM link exist. First distinguish “tool or stack absent” from “no
active calls” and “adapter present but link failed.”

### Confusing ATM with ordinary Ethernet statistics

NSAP, VPI/VCI, SVC/PVC, UBR/CBR/VBR/ABR, and ILMI are ATM concepts. Use
`Get-NetAdapter`, `Get-NetAdapterStatistics`, `pktmon`, or vendor tools for
modern Ethernet rather than interpreting ATM counters as generic TCP/IP data.

### Treating cumulative counters as rates

`/s` reports totals as well as a current-call count. Record two timestamped
samples and calculate a delta before claiming a failure rate; account for
adapter reset, driver reload, or reboot.

## PowerShell boundaries

The output is localized text, not objects. Preserve the raw output with host,
timestamp, adapter identity, and `$LASTEXITCODE`; do not build durable parsing
around spacing from one sample. The command has no documented mutation mode.

## Version and platform differences

ATM hardware and its Windows stack are legacy and normally absent from modern
hosts. Verify the executable, driver, adapter, and local help on the exact
system. The current Microsoft Learn banner does not prove that every listed
Windows edition includes usable ATM support.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`atmadm.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains resolution, adapter inventory and /c /a /s
reads only on an approved ATM fixture; no driver, adapter, link, call,
signaling or network mutation is permitted merely for evidence.

## Related documents
- [getmac.exe](getmac.exe.md)
- [pktmon.exe](pktmon.exe.md)

## Sources and license

Adapted as an original diagnostic guide from Microsoft's
[atmadm reference](https://learn.microsoft.com/windows-server/administration/windows-commands/atmadm).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
