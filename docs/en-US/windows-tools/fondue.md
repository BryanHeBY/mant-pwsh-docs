<!-- mant:tldr:start -->
# fondue

> Enable one Windows optional feature whose manifest is already present.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/fondue.

- Discover exact feature names and current state before using Fondue:

`dism.exe /Online /Get-Features /Format:Table`

- Inspect one exact feature and its current state:

`dism.exe /Online /Get-FeatureInfo /FeatureName:{{feature-name}}`

- Enable one reviewed feature while leaving reboot prompts visible:

`fondue.exe /enable-feature:{{feature-name}}`

- Verify the feature state and whether completion is pending a restart:

`dism.exe /Online /Get-FeatureInfo /FeatureName:{{feature-name}}`
<!-- mant:tldr:end -->

# fondue

## Overview

Features on Demand User Experience Tool (`fondue.exe`) enables one optional
Windows feature per invocation. The feature manifest must already exist in the
image; payload files can come from Windows Update or a source selected by
Group Policy. `/caller-name:` labels the caller for error reporting, and
`/hide-ux:` suppresses selected UI.

## Common mistakes

### Guessing a friendly feature name

Fondue requires the internal feature name, not the display label from Settings.
Enumerate features and inspect the exact candidate with DISM first.

### Using `/hide-ux:all` to make automation reliable

Hiding UI does not supply required permission or source files; the operation
can fail when interaction is needed. It also hides progress and restart
requests. Prefer an explicit deployment interface with logging, source, and
restart control for managed automation.

### Assuming it manages capabilities or every optional component

Features, Features on Demand capabilities, and packages have different
identities and servicing commands. Use DISM or the supported PowerShell
servicing cmdlet for the family actually inventoried.

### Ignoring content source and policy

Payload retrieval can depend on Windows Update, WSUS, Group Policy, network
access, and an image-matched source. Verify the configured source policy and
do not bypass organizational update controls with an arbitrary download.

### Treating process exit as enabled state

Re-query feature state and handle enable-pending/restart requirements. Test the
feature itself only after servicing has completed.

## Version and platform differences

This executable is Windows-only. Feature names, manifests, source availability,
edition support, policies, elevation, and restart behavior vary by target.

## Related documents

- [dism](dism.md)
- [sfc](sfc.md)
- [winget-install](winget-install.md)

## Sources and license

This original guide was adapted from Microsoft's official
[fondue reference](https://learn.microsoft.com/windows-server/administration/windows-commands/fondue)
and [DISM feature guidance](https://learn.microsoft.com/windows-hardware/manufacture/desktop/enable-or-disable-windows-features-using-dism?view=windows-11).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
