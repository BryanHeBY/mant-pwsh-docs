<!-- mant:tldr:start -->
# takeown

> Recover ownership of an exact Windows file or directory before separately repairing access.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/takeown.

- Inspect the current owner and DACL before changing anything:

`Get-Acl -LiteralPath '{{literal-path}}' | Select-Object Owner, AreAccessRulesProtected, AccessToString`

- Take ownership of one exact object for the current user:

`takeown.exe /F "{{literal-path}}"`

- Assign ownership of one exact object to the local Administrators group:

`takeown.exe /F "{{literal-path}}" /A`

- Verify ownership and review whether a separate minimal DACL repair is required:

`Get-Acl -LiteralPath '{{literal-path}}' | Select-Object Owner, AccessToString`
<!-- mant:tldr:end -->

# takeown

## Overview

`takeown.exe` lets an authorized administrator recover ownership of a file or
directory. By default it assigns ownership to the current user; `/A` assigns
the local Administrators group. `/R` recurses and `/D Y|N` supplies a default
answer for inaccessible directories. `/S`, `/U`, and `/P` select a legacy
remote target and run-as identity.

## Common mistakes

### Assuming ownership grants read, write, or delete access

Owner and DACL are separate parts of the security descriptor. Ownership can
permit changing the DACL, but it does not itself grant full file access.
Re-query both, then make the minimum reviewed `icacls` change if needed.

### Taking ownership of an entire drive or system tree

Recursive ownership changes can break Windows servicing, applications,
profiles, backup, quotas, and security boundaries. Start with one exact object;
inventory descendants and preserve original owners/DACLs before any narrow
recursive recovery.

### Using `/R /D Y` as harmless non-interactive syntax

`/D Y` tells recursive processing to take ownership when it cannot list/read a
directory; it broadens changes precisely where scope is least visible. Prefer
`/D N` during discovery or remove the cause of inaccessible scope before an
approved targeted action.

### Assigning the wrong owner identity

Without `/A`, the current logged-on user becomes owner. With `/A`, the local
Administrators group does. Record `whoami /user`, target computer, intended
service/account owner, and original owner; do not assume the operator should
remain the durable owner.

### Putting a remote password on the command line

Omit `/P` so the tool prompts, but prefer an approved management channel that
does not expose secrets or rely on broad remote filesystem ownership changes.
Arguments and transcripts can leak inline passwords.

### Treating every failure as an ACL problem

Open handles, read-only media, share permissions, EFS keys, offline files,
filesystem errors, policy, reparse points, and the remote protocol can all
deny an operation. Ownership repair should follow evidence, not precede it.

## Version and platform differences

This executable is Windows-only. Target filesystem, local/remote context,
privileges, UAC elevation, domain identity resolution, and reparse behavior
affect results.

## Related documents

- [icacls](icacls.md)
- [cipher](cipher.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[takeown reference](https://learn.microsoft.com/windows-server/administration/windows-commands/takeown).
The recurring ownership-versus-access confusion was cross-checked against
[practitioner discussion](https://superuser.com/a/496499/900431) and then
bounded by the official ownership semantics. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Super User contributions are licensed under CC BY-SA 4.0.
