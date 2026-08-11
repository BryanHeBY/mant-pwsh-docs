<!-- mant:tldr:start -->
# systempropertiesadvanced

> Open Advanced System Properties only after recording the exact setting and scope; environment, performance, profile, startup/recovery and virtual-memory changes affect different consumers and may require a new process, sign-in or restart.
> More information: https://learn.microsoft.com/windows/win32/procthread/environment-variables.

- Open the Advanced tab of System Properties:

`SystemPropertiesAdvanced.exe`

- Inspect this PowerShell process's Path entries:

`$env:Path -split ';'`

- Read the persistent user and machine Path values without changing them:

`'User','Machine' | ForEach-Object { [pscustomobject]@{ Scope = $_; Path = [Environment]::GetEnvironmentVariable('Path', $_) } }`
<!-- mant:tldr:end -->

# systempropertiesadvanced

## Overview

`SystemPropertiesAdvanced.exe` opens the Advanced tab of classic System
Properties. It links to performance/virtual memory, user profiles, startup and
recovery, and environment variables. These are separate configuration surfaces
with different scopes, privilege, restart and rollback requirements.

## Command interface

<!-- mant:entries role=command case=insensitive -->
- `SystemPropertiesAdvanced.exe`: Open the Advanced classic System Properties
  entry point for interactive environment, performance, profile, and recovery settings.

## Common mistakes

- Confusing the current process environment (`$env:*`) with persistent User and
  Machine values. Existing processes keep their inherited environment; opening
  a new shell, signing in again or restarting a service may be required.
- Replacing `Path` instead of adding one exact directory, removing required
  entries, introducing empty/duplicate/untrusted current-directory elements, or
  confusing `Path` with `PATHEXT` and application-specific search rules.
- Elevating the dialog to edit “your” user variables. With alternate
  credentials, the dialog can expose the administrator account's user scope.
- Assuming the Path editor's row layout proves the stored value is valid. Save
  the original User and Machine strings and verify command resolution in a new
  process after any edit.
- Downloading a replacement `SystemPropertiesAdvanced.exe` from a file site
  when a broken `%SystemRoot%`, `%windir%`, Path, ACL or protected system file is
  the actual problem. Use the full trusted system path and supported repair
  diagnostics.
- Changing virtual memory, DEP/performance, profiles, dump paths or automatic
  restart without free-space, workload, crash-capture, backup and
  console-recovery planning.

## PowerShell boundaries

Use `Start-Process "$env:SystemRoot\System32\SystemPropertiesAdvanced.exe"`
for interactive launch. `$env:Name = value` changes only the current process and
children. Use `[Environment]::GetEnvironmentVariable()` to distinguish Process,
User and Machine state; persistent mutations need explicit scope, authorization,
original-value backup and verification in a new process.

## Version and platform differences

This entry point is Windows-only. Dialog contents, environment limits/editor
behavior, dump and memory options, elevation and Settings redirects vary by
Windows release, architecture, edition, policy and account type.

## Related documents

- [control](control.md)
- [reg](reg.md)
- [where](where.md)
- [systeminfo](systeminfo.md)

## Sources and license

Microsoft documents this entry point in
[Executing Control Panel Items](https://learn.microsoft.com/windows/win32/shell/executing-control-panel-items)
and explains scope/inheritance in
[Environment Variables](https://learn.microsoft.com/windows/win32/procthread/environment-variables).
A [Super User Path-editor question](https://superuser.com/questions/1565006/path-environment-variable-is-represented-by-a-single-row-in-explorer-gui)
is recorded as evidence of recurring UI and expansion confusion, not as syntax
authority. Exact sources and licenses are in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
