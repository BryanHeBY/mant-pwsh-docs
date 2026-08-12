<!-- mant:tldr:start -->
# cmdkey.exe

> Inventory and manage Windows credentials by exact stored target name.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cmdkey.

- List stored credential targets and user names for the current user context:

`cmdkey.exe /list`

- Query one exact stored target before changing it:

`cmdkey.exe /list:{{target-name}}`

- Add one Windows credential while prompting for the password instead of exposing it in arguments:

`cmdkey.exe /add:{{target-name}} /user:"{{DOMAIN\user}}"`

- Delete one exact reviewed credential target:

`cmdkey.exe /delete:{{target-name}}`
<!-- mant:tldr:end -->

# cmdkey.exe

## Overview

`cmdkey.exe` creates, lists, and deletes credentials stored for the current
Windows user context. `/add:target` creates a domain/computer credential,
`/generic:target` creates a generic credential, `/smartcard` uses a smart
card, `/list[:target]` inventories, and `/delete:target` or `/delete /ras`
removes an entry.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `cmdkey.exe`: List, add, or delete credentials in the current Windows user's
  credential store using exact application/protocol target names.

Colon-bound target, user, and password values are part of one native argument.
Omit the password switch/value so an approved interactive prompt can be used.

<!-- mant:entries role=option case=insensitive -->
- `/add`: Add a domain/computer credential associated with the following exact
  target name.
- `/generic`: Add a generic credential associated with the following exact target.
- `/smartcard`: Select a credential from an available smart card, prompting for
  the specific card when multiple cards are present.
- `/user`: Store the following account name with a new credential; if its value
  is omitted, the command requests it.
- `/pass`: Store the following password; omit the switch/value to be prompted
  rather than exposing the secret in arguments.
- `/delete`: Delete the following exact target credential, or combine the
  parameterless form with `/ras` for the stored remote-access credential.
- `/ras`: Select the stored remote-access credential for `/delete`.
- `/list`: List all credential metadata, or only the following exact target.
- `/?`: Display installed command help; on the recorded Windows build it
  printed complete help and returned exit code 1.

## PowerShell boundaries

`cmdkey.exe` is native and its colon forms must remain one argument. Never put
a password in PowerShell source, history, transcripts, process arguments, or
agent text. Capture `$LASTEXITCODE`, then re-run `/list:TARGET` in the exact
consumer user/elevation/session context; entry presence does not prove a
connection used it, and listing never reveals the stored secret.

## Common mistakes

### Putting the password after `/pass:`

An inline secret can leak through command history, process arguments, logs,
transcripts, screenshots, and agent conversations. Omit `/pass` and let
`cmdkey` prompt, or use an approved secret-management API that never renders
the secret as command text.

### Guessing the stored target name

Credential target strings are application/protocol identities and need not be
the simple host name a user remembers. List entries, copy the exact target,
and verify how the consuming application constructs its target before adding
or deleting anything.

### Assuming a stored credential is used by every connection

Existing SMB sessions, Kerberos tickets, explicit application credentials,
RDP target forms, identity policy, and process logon context can take
precedence. Close or inspect the relevant connection safely and test the
actual protocol; do not infer use from entry presence.

### Editing the wrong user's credential store

Normal, elevated, service, scheduled-task, and alternate-user processes can
run under different identities. Record `whoami /user`, elevation/session, and
consumer process identity before inventory and change.

### Expecting `/list` to reveal a password

The command reports credential metadata, not the stored secret. Do not build
automation that attempts to recover or print credentials; rotate/recreate an
approved credential when its secret is unknown.

### Deleting before checking dependent sessions

Removal can break future authentication but may not affect an already-open
session, which makes a quick test misleading. Record the exact entry, affected
applications/tasks, rollback owner, and then validate a newly established
connection.

## Version and platform differences

This executable is Windows-only. Available credential types, smart-card use,
target matching, policy, and behavior of consumers vary by Windows release,
application, protocol, and user/session context. On Windows NT
`10.0.26200.0`, installed file version `10.0.26100.1` printed 18 nonempty
help lines for `/?` and returned 1. That help-specific status is not evidence
that credential-store access failed; classify an operational result only from
the exact operation's output and status.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 ordinary-token
/? printed 18 nonempty help lines and returned 1. The page records this as
help-specific rather than evidence of credential-store failure; no credential
target, user, password, smart card, RAS entry, or store inventory was supplied
or queried.

## Related documents
- [whoami.exe](whoami.exe.md)
- [klist.exe](klist.exe.md)
- [gpresult.exe](gpresult.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[cmdkey reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cmdkey).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
