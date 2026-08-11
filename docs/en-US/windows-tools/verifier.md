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

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `verifier.exe`: Query or configure Driver Verifier on a dedicated Windows test host.

Most configuration changes are effective after restart; volatile operations
take effect immediately. Numeric flags and rule support are build-specific.

<!-- mant:entries role=option case=insensitive -->
- `/standard`: Select Microsoft's standard verifier tests for the target build.
- `/flags`: Select a build-specific numeric combination of verifier tests.
- `/all`: Select all installed drivers for verification after restart; the
  legal `/driver.exclude` modifier can omit exact binary names but currently
  cannot be represented as a ManT option entry because its name contains a dot.
- `/driver`: Select exact driver binary names; wildcards are not supported.
- `/bootmode`: Select persistent, disable-after-fail, one-boot, or unusual-shutdown behavior.
- `/query`: Display current Driver Verifier activity and counters.
- `/querysettings`: Display next-boot settings, excluding volatile additions.
- `/reset`: Clear configured settings so no drivers are verified after next restart.
- `/rules`: Query, reset, default, or disable supported verifier rule IDs.
- `/faults`: Configure low-resource allocation fault injection.
- `/faultssystematic`: Control and inspect systematic low-resource simulation.
- `/log`: Continuously write verifier statistics until interrupted.
- `/interval`: Set the statistics-log interval in seconds.
- `/volatile`: Apply supported flag/driver/fault changes immediately.
- `/adddriver`: Add exact driver binary names to volatile verification.
- `/removedriver`: Remove exact driver binary names from volatile verification.
- `/iolevel`: Select supported I/O Verification level 1 or 2.
- `/domain`: Configure verifier extensions for WDM, NDIS, KS, or audio drivers.
- `/logging`: Enable extension rule-violation logging.
- `/livedump`: Enable extension live-dump collection for violations.
- `/help`: Display command-line help.
- `/?`: Display command-line help.

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

## PowerShell boundaries

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
