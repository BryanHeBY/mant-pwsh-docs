<!-- mant:tldr:start -->
# reagentc.exe

> Inventory Windows Recovery Environment state, exact image location, BCD identifier, and online/offline target before enabling, disabling, relocating, customizing, or scheduling recovery boot.
> More information: https://learn.microsoft.com/windows-hardware/manufacture/desktop/reagentc-command-line-options.

- Display installed REAgentC syntax and supported operations:

`reagentc.exe /?`

- Show Windows RE status, location, BCD identifier, and recovery image configuration for the running OS:

`reagentc.exe /info`

- Inspect an explicitly mounted offline Windows installation without modifying it:

`reagentc.exe /info /target "{{W:\Windows}}"`
<!-- mant:tldr:end -->

# reagentc.exe

## Overview

`reagentc.exe` configures Windows Recovery Environment (WinRE), its image path,
advanced-boot custom tools, and next-boot recovery entry for online or supported
offline Windows images. Recovery configuration spans Winre.wim, partition/files,
BCD objects, OS identity, firmware/partition layout, encryption, and servicing.

## Commands and parameters

<!-- mant:entries role=command case=insensitive -->
- `reagentc.exe`: Inspect or configure Windows Recovery Environment for an
  online or supported offline Windows installation.

Commands default to the running installation unless their contract accepts an
explicit `/target`. Resolve recovery and Windows paths in the current shell.

<!-- mant:entries role=option case=insensitive -->
- `/info`: Display WinRE status, location, BCD identifier, and configured image state.
- `/setreimage`: Set the directory containing the Windows RE boot image.
- `/enable`: Enable Windows RE for the selected Windows installation.
- `/disable`: Disable Windows RE for the selected Windows installation.
- `/boottore`: Schedule the running operating system to boot to Windows RE once.
- `/setbootshelllink`: Register a custom Advanced startup tool from XML.
- `/setosimage`: Set a push-button reset image on legacy Windows versions; the
  setting is not used by Windows 10 or later.
- `/path`: Supply the directory containing the selected recovery image.
- `/target`: Select the root Windows directory of an offline installation.
- `/index`: Select the image index used with legacy `/setosimage`.
- `/configfile`: Supply BootShell XML for `/setbootshelllink`.
- `/auditmode`: Permit the documented enable operation while in Audit Mode.
- `/osguid`: Select the BCD operating-system identifier where documented.
- `/?`: Display commands supported by the installed REAgentC build.

## Common mistakes

- Running `/enable`, `/disable`, or `/setreimage` before preserving `/info`, BCD,
  disk/partition IDs, WinRE files/hashes/ACLs, BitLocker state, and recovery media.
- Confusing the WinRE directory with the WIM file, or pointing one OS/build at a
  copied, mismatched, untrusted, inaccessible, or undersized recovery location.
- Omitting `/target` while working from WinPE/another installation and silently
  modifying the wrong Windows image; drive letters change in recovery contexts.
- Deleting, retyping, resizing, unhiding, or assigning letters to recovery/system
  partitions from a copied web recipe without resolving GPT/MBR and exact disk IDs.
- Treating “Operation Successful” alone as usable recovery. Re-query, verify BCD,
  image/index/files, partition attributes/free space, encryption, and tested boot.
- Using `/boottore` merely to test syntax; it changes the next boot destination.
- Relying on `/setosimage` for Windows 10 or later; Microsoft documents that the
  setting is not used there.

## PowerShell boundaries

Use `reagentc.exe` explicitly from an elevated, identified OS context. Capture
native output/status and immutable before/after evidence. Do not interpolate a
path or BCD GUID from untrusted text. A mutation workflow needs console/recovery
media, BitLocker keys, backup, boot verification, and a tested rollback.

## Version and platform differences

`reagentc.exe` is Windows-only. Online/offline support, Audit Mode, `/osguid`,
reset images, partition sizing/attributes, WinRE servicing, and paths vary by
Windows version, firmware, partition style, deployment phase and encryption.

## Related documents

- [bcdedit.exe](bcdedit.exe.md)
- [bcdboot.exe](bcdboot.exe.md)
- [diskpart.exe](diskpart.exe.md)
- [manage-bde.exe](manage-bde.exe.md)
- [shutdown.exe](shutdown.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[REAgentC command-line options](https://learn.microsoft.com/windows-hardware/manufacture/desktop/reagentc-command-line-options).
Failure modes were cross-checked against practitioner reports of
[missing WinRE BCD configuration](https://superuser.com/questions/1534341/reagentc-unable-to-update-winre-boot-configuration-data)
and [recovery-partition capacity errors](https://superuser.com/questions/1101816/reagentc-operation-failed-70).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
