<!-- mant:tldr:start -->
# winget-features

> List experimental WinGet features and whether each is enabled.
> More information: https://learn.microsoft.com/windows/package-manager/winget/features.

- List experimental features for the installed client:

`winget features`

- Inspect policy and client paths that can affect feature availability:

`winget --info`

- Open the settings file only after recording current feature state:

`winget settings`
<!-- mant:tldr:end -->

# winget features

## Synopsis

```text
winget features [options]
```

The command displays experimental features compiled into the installed WinGet
client and their current state. It does not enable them. Features can be
changed through supported settings and can be restricted by group policy.

## Options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display command help.
- `--wait`: Wait for a key press before exit.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warning display.
- `--disable-interactivity`: Fail instead of waiting for input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Interpret the list

```powershell
winget features
if ($LASTEXITCODE -ne 0) { throw "Feature inventory failed: $LASTEXITCODE" }
winget --info
```

The table is human-oriented, localized output. Record WinGet version, policies,
settings file, and feature list together; do not assume a feature name or state
from another machine or release.

An experimental feature can change or disappear without the compatibility
expectations of a stable command. Enabling one is a client-behavior change and
must be tested with the workflows it affects.

## PowerShell considerations

Do not parse column positions as a stable API. Check `$LASTEXITCODE` and retain
raw output. For policy and settings automation, use the documented settings,
administrator setting, or DSC contracts rather than editing formatted output.

## Common mistakes

### Assuming a disabled feature is absent

The client can contain a feature that settings or policy disable. Inspect
`winget features`, `winget --info`, and the target user's settings together.

### Enabling preview behavior fleet-wide without a client pin

Feature contracts can move between releases. Test a pinned client and maintain
rollback before broad enablement.

## Version and availability

The list is intentionally version-specific and changes with WinGet stable and
preview builds. Policy can hide or disable behavior. The installed command is
the state source; the online list is discovery guidance only.

## Verification boundary

Official behavior and options were reviewed. No installed feature inventory,
policy, settings file, network, or feature toggle was read or changed.

## Related documents

- [winget settings](winget-settings.md)
- [Windows Package Manager](winget.exe.md)

## Sources and license

This original guide was adapted from the official
[winget features documentation](https://learn.microsoft.com/windows/package-manager/winget/features).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
