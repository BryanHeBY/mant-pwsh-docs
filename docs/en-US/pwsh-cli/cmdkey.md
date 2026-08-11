<!-- mant:tldr:start -->
# cmdkey

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

# cmdkey

## Overview

`cmdkey.exe` creates, lists, and deletes credentials stored for the current
Windows user context. `/add:target` creates a domain/computer credential,
`/generic:target` creates a generic credential, `/smartcard` uses a smart
card, `/list[:target]` inventories, and `/delete:target` or `/delete /ras`
removes an entry.

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
application, protocol, and user/session context.

## Related documents

- [whoami](whoami.md)
- [klist](klist.md)
- [gpresult](gpresult.md)

## Sources and license

This original guide was adapted from Microsoft's official
[cmdkey reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cmdkey).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
