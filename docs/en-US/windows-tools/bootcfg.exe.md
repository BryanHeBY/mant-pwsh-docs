<!-- mant:tldr:start -->
# bootcfg.exe

> Identify legacy Boot.ini configuration; Windows Vista and later use BCD, so
> inspect with BCDEdit and never translate BOOTCFG mutations mechanically.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/bootcfg.

- Discover whether the legacy and current tools exist on the target:

`Get-Command bootcfg.exe, bcdedit.exe -All -ErrorAction SilentlyContinue | Format-List Name, Source, Version`

- Query a legacy Boot.ini configuration only where BOOTCFG is actually supported:

`bootcfg.exe query`

- Enumerate every BCD object and its full identifier without changing the store:

`bcdedit.exe /enum all /v`

- Read current BCDEdit topics and target-local syntax:

`bcdedit.exe /? TOPICS`

<!-- mant:tldr:end -->

# bootcfg.exe

## Overview

`bootcfg.exe` configures the legacy `Boot.ini` loader model: `query`, `copy`,
`delete`, `default`, `timeout`, raw loader switches, debugging, IEEE 1394
debugging, and Emergency Management Services. Modern Windows boot configuration is stored
as Boot Configuration Data (BCD), which replaces Boot.ini; Microsoft identifies
BCDEdit as the primary editor for Windows Vista and later.

BOOTCFG and BCDEdit are not syntax-compatible views of one file. Preserve a
legacy system's boot evidence and recovery path, then design an explicit BCD or
supported deployment change for the actual firmware, disk and OS generation.

## Legacy syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `bootcfg.exe`: Inspect or modify a legacy Boot.ini-based boot configuration.
- `query`: Display Boot.ini boot-loader and operating-system entries.
- `copy`: Copy an existing operating-system entry and give it a description.
- `delete`: Delete one operating-system entry selected by line number.
- `raw`: Replace the raw loader-switch string for one entry.
- `timeout`: Set the Boot.ini menu timeout in seconds.
- `default`: Select the default operating-system entry by line number.
- `ems`: Configure Emergency Management Services redirection for one entry.
- `debug`: Configure kernel debugging for one entry.
- `dbg1394`: Configure IEEE 1394 kernel debugging for one entry.
- `addsw`: Add selected legacy loader switches to one entry.
- `rmsw`: Remove selected legacy loader switches from one entry.

These bare words are BOOTCFG subcommands, not slash switches. Their numeric
entry model and loader switches must not be transferred mechanically to BCD.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Select a remote computer for a subcommand that supports it.
- `/u`: Select the account context for a remote operation.
- `/p`: Supply a remote password; inline secrets are exposed to process/history logs.
- `/id`: Select an operating-system entry by its Boot.ini line number.
- `/d`: Set the description for a copied entry.
- `/t`: Set the timeout value for the `timeout` subcommand.
- `/raw`: Supply the complete loader-switch string for the `raw` subcommand.
- `/ems`: Select `ON`, `OFF`, or `EDIT` EMS behavior.
- `/port`: Select a COM port or IEEE 1394 channel as documented by the subcommand.
- `/baud`: Set a supported serial debugging or EMS baud rate.
- `/mm`: Add or remove the `/maxmem` legacy loader switch.
- `/bv`: Add or remove the `/basevideo` legacy loader switch.
- `/so`: Add or remove the `/sos` legacy loader switch.
- `/ng`: Add or remove the `/noguiboot` legacy loader switch.
- `/?`: Display installed BOOTCFG syntax.

## Common mistakes

### Assuming the current Learn applicability banner makes Boot.ini current

The BOOTCFG page describes Boot.ini even when its site banner lists modern
Windows. The BCDEdit reference explicitly states that BCD replaces Boot.ini and
that BCDEdit is primary for Vista and later. Check executable behavior, boot
generation, firmware mode, and actual store before choosing a tool.

### Mapping an entry number to a BCD identifier

BCD uses objects, elements, GUIDs, well-known identifiers, multiple stores, and
firmware objects. Never translate a BOOTCFG `/id` or copied line into `{current}`
or `{default}` by guess. Enumerate `/v`, capture the exact store and identifiers,
and correlate Windows volume/device identity.

### Editing the live boot store without recovery

A valid command can make a system unbootable, weaken integrity, change debugger
or EMS exposure, or alter the wrong offline/system store. Inventory first,
export the correct BCD store, verify recovery media/BitLocker keys and console
access, review Secure Boot/firmware impact, and use a separately approved change
with a tested rollback.

### Copying raw loader switches forward

Legacy switches may be renamed, removed, unsafe, debug-only, or represented by
different BCD elements. Use target-local BCDEdit help and current feature-
specific Microsoft documentation. Do not enable testsigning, integrity bypass,
debugging, EMS, or alternate kernels as a troubleshooting shortcut.

## PowerShell boundaries

Both are native executables; invoke them explicitly and capture
`$LASTEXITCODE`. BCDEdit output is localized display text, not a stable object
API. For deployment-scale or nonstandard BCD types, use the supported deployment
or BCD management interface rather than fragile line parsing.

## Version and platform differences

BOOTCFG belongs to the NT loader/Boot.ini generation. BCDEdit covers Windows
Vista and later BCD stores, with behavior affected by BIOS/MBR versus UEFI/GPT,
Secure Boot, BitLocker, WinPE/offline context, architecture, installed OS entries
and Windows build. Tool presence alone does not identify the active boot path.

## Related documents

- [bcdedit.exe](bcdedit.exe.md)
- [bcdboot.exe](bcdboot.exe.md)
- [reagentc.exe](reagentc.exe.md)
- [manage-bde.exe](manage-bde.exe.md)

## Sources and license

This original migration guide was adapted from Microsoft's official
[BOOTCFG reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bootcfg)
and [BCDEdit reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bcdedit).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
