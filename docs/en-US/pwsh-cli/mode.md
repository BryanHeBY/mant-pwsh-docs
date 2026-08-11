<!-- mant:tldr:start -->
# mode

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

<!-- mant:tldr:end -->

# mode

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
use [chcp](chcp.md) and an explicit conversion workflow rather than changing a
shared console and hoping bytes change.

### Using LPT redirection for modern printer discovery

LPT-to-COM is a privileged legacy mapping, not a Windows print queue, driver,
port monitor or rendering configuration. Inventory queues/ports/drivers with
print-management tools and preserve any existing mapping before migration.

## PowerShell behavior

Invoke `mode.com` explicitly; `mode` can collide with functions/applications on
other platforms. Output is localized display text. Avoid parsing column labels;
use PnP, CIM, .NET serial-port, console-host or print-management objects for
automation, and capture `$LASTEXITCODE` immediately.

## Version and platform differences

MODE is Windows-only. Serial capabilities depend on hardware, driver and port;
console behavior depends on host/build; code pages depend on locale/fonts;
typematic and printer redirection may be unsupported by modern hardware.
Target-local `mode.com /?` is required.

## Related documents

- [chcp](chcp.md)
- [print](print.md)
- [getmac](getmac.md)

## Sources and license

This original guide was adapted from Microsoft's official
[MODE reference](https://learn.microsoft.com/windows-server/administration/windows-commands/mode).
High-demand console sizing and serial-port namespace/transfer mistakes were
cross-checked against [console sizing](https://superuser.com/questions/401621/how-can-i-widen-the-windows-7-command-prompt-window)
and [serial transfer](https://stackoverflow.com/questions/36443169/how-to-send-file-over-serial-port-in-windows-command-prompt)
questions. Microsoft sources govern syntax. Exact sources/licenses are recorded
in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Exchange contributions are licensed under CC BY-SA 4.0.
