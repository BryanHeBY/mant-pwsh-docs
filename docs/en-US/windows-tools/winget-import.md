<!-- mant:tldr:start -->
# winget-import

> Install a reviewed set of packages from a WinGet package-list JSON file.
> More information: https://learn.microsoft.com/windows/package-manager/winget/import.

- Inspect a package list before any installation:

`Get-Content -Raw {{packages.json}} | ConvertFrom-Json`

- Import packages interactively after review:

`winget import --import-file {{packages.json}}`

- Avoid upgrading packages that are already installed:

`winget import --import-file {{packages.json}} --no-upgrade`
<!-- mant:tldr:end -->

# winget import

## Synopsis

```text
winget import --import-file FILE [options]
```

`winget import` reads a WinGet package-list JSON document and processes its
packages serially. It can start multiple publisher installers, accept terms,
upgrade existing packages, request elevation, and reboot through installer
behavior. Review the complete file and source identities before execution.

## Options

<!-- mant:entries role=option case=insensitive -->
- `-i FILE`, `--import-file FILE`: Read package and source selections from the JSON file at `FILE`.
- `--ignore-unavailable`: Continue when a requested package or version cannot be found; preserve omissions for later reconciliation.
- `--ignore-versions`: Ignore versions stored in the file and select current available versions.
- `--no-upgrade`: Skip packages for which an installed version already exists.
- `--accept-package-agreements`: Accept package terms without prompting after review.
- `--accept-source-agreements`: Accept source terms without prompting after review.
- `-?`, `--help`: Display command help.
- `--wait`: Wait for a key press before exit; avoid in automation.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings without resolving skipped or ambiguous packages.
- `--disable-interactivity`: Fail instead of waiting for input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Review the plan

Parse and enumerate the file before giving it to WinGet:

```powershell
$path = (Resolve-Path .\packages.json).Path
$document = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json

foreach ($source in $document.Sources) {
    $source.SourceDetails
    $source.Packages | Select-Object PackageIdentifier, Version
}
```

Check the source endpoint and identifier, every exact package ID and optional
version, current installed state, publisher, architecture, scope, agreements,
elevation, restart behavior, and whether the source still serves the same
manifest. An import file is editable input, not an attestation.

## Controlled execution

Hash the approved file, run in a test context first, and check the native exit
status immediately:

```powershell
$path = (Resolve-Path .\packages.json).Path
$approvedHash = '{{sha256}}'
if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $approvedHash) {
    throw 'Import file changed after review'
}

winget import --import-file $path --no-upgrade --disable-interactivity
if ($LASTEXITCODE -ne 0) { throw "Import failed: $LASTEXITCODE" }
```

Reconcile each requested package after the run. A batch-level success result
does not replace application-specific health checks.

## Common mistakes

### Using `--ignore-unavailable` without recording omissions

The run can finish with required software absent. Capture logs and compare the
requested identifiers with a post-import `winget list` inventory.

### Combining `--ignore-versions` with reproducible provisioning

That option deliberately selects newer available versions. Keep versions and
approved artifacts when repeatability is required.

### Assuming `--disable-interactivity` makes every installer silent

It controls WinGet prompts, not every publisher installer's UI/reboot contract.
Test each exact package on a representative fixture.

## Verification boundary

The file schema, serial processing model, and switches were reviewed against
the official WinGet documentation. No import file was executed and no package,
source agreement, installer, elevation, or reboot behavior was exercised.

## Related documents

- [winget export](winget-export.md)
- [winget install](winget-install.md)
- [winget list](winget-list.md)

## Sources and license

This original guide was adapted from the official
[winget import documentation](https://learn.microsoft.com/windows/package-manager/winget/import)
and package-list JSON schemas. Exact upstream revision and paths are recorded
in `upstream/windows-tools.json`.

The cited WinGet materials are licensed under MIT. This adaptation is licensed
under CC BY 4.0.
