<!-- mant:tldr:start -->
# wmic

> Treat WMIC as a deprecated, optionally absent compatibility tool; do not install or build new automation around it when `Get-CimInstance` can return typed objects from the same WMI infrastructure.
> More information: https://learn.microsoft.com/windows/win32/wmisdk/wmic.

- Check whether the deprecated executable is present without invoking it:

`Get-Command wmic.exe -All -ErrorAction SilentlyContinue`

- Inspect whether the WMIC Feature on Demand is installed or available:

`Get-WindowsCapability -Online | Where-Object Name -Like 'WMIC*'`

- Use a typed CIM query for new PowerShell automation:

`Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture`
<!-- mant:tldr:end -->

# wmic

## Overview

`wmic.exe` is the deprecated command-line interface to Windows Management
Instrumentation (WMI). The utility, not WMI itself, is deprecated. On newer
Windows 11 releases WMIC is an optional Feature on Demand and may be absent.
New automation should normally use CIM cmdlets and real class/property names.

## Legacy shape

WMIC combines global switches, aliases, WQL queries, verbs and output formats:

```text
wmic [global switches] ALIAS [where CLAUSE] VERB [properties] [/format:FORMAT]
wmic /namespace:NAMESPACE path CLASS get PROPERTY
wmic /node:COMPUTER ...
```

Use `wmic /?`, `wmic alias /?` and `wmic path /?` on a target where legacy
compatibility is required. Do not infer class/property identity from an alias.

## Commands and global switches

<!-- mant:entries role=command case=insensitive -->
- `wmic.exe`: Run the deprecated WMIC compatibility client when the optional
  executable is present; prefer CIM cmdlets for new typed automation.
- `path`: Address an explicit WMI class rather than a WMIC alias.
- `where`: Filter instances using WMIC/WQL-compatible conditions.
- `get`: Display selected instance properties.
- `list`: Display instances using a selected WMIC list format.
- `call`: Invoke a WMI method after reviewing arguments and side effects.
- `set`: Change writable instance properties.
- `delete`: Delete selected provider instances; this is not a generic file delete.

Global slash switches precede the alias/class and use colon-bound values.

<!-- mant:entries role=option case=insensitive -->
- `/namespace`: Select the following WMI namespace instead of the default.
- `/role`: Select the following endpoint role/path context.
- `/node`: Select one or more target computers.
- `/implevel`: Select COM impersonation level for the connection.
- `/authlevel`: Select COM authentication level.
- `/locale`: Select the client locale identifier.
- `/privileges`: Enable or disable required privileges for the WMIC operation.
- `/trace`: Enable or disable WMIC command tracing.
- `/record`: Record interactive commands and output to the following file.
- `/interactive`: Enable or disable interactive prompting.
- `/failfast`: Control node-reachability ping behavior before remote commands.
- `/user`: Select the remote connection account.
- `/password`: Supply its password; avoid inline secrets and prefer CIM session
  credentials through an approved secure channel.
- `/output`: Write output to the following file instead of stdout.
- `/append`: Append output to the following file.
- `/aggregate`: Control aggregate display across multiple nodes.
- `/authority`: Select the connection authentication authority.
- `/format`: Select a WMIC output format; formatted text is not a stable schema.
- `/?`: Display installed WMIC help when the optional executable is present.

## PowerShell boundaries

Detect `wmic.exe` capability before invocation and do not install it as a new
dependency merely to preserve text parsing. Colon-bound switches are one native
argument and WMIC output is locale/provider-sensitive. Capture
`$LASTEXITCODE`; for migration, resolve namespace/class/property identity and
use `Get-CimClass`, `Get-CimInstance`, or a reviewed `Invoke-CimMethod` with a
typed `CimSession` and explicit target/authentication policy.

## Common mistakes

- Interpreting “deprecated” as “WMI is removed,” or assuming `wmic.exe` exists
  on every Windows 11 host. Detect capability and migrate rather than silently
  installing a deprecated dependency.
- Replacing WMIC with `Get-WmiObject` in new cross-version code. PowerShell 7
  does not include that legacy cmdlet; prefer `Get-CimInstance`/CIM sessions.
- Parsing column-aligned or `/format:list` text as a stable schema. Locale,
  nulls, escaping, aliases, widths and provider behavior make text brittle.
- Treating `Status = OK` as a complete storage/device health assessment. WMI
  fields have class/provider-specific semantics and can be stale or shallow.
- Querying `Win32_Product` for software inventory. Its provider can be slow and
  can trigger Windows Installer consistency checks; choose a supported inventory
  source for the actual question.
- Translating `delete`, `call`, `set` or alias verbs mechanically into a CIM
  command without reviewing target identity, method arguments, return values,
  provider side effects and rollback.
- Assuming remote WMIC and CIM use identical transport, firewall, namespace,
  authentication, delegation and authorization behavior.

## PowerShell migration

Map the WMIC alias to its underlying namespace/class/property, then use
`Get-CimClass` for schema and `Get-CimInstance` for objects. Use
`Invoke-CimMethod` only after reviewing method side effects and return values.
Select explicit properties before JSON/CSV export and record the target and
namespace. A one-line textual translation is not sufficient verification.

## Version and platform differences

`wmic.exe` is Windows-only, deprecated, and can be absent. Microsoft documents
WMIC as a Feature on Demand on Windows 11 22H2 and later and not preinstalled
starting with Windows 11 24H2. Exact capability state, providers, classes and
remote behavior vary by image, edition, build, architecture and installed roles.

## Related documents

- [dism](dism.md)
- [optionalfeatures](optionalfeatures.md)
- [systeminfo](systeminfo.md)
- [windows-tools](windows-tools.md)

## Sources and license

Microsoft's current [WMIC lifecycle page](https://learn.microsoft.com/windows/win32/wmisdk/wmic)
and [Feature on Demand catalog](https://learn.microsoft.com/windows-hardware/manufacture/desktop/features-on-demand-non-language-fod?view=windows-11)
define deprecation and availability. A highly viewed
[Stack Overflow migration question](https://stackoverflow.com/questions/57121875/what-can-i-do-about-wmic-is-deprecated)
records common replacement demand but is not lifecycle authority. Exact sources
and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
