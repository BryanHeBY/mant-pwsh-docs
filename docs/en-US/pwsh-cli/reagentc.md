<!-- mant:tldr:start -->
# reagentc

> Inventory Windows Recovery Environment state, exact image location, BCD identifier, and online/offline target before enabling, disabling, relocating, customizing, or scheduling recovery boot.
> More information: https://learn.microsoft.com/windows-hardware/manufacture/desktop/reagentc-command-line-options.

- Display installed REAgentC syntax and supported operations:

`reagentc.exe /?`

- Show Windows RE status, location, BCD identifier, and recovery image configuration for the running OS:

`reagentc.exe /info`

- Inspect an explicitly mounted offline Windows installation without modifying it:

`reagentc.exe /info /target "{{W:\Windows}}"`
<!-- mant:tldr:end -->

# reagentc

## Overview

`reagentc.exe` configures Windows Recovery Environment (WinRE), its image path,
advanced-boot custom tools, and next-boot recovery entry for online or supported
offline Windows images. Recovery configuration spans Winre.wim, partition/files,
BCD objects, OS identity, firmware/partition layout, encryption, and servicing.

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

## PowerShell behavior

Use `reagentc.exe` explicitly from an elevated, identified OS context. Capture
native output/status and immutable before/after evidence. Do not interpolate a
path or BCD GUID from untrusted text. A mutation workflow needs console/recovery
media, BitLocker keys, backup, boot verification, and a tested rollback.

## Version and platform differences

`reagentc.exe` is Windows-only. Online/offline support, Audit Mode, `/osguid`,
reset images, partition sizing/attributes, WinRE servicing, and paths vary by
Windows version, firmware, partition style, deployment phase and encryption.

## Related documents

- [bcdedit](bcdedit.md)
- [bcdboot](bcdboot.md)
- [diskpart](diskpart.md)
- [manage-bde](manage-bde.md)
- [shutdown](shutdown.md)

## Sources and license

This original guide was adapted from Microsoft's official
[REAgentC command-line options](https://learn.microsoft.com/windows-hardware/manufacture/desktop/reagentc-command-line-options).
Failure modes were cross-checked against practitioner reports of
[missing WinRE BCD configuration](https://superuser.com/questions/1534341/reagentc-unable-to-update-winre-boot-configuration-data)
and [recovery-partition capacity errors](https://superuser.com/questions/1101816/reagentc-operation-failed-70).
Exact sources and licenses are recorded in `upstream/cli.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
