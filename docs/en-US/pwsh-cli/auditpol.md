<!-- mant:tldr:start -->
# auditpol

> Inspect Windows advanced audit policy by stable category or subcategory identity.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/auditpol.

- List selectable audit subcategories in report-friendly form:

`auditpol.exe /list /subcategory:* /r`

- Show the complete effective system audit policy:

`auditpol.exe /get /category:* /r`

- Show one exact subcategory by quoted GUID from PowerShell:

`auditpol.exe /get ('/subcategory:{' + '{{subcategory-guid-without-braces}}' + '}') /r`

- Save the current audit policy as a rollback/reference artifact:

`auditpol.exe /backup /file:"{{existing-directory\audit-policy.csv}}"`
<!-- mant:tldr:end -->

# auditpol

## Overview

`auditpol.exe` lists, queries, sets, backs up, restores, clears, and removes
advanced Windows audit policy. It also handles per-user policy, policy options,
delegation security descriptors, and version-limited global resource SACLs.
`/r` requests report output suitable for preserving or processing rather than
the default display table.

## Common mistakes

### Passing an unquoted GUID through PowerShell

Curly braces have PowerShell syntax meaning. Pass a category or subcategory
GUID as one quoted native argument, including its braces, and verify the
resolved selection with `/get` before any `/set`.

### Setting a category when only one subcategory was intended

A category contains multiple audit subcategories. Select the exact
subcategory name or GUID; do not combine a broad category with a narrow
subcategory and assume only one setting will change.

### Clearing policy as a troubleshooting shortcut

`/clear`, `/remove`, `/restore`, and broad `/set` operations can disable audit
coverage across the system or user scope. Back up current policy, preserve
management ownership, establish rollback, and compare the post-change policy.

### Assuming local state is the durable source of truth

Domain or local Group Policy can define advanced audit settings and later
reapply them. Record the effective audit policy together with RSoP, policy
refresh timing, and the authority expected to manage it.

### Parsing localized names as stable identifiers

Category/subcategory display names and CSV headers can be localized. Use the
official GUID identity where automation must cross language packs, but retain
the target's raw report and account for its delimiter/encoding.

### Enabling events without validating collection

A configured success/failure flag does not prove the expected event is emitted,
retained, forwarded, or alerted. Generate an approved test event and verify
the entire logging pipeline without exposing sensitive audit content.

## Version and platform differences

This executable is Windows-only. Permissions, Group Policy, language, audit
subcategory availability, and legacy resource-SACL support vary by Windows
release and management context.

## Related documents

- [gpresult](gpresult.md)
- [whoami](whoami.md)
- [systeminfo](systeminfo.md)

## Sources and license

This original guide was adapted from Microsoft's official
[auditpol reference](https://learn.microsoft.com/windows-server/administration/windows-commands/auditpol).
A recurring PowerShell GUID-quoting failure was identified through a
[practitioner question](https://stackoverflow.com/questions/75140216/how-to-enable-a-specific-system-audit-policy-in-powershell-in-windows-11)
and checked against the official selection model. Exact sources and licenses
are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
