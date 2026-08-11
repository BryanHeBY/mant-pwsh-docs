<!-- mant:tldr:start -->
# winnt

> Recognize Windows Server 2003-era Winnt, Winnt32, RIS Setup, and SysOcMgr workflows; use current deployment tooling for supported Windows.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/winnt32.

- Inventory a legacy executable or installation medium without launching Setup:

`Get-Item -LiteralPath "{{D:\i386\winnt32.exe}}" | Select-Object FullName, Length, VersionInfo; Get-AuthenticodeSignature -LiteralPath "{{D:\i386\winnt32.exe}}"`

- Hash an answer file before offline review; do not pass it to legacy Setup:

`Get-FileHash -LiteralPath "{{C:\Evidence\unattend.txt}}" -Algorithm SHA256; Get-Content -LiteralPath "{{C:\Evidence\unattend.txt}}"`

- Identify the current Windows image/build before choosing supported deployment documentation:

`Get-ComputerInfo -Property WindowsProductName, WindowsVersion, OsBuildNumber, BiosFirmwareType`

- Inspect current DISM feature state instead of running deprecated SysOcMgr:

`dism.exe /Online /Get-Features /Format:Table`
<!-- mant:tldr:end -->

# winnt

## Overview

This family page covers `winnt` and `winnt32` Windows Server 2003 Setup,
`risetup` Remote Installation Services image creation, and deprecated
`sysocmgr` optional-component management. These references explain preserved
media, scripts, logs, and migration dependencies. They are not deployment
interfaces for Windows 10/11 or supported current Windows Server releases.

## Historical roles

<!-- mant:entries role=command case=insensitive -->
- `winnt`: Historical text-mode Windows Setup command.
- `winnt32`: Historical Windows Server 2003 install/upgrade front end.
- `risetup`: Historical Remote Installation Services image builder.
- `sysocmgr`: Deprecated optional-component answer-file processor.

The following are representative official Winnt32 families needed to interpret
preserved scripts, not supported deployment switches for current Windows.

<!-- mant:entries role=option case=insensitive -->
- `/checkupgradeonly`: Run Server 2003-era upgrade compatibility checking.
- `/unattend`: Use or generate an unattended setup path.
- `/udf`: Apply a uniqueness database and identifier.
- `/syspart`: Copy startup files and mark another disk active.

Additional source, recovery, and restart families are distinct legacy tokens.

<!-- mant:entries role=option case=insensitive -->
- `/tempdrive`: Select a drive for temporary Setup files.
- `/makelocalsource`: Copy installation source files locally.

Recovery-console and restart behavior must be interpreted in their original
Setup phase and operating-system context.

<!-- mant:entries role=option case=insensitive -->
- `/cmdcons`: Add the historical Recovery Console startup option.
- `/noreboot`: Prevent the automatic restart after the file-copy phase so the
  historical Setup process can be continued deliberately.

The family members have these broader historical roles and limitations:

- `winnt` was a text-mode-era Setup command and is deprecated.
- `winnt32` installed/upgraded Windows Server 2003 and could copy sources,
  consume answer/UDF files, run commands, alter startup/recovery choices, and
  prepare another disk.
- `risetup` built a Windows Server 2003 RIS image from CD/distribution files;
  the catalog page itself contains an apparent unrelated `rexec` deprecation
  sentence, so it must not be treated as authoritative lifecycle wording.
- `sysocmgr` managed old optional-component answer files and is deprecated.

## Common mistakes

### Running `winnt32 /checkupgradeonly` on a modern system

Its compatibility target is Server 2003-era products. Use the exact supported
Setup/upgrade assessment for the destination release and hardware.

### Treating an unattended file as passive data

Answer/UDF files can contain product keys, credentials, commands, partitions,
network/domain identity, and installation choices. Protect, redact, hash, and
review them offline; do not execute embedded commands.

### Reusing `/syspart`, `/tempdrive`, or source switches

These can mark disks active, copy startup files, select installation targets,
or execute stale binaries. Preserve original disk images and analyze only in an
isolated legacy lab when recovery requires it.

### Mapping SysOcMgr names directly to current features

Current Features on Demand, capabilities, DISM feature names, Server roles,
packages, and dependencies are different models. Discover current state and
use the supported servicing interface for the exact build.

### Trusting catalog applicability over the page's actual scope

Some Microsoft command pages display broad current applicability while their
body explicitly describes Server 2003 or deprecation. Record both, and let the
body/tool version and supported deployment docs govern use.

## PowerShell boundaries

Do not invoke these binaries from PowerShell on a current host. PowerShell is
useful for artifact metadata, signatures, hashes, and offline text review. Use
an isolated VM with snapshots and no production trust/network for unavoidable
legacy recovery research.

## Version and platform differences

These are Windows Server 2003-era/deprecated workflows. Architecture, BIOS/EFI,
disk layout, drivers, licensing, Dynamic Update, RIS/WDS, recovery console, and
component servicing differ fundamentally on current Windows.

## Related documents

- [dism.exe](dism.exe.md)
- [wdsutil.exe](wdsutil.exe.md)
- [bcdboot.exe](bcdboot.exe.md)

## Sources and license

Adapted as an original migration guide from Microsoft's [Winnt](https://learn.microsoft.com/windows-server/administration/windows-commands/winnt),
[Winnt32](https://learn.microsoft.com/windows-server/administration/windows-commands/winnt32),
[RiSetup](https://learn.microsoft.com/windows-server/administration/windows-commands/risetup),
and [SysOcMgr](https://learn.microsoft.com/windows-server/administration/windows-commands/sysocmgr)
catalog pages. Exact provenance is in `upstream/windows-tools.json`. Microsoft
documentation and this adaptation are licensed under CC BY 4.0.
