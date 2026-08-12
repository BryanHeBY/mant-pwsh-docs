<!-- mant:tldr:start -->
# winget-dscv3

> Expose WinGet package, source, and settings state as DSC v3 command resources.
> More information: https://learn.microsoft.com/windows/package-manager/winget/dscv3.

- Display the WinGet package resource manifest:

`winget dscv3 package --manifest`

- Write resource JSON files to a controlled directory:

`winget dscv3 --output {{directory}}`

- Display help for one resource family:

`winget dscv3 source --help`
<!-- mant:tldr:end -->

# winget dscv3

## Synopsis

```text
winget dscv3 [RESOURCE] [--manifest] [--output DIRECTORY] [options]
```

`winget dscv3` exposes WinGet as Microsoft Desired State Configuration v3
command-based resources. DSC drives those resources through JSON on standard
input/output; this command is primarily a resource discovery/dispatch surface,
not the same workflow as applying a WinGet Configuration file.

## Resource families

<!-- mant:entries role=command case=insensitive -->
- `package`: Get, test, set, export, or enumerate WinGet package state through the DSC resource contract.
- `source`: Manage configured WinGet source state through DSC.
- `user-settings-file`: Manage the current user's WinGet settings file as a DSC resource.
- `admin-settings`: Manage policy-capable WinGet administrator settings as a DSC resource.

## Options

<!-- mant:entries role=option case=insensitive -->
- `-m`, `--manifest`: Display the selected DSC resource JSON manifest.
- `-o DIRECTORY`, `--output DIRECTORY`: Write resource JSON files to `DIRECTORY` instead of only displaying them.
- `-?`, `--help`: Display command or selected-resource help.
- `--wait`: Wait for a key press before exit; avoid in DSC hosts.
- `--logs`, `--open-logs`: Open WinGet's log directory in the interactive desktop.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings without changing resource semantics.
- `--disable-interactivity`: Fail instead of prompting; appropriate for resource hosts after agreements/policy are prepared.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Resource contract boundary

Inspect the exact resource manifest shipped by the target client before
authoring a DSC document:

```powershell
$json = winget dscv3 package --manifest
if ($LASTEXITCODE -ne 0) { throw "Resource discovery failed: $LASTEXITCODE" }
$manifest = $json | ConvertFrom-Json
$manifest | ConvertTo-Json -Depth 20
```

The manifest, not guessed CLI table fields, defines input/output schemas,
capabilities, version, and executable invocation. A resource `set` can install,
upgrade, uninstall, add/remove sources, or change settings according to desired
state. Require the same package/source/agreement and mutation approvals as the
corresponding direct WinGet command.

## PowerShell considerations

Manifest/resource streams are JSON protocol data. Keep stdout clean for JSON,
send diagnostics to the proper stream, use `Get-Content -Raw` for saved payloads,
and check `$LASTEXITCODE` before deserialization. Do not insert PowerShell object
formatting into a DSC stdio exchange.

## Common mistakes

### Confusing `dscv3` with `winget configure`

`dscv3` implements resource endpoints for a DSC engine. `configure` consumes a
configuration document and orchestrates resources. Choose based on who owns the
desired-state engine.

### Treating `get` or `test` as proof that `set` is safe

Mutation can run installers and change sources/settings. Present the desired
and actual identities plus the exact planned change before approval.

### Assuming resource schemas never change

Pin and inspect WinGet/resource versions in automation; regenerate client code
or fixtures when the manifest changes.

## Version and availability

DSC v3 command-resource support depends on the installed WinGet/App Installer
version and policy. Resource schemas and capabilities evolve independently of
this page. Capture `winget --version` and the emitted manifest on every target
baseline.

## Verification boundary

Official resource families and options were reviewed. No manifest was emitted,
no DSC host exchanged JSON, and no package, source, settings, or administrator
state was read, tested, exported, or changed.

## Related documents

- [winget configure](winget-configure.md)
- [winget source](winget-source.md)
- [winget settings](winget-settings.md)

## Sources and license

This original guide was adapted from the official
[winget dscv3 documentation](https://learn.microsoft.com/windows/package-manager/winget/dscv3)
and Microsoft DSC v3 command-resource contracts. Exact upstream revision and
path are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
