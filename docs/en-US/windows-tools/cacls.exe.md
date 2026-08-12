<!-- mant:tldr:start -->
# cacls.exe

> Recognize deprecated CACLS syntax, but inspect and manage modern Windows DACLs
> with ICACLS or typed ACL APIs after preserving before-state.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cacls.

- Confirm how both executable names resolve on the target:

`Get-Command cacls.exe, icacls.exe -All | Format-Table Name, Source, Version`

- Display the DACL for one exact path without changing it:

`icacls.exe "{{path}}"`

- Inspect owner, access rules, and protected-inheritance state as typed data:

`Get-Acl -LiteralPath "{{path}}" | Format-List Path, Owner, AreAccessRulesProtected, AccessToString, Sddl`

- Read the modern command's target-local syntax before designing a change:

`icacls.exe /?`

<!-- mant:tldr:end -->

# cacls.exe

## Overview

`cacls.exe` displays or modifies file and directory discretionary access control
lists (DACLs). Microsoft explicitly deprecates it in favor of `icacls.exe`.
Keep this page searchable so old installers and scripts can be reviewed, but do
not copy CACLS mutation syntax into new automation.

ACL work is security policy, not a text substitution. Resolve the exact object,
owner, filesystem, reparse behavior, existing explicit and inherited ACEs,
canonical order, protected state, principal SIDs, inheritance flags, effective
access, backup/recovery identities, and rollback before changing anything.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `cacls.exe`: Display or change legacy file and directory ACLs.

Prefer `icacls` or typed ACL APIs for current automation.

<!-- mant:entries role=option case=insensitive -->
- `/t`: Traverse selected subdirectories and therefore broaden scope.
- `/m`: Change ACLs on volumes mounted to directories.
- `/l`: Act on a symbolic link itself rather than its target.
- `/s`: Display the security descriptor in SDDL form.
- `/e`: Edit instead of replacing the existing ACL.
- `/c`: Continue after access errors and risk partial application.
- `/g`: Grant one account a legacy permission set.
- `/r`: Revoke one account only when used with `/e`.
- `/p`: Replace one account's permissions.
- `/d`: Deny one account access and potentially override allows.
- `/?`: Display installed deprecated syntax.

Exact installed 10.0.26100.8115 returned 42 nonempty help lines on stdout but
status 160. This is valid help, not proof of an ACL operation failure; preserve
payload, requested operation, and native status separately.

## Common mistakes

### Translating `/G`, `/P`, `/R`, or `/D` by name alone

Grant, replace, revoke/remove, and deny have different effects on explicit and
inherited ACEs. A deny is not a safer remove. Use the ICACLS documentation and a
disposable ACL fixture to compare before/after SDDL and effective access for
ordinary user, administrator, SYSTEM, service, backup, and recovery identities.

### Removing inheritance and locking out management identities

`icacls /inheritance:r` removes inherited ACEs; invalid file/directory
inheritance flags can also leave an object without the access you expected.
Never run it recursively from an agent-generated one-liner. Preserve ACLs,
grant required recovery identities explicitly, test one leaf, then expand only
with a reviewed selection and rollback.

### Confusing `/T` with future inheritance

Recursion changes existing descendants; `(OI)` and `(CI)` describe propagation
to child objects. They are not interchangeable. Reparse points, mount points,
offline files, long paths, access-denied continuation, and concurrent tree
changes further complicate a recursive result.

### Using localized account names as durable identity

Names can be renamed, localized, duplicated across authorities, or unresolved
offline. Resolve the intended SID and authority, avoid broad groups such as
Everyone unless explicitly required, and verify the stored ACE rather than the
input spelling.

### Treating displayed ACL text as effective access

Effective access also depends on token group membership, deny precedence,
privileges, share permissions, integrity level, ownership, claims, and the
operation attempted. Validate with the real least-privileged identity and retain
the security rationale.

## PowerShell boundaries

Use explicit `.exe` names to avoid command ambiguity. PowerShell's `Get-Acl` and
`Set-Acl` expose objects but do not make ACL editing automatically safe; object
construction, canonicalization, provider differences, and error handling still
need review. Capture native `$LASTEXITCODE` immediately when using ICACLS.

## Version and platform differences

CACLS is deprecated on supported Windows client/server releases. ACL features
depend on filesystem, object type, Windows build, domain/identity availability,
path namespace, privileges, and local versus remote/share context. Use ICACLS
target-local help for supported syntax.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 CACLS file version 10.0.26100.8115
/? returned 42 nonempty stdout help lines/no stderr but status 160. Only help
ran; no path, ownership, DACL, SACL, inheritance or recursive mutation was
supplied.

## Related documents
- [icacls.exe](icacls.exe.md)
- [takeown.exe](takeown.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original migration guide was adapted from Microsoft's official
[CACLS reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cacls)
and [ICACLS reference](https://learn.microsoft.com/windows-server/administration/windows-commands/icacls).
Deprecation demand and inheritance/lockout failures were cross-checked against
[permission-management](https://stackoverflow.com/questions/2928738/how-to-grant-permission-to-users-for-a-directory-using-command-line-in-windows)
and [inheritance-removal](https://stackoverflow.com/questions/52103763/powershell-icacls-to-change-permissions-on-a-file)
questions. Microsoft sources govern supported behavior. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
