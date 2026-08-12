<!-- mant:tldr:start -->
# gpresult.exe

> Report the Resultant Set of Policy for an exact Windows user/computer context.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/gpresult.

- Show the current user's RSoP summary:

`gpresult.exe /scope user /r`

- Show computer RSoP from an elevated shell:

`gpresult.exe /scope computer /r`

- Create a detailed local HTML report at a new protected path:

`gpresult.exe /h "{{existing-directory\gpresult-report.html}}"`

- Query one remote computer and target user with current credentials:

`gpresult.exe /s {{computer-name}} /user "{{DOMAIN\user}}" /scope user /r`
<!-- mant:tldr:end -->

# gpresult.exe

## Overview

`gpresult.exe` reports Resultant Set of Policy (RSoP) recorded for a user and
computer. `/scope user|computer` narrows the half of policy, `/r` summarizes,
`/v` is verbose, `/z` includes all available detail, and `/h` or `/x` writes
HTML or XML. Remote reporting uses `/s` and optionally alternate run-as
credentials; it does not itself refresh Group Policy.

## Command and options

<!-- mant:entries role=command case=insensitive -->
- `gpresult.exe`: Report recorded Resultant Set of Policy for an explicit
  computer and user context without refreshing policy.

Run-as identity (`/u`) and reported target identity (`/user`) are distinct.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Query the following remote computer instead of the local computer.
- `/u`: Use the following account to run the remote query.
- `/p`: Supply the `/u` password; omit the entire switch to receive a prompt.
- `/user`: Report RSoP for the following target user on the selected computer.
- `/scope`: Restrict the report to `USER` or `COMPUTER` policy.
- `/r`: Display summary RSoP data.
- `/v`: Display verbose policy information.
- `/z`: Display all available detailed policy information.
- `/x`: Write XML report output to the following file.
- `/h`: Write HTML report output to the following file.
- `/f`: Force overwrite of an existing `/x` or `/h` report file.
- `/?`: Display installed command help. On the recorded Windows build it
  returned 0 but omitted `/x`, `/h`, and `/f`; ordinary help is therefore not
  a complete capability inventory on every build.

## PowerShell boundaries

Invoke `gpresult.exe` with separate native arguments, never inline `/p`, and
capture `$LASTEXITCODE`. Reports contain sensitive policy/security topology;
write to a protected new path and import XML only after validating its schema
and target identity. A successful text/HTML report is not a refresh operation
or proof that every effective setting currently matches RSoP.

## Common mistakes

### Expecting computer settings from a non-elevated shell

Computer RSoP often requires local administrative access and elevation. State
`/scope computer`, run in the correct target context, and treat missing output
or access errors as evidence to diagnose—not proof that no computer policy
applied.

### Querying a user with no recorded RSoP on that computer

RSoP is associated with processing for a real user/computer context. A user
who has never signed in or has no collected RSoP can produce “no RSoP data.”
Identify the intended user, host, session, and last policy-processing time.

### Confusing run-as identity with target identity

`/u` supplies credentials used to execute a remote query; `/user` selects the
user whose RSoP is reported. They are not interchangeable. Omit `/p` so a
password is prompted rather than exposed in history and process arguments.

### Overwriting or publishing a sensitive report

`/f` overwrites an existing HTML/XML file. Reports can reveal users, groups,
GPO names, paths, scripts, filters, and security settings. Use a new protected
path, restrict access, and sanitize before sharing.

### Treating RSoP as proof of every current setting

The report describes Group Policy processing, not every local, MDM, runtime,
application, registry, or security control. Confirm the relevant effective
setting and application behavior separately, especially when processing
errors or pending restart/sign-in are present.

### Forcing refresh before preserving evidence

Capture RSoP, event/log evidence, network/DC state, and timestamps before
`gpupdate`. A refresh changes the state being diagnosed and can trigger
foreground work, sign-out, or restart requirements.

## Version and platform differences

This executable is Windows-only. Remote RSoP requires access and firewall/RPC
support. On Windows ARM64, Microsoft documents that only the SysWOW64 build
supports `/h`. On Windows NT `10.0.26200.0`, installed file version
`10.0.26100.8115` printed 35 nonempty help lines for `/?` and returned 0, but
that help did not list the current official `/x`, `/h`, or `/f` report options.
Keep installed help, architecture, and the current official reference as
separate evidence rather than deleting a supported option from one shortened
help display.

## Runtime evidence

On Windows NT 10.0.26200.0, installed file version 10.0.26100.8115
ordinary-token /? printed 35 nonempty help lines and returned 0, but omitted
the current official /x, /h, and /f report options. The page retains those
options and records installed help, architecture, and current official
reference as separate evidence; no RSoP query, remote target, credential, or
report path was supplied.

## Related documents
- [systeminfo.exe](systeminfo.exe.md)
- [auditpol.exe](auditpol.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[gpresult reference](https://learn.microsoft.com/windows-server/administration/windows-commands/gpresult).
High-frequency missing-computer-scope and missing-user-RSoP cases were
cross-checked against [practitioner discussion](https://serverfault.com/questions/883244/gpresult-error-the-user-does-not-have-rsop-data-fails-as-domain-admin)
and constrained by the official target/run-as distinction. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
