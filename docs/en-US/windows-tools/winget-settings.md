<!-- mant:tldr:start -->
# winget-settings

> Inspect or edit WinGet user settings and supported administrator settings.
> More information: https://learn.microsoft.com/windows/package-manager/winget/settings.

- Open the current user's JSON settings file in its associated editor:

`winget settings`

- Export effective settings for review:

`winget settings export`

- List experimental feature state before editing settings:

`winget features`
<!-- mant:tldr:end -->

# winget settings

## Synopsis

```text
winget settings [export | set | reset] [arguments] [options]
```

The alias `winget config` opens the same settings workflow. With no subcommand,
WinGet launches the current user's JSON settings file in its associated editor.
Settings change defaults; explicit command arguments and administrator/group
policy can override or restrict them.

## Subcommands

<!-- mant:entries role=command case=insensitive -->
- `export`: Export effective user and administrator settings for inspection or automation.
- `set`: Set a supported administrator setting; use `--enable` or `--disable` according to its contract.
- `reset`: Restore a supported administrator setting to its default state.

## Command options

<!-- mant:entries role=option case=insensitive -->
- `--enable SETTING`: Enable the named administrator setting through `settings set`.
- `--disable SETTING`: Disable the named administrator setting through `settings set`.
- `-?`, `--help`: Display help for the selected settings operation.
- `--wait`: Wait for a key press before exit; avoid in unattended workflows.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings without changing validation or policy.
- `--disable-interactivity`: Fail instead of opening prompts.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Safe editing workflow

Export/copy the current file, validate JSON, retain the `$schema` property, make
one scoped change, and test the commands it affects:

```powershell
winget settings export
if ($LASTEXITCODE -ne 0) { throw "Settings export failed: $LASTEXITCODE" }

winget features
winget --info
```

`winget settings` opens a GUI editor and can block or outlive the invoking
process. For managed automation, locate the user settings through `winget
--info`, work on reviewed JSON with schema validation, and use supported DSC,
administrator setting, or policy interfaces rather than UI automation.

## Source settings

### source.autoUpdateIntervalInMinutes

A positive integer controls how often source refresh is checked when a source
is used. `0` disables automatic checks; the documented default is 15 minutes.
Use `winget source update` for an explicit refresh.

## Visual settings

### visual.progressBar

Selects a supported progress style such as `accent`, `rainbow`, `retro`,
`sixel`, or `disabled`. This affects display, not package progress semantics.

### visual.anonymizeDisplayedPaths

Replaces recognized folder prefixes with environment-variable forms in display
output. It is not a data-loss-prevention or secret-redaction guarantee.

### visual.enableSixels

Allows sixel images in supported output contexts. Terminal capability and
logging behavior still need target verification.

## Logging settings

### logging.level

Sets `verbose`, `info`, `warning`, `error`, or `critical`; invalid/unset values
default to `info`. `--verbose-logs` overrides this for one invocation.

### logging.channels

Restricts log channels; `default` and `all` are special values. Unknown channel
names are ignored, so verify resulting logs.

### logging.file.ageLimitInDays

Deletes older files in WinGet's default log directory at process startup; the
documented default is 7 days and `0` disables this limit.

### logging.file.totalSizeLimitInMB

Deletes oldest default-directory logs after the total exceeds the limit; the
documented default is 128 MB and `0` disables it.

### logging.file.countLimit

Limits log-file count by deleting oldest files; default `0` disables the count
limit.

### logging.file.individualSizeLimitInMB

Wraps one log at the size limit; the documented default is 16 MB and `0`
disables it. Cleanup applies only to WinGet's default log directory.

## Installer preferences and requirements

The same selector names can appear under `installBehavior.preferences` or
`installBehavior.requirements`. Preferences rank acceptable candidates and can
fall back. Requirements filter candidates and can leave no applicable
installer. An explicit CLI selector overrides the corresponding requirement
for that invocation.

### scope

Uses `user` or `machine`, corresponding to `--scope`.

### locale

Uses ordered BCP 47 locale tags, corresponding to `--locale`.

### architectures

Uses ordered compatible architecture names, corresponding to `--architecture`.

### installerTypes

Uses an ordered list such as `appx`, `burn`, `exe`, `font`, `inno`, `msi`,
`msix`, `msstore`, `nullsoft`, `portable`, `wix`, or `zip`, corresponding to
`--installer-type`. Exact accepted values evolve with WinGet.

## Install behavior

### installBehavior.disableInstallNotes

