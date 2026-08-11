<!-- mant:tldr:start -->
# driverquery.exe

> Inventory installed Windows device drivers and selected properties.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/driverquery.

- List local drivers in CSV form:

`driverquery.exe /fo csv`

- Display verbose driver properties:

`driverquery.exe /v /fo list`

- Display signed-driver information:

`driverquery.exe /si /fo list`
<!-- mant:tldr:end -->

# driverquery.exe

## Overview

`driverquery.exe` lists installed device drivers locally or remotely. `/v`
requests verbose properties, `/si` signed-driver information, and `/fo`
selects table, list, or CSV. `/v` and `/si` are mutually exclusive.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `driverquery.exe`: Inventory installed Windows device drivers on the local or
  one remote computer using the selected display view.

Remote credentials affect query access, not the target driver trust decision.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Query the following remote computer name or IP address.
- `/u`: Run the remote query using the following account.
- `/p`: Supply the `/u` password; omit the entire switch to receive a prompt
  instead of exposing a secret in command arguments.
- `/fo`: Select `TABLE`, `LIST`, or `CSV` output.
- `/nh`: Suppress headers in `TABLE` or `CSV` output.
- `/v`: Include verbose driver properties; it cannot be combined with `/si`.
- `/si`: Display signed-driver information; it cannot be combined with `/v`.
- `/?`: Display installed command help.

## PowerShell boundaries

`driverquery.exe` emits localized text. Use `/fo csv` with headers retained for
bounded interchange, or query typed CIM/PnP/Driver Store interfaces for the
specific inventory question. Capture `$LASTEXITCODE`; a signed row is not a
typed chain/revocation/vulnerability assessment, and a failed remote query is
not an empty driver inventory.

## Common mistakes

### Treating the list as Driver Store package inventory

This is not a replacement for `pnputil /enum-drivers`, device enumeration, or
package/version compliance tooling. Decide whether the subject is a loaded
driver, installed driver service, device, or Driver Store package.

### Inferring trust from a signed row alone

Signature presence is not a complete assessment of chain validity, revocation,
publisher policy, vulnerability, load state, or compatibility. Use the
security and servicing checks required by the decision.

### Parsing default tables or comparing localized dates

Request CSV where text is unavoidable, retain headers, and normalize typed
data. Output fields, truncation, names, and dates can vary by locale and host.

### Passing remote passwords on the command line

Omit `/p` so the command prompts. Never embed credentials in scripts or agent
transcripts.

## Version and platform differences

This administrative executable is Windows-only. Visibility and fields depend
on permissions, OS version, architecture, remote services, and driver model.

## Related documents

- [systeminfo.exe](systeminfo.exe.md)
- [whoami.exe](whoami.exe.md)
- [tasklist.exe](tasklist.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[driverquery reference](https://learn.microsoft.com/windows-server/administration/windows-commands/driverquery).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
