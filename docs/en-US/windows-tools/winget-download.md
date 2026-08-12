<!-- mant:tldr:start -->
# winget-download

> Download a reviewed package installer and dependencies without running them.
> More information: https://learn.microsoft.com/windows/package-manager/winget/download.

- Download one exact package to a controlled directory:

`winget download --id {{package-id}} --exact --source {{source}} --download-directory {{directory}}`

- Download one exact version and architecture:

`winget download --id {{package-id}} --exact --version {{version}} --architecture {{x64}} --download-directory {{directory}}`

- Verify downloaded artifacts before any execution:

`Get-ChildItem -File {{directory}} | Get-FileHash -Algorithm SHA256`
<!-- mant:tldr:end -->

# winget download

## Synopsis

```text
winget download [query] [selection options] [--download-directory DIRECTORY]
```

`winget download` resolves a package manifest and downloads matching installer
artifacts, dependencies, and—for eligible Microsoft Store packaged apps—an
offline license unless skipped. It does not install the artifacts. By default,
downloads go to the current user's Downloads folder.

## Selection and artifact options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Select by free-form query; exact ID is safer for automation.
- `-d DIRECTORY`, `--download-directory DIRECTORY`: Write downloaded artifacts below this directory.
- `-m FILE`, `--manifest FILE`: Resolve a reviewed local YAML manifest.
- `--id ID`: Select by package identifier.
- `--name NAME`, `--moniker MONIKER`: Select by display name or moniker.
- `-v VERSION`, `--version VERSION`: Select one exact source-provided package version.
- `-s SOURCE`, `--source SOURCE`: Restrict selection to one configured source.
- `--scope SCOPE`: Select an installer intended for `user` or `machine` scope where available.
- `-a ARCHITECTURE`, `--architecture ARCHITECTURE`: Select `x86`, `x64`, `arm`, or `arm64` artifacts.
- `--installer-type TYPE`: Restrict selection to one installer technology.
- `-e`, `--exact`: Require an exact match for the selected field.
- `--locale LOCALE`: Select a BCP 47 installer locale.
- `--platform PLATFORM`: Select a target such as `Windows.Desktop`, `Windows.Universal`, or `Windows.Holographic`.
- `--skip-dependencies`: Do not download package dependencies or required Windows features.
- `--skip-license`, `--skip-microsoft-store-package-license`: Do not retrieve a Microsoft Store offline license.
- `--ignore-security-hash`: Continue after an installer hash mismatch; this disables a security control and should not be routine.

## Source and interaction options

<!-- mant:entries role=option case=insensitive -->
- `--header HEADER`: Send a reviewed header to a REST source; protect credentials from process and log exposure.
- `--authentication-mode MODE`: Choose `silent`, `silentPreferred`, or `interactive` source authentication.
- `--authentication-account ACCOUNT`: Select the source-authentication account.
- `--accept-package-agreements`: Accept reviewed package terms without prompting.
- `--accept-source-agreements`: Accept reviewed source terms without prompting.
- `-?`, `--help`: Display command help.
- `--wait`: Wait for a key press before exit.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings without proving artifact integrity.
- `--disable-interactivity`: Fail instead of waiting for input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Controlled download workflow

Use an empty staging directory, exact identity, explicit source, and explicit
target characteristics. Inventory and hash everything afterward:

```powershell
$stage = New-Item -ItemType Directory -Path .\winget-stage -ErrorAction Stop
winget show --id Microsoft.PowerToys --exact --source winget
if ($LASTEXITCODE -ne 0) { throw 'Manifest inspection failed' }

winget download --id Microsoft.PowerToys --exact --source winget `
    --architecture x64 --download-directory $stage.FullName `
    --accept-package-agreements --accept-source-agreements --disable-interactivity
if ($LASTEXITCODE -ne 0) { throw "Download failed: $LASTEXITCODE" }

Get-ChildItem -LiteralPath $stage.FullName -File -Recurse |
    Select-Object FullName, Length, @{n='SHA256';e={(Get-FileHash $_.FullName).Hash}}
```

Validate Authenticode signatures where applicable and compare the artifacts to
the reviewed manifest. Download success is not approval to execute.

## Microsoft Store boundary

Downloading packaged Store apps or their offline license can require Microsoft
Entra authentication and an account with an eligible administrator role.
`--skip-license` can avoid retrieving the offline license but does not grant
deployment rights. Follow organizational licensing and device-management rules.

## PowerShell considerations

The command accepts paths and selectors as native string arguments and emits
progress/display text. Use `--download-directory` rather than redirecting
stdout, and check `$LASTEXITCODE` before enumerating the directory.

## Common mistakes

### Assuming download is read-only

It writes executable artifacts and may authenticate to remote sources. Use a
controlled directory, protect it from accidental execution, and clean it under
an approved retention policy.

### Using `--ignore-security-hash` after a mismatch

A mismatch can indicate corruption or tampering. Stop, preserve evidence,
refresh trusted metadata, and investigate instead of normalizing the bypass.

### Expecting one artifact without narrowing selectors

The latest package can have multiple architectures, scopes, platforms,
locales, and dependencies. State all deployment-relevant selectors and inspect
the resulting inventory.

## Version and availability

Available selectors and artifacts depend on WinGet, source, manifest, account,
region, architecture, and platform. Microsoft Store offline licensing also has
tenant-role requirements; verify the target deployment context.

## Verification boundary

Options and Store prerequisites were reviewed against the official WinGet
documentation. No source authentication, query, artifact/license download,
hash bypass, or installer execution ran.

## Related documents

- [winget show](winget-show.md)
- [winget source](winget-source.md)
- [winget install](winget-install.md)

## Sources and license

This original guide was adapted from the official
[winget download documentation](https://learn.microsoft.com/windows/package-manager/winget/download).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
