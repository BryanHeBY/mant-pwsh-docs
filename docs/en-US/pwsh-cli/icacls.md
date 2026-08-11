<!-- mant:tldr:start -->
# icacls

> Inspect, verify, save, and deliberately change Windows file and directory DACLs.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/icacls.

- Display the DACL for one exact file or directory:

`icacls.exe "{{literal-path}}"`

- Inspect owner and access rules as PowerShell objects:

`Get-Acl -LiteralPath '{{literal-path}}' | Select-Object Owner, AreAccessRulesProtected, AccessToString`

- Verify ACL canonical form recursively while operating on links rather than their targets:

`icacls.exe "{{root-path}}" /verify /T /C /L`

- Save matching DACLs before a reviewed recursive change:

`icacls.exe "{{root-path\*}}" /save "{{existing-directory\acl-backup.txt}}" /T /C /L`
<!-- mant:tldr:end -->

# icacls

## Overview

`icacls.exe` displays and changes discretionary access control lists (DACLs),
owner, integrity labels, and inheritance for files/directories. It can save and
restore DACLs, verify canonical form, find or substitute SIDs, reset inherited
ACLs, and grant, deny, or remove ACEs. `/T` recurses, `/C` continues after
errors, and `/L` applies the operation to a symbolic link instead of its target.

## Common mistakes

### Leaving inheritance parentheses unquoted in PowerShell

PowerShell parses parentheses. Construct the complete trustee/permission value
as one string, for example `"${principal}:(OI)(CI)(M)"`, and pass it as one
argument. Do not use `Invoke-Expression` to assemble ACL commands.

### Confusing `/grant` with `/grant:r`

`/grant` adds permissions to existing explicit grants for that SID;
`/grant:r` replaces its prior explicit grants. Neither automatically removes
inherited ACEs or unrelated deny entries. Inspect the complete DACL and
effective access before and after.

### Breaking inheritance without choosing copy versus remove

`/inheritancelevel:d` disables inheritance and copies inherited ACEs as
explicit; `:r` disables inheritance and removes inherited ACEs. The latter can
lock out users, backup, management, or the service itself. Preserve the DACL
and recovery access first.

### Treating `/C` as success

`/C` continues past errors, so a large tree can be partially changed. Preserve
stdout/stderr and exit status, enumerate failures, re-query representative and
exception paths, and do not silence success/errors during initial rollout.

### Recursing through links or unexpected scope

Decide whether an operation should affect a link or its destination and state
`/L` accordingly. Resolve the exact root and matches before `/T`; reparse
points, mounts, inaccessible children, and long paths can invalidate assumed
scope.

### Restoring against the wrong root

`/save` records matching paths for later `/restore` under a directory root.
Keep the backup with its exact original root, target identity, timestamp, and
filesystem snapshot; test restore on an equivalent disposable tree first.

### Using friendly names as durable principal identity

Names can resolve differently across machines/domains. For controlled
migration or automation, record the SID; numeric SIDs passed to `icacls` need
the documented leading `*`.

## Version and platform differences

This Windows-only tool replaces deprecated `cacls`. ACL semantics require a
filesystem/provider that supports Windows security descriptors; privileges,
domain resolution, integrity labels, reparse points, and remote shares affect
behavior.

## Related documents

- [takeown](takeown.md)
- [whoami](whoami.md)
- [secedit](secedit.md)

## Sources and license

This original guide was adapted from Microsoft's official
[icacls reference](https://learn.microsoft.com/windows-server/administration/windows-commands/icacls).
The frequent PowerShell-parenthesis failure was cross-checked against
[practitioner Q&A](https://stackoverflow.com/questions/8581487/powershell-calling-icacls-with-parantheses-included-in-parameters)
and resolved with the official inheritance syntax. Exact sources and licenses
are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Stack Overflow contributions are licensed under CC BY-SA 4.0.
