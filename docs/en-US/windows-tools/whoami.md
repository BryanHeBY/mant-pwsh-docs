<!-- mant:tldr:start -->
# whoami

> Inspect the Windows identity and access token of the current process.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/whoami.

- Show the effective domain and user name:

`whoami.exe`

- Show the current token's SID in CSV form:

`whoami.exe /user /fo csv`

- Inspect groups carried by the current token:

`whoami.exe /groups /fo list`

- Inspect privileges and their current states:

`whoami.exe /priv /fo list`
<!-- mant:tldr:end -->

# whoami

## Overview

`whoami.exe` reports identity, SID, groups, privileges, claims, and logon ID
from the current process access token. `/all` combines the token-oriented
views. It answers “who is this process running as?”, not every meaning of
“current user.”

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `whoami.exe`: Report identity and authorization attributes from the current
  Windows process access token.

Detailed views can contain security-sensitive identifiers. Choose only the
view needed for the diagnostic and protect captured output.

<!-- mant:entries role=option case=insensitive -->
- `/upn`: Display the current user in user-principal-name format when the
  account supports that format; it cannot be combined with `/fo`.
- `/fqdn`: Display the current user in fully qualified distinguished-name form
  when applicable; it cannot be combined with `/fo`.
- `/user`: Display the current token's user name and SID.
- `/groups`: Display groups in the current token together with type, SID, and
  attributes.
- `/priv`: Display privileges in the current token and their enabled/disabled
  state.
- `/claims`: Display claims in the current token when claims are available.
- `/logonid`: Display the current user's logon ID.
- `/all`: Display user, groups, privileges, claims, and logon ID together.
- `/fo`: Select `TABLE`, `LIST`, or `CSV` formatting for compatible detailed
  views.
- `/nh`: Suppress headers for `TABLE` or `CSV` output; this is not valid with
  every output mode.
- `/?`: Display installed command help.

## PowerShell boundaries

`whoami.exe` returns formatted native text. Use `/fo csv` plus careful header
handling only for simple inventory; use .NET security principals and Windows
authorization APIs for typed decisions. Check `$LASTEXITCODE`, and do not
confuse the effective process token with the interactive desktop session user.

## Common mistakes

### Confusing the effective token with the interactive desktop user

An elevated process, scheduled task, service, remote session, or supplied
administrator credential can use another token. `whoami` correctly reports
that token; it does not discover who owns a visible console session.

### Treating group membership as an enabled authorization

Token groups have attributes and privileges have states. Inspect the complete
row and apply the target resource's ACL/policy evaluation; a name alone is not
proof that an action is allowed.

### Logging `/all` indiscriminately

Token output exposes SIDs, groups, claims, and privilege details useful to an
attacker. Collect only needed fields and protect diagnostics.

### Parsing a formatted table

Use `/fo csv` or `/fo list` deliberately, retain headers where needed, and
expect localization. For PowerShell authorization logic, prefer security APIs
and typed identity objects.

## Version and platform differences

This page describes Windows `whoami.exe`. Unix-like `whoami` tools generally
return only a user name and do not accept this token-inspection syntax.

## Related documents

- [systeminfo](systeminfo.md)
- [tasklist](tasklist.md)
- [openfiles](openfiles.md)

## Sources and license

This original guide was adapted from Microsoft's official
[whoami reference](https://learn.microsoft.com/windows-server/administration/windows-commands/whoami).
The elevated-token versus interactive-user distinction is illustrated by
[Get logon username in an elevated script](https://stackoverflow.com/questions/61397541/get-logon-username-in-elevated-script-with-standard-user-account).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
