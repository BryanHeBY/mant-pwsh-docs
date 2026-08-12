<!-- mant:tldr:start -->
# taskkill.exe

> End Windows processes by verified PID, image, or filters.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/taskkill.

- Recheck one exact PID immediately before termination:

`tasklist.exe /fi "PID eq {{1234}}" /fo list`

- Request ordinary termination of one verified PID:

`taskkill.exe /pid {{1234}}`

- Preview a PowerShell termination without applying it:

`Stop-Process -Id {{1234}} -WhatIf`
<!-- mant:tldr:end -->

# taskkill.exe

## Overview

`taskkill.exe` terminates processes selected by `/pid`, `/im`, and `/fi`.
`/f` forces termination and `/t` includes child processes started by the
selected process. Remote terminations are always forced.

## Important options

<!-- mant:entries role=command case=insensitive -->
- `taskkill.exe`: Terminate selected local or remote Windows processes after
  revalidating identity, scope, dependencies, and force/tree behavior.

Selection and remote options are addressable separately:

<!-- mant:entries role=option case=insensitive -->
- `/pid PID`: Select one process ID; repeat the option to select multiple PIDs.
- `/im IMAGE`: Select processes by executable image name; `*` is accepted only with a filter.
- `/fi FILTER`: Apply one selection filter; repeated filters are combined.
- `/f`: Force termination; remote termination is forced even when this switch is absent.
- `/t`: Include child processes started by each selected process.
- `/s COMPUTER`: Target a remote computer by name or IP address.
- `/u`: Authenticate the remote operation as another user or `DOMAIN\USER`; valid only with `/s`.
- `/p PASSWORD`: Supply the remote password; omit its value to prompt rather than exposing a secret in the command line.
- `/?`: Display installed syntax, filter operators, remote limitations, and force behavior without terminating a process.

## PowerShell boundaries

Call `taskkill.exe` explicitly, pass each filter as one quoted argument, and
check `$LASTEXITCODE`. Prefer `Stop-Process -WhatIf` for a typed local preview,
but do not assume it reproduces Taskkill's remote or tree semantics.

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

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8457 /? returned
0 and matched the official eight selectors plus help; command and help are now
independently ManT-addressable. No process was selected or terminated.

## Related documents
- [tasklist.exe](tasklist.exe.md)
- [openfiles.exe](openfiles.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[taskkill reference](https://learn.microsoft.com/windows-server/administration/windows-commands/taskkill).
The need for PID-level selection when image names are shared is reflected in
[What is the PID advantage with taskkill?](https://stackoverflow.com/questions/35436565/what-is-pid-advantage).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation is CC BY 4.0 and Stack Overflow content CC BY-SA 4.0.
This adaptation is CC BY 4.0; no answer text is reproduced.
