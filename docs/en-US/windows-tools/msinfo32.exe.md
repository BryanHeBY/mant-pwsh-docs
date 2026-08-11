<!-- mant:tldr:start -->
# msinfo32.exe

> Inspect System Information categories and export a new, access-controlled NFO or text report while waiting for collection to finish and verifying the artifact rather than trusting process launch.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/msinfo32.

- Display installed command-line syntax:

`msinfo32.exe /?`

- Open System Information with stable category IDs visible:

`msinfo32.exe /showcategories`

- Export only System Summary to a new NFO and wait for the GUI process to finish:

`Start-Process msinfo32.exe -ArgumentList @('/nfo', '"{{C:\Evidence\system-summary.nfo}}"', '/categories', '+systemsummary') -Wait`

- Export selected problem-device/resource categories to a new text report and wait:

`Start-Process msinfo32.exe -ArgumentList @('/report', '"{{C:\Evidence\device-resources.txt}}"', '/categories', '+componentsproblemdevices+resourcesconflicts+resourcesforcedhardware') -Wait`
<!-- mant:tldr:end -->

# msinfo32.exe

## Overview

`msinfo32.exe` is the Windows System Information GUI and report exporter. It can
collect local or remote hardware, components, resources, drivers, and software
environment data; `/showcategories` exposes category IDs, `/categories` limits
the collection, `/nfo` writes the native format, and `/report` writes text.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `msinfo32.exe`: Open Windows System Information or collect one scoped local or
  remote diagnostic report.

Report collection is asynchronous unless the caller explicitly waits for the
process; output can contain sensitive host/user/software details.

<!-- mant:entries role=option case=insensitive -->
- `/nfo`: Save the collected report in native System Information NFO format.
- `/report`: Save the collected report as text at the following exact filename.
- `/computer`: Collect from the following remote Windows computer using the
  caller's permitted remote-management context.
- `/showcategories`: Display category IDs that can be used for scoped collection.
- `/categories`: Include/exclude the following category-ID expression.
- `/?`: Display installed launcher help where supported.

## Common mistakes

- Launching export asynchronously and copying, hashing, or uploading a partial
  file. Wait for the process, then verify existence, size, timestamps, format,
  expected categories, collection host, and content—not merely an exit code.
- Omitting quotes around paths with spaces, using a missing parent directory, or
  assuming `/report` appends `.txt`; it preserves the specified filename.
- Renaming an NFO to `.txt` and treating it as a text report. Choose `/nfo` for
  native viewing and `/report` for text; retain the format and tool version.
- Using localized display labels as category IDs. Discover stable IDs with
  `/showcategories` and test inclusion/exclusion expressions on the target build.
- Exporting everything without data-handling review. Reports can expose host,
  serial, driver, hotfix, process, environment, path, share, and user details.
- Treating remote `/computer` as a credential switch or proof of completeness.
  Record caller, target, RPC/firewall/services/permissions, failures, and locality.

## PowerShell boundaries

Use `Start-Process -Wait` with an argument array and a new explicit destination.
Avoid `Invoke-Expression`; never derive categories or paths from untrusted text.
After completion, validate the artifact before copying it across a trust boundary.
For structured automation, prefer supported CIM/API queries scoped to the exact
facts needed rather than parsing a localized all-system text report.

## Version and platform differences

`msinfo32.exe` is Windows-only. Categories, fields, remote collection, output,
localization, privileges, services, and collection duration vary by build,
architecture, installed hardware/software, policy, and caller/session identity.

## Related documents

- [systeminfo.exe](systeminfo.exe.md)
- [driverquery.exe](driverquery.exe.md)
- [perfmon.exe](perfmon.exe.md)
- [pnputil.exe](pnputil.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[msinfo32 reference](https://learn.microsoft.com/windows-server/administration/windows-commands/msinfo32).
Waiting and export-path failure modes were cross-checked against practitioner
questions about [automated device reports](https://stackoverflow.com/questions/38014700/exporting-device-manager-to-a-txt-file)
and [PowerShell export execution](https://stackoverflow.com/questions/52418822/how-to-run-msinfo32-console-command-from-c).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
