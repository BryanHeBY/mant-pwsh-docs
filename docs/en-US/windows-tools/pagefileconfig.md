<!-- mant:tldr:start -->
# pagefileconfig

> Migrate from the deprecated PageFileConfig command; distinguish startup configuration from current page-file usage.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/pagefileconfig.

- Confirm that the legacy executable is present before handling an old script:

`Get-Command pagefileconfig.exe -ErrorAction SilentlyContinue`

- Query configured page-file settings; an empty result can mean system-managed sizing:

`Get-CimInstance -ClassName Win32_PageFileSetting | Select-Object Name, InitialSize, MaximumSize`

- Query page files currently in use instead of configuration objects:

`Get-CimInstance -ClassName Win32_PageFileUsage | Select-Object Name, AllocatedBaseSize, CurrentUsage, PeakUsage`

- Check whether Windows manages paging files automatically:

`Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object AutomaticManagedPagefile`
<!-- mant:tldr:end -->

# pagefileconfig

## Overview

`pagefileconfig.exe` was a command for displaying and configuring paging-file
virtual-memory settings. Microsoft marks it deprecated. New automation should
use supported CIM/system-management interfaces and preserve system-managed
behavior unless a measured workload, crash-dump, or vendor requirement justifies
a reviewed change.

## Configuration, runtime, and policy

<!-- mant:entries role=command case=insensitive -->
- `pagefileconfig.exe`: Deprecated paging-file configuration utility; migrate to CIM.

The command is indexed for legacy discovery only. Current automation should
distinguish startup settings, runtime usage, and automatic management.

`Win32_PageFileSetting` represents startup settings and can be absent when
Windows automatically manages paging files. `Win32_PageFileUsage` represents
runtime state. `Win32_ComputerSystem.AutomaticManagedPagefile` identifies the
automatic-management choice. These are related but not interchangeable views.

## Common mistakes

### Treating an empty Win32_PageFileSetting query as no page file

A Microsoft Q&A case across Windows 10/11 and Server 2016–2025 was resolved by
recognizing system-managed sizing; `Win32_PageFileUsage` still showed runtime
files. Query all three views before reporting absence or drift.

### Copying a fixed size from another computer

Paging and dump requirements depend on committed memory, workload behavior,
storage, dump type, support policy, and automatic crash-dump management. A
universal RAM multiplier is not a sound change plan.

### Changing settings and verifying only the stored values

Page-file settings are applied at startup. Plan the reboot, then verify runtime
usage and crash-dump readiness. Do not claim completion from a CIM write alone.

### Removing the last usable page file

This can affect commit capacity and crash dumps. Preserve a recovery route and
coordinate with workload and incident-response owners before any mutation.

## PowerShell boundaries

`Get-CimInstance` returns typed data and works in PowerShell 5.1 and 7 on
Windows. Creating or changing `Win32_PageFileSetting` needs administrative
privilege and is intentionally omitted from the TLDR because it is a high-
impact, restart-dependent change.

## Version and platform differences

PageFileConfig is deprecated and may be absent. CIM class availability starts
with older Windows versions, but automatic-management, crash-dump, storage,
policy, virtualization, and product-support behavior varies by release.

## Related documents

- [wmic](wmic.md)
- [systempropertiesadvanced](systempropertiesadvanced.md)

## Sources and license

This original migration guide was adapted from Microsoft's deprecated
[PageFileConfig catalog entry](https://learn.microsoft.com/windows-server/administration/windows-commands/pagefileconfig),
[Win32_PageFileSetting reference](https://learn.microsoft.com/windows/win32/cimwin32prov/win32-pagefilesetting),
and a [Microsoft Q&A configuration-versus-usage case](https://learn.microsoft.com/answers/questions/2118221/querying-win32-pagefilesetting-results-in-empty-re).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft-hosted material
and this adaptation are licensed under CC BY 4.0.
