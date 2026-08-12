<!-- mant:tldr:start -->
# winget-repair

> Invoke the publisher-defined repair mechanism for one exact installed package.
> More information: https://learn.microsoft.com/windows/package-manager/winget/repair.

- Inspect the installed identity before repair:

`winget list --id {{package-id}} --exact`

- Repair one exact package interactively:

`winget repair --id {{package-id}} --exact`

- Request the package's silent repair mode:

`winget repair --id {{package-id}} --exact --silent --log {{repair.log}}`
<!-- mant:tldr:end -->

# winget repair

## Synopsis

```text
winget repair [query] [selection options] [installer options]
```

The alias `winget fix` invokes the same operation. WinGet selects an installed
package and runs the repair behavior described by its manifest and installer
technology. Repair is a package action, not a generic Windows file checker;
it can request elevation, change files/settings, show UI, or require a restart.

## Package selection options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Select by free-form query; use exact identity in automation.
- `-m FILE`, `--manifest FILE`: Use a reviewed local manifest for repair metadata.
- `--id ID`: Select by package identifier.
- `--name NAME`, `--moniker MONIKER`: Select by display name or moniker.
- `-v VERSION`, `--version VERSION`: Select one package version.
- `--product-code CODE`: Match an installed package by product code.
- `-a ARCHITECTURE`, `--architecture ARCHITECTURE`: Restrict installer architecture.
- `--scope SCOPE`: Restrict installed scope where supported.
- `-s SOURCE`, `--source SOURCE`: Restrict manifest resolution to one configured source.
- `--locale LOCALE`: Select a BCP 47 locale.
- `-e`, `--exact`: Require an exact match for the selected field.

## Repair execution options

<!-- mant:entries role=option case=insensitive -->
- `-i`, `--interactive`: Request interactive repair UI.
- `-h`, `--silent`: Request the installer's silent repair mode; support depends on the selected package.
- `-o FILE`, `--log FILE`: Request an installer log at `FILE` where supported.
- `--ignore-local-archive-malware-scan`: Skip malware scanning for a local archive manifest; use only under an independent security process.
- `--ignore-security-hash`: Continue after a hash mismatch; this weakens a security control.
- `--force`: Continue through selected non-security checks.
- `--header HEADER`: Send a reviewed header to a REST source.
- `--authentication-mode MODE`: Choose `silent`, `silentPreferred`, or `interactive` source authentication.
- `--authentication-account ACCOUNT`: Select the source-authentication account.
- `--accept-package-agreements`: Accept reviewed package terms without prompting.
- `--accept-source-agreements`: Accept reviewed source terms without prompting.

## Diagnostic and interaction options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display command help.
- `--wait`: Wait for a key press before exit.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings without resolving repair risk.
- `--disable-interactivity`: Fail instead of waiting for WinGet input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Controlled repair workflow

Capture installed state and application data backup, verify exact identity and
manifest, then run the least surprising repair mode:

```powershell
winget list --id Microsoft.PowerToys --exact
if ($LASTEXITCODE -ne 0) { throw 'Installed package lookup failed' }
winget show --id Microsoft.PowerToys --exact --source winget
if ($LASTEXITCODE -ne 0) { throw 'Manifest lookup failed' }

winget repair --id Microsoft.PowerToys --exact --source winget --interactive
if ($LASTEXITCODE -ne 0) { throw "Repair failed: $LASTEXITCODE" }

winget list --id Microsoft.PowerToys --exact
```

Use application-specific validation afterward. A zero WinGet exit status does
not prove user data, plugins, services, or application health were restored.

## PowerShell considerations

Repair output and installer progress are native text, not typed objects. Pass
the log path as one argument, check `$LASTEXITCODE` immediately, and do not use
PowerShell `$?` alone as the durable package-health result.

## Common mistakes

### Expecting repair to restore user data

Installer repair usually targets registered product resources. Back up and
restore user data through the application's supported mechanism.

### Assuming `--silent` controls restart and all UI

The publisher installer owns the repair contract. Test the exact version and
context before unattended rollout and coordinate reboot handling separately.

### Using hash or malware-scan bypasses as troubleshooting defaults

These switches weaken integrity controls. Stop and investigate the artifact or
manifest rather than making bypasses permanent automation.

## Version and availability

Repair support depends on WinGet client version, installed-package metadata,
source manifest, installer technology, scope, and privileges. Some packages
have no supported repair action; do not substitute reinstall without separate
approval and backup.

## Verification boundary

Options and repair semantics were reviewed against official WinGet
documentation. No package inventory, manifest query, repair mechanism,
installer UI, elevation, data change, or restart ran.

## Related documents

- [winget list](winget-list.md)
- [winget show](winget-show.md)
- [winget install](winget-install.md)

## Sources and license

This original guide was adapted from the official
[winget repair documentation](https://learn.microsoft.com/windows/package-manager/winget/repair).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
