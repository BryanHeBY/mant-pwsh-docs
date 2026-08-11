<!-- mant:tldr:start -->
# msmq

> Inventory Message Queuing services, features, queues, and backup paths before any stop, backup, restore, trigger, or executable action.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/mqbkup.

- Inventory installed MSMQ features without enabling them:

`Get-WindowsOptionalFeature -Online -FeatureName '*MSMQ*' | Select-Object FeatureName, State`

- Inspect core and trigger service state without launching service executables:

`Get-Service -Name MSMQ,MSMQTriggers -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType`

- Read the backup/restore syntax without stopping MSMQ:

`mqbkup.exe /?`

- Confirm a proposed new backup directory is absent and its parent has space:

`$target = "{{D:\Backups\MSMQ-2026-08-11}}"; if (Test-Path -LiteralPath $target) { throw 'Target must be new' }; Get-Volume -DriveLetter {{D}} | Select-Object SizeRemaining`

- Inventory queues through the optional MSMQ PowerShell module when installed:

`Get-Command -Module MSMQ -ErrorAction SilentlyContinue; Get-MsmqQueue -QueueType Private -ErrorAction SilentlyContinue`
<!-- mant:tldr:end -->

# msmq

## Overview

This family page covers `mqsvc.exe` (the Message Queuing service executable),
`mqtgsvc.exe` (the trigger service that can launch executables/COM components),
and `mqbkup.exe` (local message/registry backup and restore). The service
executables are not general interactive administration commands. Use service,
feature, queue, event, and MSMQ management interfaces instead.

## Backup and restore

<!-- mant:entries role=command case=insensitive -->
- `mqbkup.exe`: Back up or restore local MSMQ messages and registry configuration.
- `mqsvc.exe`: MSMQ service executable; do not launch manually.
- `mqtgsvc.exe`: MSMQ trigger service executable; do not launch manually.

Backup and restore modes mutate service availability and persistent queue data.

<!-- mant:entries role=option case=insensitive -->
- `/b`: Back up MSMQ state into a new dedicated directory.
- `/r`: Restore MSMQ state from an exact reviewed backup directory.
- `/y`: Suppress confirmation and permit destructive directory handling.
- `/?`: Display installed backup/restore syntax.

`mqbkup /b <folder>` backs up local messages and registry settings; `/r`
restores them. Both stop the local MSMQ service and try to restart it only if it
was running beforehand. Local applications must be closed. An existing nonempty
target can be recursively deleted, especially with `/y`. Restore destinations
come from restored registry paths, not necessarily the old storage locations.

## Common mistakes

### Launching `mqsvc.exe` or `mqtgsvc.exe` manually

They are service images. Manual execution bypasses Service Control Manager
identity, dependencies, recovery, arguments, logging, and lifecycle. Query/control
the registered service through supported administration instead.

### Backing up into an existing directory

The utility can delete all files and subdirectories in a nonempty target. Use a
new dedicated protected path on validated storage; do not use `/y` as a normal
automation convenience.

### Treating backup completion as application-consistent recovery

Producers/consumers and triggers must be quiesced. Verify service restart,
queue/message/application behavior, permissions/certificates, transactional
state, storage locations, and a restore drill on a compatible isolated system.

### Restoring over a differently configured host

Registry-directed paths, machine identity, AD integration, certificates,
permissions, feature set, version, and applications can differ. Establish
supported compatibility and collision/duplicate-message handling first.

### Ignoring trigger code execution

MSMQ Triggers can start an executable or COM component based on message rules.
Inventory trigger definitions, binary path/signature, service identity,
arguments, queue ACLs, secrets, network access, and downstream side effects.

## PowerShell boundaries

MSMQ cmdlets return objects when the optional module exists; service executables
and MqBkUp are native. Capture the backup exit code and logs immediately. Never
infer queue durability or exactly-once application processing from process exit
alone.

## Version and platform differences

This is Windows-only optional-feature/role tooling. Workgroup versus domain,
routing, HTTP support, triggers, AD integration, certificates, storage paths,
clustering, feature names, and PowerShell module availability vary by release.

## Related documents

- [sc.exe](sc.exe.md)
- [wevtutil.exe](wevtutil.exe.md)

## Sources and license

Adapted as an original family guide from Microsoft's [MqBkUp](https://learn.microsoft.com/windows-server/administration/windows-commands/mqbkup),
[MqSvc](https://learn.microsoft.com/windows-server/administration/windows-commands/mqsvc),
and [MqTgSvc](https://learn.microsoft.com/windows-server/administration/windows-commands/mqtgsvc)
references. Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
