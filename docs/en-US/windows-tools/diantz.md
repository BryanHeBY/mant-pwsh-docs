<!-- mant:tldr:start -->
# diantz

> Use the searchable legacy name for the same Cabinet-packaging utility as `makecab`; prefer `makecab.exe` in new automation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/diantz.

- Confirm whether both executable names resolve on this Windows host:

`Get-Command diantz.exe, makecab.exe -All -ErrorAction SilentlyContinue`

- Display the compatibility executable's installed syntax:

`diantz.exe /?`

- Use the clearer current name to package one reviewed file at an explicit destination:

`makecab.exe "{{C:\Build\payload\file.dll}}" "{{C:\Build\output\file.cab}}"`

<!-- mant:tldr:end -->

# diantz

## Overview

`diantz.exe` packages files into Microsoft Cabinet (`.cab`) format. Microsoft
documents it as performing the same actions as the updated `makecab` command.
This page exists so `mant diantz` and legacy scripts lead to the canonical
concept rather than appearing undocumented.

Prefer `makecab.exe` in new commands, documentation, allowlists, telemetry,
and process-launch policy. The alternate filename does not change the input,
output, signing, encryption, or directive-file safety model.

## Common mistakes

### Treating the names as different compression formats

They expose the same Cabinet packaging behavior. Do not convert, repack, or run
both in sequence merely because a recipe uses another name.

### Allowlisting one name and forgetting the other

Application control, child-process monitoring, software inventory, and build
policy should account for both executable names when both are present. An
alternate binary name can otherwise bypass filename-only reasoning.

### Preserving the legacy name in new automation

Use `makecab.exe` to make intent and current documentation easier to discover.
Before migrating an existing script, compare executable paths/versions and
test artifact hashes and layout in the supported build environment.

## Canonical behavior

See [makecab](makecab.md) for single-file and directive-file modes, output-name
defaults, multi-file layouts, PowerShell invocation, signature/provenance, and
artifact verification. See [expand](expand.md) for CAB listing and extraction.

## Version and platform differences

This is a Windows compatibility executable documented on supported Windows
client and server releases. Presence, path, file version, policy, and future
availability must be discovered on the target host; do not copy or redistribute
the executable to manufacture compatibility.

## Sources and license

This original compatibility guide was adapted from Microsoft's official
[Diantz reference](https://learn.microsoft.com/windows-server/administration/windows-commands/diantz)
and [MakeCab reference](https://learn.microsoft.com/windows-server/administration/windows-commands/makecab),
which explicitly describe the commands as equivalent. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
