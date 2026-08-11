<!-- mant:tldr:start -->
# sfc

> Verify or repair Windows protected system files in an explicit image.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/sfc.

- Verify all protected files without repairing them, from an elevated shell:

`sfc.exe /verifyonly`

- Verify one exact protected file without repairing it:

`sfc.exe /verifyfile={{C:\Windows\System32\kernel32.dll}}`

- Scan and repair protected files in the running Windows installation:

`sfc.exe /scannow`

- Repair one file in an offline Windows installation with explicit boot and Windows roots:

`sfc.exe /scanfile={{D:\Windows\System32\kernel32.dll}} /offbootdir={{D:\}} /offwindir={{D:\Windows}} /offlogfile={{D:\sfc-offline.log}}`
<!-- mant:tldr:end -->

# sfc

## Overview

System File Checker (`sfc.exe`) verifies Windows-protected system files and,
for scan operations, replaces incorrect versions when possible. `/verifyonly`
and `/verifyfile=` do not repair; `/scannow` and `/scanfile=` attempt repair.
Offline operation requires both the boot directory and Windows directory.

## Operations and offline options

<!-- mant:entries role=option case=insensitive -->
- `/scannow`: Verify all protected system files and repair incorrect versions when possible.
- `/verifyonly`: Verify all protected files without attempting repair.
- `/scanfile`: Written `/scanfile=FULL-PATH`, verify and repair one exact protected file.
- `/verifyfile`: Written `/verifyfile=FULL-PATH`, verify one exact protected file without repair.
- `/offbootdir`: Written `/offbootdir=PATH`, select the offline boot directory for an offline operation.
- `/offwindir`: Written `/offwindir=PATH`, select the offline Windows directory; do not infer its drive letter from the running environment.
- `/offlogfile`: Written `/offlogfile=FILE`, write offline servicing log output to an explicit file.

## PowerShell boundaries

Call `sfc.exe` explicitly and preserve each equals-bearing option as one native
argument. Capture output and `$LASTEXITCODE`, then correlate CBS/SFC logs and
the original symptom instead of parsing one localized final sentence.

## Common mistakes

### Omitting the slash or equals sign

The supported forms are `/scannow`, `/verifyonly`, `/scanfile=full-path`, and
`/verifyfile=full-path`. `sfc scannow` and a detached file argument do not have
the documented meaning.

### Pointing offline options at the current drive letters by habit

WinRE/WinPE can assign different letters than the running OS. Locate the
actual offline Windows and boot volumes, verify their contents, and keep
`/offbootdir` distinct from `/offwindir`.

### Expecting SFC to repair every Windows problem

SFC covers protected system files, not arbitrary applications, registry
configuration, drivers, disks, malware, or network state. If its repair source
is unhealthy, use the approved DISM component-store workflow and then rerun
SFC.

### Reading only the final console sentence

Preserve the full output and relevant CBS/SFC log evidence, distinguish no
violations, repaired violations, and unrepaired violations, and verify the
original symptom after any required restart.

### Running repair casually on production

Verification is read-only; repair can replace protected files and may require
maintenance planning. Capture system/version state, backups or recovery path,
and active servicing/restart conditions first.

## Version and platform differences

This executable is Windows-only and requires administrator membership. Offline
syntax, protected-resource scope, repair source, and logs depend on the target
Windows version and servicing state.

## Related documents

- [dism](dism.md)
- [systeminfo](systeminfo.md)
- [driverquery](driverquery.md)

## Sources and license

This original guide was adapted from Microsoft's official
[sfc reference](https://learn.microsoft.com/windows-server/administration/windows-commands/sfc).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
