<!-- mant:tldr:start -->
# verifier

> Query Driver Verifier only on a dedicated test/debug computer; enabling tests deliberately stresses kernel drivers and can crash or boot-loop Windows, so prepare debugger, dumps, recovery, and rollback first.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/verifier.

- Display target-build syntax, test flags, boot modes, and return codes:

`verifier.exe /help`

- Show tests and drivers configured for the next boot; note that volatile additions are excluded:

`verifier.exe /querysettings`

- Show current Driver Verifier activity and counters:

`verifier.exe /query`

- On the exact test OS after preserving settings and deciding to stop verification, clear settings for the next restart:

`verifier.exe /reset`
<!-- mant:tldr:end -->

# verifier

## Overview

`verifier.exe` configures and monitors Driver Verifier stress/checking for
kernel-mode and graphics drivers. It is a driver development/debugging tool,
not a general production health scan. Microsoft warns that it can intentionally
bug-check Windows and recommends only dedicated test/debug computers.

## Common mistakes

- Enabling `/standard /all` on a workstation/server/VM without a reproducer,
  console, kernel debugger, complete dumps, symbols, backup, and recovery plan.
- Selecting every driver when one suspect binary/device stack would preserve
  resources and isolate evidence. `/driver` takes binary names and no wildcards.
- Confusing `/querysettings` (next-boot configuration, excluding volatile adds)
  with `/query` (current activity), or assuming `/reset` takes effect immediately;
  normal reset disables verification after the next restart.
- Copying numeric `/flags` from another Windows build. Standard options and
  supported rule classes evolve; prefer target help and current Microsoft docs.
- Enabling low-resource/fault injection, volatile settings, logging, or persistent
  boot mode without bounding driver, flags, duration, workload, and stop trigger.
- Waiting until a boot loop to design recovery. Prove Safe Mode/WinRE access,
  identify the actual Windows volume/store, preserve dumps, and test rollback.
- Treating a bug check as proof the named driver is the root cause without dump,
  stack, verifier settings, workload, driver build/signature, and reproduction.

## PowerShell behavior

Use `verifier.exe` explicitly from an elevated test-host session and preserve
stdout, native status (including reboot-needed), settings, driver inventory,
symbols, dumps, event/boot history, and hashes. Do not feed web-derived driver
names/flags into automation. A successful configuration command is not a test
pass; a reset command is not evidence that a rebooted system is healthy.

## Version and platform differences

`verifier.exe` is Windows-only and may be absent from restricted editions.
Options, standard flags, rule classes, verified driver types, return codes,
volatile support, and known build issues vary; always check exact target help.

## Related documents

- [driverquery](driverquery.md)
- [pnputil](pnputil.md)
- [shutdown](shutdown.md)
- [bcdedit](bcdedit.md)

## Sources and license

This original guide was adapted from Microsoft's official
[verifier command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/verifier)
and [Driver Verifier testing guidance](https://learn.microsoft.com/windows-hardware/drivers/devtest/driver-verifier).
Recovery demand was cross-checked against a practitioner report of a
[Driver Verifier boot loop](https://superuser.com/questions/1202944/windows-10-stuck-in-bsod-loop-driver-verifier-detected-violation).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
