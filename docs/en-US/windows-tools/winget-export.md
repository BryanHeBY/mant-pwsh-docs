<!-- mant:tldr:start -->
# winget-export

> Export source-matched installed package identities to a WinGet JSON file.
> More information: https://learn.microsoft.com/windows/package-manager/winget/export.

- Export package identifiers for later review:

`winget export --output {{packages.json}}`

- Include installed versions when reproducibility matters:

`winget export --output {{packages.json}} --include-versions`

- Inspect the generated JSON in PowerShell:

`Get-Content -Raw {{packages.json}} | ConvertFrom-Json`
<!-- mant:tldr:end -->

# winget export

## Synopsis

```text
winget export --output FILE [--source SOURCE] [--include-versions] [options]
```

`winget export` matches installed-app registration metadata to configured
WinGet sources and writes a package-list JSON document. It is an inventory
starting point, not a complete backup: unmatched applications, configuration,
data, licenses, installer arguments, and many Store details are not preserved.

## Options

<!-- mant:entries role=option case=insensitive -->
- `-o FILE`, `--output FILE`: Write the package-list JSON to `FILE`.
- `-s SOURCE`, `--source SOURCE`: Export only packages matched to one configured source.
- `--include-versions`: Include matched installed versions; without it a later import normally selects current available versions.
- `--accept-source-agreements`: Accept source terms without prompting after review.
- `-?`, `--help`: Display command help.
- `--wait`: Wait for a key press before exit; avoid in automation.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings, including information that may explain missing matches.
- `--disable-interactivity`: Fail instead of waiting for input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## JSON structure

The published package schema groups entries under `Sources`; each source has a
`SourceDetails` identity and a `Packages` array. Package entries contain a
`PackageIdentifier` and may contain a `Version`. Treat unknown fields as a
schema-version concern rather than silently discarding them.

```powershell
$path = Join-Path $PWD 'packages.json'
winget export --output $path --include-versions
if ($LASTEXITCODE -ne 0) { throw "Export failed: $LASTEXITCODE" }

$inventory = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
$inventory.Sources | ForEach-Object {
    $_.Packages | Select-Object PackageIdentifier, Version
}
```

Review WinGet warnings: an application that cannot be matched to a configured
source is omitted from the reusable package set.

## Reproducibility boundary

Even with `--include-versions`, a version can disappear from a source, change
installer availability by architecture/locale, or be blocked by policy. Record
the source identity and archive approved installers separately when the
deployment requires reproducible artifacts.

## Common mistakes

### Calling the export a system backup

It does not capture application data, settings, secrets, Windows features, or
unmatched installers. Use purpose-built backup and configuration management in
addition to this package list.

### Ignoring warning output

A zero exit status does not mean every installed application was represented.
Preserve stdout/stderr and reconcile the exported IDs against a separate
installed-software inventory.

## Verification boundary

The JSON contract and options were reviewed against the official WinGet
documentation and schema baseline. No installed application inventory or
source query ran, and no export file was created on a Windows fixture.

## Related documents

- [winget import](winget-import.md)
- [winget source](winget-source.md)
- [winget list](winget-list.md)

## Sources and license

This original guide was adapted from the official
[winget export documentation](https://learn.microsoft.com/windows/package-manager/winget/export)
and package-list JSON schemas. Exact upstream revision and paths are recorded
in `upstream/windows-tools.json`.

The cited WinGet materials are licensed under MIT. This adaptation is licensed
under CC BY 4.0.
