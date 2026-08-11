<!-- mant:tldr:start -->
# bootcfg

> Identify legacy Boot.ini configuration; Windows Vista and later use BCD, so
> inspect with BCDEdit and never translate BOOTCFG mutations mechanically.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/bootcfg.

- Discover whether the legacy and current tools exist on the target:

`Get-Command bootcfg.exe, bcdedit.exe -All -ErrorAction SilentlyContinue | Format-List Name, Source, Version`

- Query a legacy Boot.ini configuration only where BOOTCFG is actually supported:

`bootcfg.exe /query`

- Enumerate every BCD object and its full identifier without changing the store:

`bcdedit.exe /enum all /v`

- Read current BCDEdit topics and target-local syntax:

`bcdedit.exe /? TOPICS`

<!-- mant:tldr:end -->

# bootcfg

## Overview

`bootcfg.exe` configures the legacy `Boot.ini` loader model: query, copy/delete
entries, default, timeout, raw loader switches, debugging, IEEE 1394 debugging,
and Emergency Management Services. Modern Windows boot configuration is stored
as Boot Configuration Data (BCD), which replaces Boot.ini; Microsoft identifies
BCDEdit as the primary editor for Windows Vista and later.

BOOTCFG and BCDEdit are not syntax-compatible views of one file. Preserve a
legacy system's boot evidence and recovery path, then design an explicit BCD or
supported deployment change for the actual firmware, disk and OS generation.

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

## PowerShell behavior

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

- [bcdedit](bcdedit.md)
- [bcdboot](bcdboot.md)
- [reagentc](reagentc.md)
- [manage-bde](manage-bde.md)

## Sources and license

This original migration guide was adapted from Microsoft's official
[BOOTCFG reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bootcfg)
and [BCDEdit reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bcdedit).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
