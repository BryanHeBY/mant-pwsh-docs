<!-- mant:tldr:start -->
# bcdboot

> Copy Windows boot files and build or repair a BCD store only after identifying the exact Windows and system partitions.
> More information: https://learn.microsoft.com/windows-hardware/manufacture/desktop/bcdboot-command-line-options-techref-di.

- Show options supported by the installed Windows or Windows PE build:

`bcdboot.exe /?`

- Confirm that an offline drive letter is an actual Windows source before repair:

`Test-Path -LiteralPath "{{W:\Windows\System32\Config\SYSTEM}}"`

- Repair the firmware-detected system partition from the running Windows source while preserving UEFI order and the existing default loader:

`bcdboot.exe "{{C:\Windows}}" /p /d /v`

- Build UEFI boot files on one explicitly identified offline EFI System Partition:

`bcdboot.exe "{{W:\Windows}}" /s "{{S:}}" /f UEFI /v`

- Verify the BCD store created on that explicit UEFI target:

`bcdedit.exe /store "{{S:\EFI\Microsoft\Boot\BCD}}" /enum all /v`
<!-- mant:tldr:end -->

# bcdboot

## Overview

`bcdboot.exe` initializes or repairs Windows boot files on a system partition
using a selected Windows directory as its source. It copies the appropriate
boot environment, creates a BCD store from the Windows template, and can merge
or preserve selected existing settings. On UEFI systems it can also create or
reorder the Windows Boot Manager firmware entry.

This is a state-changing deployment and recovery tool with no dry-run mode.
Its drive letters identify volumes in the shell that is currently running;
WinPE/WinRE letters commonly differ from those seen by the installed Windows.
Inventory disks, firmware mode, partition style/type, BitLocker state, Windows
source, and recovery media before running it.

## Target-selection model

Without `/s`, BCDBoot uses the system partition identified by firmware and can
manage the Windows Boot Manager firmware entry. Microsoft says `/s` should not
be used in typical deployment scenarios; it is intended for an explicit
system partition such as a drive prepared for another computer.

With `/s volume`:

- UEFI boot files and the BCD store go to the named EFI System Partition;
- BCDBoot does not create the normal Windows Boot Manager NVRAM entry and
  instead relies on the firmware's default fallback path;
- BIOS boot files go to the named active system partition;
- `/f UEFI`, `/f BIOS`, or `/f ALL` selects which firmware files are created,
  and Microsoft requires `/s` when `/f` is specified.

Therefore `/s` is not merely an output directory flag. Verify that the target
is the correct ESP/system partition on the correct disk and that firmware mode
matches disk layout and deployment intent.

## Important options

| Option | Effect and decision |
| --- | --- |
| `/l locale` | Sets BCD locale; verify an installed/supported locale instead of accepting the US-English default accidentally. |
| `/s volume` | Selects an explicit system partition and changes UEFI NVRAM behavior; avoid for ordinary current-machine repair unless required. |
| `/f UEFI|BIOS|ALL` | Creates firmware-specific files; firmware, GPT/MBR layout, partition type, and target must agree. |
| `/v` | Enables verbose diagnostics; it is not verification that firmware will boot the target. |
| `/m [GUID]` | Merges global objects and optionally one existing loader into the new store; inspect that source entry first. |
| `/p` | Preserves an existing Windows Boot Manager position in UEFI order; mutually exclusive with `/addlast`. |
| `/addlast` | Adds the Windows firmware entry last instead of the default first position; mutually exclusive with `/p`. |
| `/d` | Preserves the existing default OS entry in `{bootmgr}`. |
| `/c` | Starts from the template without migrating otherwise-preserved BCD elements; this can discard intentional settings. |
| `/bootex` | Selects BootEx binaries when Secure Boot servicing conditions require them; follow Microsoft's current revocation rollout guidance. |
| `/offline` | Forces offline boot-file servicing on only the Windows builds that document support; do not assume older WinPE media accepts it. |

## Common mistakes

### Guessing drive letters in WinPE or WinRE

