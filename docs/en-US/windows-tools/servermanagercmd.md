<!-- mant:tldr:start -->
# servermanagercmd

> Migrate deprecated ServerManagerCmd role/feature automation to Server Manager PowerShell cmdlets after inventory and restart planning.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/servermanagercmd.

- Confirm legacy tool presence and version without changing roles:

`Get-Command servermanagercmd.exe -ErrorAction SilentlyContinue; servermanagercmd.exe -version`

- Query current Server roles/features through the supported typed interface:

`Get-WindowsFeature | Select-Object Name, DisplayName, InstallState`

- Review a legacy answer file as data without applying it:

`[xml]$answer = Get-Content -LiteralPath "{{C:\Evidence\servermanager-answer.xml}}" -Raw; $answer.DocumentElement.Name`

- Preview an exact current role change without applying it:

`Install-WindowsFeature -Name {{Web-Server}} -WhatIf`
<!-- mant:tldr:end -->

# servermanagercmd

## Overview

`servermanagercmd.exe` queried, installed, and removed Windows Server roles,
role services, and features, directly or from XML. Microsoft deprecates it and
recommends Server Manager PowerShell cmdlets. Migrate by semantic intent and
exact target build, not by mechanically translating old identifiers.

## Common mistakes

### Treating `-whatif` on an answer file as permanent validation

It previews against the current machine at that time. Dependencies, source
payload, policy, pending restart, servicing state, and later build can differ.

### Copying legacy feature IDs into current cmdlets

Names and dependency graphs change. Use `Get-WindowsFeature` on the target,
review subfeatures/management tools and removal consequences, then test.

### Carrying `-restart` into automation

Automatic restart can interrupt workloads and management access. Make restart
an explicit orchestrated phase with drain, backup, maintenance and validation.

### Parsing display text instead of using objects

Use typed PowerShell results and their documented restart/success properties;
do not scrape localized ServerManagerCmd output or equate process code alone
with an operational role.

## PowerShell behavior

Server Manager cmdlets are Windows PowerShell/Windows Server management APIs
and may be available through compatibility/remoting rather than natively on
every PowerShell 7 host. Record edition, module version, target and result.

## Version and platform differences

This is deprecated Windows Server tooling. Server Core, Features on Demand,
payload sources, remote management, clustering, roles and PowerShell module
availability vary by Windows Server release.

## Related documents

- [dism](dism.md)
- [optionalfeatures](optionalfeatures.md)

## Sources and license

Adapted as an original migration guide from Microsoft's [ServerManagerCmd reference](https://learn.microsoft.com/windows-server/administration/windows-commands/servermanagercmd)
and [Windows Server management overview](https://learn.microsoft.com/windows-server/administration/overview).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
