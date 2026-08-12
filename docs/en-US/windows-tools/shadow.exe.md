<!-- mant:tldr:start -->
# shadow.exe

> View or control one verified active Remote Desktop session only under an approved support/privacy policy and with informed user consent.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/shadow.

- Inventory session IDs, owners, state, and the caller's current-session marker:

`query.exe session /server:"{{server}}"`

- Re-query the exact active target session immediately before requesting control:

`query.exe user {{session-id}} /server:"{{server}}"`

- Send a bounded support notice through an approved channel before the request:

`msg.exe {{session-id}} /server:"{{server}}" /time:{{120}} "{{Support requests permission to view/control this session.}}"`

- Under the approved consent policy, start shadowing that exact session verbosely:

`shadow.exe {{session-id}} /server:"{{server}}" /v`

- End shadowing with Control plus the numeric-keypad asterisk, as documented by Microsoft:

`Ctrl+Numpad-*`
<!-- mant:tldr:end -->

# shadow.exe

## Overview

`shadow.exe` initiates viewing or active keyboard/mouse control of another
active session on a Remote Desktop Session Host. Its target is a session name or
ID; `/server:` selects the host and `/v` is verbose. The operation exposes the
user's screen and possibly permits input, so authorization, notice, consent,
privacy, recording, audit, and support-purpose limits are primary requirements.

Microsoft documents a user warning/response before monitoring unless policy
disables it. Ability to suppress consent is not permission to do so. Do not
change Group Policy or use no-consent behavior from a generic troubleshooting
snippet; require explicit legal/security/HR policy and auditable approval.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `shadow.exe`: View or control one active RDS session under the host's consent policy.

The positional session name/ID is host-local and reusable; re-query it
immediately. MSTSC shadow options do not belong to this executable.

<!-- mant:entries role=option case=insensitive -->
- `/server`: Select one exact Session Host; it does not supply credentials.
- `/v`: Display extended shadow operation information.
- `/?`: Display installed syntax.

## Common mistakes

### Confusing `shadow.exe` with `mstsc /shadow`

They are related RDS surfaces with different syntax. `/control` and
`/noConsentPrompt` are Remote Desktop Connection options, not documented
`shadow.exe` switches. Use target-host installed help and the separate `mstsc`
guide rather than mixing arguments from web examples.

### Shadowing the wrong or stale session ID

IDs are host-local and reusable. Verify host, owner, name, state, current-session
marker, support ticket, and timestamp immediately before connection. Avoid
username-only selection when a user has multiple sessions.

### Treating a warning as informed consent

A pop-up can be missed, misunderstood, coerced by policy, or accepted by the
wrong person. Establish the support purpose, data categories visible, control
level, expected duration, recording rules, stop mechanism, and alternate contact
through the organization's approved process.

### Disabling consent or broadening remote-control rights

Another user's session requires Full Control or Remote Control special access.
Changing policy to control without permission materially expands surveillance/
input power. Apply least privilege and scoped policy through change control;
preserve policy and event evidence and provide an emergency stop/report route.

### Ignoring console/current-session and display constraints

Microsoft documents that the console session cannot shadow or be shadowed by
another session, the current session cannot shadow itself, and incompatible
video resolution can fail. Do not weaken display/security policy or repeatedly
attach to troubleshoot an unsupported path.

### Forgetting how to stop control

Microsoft specifies Control plus the asterisk on the numeric keypad. Confirm the
operator keyboard/input path and a secondary termination method before starting;
record start/end and verify the target session remains with its owner.

## PowerShell boundaries

Use `shadow.exe` explicitly with scalar ID/server arguments. Do not launch it
from unattended automation or pipe parsed localized output into it. Capture
native status where possible, but the interactive session, user response,
events, and support record—not `$LASTEXITCODE` alone—establish outcome.

## Version and platform differences

`shadow.exe` is Windows-only. View/control choices, consent prompts, console
rules, resolution support, permissions, audit, and remote reachability depend on
build, edition, RDS role, policy, client, session type, and organization rules.

## Runtime evidence

Exact System32 discovery on the recorded Windows NT 10.0.26200.0 Home China
client found shadow.exe absent; no PATH substitute or shadow session ran. Help
and consent/privacy verification remains pending on an approved disposable
support session and consenting test user.

## Related documents
- [query.exe](query.exe.md)
- [msg.exe](msg.exe.md)
- [tscon.exe](tscon.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[shadow reference](https://learn.microsoft.com/windows-server/administration/windows-commands/shadow)
and its historical [no-consent policy article](https://learn.microsoft.com/troubleshoot/windows-server/remote/shadow-terminal-server-session),
which is cited to explain why policy capability must remain separately governed.
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
