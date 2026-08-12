<!-- mant:tldr:start -->
# winget-uninstall

> Remove one identified Windows package with Windows Package Manager.
> More information: https://learn.microsoft.com/windows/package-manager/winget/uninstall.

- List installed package matches first:

`winget list {{query}}`

- Remove an exact package:

`winget uninstall --id {{package-id}} --exact`

- Request a silent uninstall after testing it:

`winget uninstall --id {{package-id}} --exact --silent`
<!-- mant:tldr:end -->

# winget uninstall

## Synopsis

```text
winget uninstall [query] [--id ID] [--exact] [--source SOURCE]
                  [--silent] [--interactive]
```

`winget uninstall` removes a package. It is destructive: it can remove user
data, shared dependencies, integrations, or management agents depending on the
installer. Identify the installed target before executing it.

## Identify exactly

Use `winget list` to see installed matches, then select a reviewed exact ID:

```powershell
winget list --id Microsoft.PowerShell
winget uninstall --id Microsoft.PowerShell --exact
if ($LASTEXITCODE -ne 0) {
    throw "winget uninstall failed with exit code $LASTEXITCODE"
}
```

Do not remove a package based only on a display-name search. Confirm product,
publisher, scope, current user/device impact, and any data-retention or
rollback requirement before changing the endpoint.

## Selection and removal options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Select by free-form query; avoid broad matching for removal.
- `-m FILE`, `--manifest FILE`: Select a package using a reviewed local manifest where supported.
- `--id ID`: Select an installed package by exact identifier.
- `--name NAME`, `--moniker MONIKER`: Select by display name or moniker when exact identity is verified separately.
- `--product-code CODE`: Select by registered product code where supported.
- `-e`, `--exact`: Require exact matching for the selected field.
- `-v VERSION`, `--version VERSION`: Select one installed version where the client exposes it.
- `--all`, `--all-versions`: Remove every detected version of the selected package; confirm each target and its retained data first.
- `-s SOURCE`, `--source SOURCE`: Restrict package correlation to one source.
- `--scope SCOPE`: Restrict the detected removal target to user or machine scope.
- `-i`, `--interactive`: Request interactive uninstaller behavior.
- `-h`, `--silent`: Request silent uninstaller behavior; actual support belongs to the package.
- `--force`: Continue through selected non-security checks without reducing removal impact.
- `--purge`: Remove additional package data where supported; review data-retention consequences.
- `--preserve`: Preserve supported package data during removal where available.
- `-o FILE`, `--log FILE`: Request an explicit installer/uninstaller log path where supported.
- `--header HEADER`: Send a reviewed HTTP header to a REST package source; do not expose credentials in process arguments or logs.
- `--authentication-mode MODE`: Choose `silent`, `silentPreferred`, or `interactive` source authentication behavior.
- `--authentication-account ACCOUNT`: Select the account used for source authentication.
- `--accept-source-agreements`: Accept reviewed source agreements for unattended package correlation.
- `--disable-interactivity`: Disable prompts so unattended removal fails rather than waiting.

Current WinGet 1.29 help and the cited official page do not list
`--architecture` or `--installer-type` for `uninstall`; those selectors belong
to installer-selection workflows, not this current removal interface.

## Execution and diagnostics options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display help for this subcommand without selecting or removing a package.
- `--wait`: Wait for a key press before the client exits; avoid it in unattended automation.
- `--logs`, `--open-logs`: Open the WinGet log directory in the interactive desktop.
- `--verbose`, `--verbose-logs`: Enable verbose WinGet logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warning display; it does not reduce removal impact.
- `--proxy URL`: Use the specified proxy for this invocation; protect credentials embedded in a proxy URL.
- `--no-proxy`: Disable proxy use for this invocation.

## UI and automation

`--silent` requests an unattended installer path, but support and behavior are
manifest-specific. Test the exact uninstall under the production user and
elevation context. Capture logs and use a post-action check appropriate to the
package; process success alone may not prove that all associated state is gone.

## PowerShell boundaries

Call WinGet as a native process, keep exact selection values separate, capture
`$LASTEXITCODE`, and verify application, service, data, and reboot state after
the vendor uninstaller finishes.

## Version and availability

Options and cleanup behavior depend on WinGet version, installer technology,
manifest metadata, package registration, scope, and policy.

## Common mistakes

### Removing a fuzzy display-name match

Confirm exact ID, product code, publisher, scope, version, owning application,
and user/device impact before removal.

### Assuming uninstall removes all data or shared dependencies safely

`--purge` and `--preserve` are package-specific, while shared components and
management agents can affect other workloads. Define retention and rollback.

## Runtime evidence

A dual-collector local help audit against WinGet `1.29.280` matched all 33
printed `uninstall --help` long options to ManT entries. Current help omitted
the formerly claimed architecture/installer-type selectors and included
`--all` and `--all-versions`; the page was synchronized accordingly. No
inventory, target selection, uninstaller, purge/preserve behavior, package
removal, data change, or restart ran.

## Related documents

- [winget list](winget-list.md)
- [winget show](winget-show.md)
- [winget install](winget-install.md)

## Sources and license

This original command guide was adapted from the official
[winget uninstall documentation](https://learn.microsoft.com/windows/package-manager/winget/uninstall).
It emphasizes exact identity and removal safety. Exact upstream revision and
path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
