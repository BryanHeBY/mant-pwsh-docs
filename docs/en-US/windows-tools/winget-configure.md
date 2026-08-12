<!-- mant:tldr:start -->
# winget-configure

> Inspect, test, and apply a reviewed WinGet Configuration file.
> More information: https://learn.microsoft.com/windows/package-manager/winget/configure.

- Show what a configuration declares before applying it:

`winget configure show --file {{configuration.dsc.yaml}}`

- Test the current machine against the desired state:

`winget configure test --file {{configuration.dsc.yaml}}`

- Apply a locally reviewed configuration interactively:

`winget configure --file {{configuration.dsc.yaml}}`
<!-- mant:tldr:end -->

# winget configure

## Synopsis

```text
winget configure --file FILE [options]
winget configure <show|list|test|validate|export> [options]
```

`winget configure` uses a WinGet Configuration file to bring packages and
other declared machine settings toward a desired state. Its aliases are
`winget configuration` and `winget dsc`. A configuration can execute
PowerShell Desired State Configuration resources and change much more than
installed packages, so treat the file and every referenced module as code.

## Subcommands

<!-- mant:entries role=command case=insensitive -->
- `show`: Display a configuration's resources and initial details without applying them.
- `list`: List configurations previously applied on this machine.
- `test`: Compare current state with a configuration without applying the desired state.
- `validate`: Validate the configuration document and resource declarations.
- `export`: Write selected current resource state to a configuration file.

## Input and execution options

<!-- mant:entries role=option case=insensitive -->
- `-f FILE`, `--file FILE`: Read the WinGet Configuration file at `FILE`.
- `--module-path DIRECTORY`: Use a nondefault directory for configuration modules.
- `--processor-path FILE`: Use the specified configuration processor executable.
- `-h`, `--history`: Select a configuration from local execution history.
- `--accept-configuration-agreements`: Accept the configuration warning without an interactive confirmation; use only after review.
- `--suppress-initial-details`: Suppress initial configuration details where supported; do not use it as a substitute for review.
- `--enable`: Enable WinGet Configuration components; Microsoft Store access may be required.
- `--disable`: Disable WinGet Configuration components; Microsoft Store access may be required.

## Diagnostic and interaction options

<!-- mant:entries role=option case=insensitive -->
- `-?`, `--help`: Display help for the selected configure operation.
- `--wait`: Wait for a key press before exit; avoid in unattended execution.
- `--logs`, `--open-logs`: Open WinGet's log directory in the interactive desktop.
- `--verbose`, `--verbose-logs`: Enable verbose WinGet logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warning display without changing the underlying risk.
- `--disable-interactivity`: Fail instead of waiting for user input.
- `--proxy URL`: Use one proxy for this invocation.
- `--no-proxy`: Disable proxy use for this invocation.

## Review before execution

Inspect a configuration from a trusted local path, then test it:

```powershell
winget configure show --file .\dev-machine.dsc.yaml
if ($LASTEXITCODE -ne 0) { throw 'Configuration inspection failed' }

winget configure validate --file .\dev-machine.dsc.yaml
if ($LASTEXITCODE -ne 0) { throw 'Configuration validation failed' }

winget configure test --file .\dev-machine.dsc.yaml
if ($LASTEXITCODE -ne 0) { throw 'Configuration test failed' }
```

Review resource types, module publishers and versions, package identities,
download locations, scripts, credentials, elevation needs, and reboot effects.
Validation checks structure; it does not establish that referenced code is
trusted or that every resource is harmless.

## Applying a configuration

Apply only the same immutable file that was reviewed. In automation, record a
content hash and check the native exit code immediately:

```powershell
$path = (Resolve-Path .\dev-machine.dsc.yaml).Path
$approvedHash = '{{sha256}}'
if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $approvedHash) {
    throw 'Configuration changed after review'
}

winget configure --file $path --accept-configuration-agreements --disable-interactivity
if ($LASTEXITCODE -ne 0) { throw "Configuration failed: $LASTEXITCODE" }
```

Agreement acceptance records a decision; it is not a trust control. Use a
disposable test machine before fleet deployment and verify final resource
state independently.

## PowerShell considerations

WinGet is a native process: pass the resolved file path as one argument and
check `$LASTEXITCODE` immediately. Its progress and diagnostic text are not
PowerShell objects; preserve logs rather than parsing localized console tables.

## Common mistakes

### Treating configuration as a package list

Configuration resources can change Windows settings and execute provider
code. Use `winget export` and `winget import` when the requirement is only a
portable package inventory.

### Applying a URL directly from an issue or prompt

Download to a controlled path, verify provenance and hash, inspect the complete
file and referenced resources, then pass that local file explicitly.

### Assuming `test` proves the file is safe

`test` evaluates desired state. It does not authenticate publishers, approve
scripts, or prove that a subsequent apply has no side effects.

## Version and availability

WinGet Configuration requires WinGet 1.6.2631 or later and supported Windows
10/11 builds. Resource availability, schema support, Store access, policy, and
elevation vary by client and machine. Confirm with `winget configure --help`
on the target before unattended use.

## Verification boundary

Syntax and safety boundaries were reviewed against the current official
WinGet documentation and implementation baseline. No configuration resource
was downloaded, enabled, tested, or applied; runtime verification belongs on a
disposable Windows fixture with an approved configuration and rollback plan.

## Related documents

- [Windows Package Manager](winget.exe.md)
- [winget export](winget-export.md)
- [winget import](winget-import.md)
- [Microsoft Learn MCP queries](microsoft-learn-mcp.md)

## Sources and license

This original guide was adapted from the official
[winget configure documentation](https://learn.microsoft.com/windows/package-manager/winget/configure)
and its linked configuration trust guidance. Exact upstream revision and paths
are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
