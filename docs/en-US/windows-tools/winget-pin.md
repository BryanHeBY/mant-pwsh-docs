<!-- mant:tldr:start -->
# winget-pin

> Inspect and constrain the versions WinGet may choose during upgrades.
> More information: https://learn.microsoft.com/windows/package-manager/winget/pinning.

- List all current pins before changing upgrade policy:

`winget pin list`

- Block WinGet upgrades for one exact package:

`winget pin add --id {{package-id}} --exact --blocking`

- Allow upgrades only within one version family:

`winget pin add --id {{package-id}} --exact --version {{1.2.*}}`
<!-- mant:tldr:end -->

# winget pin

## Synopsis

```text
winget pin <add|remove|list|reset> [query] [options]
```

A pin changes WinGet's upgrade selection policy for an installed package. It
does not prevent the application from self-updating or another deployment tool
from changing the package.

## Subcommands

<!-- mant:entries role=command case=insensitive -->
- `add`: Create a normal, blocking, or gating pin for one package.
- `remove`: Remove the matching package pin.
- `list`: List all pins or filter to one package.
- `reset`: Preview all pins that would be removed; add `--force` to remove them.

## Package selection options

<!-- mant:entries role=option case=insensitive -->
- `-q QUERY`, `--query QUERY`: Select a package by free-form query; prefer exact ID in automation.
- `--id ID`: Select by package identifier.
- `--name NAME`: Select by package display name.
- `--moniker MONIKER`: Select by package moniker.
- `--tag TAG`: Select by manifest tag where the selected subcommand supports it.
- `--cmd COMMAND`, `--command COMMAND`: Select a package that provides the command.
- `-e`, `--exact`: Require an exact match for the selected field.
- `-s SOURCE`, `--source SOURCE`: Restrict resolution or reset to one source.
- `--installed`: Match the installed package/version where supported by add or remove.
- `--header HEADER`: Send a reviewed REST-source header; do not expose reusable secrets in process arguments.
- `--authentication-mode MODE`: Choose `silent`, `silentPreferred`, or `interactive` source authentication.
- `--authentication-account ACCOUNT`: Select the source-authentication account.
- `--accept-source-agreements`: Accept reviewed source terms without prompting.

## Pin behavior options

<!-- mant:entries role=option case=insensitive -->
- `-v VERSION`, `--version VERSION`: Create a gating pin at an exact version or a range ending in `*`, such as `1.2.*`.
- `--blocking`: Prevent normal targeted and `--all` WinGet upgrades until the pin is removed.
- `--force`: Override selected pin behavior, or confirm removal by `pin reset`.

Without `--version` or `--blocking`, an add creates a normal pin: `winget
upgrade --all` excludes it, but a targeted upgrade can proceed. A gating pin
allows only versions inside its range. A blocking pin prevents normal WinGet
upgrade selection.

## Diagnostic and interaction options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display help for the selected pin subcommand.
- `--wait`: Wait for a key press before exit.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings without changing pin semantics.
- `--disable-interactivity`: Fail instead of waiting for input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Safe workflow

Resolve installed identity, inspect the existing pin, then apply and verify:

```powershell
winget list --id Microsoft.PowerToys --exact
if ($LASTEXITCODE -ne 0) { throw 'Package lookup failed' }

winget pin list --id Microsoft.PowerToys --exact
winget pin add --id Microsoft.PowerToys --exact --version '0.95.*'
if ($LASTEXITCODE -ne 0) { throw "Pin failed: $LASTEXITCODE" }
winget pin list --id Microsoft.PowerToys --exact
```

Quote wildcard ranges in PowerShell so the value is visibly one argument and
is not confused with filesystem wildcard intent.

## PowerShell considerations

Pin output is human-oriented text rather than typed objects. Use exact ID and
source arguments, quote version ranges, and check `$LASTEXITCODE` immediately
before a follow-up query can overwrite the native status.

## Common mistakes

### Treating a pin as endpoint enforcement

It constrains WinGet only. Disable or govern vendor self-update and other
deployment channels separately when version policy is mandatory.

### Assuming a normal pin blocks targeted upgrades

Normal pins affect `upgrade --all`. Use a blocking pin when targeted WinGet
upgrades must also stop, and document the operational reason.

### Running `pin reset --force` without preview

Run `winget pin reset` first; it lists what would be removed. Preserve the
inventory and recreate only intentionally retired policies.

## Version and availability

Pin support and override behavior depend on WinGet client version. The pin is
local WinGet state and may not roam with the application or apply to another
account; inventory the target execution context.

## Verification boundary

Pin types, subcommands, and selection options were reviewed against official
WinGet documentation. No package inventory, pin mutation, upgrade, reset, or
source request ran on a Windows fixture.

## Related documents

- [winget list](winget-list.md)
- [winget upgrade](winget-upgrade.md)
- [Windows Package Manager](winget.exe.md)

## Sources and license

This original guide was adapted from the official
[winget pin documentation](https://learn.microsoft.com/windows/package-manager/winget/pinning).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
