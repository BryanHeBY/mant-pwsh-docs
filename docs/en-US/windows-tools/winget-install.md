<!-- mant:tldr:start -->
# winget-install

> Install one reviewed Windows package by exact identifier.
> More information: https://learn.microsoft.com/windows/package-manager/winget/install.

- Install an exact package:

`winget install --id {{package-id}} --exact`

- Install a specific version:

`winget install --id {{package-id}} --exact --version {{version}}`

- Run a noninteractive install after reviewing agreements:

`winget install --id {{package-id}} --exact --silent --accept-package-agreements --accept-source-agreements`
<!-- mant:tldr:end -->

# winget install

## Synopsis

```text
winget install [query] [--id ID] [--exact] [--version VERSION]
               [--source SOURCE] [--scope SCOPE] [--silent]
               [--accept-package-agreements] [--accept-source-agreements]
```

`winget install` installs a package selected from configured sources. It can
start a vendor installer and may affect all users or device configuration.

## Selection and installer options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Select by free-form query; avoid it in durable automation when an ID is known.
- `-m FILE`, `--manifest FILE`: Install from a reviewed local manifest path.
- `--id ID`: Select a source package identifier.
- `--name NAME`, `--moniker MONIKER`: Select by display name or moniker only when exact identity is verified separately.
- `-e`, `--exact`: Require an exact match for the selected field.
- `-v VERSION`, `--version VERSION`: Request one exact source-provided version.
- `-s SOURCE`, `--source SOURCE`: Restrict selection to one configured source.
- `--scope SCOPE`: Request user or machine installation where the manifest supports it.
- `--architecture ARCHITECTURE`: Select an installer for one architecture.
- `--installer-type TYPE`: Restrict selection to one supported installer technology.
- `--locale LOCALE`: Select an installer locale where available.
- `-l LOCATION`, `--location LOCATION`: Request an installation location only when the installer honors it.
- `-i`, `--interactive`: Request interactive installer behavior.
- `-h`, `--silent`: Request silent installer behavior; the manifest/installer owns actual UI support.
- `-o FILE`, `--log FILE`: Request an installer log path where the selected installer supports it.
- `--custom ARGUMENTS`: Add reviewed arguments after WinGet's normal installer switches.
- `--override ARGUMENTS`: Replace WinGet's normal installer arguments; this changes the manifest contract substantially.
- `--accept-package-agreements`, `--accept-source-agreements`: Record explicit agreement acceptance for unattended use.
- `--skip-dependencies`: Skip dependency processing only when dependencies are managed and verified separately.
- `--dependencies-only`: Install dependencies without installing the requested package; available in the locally reviewed WinGet 1.29 client but absent from the cited 2026-07-19 command page.
- `--dependency-source SOURCE`: Resolve package dependencies through one specified source.
- `--ignore-security-hash`: Bypass an installer hash mismatch; this weakens a security control and should not be routine automation.
- `--ignore-local-archive-malware-scan`: Skip the malware scan for a local archive-manifest install; use only under an independently verified security process.
- `--force`: Continue through selected non-security checks; it does not make an installer trustworthy.
- `--allow-reboot`: Permit the installer to restart Windows; use only inside coordinated maintenance.
- `--no-upgrade`: Refuse to turn an install request into an upgrade of an existing package.
- `--uninstall-previous`: Request removal of the previous version when the manifest supports the workflow.
- `-r NAME`, `--rename NAME`: Rename the executable produced by a portable package where supported.
- `--header HEADER`: Send a reviewed HTTP header to a REST package source; do not expose credentials in process arguments or logs.
- `--authentication-mode MODE`: Choose `silent`, `silentPreferred`, or `interactive` source authentication behavior.
- `--authentication-account ACCOUNT`: Select the account used for source authentication.
- `--disable-interactivity`: Fail instead of waiting for user input in unattended execution.

## Execution and diagnostics options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display help for this subcommand without selecting or installing a package.
- `--wait`: Wait for a key press before the client exits; avoid it in unattended automation.
- `--logs`, `--open-logs`: Open the WinGet log directory in the interactive desktop.
- `--verbose`, `--verbose-logs`: Enable verbose WinGet logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warning display; it does not make an installer safe.
- `--proxy URL`: Use the specified proxy for this invocation; protect credentials embedded in a proxy URL.
- `--no-proxy`: Disable proxy use for this invocation.

## Confirm before installing

Run `winget show --id ID --exact` first and approve the package identifier,
publisher, source, version, installer, scope, privileges, and agreements.
Then make the installation selection exact:

```powershell
winget install --id Microsoft.PowerShell --exact --source winget
if ($LASTEXITCODE -ne 0) {
    throw "winget install failed with exit code $LASTEXITCODE"
}
```

Do not automate a broad name match. A source update can change which candidate
a non-exact query finds.

## Silent and noninteractive use

`--silent` requests an installer mode with minimal UI; it does not guarantee
that every installer is unattended. Agreement-acceptance switches document an
explicit decision in noninteractive workflows. Use them only after the package
and source have been reviewed and their terms are acceptable to the deploying
organization.

Scope, architecture, installer switches, logging, and elevation behavior vary
by manifest and client version. Test the exact command under the production
user and elevation context before using it in fleet automation.

## PowerShell boundaries

`winget` is a native process. Check `$LASTEXITCODE` immediately, keep its
arguments separate, and log the exact ID/version/source/exit result. Do not
assume that a successful process return proves the installed application is
ready; run a narrowly scoped post-install health check if the workload needs it.

## Version and availability

The accepted options and installer behavior depend on WinGet version, source
manifest, installer technology, package policy, and Windows context.

## Common mistakes

### Assuming `--silent` guarantees unattended installation

The installer owns its UI and reboot contract. Test the exact manifest and
context, combine with explicit noninteractive policy, and handle failure.

### Using `--override` as routine boilerplate

It replaces manifest-provided installer arguments and can bypass publisher-
tested behavior. Use it only with an exact documented installer contract.

## Runtime evidence

A 2026-08-12 help-only audit matched all 44 WinGet 1.29.280 long options to
local ManT entries under both PowerShell collectors; locally present
dependencies-only is explicitly labeled as absent from the contemporaneous
official page. No install or source query ran.

## Related documents
- [winget show](winget-show.md)
- [winget search](winget-search.md)
- [winget upgrade](winget-upgrade.md)
- [winget uninstall](winget-uninstall.md)

## Sources and license

This original command guide was adapted from the official
[winget install documentation](https://learn.microsoft.com/windows/package-manager/winget/install).
It emphasizes exact identity, agreement review, and post-install verification.
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
