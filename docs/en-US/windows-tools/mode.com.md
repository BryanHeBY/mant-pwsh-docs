<!-- mant:tldr:start -->
# mode.com

> Query console and device state before changing it; MODE spans serial ports,
> legacy printer redirection, console code pages, dimensions, and keyboard rate.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mode.

- Display controllable console attributes and available COM-device status:

`mode.com`

- Query one exact serial port without reconfiguring it:

`mode.com "{{COM3}}" /status`

- Query the console code-page state without selecting a new code page:

`mode.com con codepage /status`

- Correlate friendly port names with device identities before opening a COM port:

`Get-PnpDevice -Class Ports -PresentOnly | Format-Table Status, FriendlyName, InstanceId`

- Read Cmd's static MODE syntax without asking MODE to interpret a device token:

`cmd.exe /d /c help MODE`

<!-- mant:tldr:end -->

# mode.com

## Overview

`mode.com` is a multi-family Windows device utility. With no parameters it
displays controllable console attributes and available COM devices. It can also
configure serial framing/flow control, report device status, redirect legacy
LPT output to COM, query/select the console code page, resize the Cmd buffer,
and change keyboard typematic rate.

These families share a name, not a rollback or safety model. Query the exact
device and capture before-state. Prefer device/application-specific APIs when
automation needs structured status, exclusive ownership, timeouts, reliable
binary transfer, or modern terminal behavior.

## Command-family map

- Serial: `mode COMn` plus baud, parity, data bits, stop bits, timeout, XON/XOFF,
  DSR/CTS, DTR/RTS and DSR-sensitivity controls.
- Status: `mode [device] /status` for console, COM and legacy LPT state.
- Printing: privileged `mode LPTn=COMm` redirection after COM configuration.
- Encoding: `mode CON codepage /status` or `select=<number>`.
- Presentation/input: `mode CON cols= lines=` and `rate= delay=`.

## Families and option

<!-- mant:entries role=command case=insensitive -->
- `mode.com`: Display controllable console/COM state or address one explicit
  serial, console, keyboard, code-page, or legacy printer-redirection family.
- `COMn`: Query or configure one exact serial device's framing/flow-control state.
- `CON`: Query or configure console dimensions, code page, or keyboard rate/delay.
- `LPTn`: Query legacy printer-device status or configure supported COM redirection.

The slash status form is read-only; key/value operands can mutate device state.

<!-- mant:entries role=option case=insensitive -->
- `/status`: Display status for the selected console, COM, or legacy LPT device.

Microsoft's reference labels `/?` as help, but exact installed
10.0.26100.1 treated `mode.com /?` as an all-device/current-CON status query.
It is deliberately not a ManT help alias. Use `cmd.exe /d /c help MODE` for the
verified static syntax on this build; query a specific inactive device with an
explicit `/status` only after discovery.

## Common mistakes

### Treating `mode COM3` as a harmless query after adding options

The bare device/status form queries, but baud/parity/data/stop/handshake options
reconfigure shared device state. Identify the physical/USB/virtual device,
owner process, protocol specification and full before-state; coordinate exclusive
access and restore state after an approved test.

### Guessing serial defaults or abbreviations

Microsoft documents legacy abbreviated baud values, device-dependent parity/
data/stop support and multiple flow-control signals. Specify the complete
protocol contract; both endpoints must agree. A successful MODE command does
not prove wiring, pinout, voltage, driver, framing, receiver readiness, payload
integrity, or application protocol.

### Sending binary data through text-oriented shell commands

Encoding, Ctrl+Z, newline conversion, buffering and timeouts can corrupt or hang
a transfer. High-numbered ports may require the `\\.\COM10` namespace in APIs.
Use a serial library/tool with explicit byte, timeout and flow-control handling,
then validate length/hash/protocol response.

### Expecting console resizing to control Windows Terminal

MODE describes the classic Cmd console buffer. Windows Terminal, ConPTY,
remoting, redirection, IDE terminals and host profiles can ignore, constrain or
reinterpret dimensions. Do not resize shared/unattended sessions for formatting;
make output width-independent.

### Treating code-page selection as file conversion

Console input/output code page, PowerShell encodings, native-pipeline bytes,
file encoding, fonts and application Unicode support are separate. Query first;
use [chcp.com](chcp.com.md) and an explicit conversion workflow rather than changing a
shared console and hoping bytes change.

### Using LPT redirection for modern printer discovery

LPT-to-COM is a privileged legacy mapping, not a Windows print queue, driver,
port monitor or rendering configuration. Inventory queues/ports/drivers with
print-management tools and preserve any existing mapping before migration.

## PowerShell boundaries

Invoke `mode.com` explicitly; `mode` can collide with functions/applications on
other platforms. Output is localized display text. Avoid parsing column labels;
use PnP, CIM, .NET serial-port, console-host or print-management objects for
automation, and capture `$LASTEXITCODE` immediately.

## Version and platform differences

MODE is Windows-only. Serial capabilities depend on hardware, driver and port;
console behavior depends on host/build; code pages depend on locale/fonts;
typematic and printer redirection may be unsupported by modern hardware.
Installed behavior is required. Do not assume the reference's generic `/?`
contract: on the recorded build it returned localized CON state/status 0,
whereas `cmd.exe /d /c help MODE` returned 11 static help lines/status 1.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 Mode file version 10.0.26100.1
contradicted the generic reference: mode.com /? returned localized current-CON
status/status 0 rather than help. Exact cmd.exe /d /c help MODE returned 11
static help lines/status 1 without asking Mode to parse a device token. The
page therefore does not index /? as help. No serial, LPT, code-page,
buffer-size or typematic mutation occurred.

## Related documents
- [chcp.com](chcp.com.md)
- [print.exe](print.exe.md)
- [getmac.exe](getmac.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[MODE reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mode).
High-demand console sizing and serial-port namespace/transfer mistakes were
cross-checked against [console sizing](https://superuser.com/questions/401621/how-can-i-widen-the-windows-7-command-prompt-window)
and [serial transfer](https://stackoverflow.com/questions/36443169/how-to-send-file-over-serial-port-in-windows-command-prompt)
questions. Microsoft sources govern syntax. Exact sources/licenses are recorded
in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Exchange contributions are licensed under CC BY-SA 4.0.
