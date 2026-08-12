<!-- mant:tldr:start -->
# winrm.exe

> Resolve `winrm.exe` before use: Windows ships `winrm.cmd`, which invokes `winrm.vbs`; it does not ship `winrm.exe`.
> More information: https://learn.microsoft.com/windows/win32/winrm/installation-and-configuration-for-windows-remote-management.

- Confirm that the explicit `.exe` name is absent on the current host:

`Get-Command winrm.exe -All -ErrorAction SilentlyContinue`

- Resolve every actual WinRM command-line entry without running it:

`Get-Command winrm, winrm.cmd, winrm.vbs -All -ErrorAction SilentlyContinue`

- Inspect the small command wrapper as data:

`Get-Content -LiteralPath "$env:SystemRoot\System32\winrm.cmd"`
<!-- mant:tldr:end -->

# winrm.exe

## Meaning and resolution

Windows does not ship `winrm.exe`. The command-line entry point is
`winrm.cmd`, a wrapper that invokes `winrm.vbs` with `cscript.exe`. If
`winrm.exe` resolves, another product or local configuration supplied it; do
not assign the system WinRM client's authority or behavior to that file.

<!-- mant:entries role=command case=insensitive -->
- `winrm.exe`: Non-built-in name; resolve and verify its provenance before any use.
- `winrm.cmd`, `winrm`: Windows command wrapper for the WinRM VBScript client.
- `winrm.vbs`: Underlying system script; normally reached through `winrm.cmd` rather than invoked as a standalone executable.

## Why the extension matters

An explicit `.exe` name must resolve that exact extension. Bare `winrm` follows
normal command and `PATHEXT` precedence, which can be changed by aliases,
functions, scripts, and `PATH`. Shared automation should resolve `winrm.cmd`
or use supported WSMan/PowerShell remoting APIs with an explicit endpoint and
security design.

Correcting the extension does not make `quickconfig`, listener, authentication,
TrustedHosts, plugin, shell, or firewall changes safe. Inventory those layers
and preserve an out-of-band recovery path first.

## PowerShell boundaries

`Get-Command winrm.exe` requests that exact filename; PowerShell does not
reinterpret it as the `.cmd` wrapper. Bare `winrm` follows normal alias,
function, script, `PATHEXT`, and `PATH` precedence. Resolve `winrm.cmd`
explicitly for the Windows wrapper and remember that arguments then cross
PowerShell, `cmd.exe`, and `cscript.exe` parsing boundaries.

## Version and platform differences

The recorded Windows NT `10.0.26200.0` host supplies a 33-byte
`C:\Windows\System32\winrm.cmd` wrapper and 204,072-byte `winrm.vbs`, with no
built-in `winrm.exe`. WinRM availability, service state, listeners, endpoints,
defaults, and policy vary by Windows/WMF version and managed environment;
discover them locally without treating the recorded sizes as a compatibility
contract. This entry point is Windows-specific.

## Common mistakes

### Assuming every command-line tool is a native executable

The WinRM client is implemented as a command wrapper and VBScript. Process,
quoting, localization, code-page, and error behavior therefore includes
`cmd.exe`/`cscript.exe` boundaries rather than a single native `.exe` parser.

### Executing an unexpected `winrm.exe`

Do not run a newly resolved file merely to discover what it does. Inspect
`Get-Command ... -All`, the full path, signature, owner, version metadata, and
deployment provenance first.

## Full command

See [winrm.cmd](winrm.cmd.md) for read-only inventory, authentication,
certificate, TrustedHosts, endpoint, listener, plugin, quota, and PowerShell
remoting boundaries.

## Runtime evidence

The protected dual-edition fixture found zero Application matches for exact
`winrm.exe`, while separately verifying the built-in System32 `winrm.cmd`
wrapper. This is a command-resolution result for Windows NT `10.0.26200.0`, not
a universal claim about arbitrary third-party files or future Windows builds.
No similarly named executable was invoked, no WinRM resource was queried, and
no local or remote configuration changed.

## Related documents

- [winrs.exe](winrs.exe.md)
- [sc.exe](sc.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This command-resolution guide is based on Microsoft's official
[WinRM installation and configuration reference](https://learn.microsoft.com/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)
and read-only inspection of the system wrapper. Exact source and runtime
evidence are recorded in `upstream/windows-tools.json` and `release/`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