`C:` is not guaranteed to be the offline Windows volume, and an ESP often has
no letter until one is assigned temporarily. Confirm volume filesystem, size,
partition type, disk number, Windows registry hives, and expected OS build.
Keep the Windows source and system target distinct in the change record.

### Using `/s` during a normal repair without understanding UEFI behavior

On UEFI, explicit `/s` suppresses creation of the ordinary Windows Boot
Manager NVRAM entry. Files can copy successfully while firmware still does not
select them. Omit `/s` when firmware detection is appropriate; otherwise
validate the fallback/NVRAM design and actual next boot.

### Selecting `/f ALL` as a universal fix

Writing both BIOS and UEFI directories does not convert MBR to GPT, create a
correctly typed ESP, mark a BIOS partition active, change firmware mode, or
make one disk layout valid for both. Choose the known target firmware and use
`ALL` only for an intentional multi-firmware removable/deployment design.

### Pointing source and target at the same visible volume by accident

The required source is a Windows directory, while `/s` is the system
partition. An EFI System Partition is normally FAT32 and does not contain the
offline `Windows` directory. Verify both full paths and disk/partition
identities before copying.

### Formatting or recreating the system partition as the first step

BCDBoot itself does not require formatting. Formatting can remove other boot
managers, vendor tools, recovery paths, and forensic evidence. Back up the
partition and BCD, inventory all firmware entries and multiboot dependencies,
and use a platform-specific recovery runbook before any DiskPart or `format`
operation.

### Assuming “Boot files successfully created” proves bootability

That message proves only that BCDBoot completed its operation. Verify the
created BCD with an explicit `/store`, inspect copied paths, firmware entries
or fallback path, partition flags/type, Secure Boot compatibility, BitLocker
state, and finally a controlled boot with a recovery route available.

### Overwriting intentional order or default selections

BCDBoot can place Windows Boot Manager first in UEFI order and can recreate
the default loader. Use `/p` or `/addlast` intentionally, `/d` when the existing
default must remain, and compare pre/post `bcdedit /enum ... /v` evidence.

### Using stale recovery media against a newer boot-security rollout

Available `/bootex` and `/offline` behavior varies by build, and Secure Boot
revocation servicing evolves. Use recovery media and BCDBoot binaries aligned
with the target Windows servicing guidance. Do not copy boot files from an
untrusted or arbitrarily older installation.

### Treating `/c` as a generic clean repair

`/c` prevents migration of existing elements that newer Windows versions may
otherwise preserve, including diagnostic or flight settings. It can be useful
for a deliberate clean template, but first determine which recovery, debugger,
hypervisor, integrity, and deployment settings must survive.

## PowerShell behavior

`bcdboot.exe` is a native state-changing tool. Quote Windows and target paths,
preserve verbose output, and check `$LASTEXITCODE` immediately. A drive letter
string is not sufficient evidence of identity; collect structured volume and
partition data with supported storage cmdlets before invocation. Avoid a
32-bit shell on 64-bit recovery hosts when System32 redirection could select
the wrong executable or make it appear missing.

## Version and platform differences

This Windows-only command is available in supported Windows and Windows PE
environments. Options and boot binaries vary by Windows/ADK build. Firmware
mode, architecture, GPT/MBR layout, ESP/active-partition rules, Secure Boot,
BitLocker, multiboot design, and physical versus virtual firmware determine
valid usage.

## Related documents

- [bcdedit](bcdedit.md)
- [dism](dism.md)
- [cipher](cipher.md)

## Sources and license

This original guide was adapted from Microsoft's official
[BCDBoot command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bcdboot)
and the more complete
[BCDBoot deployment option reference](https://learn.microsoft.com/windows-hardware/manufacture/desktop/bcdboot-command-line-options-techref-di?view=windows-11).
Questions about copied files that still do not boot and unexpected UEFI order
were used as discovery signals; behavior in this page follows the current
official `/s`, `/f`, `/p`, `/addlast`, `/d`, and `/c` contracts. Exact sources
and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0.
