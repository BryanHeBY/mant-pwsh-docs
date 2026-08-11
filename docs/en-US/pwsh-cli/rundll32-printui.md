<!-- mant:tldr:start -->
# rundll32 printui

> Inspect PrintUI syntax and per-computer printer connections before invoking its mutating printer/driver functions.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rundll32-printui.

- Display the local PrintUIEntry help; preserve its exact case and comma syntax:

`rundll32.exe printui.dll,PrintUIEntry /?`

- Display per-computer printer connections on the local computer:

`rundll32.exe printui.dll,PrintUIEntry /ge`

- Display per-computer connections on one exact remote computer:

`rundll32.exe printui.dll,PrintUIEntry /ge /c\\{{CLIENT01}}`

- Compare typed local queue/connection inventory from PrintManagement:

`Get-Printer | Select-Object Name,Type,ComputerName,DriverName,PortName,Shared,Published,PrinterStatus`
<!-- mant:tldr:end -->

# rundll32 printui

## Overview

`rundll32.exe printui.dll,PrintUIEntry` exposes printer dialogs plus scripted
driver, queue, connection, default-printer, test-page, settings save/restore,
and property operations. Exactly one base parameter is combined with only the
modifiers that base accepts. `PrintUIEntry` is case-sensitive.

## Common mistakes

### Omitting the comma or changing `PrintUIEntry` case

Multiple documented forms exist, but the comma form makes DLL/entry-point
binding explicit. Preserve `printui.dll,PrintUIEntry`; do not let generic
Rundll32 examples invent an export name or arbitrary DLL path.

### Confusing `/ge`, `/ga`, `/gd`, and `/in`

`/ge` reads per-computer connections; `/ga` and `/gd` schedule per-computer
addition/removal realized at user logon; `/in` connects in the running user's
context. They differ in scope and timing, not merely verbosity.

### Supplying queue display text to `/m`

For driver installation, `/m` must exactly match a model in the INF. `/b` is
the new printer base name, `/r` the existing port, `/f` the INF, and `/h` the
architecture. Validate signed package dependencies and local target-build help.

### Treating `/Ss` and `/Sr` as portable backup/restore

The binary settings file can contain queue, security, DEVMODE, directory, color,
driver, and port-related data selected by flags. Restore conflict flags and
driver/build/bitness differences can change or reject results. Preserve a
tested rollback and never apply an untrusted settings file.

### Using `/q` before the workflow is proven

Quiet mode suppresses notifications, not failures or side effects. Keep prompts
and complete logs in a disposable test, then verify every exact queue, driver,
port, connection, default, share, and security result.

### Assuming the exit behavior proves completion

Rundll32 calls a DLL entry point; UI, deferred logon realization, driver setup,
and spooler work may outlive the launcher. Verify target state and relevant
events rather than trusting process exit alone.

## PowerShell behavior

Call `rundll32.exe` explicitly and keep `printui.dll,PrintUIEntry` one token.
PowerShell does not treat `/` as its own parameter prefix for native commands,
but backslash/UNC quoting still matters. Output/UI is not an object contract;
use PrintManagement for structured verification.

## Version and platform differences

Windows-only. Parameters include legacy driver architectures/types; accepted
forms, UI, security prompts, driver installation policy, Point and Print rules,
per-machine realization, and WOW64 behavior vary by build and patch level.

## Related documents

- [rundll32](rundll32.md)
- [prndrvr](prndrvr.md)
- [prnmngr](prnmngr.md)
- [pushprinterconnections](pushprinterconnections.md)

## Sources and license

This original guide was adapted from Microsoft's official
[PrintUIEntry reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rundll32-printui).
INF model-name and settings-restore failures were cross-checked against
practitioner discussions of [driver installation](https://serverfault.com/questions/393755/error-when-attempting-to-install-network-printer-driver-using-printui-command)
and [printer settings restore](https://serverfault.com/questions/251873/restoring-printer-settings/361058).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
