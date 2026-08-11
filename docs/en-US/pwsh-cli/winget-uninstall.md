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

## UI and automation

`--silent` requests an unattended installer path, but support and behavior are
manifest-specific. Test the exact uninstall under the production user and
elevation context. Capture logs and use a post-action check appropriate to the
package; process success alone may not prove that all associated state is gone.

## Related documents

- [winget list](winget-list.md)
- [winget show](winget-show.md)
- [winget install](winget-install.md)

## Sources and license

This original command guide was adapted from the official
[winget uninstall documentation](https://learn.microsoft.com/windows/package-manager/winget/uninstall).
It emphasizes exact identity and removal safety. Exact upstream revision and
path are recorded in `upstream/cli.json`.

The cited documentation is licensed under MIT. This adaptation is licensed
under CC BY 4.0.
