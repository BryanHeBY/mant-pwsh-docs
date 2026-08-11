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

## PowerShell automation

`winget` is a native process. Check `$LASTEXITCODE` immediately, keep its
arguments separate, and log the exact ID/version/source/exit result. Do not
assume that a successful process return proves the installed application is
ready; run a narrowly scoped post-install health check if the workload needs it.

## Related documents

- [winget show](winget-show.md)
- [winget search](winget-search.md)
- [winget upgrade](winget-upgrade.md)
- [winget uninstall](winget-uninstall.md)

## Sources and license

This original command guide was adapted from the official
[winget install documentation](https://learn.microsoft.com/windows/package-manager/winget/install).
It emphasizes exact identity, agreement review, and post-install verification.
Exact upstream revision and path are recorded in `upstream/cli.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
