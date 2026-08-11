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
- `-s SOURCE`, `--source SOURCE`: Restrict package correlation to one source.
- `--scope SCOPE`, `--architecture ARCHITECTURE`, `--installer-type TYPE`: Restrict the detected removal target.
- `-i`, `--interactive`: Request interactive uninstaller behavior.
- `-h`, `--silent`: Request silent uninstaller behavior; actual support belongs to the package.
- `--force`: Continue through selected non-security checks without reducing removal impact.
- `--purge`: Remove additional package data where supported; review data-retention consequences.
- `--preserve`: Preserve supported package data during removal where available.
- `-o FILE`, `--log FILE`: Request an explicit installer/uninstaller log path where supported.
- `--disable-interactivity`: Disable prompts so unattended removal fails rather than waiting.

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
