<!-- mant:tldr:start -->
# msiexec

> Install, repair, patch, or remove one reviewed Windows Installer product with logs and explicit completion.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/msiexec.

- Verify the selected MSI's signature and content hash before execution:

`Get-Item -LiteralPath '{{package.msi}}' | Select-Object FullName, Length, LastWriteTime; Get-AuthenticodeSignature -LiteralPath '{{package.msi}}'; Get-FileHash -LiteralPath '{{package.msi}}' -Algorithm SHA256`

- Run a quiet installation, suppress automatic restart, wait, and retain a verbose log:

`$msiArgs = @('/i', ('"{0}"' -f '{{package.msi}}'), '/qn', '/norestart', '/L*v', ('"{0}"' -f '{{install.log}}')); $p = Start-Process -FilePath msiexec.exe -ArgumentList $msiArgs -Wait -PassThru; $p.ExitCode`

- Classify the common Windows Installer completion codes explicitly:

`switch ($p.ExitCode) { 0 {'success'} 1641 {'success; restart initiated'} 3010 {'success; restart required'} default {"failure or product-specific result: $($p.ExitCode)"} }`

- Remove one product by its verified product code, with no automatic restart and a log:

`$productCode = '{' + '{{product-code-guid-without-braces}}' + '}'; $msiArgs = @('/x', $productCode, '/qn', '/norestart', '/L*v', ('"{0}"' -f '{{uninstall.log}}')); (Start-Process msiexec.exe -ArgumentList $msiArgs -Wait -PassThru).ExitCode`
<!-- mant:tldr:end -->

# msiexec

## Overview

`msiexec.exe` is the Windows Installer command-line client. `/i` installs,
`/x` uninstalls, `/f` repairs, `/p` applies a patch, `/q*` controls UI,
`/norestart|/promptrestart|/forcerestart` controls restart behavior, and
`/L*V` produces verbose logging. Product properties are case-sensitive public
property names supplied as `NAME=value` after the package operation.

## Operations and options

<!-- mant:entries role=command case=insensitive -->
- `msiexec.exe`: Run one Windows Installer installation, administrative image,
  repair, patch, advertise, uninstall, or service-registration operation.

Package public properties use bare case-sensitive `NAME=value` operands and
are package-specific; they are not generic PowerShell named parameters.

<!-- mant:entries role=option case=insensitive -->
- `/i`: Install or configure the following MSI package path or product code.
- `/x`: Uninstall the following package path or verified product-code GUID;
  `/uninstall` is the long spelling.
- `/a`: Create or update an administrative installation image from a package.
- `/j`: Advertise a product to the current user (`u`) or all users (`m`), with
  optional transform/language selectors.
- `/f`: Repair a product using following repair-mode letters and product identity.
- `/p`: Apply the following MSP patch to an installed product.
- `/update`: Apply one or more semicolon-delimited patches.
- `/q`: Select UI level through its attached mode letters such as `n`, `b`,
  `r`, or `f`; `/quiet` is equivalent to no UI and `/passive` shows progress.
- `/quiet`: Run with no user interface; choose logging and restart behavior too.
- `/passive`: Show only an unattended progress display; specify restart policy
  separately instead of assuming this UI option prevents a restart.
- `/norestart`: Do not automatically restart after the operation.
- `/promptrestart`: Prompt before a restart when UI is available.
- `/forcerestart`: Restart after the operation; this is disruptive and requires
  explicit maintenance authorization.
- `/l`: Write a Windows Installer log using attached detail letters and the
  following protected log path; `/log` is the simpler long spelling.
- `/t`: Apply the following transform in advertise/administrative contexts.
- `/g`: Select language ID for an advertised product.
- `/?`: Display Windows Installer command help; `/help` is the long spelling.

## PowerShell boundaries

Build a reviewed argument array, use `Start-Process -Wait -PassThru`, and read
its `ExitCode`; direct invocation instead uses `$LASTEXITCODE`. Quote package
and log paths once for the actual native boundary, never via
`Invoke-Expression`. Treat 0, 1641, and 3010 distinctly, preserve the protected
log, and verify product/version/context after completion.

## Common mistakes

### Assuming exit code zero is the only success

`0` is success; `1641` means success with restart initiated, and `3010` means
success with restart required. Capture the actual process exit code, classify
the documented values, and verify installed product state and version.

### Losing completion by launching the GUI process

Use `Start-Process -Wait -PassThru` and inspect its `ExitCode`. Do not infer
completion from the first `msiexec` process seen in Task Manager or from a
launcher returning; Windows Installer can involve its service and child
processes.

### Mixing cmd variables and PowerShell syntax

`%ERRORLEVEL%` and `%TEMP%` are cmd expansions, not PowerShell expressions.
Use `$p.ExitCode`, `$LASTEXITCODE` after direct invocation, and `$env:TEMP`.
Quote package/log paths through the one actual shell boundary.

### Using a display name as uninstall identity

`/x` needs a package path or verified product code. Display names are not
unique or stable. Inventory the product/version/context and preserve the exact
GUID braces; do not scrape an unrelated registry view blindly.

### Hiding all UI without a log or restart policy

`/qn` can conceal a prompt, source failure, policy denial, or custom-action
error. Always choose restart behavior, write a protected log to an existing
writable directory, and remember that logs and command properties can contain
secrets.

### Assuming every MSI accepts the same properties

Generic `msiexec` switches are not vendor-specific MSI public properties.
Obtain the package vendor's deployment contract and test the exact package;
do not invent `INSTALLDIR`, feature, or license properties.

## Version and platform differences

This executable is Windows-only. Package bitness, per-user/per-machine
context, elevation, policy, installed Windows Installer version, transforms,
custom actions, and vendor package design affect behavior.

## Related documents

- [winget-install](winget-install.md)
- [cmd](cmd.md)
- [reg](reg.md)

## Sources and license

This original guide was adapted from Microsoft's official
[msiexec reference](https://learn.microsoft.com/windows-server/administration/windows-commands/msiexec).
Recurring PowerShell wait, quoting, and exit-code failures were cross-checked
against a [practitioner installation question](https://stackoverflow.com/questions/73063024/msiexec-powershell-silent-install)
and constrained by the official Windows Installer contract. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
