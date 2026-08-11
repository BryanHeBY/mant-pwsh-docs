<!-- mant:tldr:start -->
# regedit.exe

> Open Registry Editor only for a reviewed interactive investigation or change; use `reg.exe` or the PowerShell Registry provider when the operation must be scripted, typed, bounded, and verified.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/reg.

- Resolve the exact Registry Editor executable without opening it:

`Get-Command regedit.exe -All`

- Open Registry Editor in the current interactive session:

`Start-Process regedit.exe`

- Query one value without opening the editor or changing registry state:

`Get-ItemProperty -LiteralPath '{{HKCU:\Software\Vendor\Product}}' -Name {{ValueName}}`
<!-- mant:tldr:end -->

# regedit.exe

## Overview

Registry Editor is the interactive Windows GUI for viewing and changing registry
keys, values, data types, permissions, hives, and remote registry connections.
It is not a typed automation API, and this page deliberately does not promise an
undocumented command-line switch contract.

Prefer the supported product UI, policy interface, deployment system, or
application API when one owns the setting. Direct registry editing bypasses
their validation and can damage applications, profiles, security, or Windows.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `regedit.exe`: Open Registry Editor for an explicitly identified interactive user, computer, privilege level, architecture, and registry view.

Opening the process proves only that a GUI was requested. It does not prove that
the expected hive loaded, the intended view is visible, a write succeeded, the
consumer accepted it, or policy will not overwrite it.

## Safe workflow

1. Identify the owning product and prefer its documented configuration surface.
2. Record the computer, user/SID, hive, complete key, value name, type, data,
   registry view, permissions, policy authority, and consuming process.
3. Export or otherwise back up the narrow target and test restoration before a
   material change; a `.reg` file is not a complete system rollback.
4. Make the smallest reviewed change and verify both registry state and the
   consuming feature from the same identity and architecture.

## Common mistakes

- Treating Registry Editor as an unattended CLI or relying on remembered,
  undocumented switches for import, export, or navigation.
- Confusing HKCU for the elevated account with HKCU for the intended user, or
  confusing local, loaded, offline, and remote hives.
- Editing the 32-bit view while the consumer reads the 64-bit view, or the
  reverse, without recording caller architecture and redirection.
- Assuming an exported subtree is a transactional backup: importing merges data
  and does not necessarily remove values created after export.
- Changing a policy-backed value locally and treating the temporary appearance
  as effective or durable policy.
- Assuming Windows automatically maintains a current `RegBack` copy; automatic
  system-registry backup to that folder is not a general recovery guarantee.
- Deleting a key because it looks unused without dependency, ACL, service,
  profile, installer, rollback, and offline-recovery evidence.

## PowerShell behavior

`Start-Process regedit.exe` launches the GUI and returns process information only
when requested; it does not return registry objects. For automation, use the
Registry provider (`Get-Item`, `Get-ItemProperty`, and narrowly reviewed write
cmdlets) or call `reg.exe` explicitly and check `$LASTEXITCODE` immediately.

PowerShell 7 on Windows and Windows PowerShell 5.1 can run at different process
architectures. Resolve the target view explicitly when architecture matters and
never infer the intended HKCU from the window title alone.

## Version and platform differences

`regedit.exe` is Windows-only. Available hives, protected keys, virtualization,
remote access, architecture views, UI behavior, and policy ownership vary by
Windows version, edition, role, installed software, identity, and architecture.

## Related documents

- [reg.exe](reg.exe.md)
- [regini.exe](regini.exe.md)
- [control.exe](control.exe.md)
- [mmc.exe](mmc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Registry command guidance](https://learn.microsoft.com/windows-server/administration/windows-commands/reg),
[remote Registry Editor guidance](https://learn.microsoft.com/troubleshoot/windows-server/system-management-components/remotely-edit-the-registry),
and [system registry backup behavior](https://learn.microsoft.com/troubleshoot/windows-client/installing-updates-features-roles/system-registry-no-backed-up-regback-folder).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