Hides post-install notes when true. Hiding them can remove operational guidance
from interactive runs; it does not change installer behavior.

### installBehavior.portablePackageUserRoot

Sets an absolute user-scope root for portable packages; the default is below
`%LOCALAPPDATA%\Microsoft\WinGet\Packages`.

### installBehavior.portablePackageMachineRoot

Sets an absolute machine-scope root for portable packages; the default is below
`%PROGRAMFILES%\WinGet\Packages`.

### installBehavior.defaultInstallRoot

Sets the default path for installers requiring an explicit install location.
The selected installer must still honor that location.

### installBehavior.maxResumes

Caps resume attempts for one resume ID to prevent an undetected reboot loop.

### installBehavior.archiveExtractionMethod

Selects `shellApi` or `tar` for archive extraction. This is implementation
choice, not permission to process untrusted archives.

## Uninstall and configuration behavior

### uninstallBehavior.purgePortablePackage

When true, portable-package uninstall removes related files/directories. The
documented default is false; enabling it increases data-loss scope.

### configureBehavior

Controls the default root where PowerShell modules are installed while applying
a WinGet Configuration. Review module trust and path ACLs separately.

## Download behavior

### downloadBehavior.defaultDownloadDirectory

Sets an absolute default artifact directory; otherwise the user's Downloads
directory is used. A CLI `--download-directory` selection is clearer in
controlled automation.

## Telemetry settings

### telemetry.disable

When true, prevents WinGet from writing its telemetry ETW events. Review the
current WinGet privacy statement and organizational policy for full scope.

## Network settings

### network.downloader

Selects Delivery Optimization (`do`, the default) or WinINet (`wininet`) where
policy permits. Authentication, proxy, cache, and service behavior differ.

### network.doProgressTimeoutInSeconds

Sets the no-progress timeout before WinGet falls back from Delivery
Optimization behavior.

## Interactivity

### interactivity

Controls whether WinGet prompts are allowed by default. Disabling prompts does
not make publisher installers silent; use command and package-specific controls.

## Experimental features

### experimentalFeatures.directMSI

Allows direct MSI API installation. Experimental contracts can change and must
be tested with elevation and rollback.

### experimentalFeatures.resume

Allows supported commands to resume after reboot. Coordinate with maintenance
and cap retries through `maxResumes`.

### experimentalFeatures.fonts

Enables WinGet font support and related font commands where compiled into the
client.

### experimentalFeatures.sourcePriority

Enables source priority as a lower-order package-selection signal; match quality
and field still precede priority.

Use `winget features` to discover the exact feature names present in the
installed client. Do not copy preview feature keys blindly into stable clients.

## PowerShell considerations

The editor workflow is GUI state, while `settings export` is the automation-
friendly path. Check `$LASTEXITCODE` before parsing export output. Read a JSON
file with `Get-Content -Raw | ConvertFrom-Json`; avoid regex editing because it
can corrupt structure or comments supported by the client parser.

## Common mistakes

### Editing the wrong user's settings

WinGet settings are user-context dependent. Confirm `winget --info` from the
same account/service context that performs package operations.

### Treating preferences as hard policy

Preferences can fall back. Use requirements or administrator/group policy when
selection must fail closed, then test that no candidate produces a clear error.

### Assuming malformed/unknown keys fail loudly

Some values default or are ignored. Validate against the current schema and
verify the effective export and affected behavior.

### Enabling write purge or mapped roots without data review

Portable uninstall and root changes affect filesystem ownership and deletion
scope. Inventory existing packages and establish rollback first.

## Version and availability

Settings keys and accepted values evolve with WinGet. The current upstream page
labels its main list for WinGet 1.28 while documenting later installer-type
values; the locally reviewed client family is 1.29. Always use the schema,
`features`, `--info`, and export from the exact target client.

## Verification boundary

The current settings groups, keys, defaults, and override relationships were
reviewed against official documentation. No editor, user/admin setting, policy,
feature, log cleanup, network, download, install, uninstall, or configuration
behavior was opened, exported, or changed.

## Related documents

- [winget features](winget-features.md)
- [winget source](winget-source.md)
- [winget download](winget-download.md)
- [winget configure](winget-configure.md)

## Sources and license

This original guide was adapted from the official
[winget settings documentation](https://learn.microsoft.com/windows/package-manager/winget/settings),
the current settings schema, and WinGet privacy materials. Exact upstream
revision and paths are recorded in `upstream/windows-tools.json`.

The cited WinGet materials are licensed under MIT. This adaptation is licensed
under CC BY 4.0.
