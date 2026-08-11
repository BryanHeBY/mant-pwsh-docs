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

## Base and modification parameters

<!-- mant:entries role=command case=sensitive -->
- `PrintUIEntry`: Case-sensitive `printui.dll` entry point invoked by `rundll32.exe`.

Use exactly one base parameter, then only modifiers accepted by that base.
Case matters because several lowercase/uppercase spellings differ.

<!-- mant:entries role=option case=sensitive -->
- `/dl`: Delete one local printer.
- `/dn`: Delete one network-printer connection.
- `/dd`: Delete one printer driver.
- `/e`: Display printing preferences for a printer.
- `/ga`: Add a per-computer connection realized when users log on.
- `/ge`: Display per-computer printer connections.
- `/gd`: Delete a per-computer connection at later user logon.
- `/ia`: Install a printer driver from an INF.
- `/id`: Open the Add Printer Driver Wizard.
- `/if`: Install a printer from an INF.
- `/ii`: Open the Add Printer Wizard using a selected INF.
- `/il`: Open the Add Printer Wizard.
- `/in`: Connect in the running user's context to a network printer.
- `/ip`: Open the Network Printer Installation Wizard.
- `/k`: Submit a printer test page.
- `/o`: Display a printer queue.
- `/p`: Display properties for the printer selected by `/n`.
- `/s`: Display local or `/c`-selected remote print-server properties.
- `/Ss`: Save selected printer information categories to a binary settings file.
- `/Sr`: Restore selected information and conflict policy from a settings file.
- `/Xg`: Retrieve a printer setting.
- `/Xs`: Set a printer setting.
- `/y`: Set the selected printer as default.
- `/?`: Display installed PrintUIEntry help.
- `/a`: Select a binary settings filename.
- `/b`: Set a base printer name.
- `/c`: Select a remote computer.
- `/f`: Select a primary INF or task-specific output filename.
- `/F`: Select an INF dependency.
- `/h`: Select driver architecture.
- `/j`: Select a print provider.
- `/l`: Select a driver-files path.
- `/m`: Select the exact driver model name from the INF.
- `/n`: Select a printer name or UNC connection.
- `/q`: Suppress notifications without suppressing impact or failures.
- `/r`: Select an existing port name.
- `/u`: Reuse an already installed printer driver.
- `/t`: Select a zero-based wizard/property page.
- `/v`: Select the printer-driver type/version.
- `/w`: Prompt for a driver if the INF does not identify it.
- `/Y`: Disable automatic printer-name generation.
- `/z`: Do not automatically share the installed printer.
- `/K`: Switch architecture/version modifiers to numeric legacy values.
- `/Z`: Share a printer installed with `/if`.
- `/Mw`: Display a warning before committing changes.
- `/Mq`: Require confirmation before committing changes.
- `/W`: Set wizard-specific flags.
- `/G`: Set global setup flags.

The separate `@[file]` argument-file form is documented in prose because it is
not a slash option and expands reviewed text directly into the command line.

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

## PowerShell boundaries

Call `rundll32.exe` explicitly and keep `printui.dll,PrintUIEntry` one token.
PowerShell does not treat `/` as its own parameter prefix for native commands,
but backslash/UNC quoting still matters. Output/UI is not an object contract;
use PrintManagement for structured verification.

## Version and platform differences

Windows-only. Parameters include legacy driver architectures/types; accepted
forms, UI, security prompts, driver installation policy, Point and Print rules,
per-machine realization, and WOW64 behavior vary by build and patch level.

## Related documents

- [rundll32.exe](rundll32.exe.md)
- [prndrvr.vbs](prndrvr.vbs.md)
- [prnmngr.vbs](prnmngr.vbs.md)
- [pushprinterconnections.exe](pushprinterconnections.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[PrintUIEntry reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rundll32-printui).
INF model-name and settings-restore failures were cross-checked against
practitioner discussions of [driver installation](https://serverfault.com/questions/393755/error-when-attempting-to-install-network-printer-driver-using-printui-command)
and [printer settings restore](https://serverfault.com/questions/251873/restoring-printer-settings/361058).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
