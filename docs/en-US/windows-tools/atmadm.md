<!-- mant:tldr:start -->
# atmadm

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

# atmadm

## Overview

`atmadm.exe` is a read-only diagnostic for the Windows ATM Call Manager. `/c`
lists current connections and their VPI/VCI, direction, call type, remote NSAP,
and media rates; `/a` lists registered ATM Network Service Access Point
addresses; `/s` reports current, successful, failed, closed, signaling, and
ILMI packet counters.

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

## PowerShell behavior

The output is localized text, not objects. Preserve the raw output with host,
timestamp, adapter identity, and `$LASTEXITCODE`; do not build durable parsing
around spacing from one sample. The command has no documented mutation mode.

## Version and platform differences

ATM hardware and its Windows stack are legacy and normally absent from modern
hosts. Verify the executable, driver, adapter, and local help on the exact
system. The current Microsoft Learn banner does not prove that every listed
Windows edition includes usable ATM support.

## Related documents

- [getmac](getmac.md)
- [pktmon](pktmon.md)

## Sources and license

Adapted as an original diagnostic guide from Microsoft's
[atmadm reference](https://learn.microsoft.com/windows-server/administration/windows-commands/atmadm).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
