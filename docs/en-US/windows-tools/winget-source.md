<!-- mant:tldr:start -->
# winget-source

> Inspect and manage the package catalogs trusted by WinGet.
> More information: https://learn.microsoft.com/windows/package-manager/winget/source.

- List configured sources before a package operation:

`winget source list`

- Inspect one source, including its URL, trust level, and explicit state:

`winget source list --name {{source}}`

- Refresh one reviewed source:

`winget source update --name {{source}}`
<!-- mant:tldr:end -->

# winget source

## Synopsis

```text
winget source <add|edit|list|update|remove|reset|export> [options]
```

Sources decide which package identities, manifests, agreements, and installers
WinGet can discover. A source change therefore changes the software supply
chain even when it installs nothing immediately.

## Subcommands

<!-- mant:entries role=command case=insensitive -->
- `add`: Register a source; requires a name and source argument and normally requires elevation.
- `edit`: Change an existing source, currently including its explicit-selection behavior.
- `list`, `ls`: List all sources or full details for one source.
- `update`, `refresh`: Refresh one named source or every configured source.
- `remove`, `rm`: Remove a named source and its availability to WinGet operations.
- `reset`: Restore default source configuration; forcing a full reset removes nondefault sources.
- `export`: Emit one source or all source definitions as JSON for review or policy authoring.

## Source identity options

<!-- mant:entries role=option case=insensitive -->
- `-n NAME`, `--name NAME`: Select or assign the local source name.
- `-a URI`, `--arg URI`: Set the source URL, UNC path, or provider-specific argument when adding a source.
- `-t TYPE`, `--type TYPE`: Select `Microsoft.PreIndexed.Package` or `Microsoft.Rest` when adding a source.
- `--trust-level LEVEL`: Set `none` or `trusted`; the label does not independently authenticate the endpoint.
- `--explicit BOOLEAN`: Require callers to name the source with `--source` when true; allow implicit searching when false.
- `--header HEADER`: Send a reviewed HTTP header to a REST source; command-line secrets can be exposed through logs and process inspection.
- `--accept-source-agreements`: Accept source terms without prompting after the terms and source identity have been reviewed.
- `--force`: Confirm the destructive `reset` operation.

## Diagnostic and interaction options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display help for the selected source subcommand.
- `--wait`: Wait for a key press before exit; avoid in automation.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Hide warnings without changing source trust or state.
- `--disable-interactivity`: Fail instead of waiting for input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Inventory and export

Use the detail form before approving a package action or source change:

```powershell
winget source list --name winget
if ($LASTEXITCODE -ne 0) { throw "Source lookup failed: $LASTEXITCODE" }

$sourceJson = winget source export winget
if ($LASTEXITCODE -ne 0) { throw "Source export failed: $LASTEXITCODE" }
$source = $sourceJson | ConvertFrom-Json
$source | Select-Object Name, Type, Arg, Identifier, TrustLevel, Explicit
```

Unlike ordinary WinGet search tables, `source export` intentionally emits
JSON. Still validate the schema and required fields before using it as policy
input.

## Add or edit a source

Approve the endpoint, transport, owner, source type, agreements, authentication
method, and whether implicit search is acceptable. Marking a specialized or
less-trusted source explicit limits accidental selection:

```powershell
winget source add --name Contoso --arg https://packages.example.test/api `
    --type Microsoft.Rest --explicit --accept-source-agreements
if ($LASTEXITCODE -ne 0) { throw "Source add failed: $LASTEXITCODE" }
winget source list --name Contoso
```

Do not put reusable bearer tokens in `--header`. Prefer the source's supported
authentication flow and protect any unavoidable one-time value from logs.

## Remove and reset

`remove` changes future package resolution. `reset --force` restores defaults
and removes nondefault sources; it can also cause agreements to be presented
again. Export and review current state first, name the target whenever
possible, and verify the resulting source inventory.

## Common mistakes

### Treating `trusted` as certificate verification

The trust level is WinGet source metadata. Independently verify the HTTPS/UNC
endpoint, administrator, authentication, and package governance.

### Parsing `source list` as durable structured data

Its table is for humans and can localize or change. Use `winget source export`
when machine-readable source metadata is required.

### Resetting sources to fix an unrelated package error

Reset is broad and destructive to custom configuration. Capture logs and test
an update of the exact named source first.

## Version and availability

Default sources and their explicit state can change with WinGet servicing,
region, policy, and App Installer version. The current official documentation
lists `msstore`, `winget`, and the explicit `winget-font` source. Always inspect
the target machine rather than assuming that inventory.

## Verification boundary

Current syntax and behaviors were reviewed against the official WinGet source
documentation. No source was contacted, refreshed, added, edited, removed, or
reset; those checks require an approved Windows fixture and controlled test
catalog.

## Related documents

- [Windows Package Manager](winget.exe.md)
- [winget search](winget-search.md)
- [winget show](winget-show.md)

## Sources and license

This original guide was adapted from the official
[winget source documentation](https://learn.microsoft.com/windows/package-manager/winget/source).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
