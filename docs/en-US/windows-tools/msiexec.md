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
