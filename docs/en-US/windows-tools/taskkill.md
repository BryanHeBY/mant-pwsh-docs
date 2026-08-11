<!-- mant:tldr:start -->
# taskkill

> End Windows processes by verified PID, image, or filters.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/taskkill.

- Recheck one exact PID immediately before termination:

`tasklist.exe /fi "PID eq {{1234}}" /fo list`

- Request ordinary termination of one verified PID:

`taskkill.exe /pid {{1234}}`

- Preview a PowerShell termination without applying it:

`Stop-Process -Id {{1234}} -WhatIf`
<!-- mant:tldr:end -->

# taskkill

## Overview

`taskkill.exe` terminates processes selected by `/pid`, `/im`, and `/fi`.
`/f` forces termination and `/t` includes child processes started by the
selected process. Remote terminations are always forced.

## Common mistakes

### Killing every process with an image name

`/im app.exe` can select unrelated instances and cannot distinguish executable
paths. Prefer an exact PID after verifying path, owner/session, start time, and
purpose. High-risk shared hosts need a stronger process identity workflow.

### Adding `/f /t` as routine boilerplate

Force can skip application cleanup; `/t` broadens scope to descendants. Start
with ordinary exact-PID termination, wait and verify, then escalate only under
an explicit recovery policy.

### Trusting an old PID

Windows can reuse a PID after a process exits. Requery immediately before the
kill and, where possible, compare start time and executable identity.

### Assuming remote behavior is graceful

Microsoft documents that remote process termination is forced even without
`/f`. Treat remote use as disruptive and coordinate it like an administrative
change, not a harmless extension of local behavior.

### Supplying remote credentials inline

Omit `/p` to prompt. Never embed a password in examples, scripts, logs, or
agent requests.

## Version and platform differences

This executable is Windows-only. Protected processes, permissions, services,
jobs, and process state can prevent termination or cause dependent recovery.

## Related documents

- [tasklist](tasklist.md)
- [openfiles](openfiles.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[taskkill reference](https://learn.microsoft.com/windows-server/administration/windows-commands/taskkill).
The need for PID-level selection when image names are shared is reflected in
[What is the PID advantage with taskkill?](https://stackoverflow.com/questions/35436565/what-is-pid-advantage).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
