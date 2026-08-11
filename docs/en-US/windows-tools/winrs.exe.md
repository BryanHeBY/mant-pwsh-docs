<!-- mant:tldr:start -->
# winrs.exe

> Run one explicit native command through an already approved WinRM endpoint, using the caller's identity and validating remote context, streams, and exit behavior.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/winrs.

- Identify the exact WS-Management endpoint before starting a remote shell:

`winrm.exe identify -r:"{{server}}"`

- Show the remote computer name using the caller's negotiated identity:

`winrs.exe /r:"{{server}}" /noprofile hostname.exe`

- Show the remote effective identity and groups; protect the sensitive token output:

`winrs.exe /r:"{{server}}" /noprofile whoami.exe /all`

- Run one explicit cmd command with cmd parsing disabled from AutoRun and quote the remote command as one argument:

`winrs.exe /r:"{{server}}" /noprofile cmd.exe /d /c "{{ver}}"`

- Use a reviewed HTTPS endpoint name/port when TLS endpoint protection is required:

`winrs.exe /r:"https://{{server}}:5986" /noprofile hostname.exe`
<!-- mant:tldr:end -->

# winrs.exe

## Overview

`winrs.exe` creates a remote command shell through Windows Remote Management
and executes a program. `/r:`/`/remote:` selects the endpoint; `/d:` sets the
remote starting directory; repeated `/env:` values set remote environment;
`/noprofile` skips loading the remote user profile; `/usessl`/HTTPS selects TLS;
and authentication, delegation, encryption, compression, input, and echo
options change security or interaction behavior.

This is native remote process execution, not a Remote Desktop session and not
automatically PowerShell Remoting. Paths, environment, account, filesystem,
registry, network access, profiles, child processes, and side effects belong to
the remote host and token.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `winrs.exe`: Execute one command through an authorized WinRM remote shell.

Everything after WinRS options is parsed again by the remote executable or
shell. Prefer a direct executable and reviewed scalar arguments.

<!-- mant:entries role=option case=insensitive -->
- `/remote`: Select the remote WS-Management endpoint; short alias `/r`.
- `/username`: Select an alternate username; short alias `/u`.
- `/password`: Supply an alternate password; short alias `/p` exposes it.
- `/directory`: Set the remote process working directory; short alias `/d`.
- `/environment`: Set one remote environment variable; repeat as needed.
- `/noprofile`: Skip loading the remote user profile.
- `/noecho`: Suppress echo of interactive input.
- `/unencrypted`: Disable WSMan message encryption unless HTTPS makes it inapplicable.
- `/allowdelegate`: Permit credential delegation to a second remote resource.
- `/compress`: Enable transport compression where supported.
- `/usessl`: Select HTTPS/TLS transport.
- `/skipcachecheck`: Skip selected certificate cache checks.
- `/skipcncheck`: Skip TLS certificate name validation and weaken endpoint identity.
- `/skiprevocationcheck`: Skip TLS certificate revocation validation.
- `/timeout`: Use a deprecated remote operation timeout form on builds that retain it.
- `/?`: Display installed syntax.

## Safe workflow

1. Establish target identity/name, transport, authentication, authorization,
   listener/plugin policy, source network, and audit/change scope with `winrm`
   and endpoint management—not by trial execution.
2. Start with `hostname.exe` and `whoami.exe /all`; record remote host, token,
   integrity, groups/privileges, working directory, environment, architecture,
   locale, and timestamp.
3. Invoke an exact executable and scalar arguments; avoid a compound shell or
   user-provided command string. Set an explicit remote directory/environment
   only after verifying them on the remote host.
4. Capture local native status, remote stdout/stderr/events, created process and
   application evidence. Treat transport success, process start, process exit,
   and desired result as separate outcomes.

## Common mistakes

### Putting `/u:` and `/p:` secrets on the command line

Literal passwords leak through history, transcripts, process/endpoint telemetry,
logs, and screen sharing. Prefer the caller's Kerberos/Negotiate identity or an
approved managed/service endpoint. If an interactive legacy prompt is supported
and required, verify target-host behavior and protect the session; never store
the resulting command in scripts.

### Using `/unencrypted` for troubleshooting

It explicitly requests unencrypted remote-shell messages and is ignored only
when HTTPS is selected. Do not use it on an ordinary network. Diagnose
authentication/certificate/listener/firewall layers without removing protection;
an IPsec claim must be independently verified and approved.

### Enabling `/allowdelegate` to fix a share access failure

Delegation lets credentials be used for a third resource and expands the impact
of target compromise. A failed UNC access is the second-hop boundary, not proof
that delegation should be enabled. Use least-privilege constrained delegation,
resource/service identity, JEA/run-as, or workflow redesign after security review.

### Forgetting `/noprofile` changes behavior

Microsoft says the server attempts to load the user profile by default and
`/noprofile` is required when the remote user is not a local administrator.
Profiles also change environment, mapped resources, startup behavior, and attack
surface. Use `/noprofile` for deterministic inventory and explicitly provide
required remote paths/settings; do not rely on interactive profile side effects.

### Confusing local and remote parsing

PowerShell first parses the local invocation; WinRS parses its options; a remote
program or `cmd.exe`/`powershell.exe` may parse again. Quotes, `%variables%`,
`$variables`, redirects, pipes, and metacharacters can execute in an unintended
layer. Prefer direct executable/argument invocation; for complex PowerShell use
`Invoke-Command` with a script block/arguments and reviewed endpoint.

### Assuming local paths, drives, mappings, and environment exist remotely

`/directory:` and `/environment:` apply to the remote shell. Mapped drives are
logon-session specific; the remote profile/home, architecture, PATH, locale,
code page, modules, and filesystem differ. Use exact remote paths and an
identity authorized at the destination; avoid drive-letter assumptions.

### Treating Ctrl+C as a simple local cancellation

Microsoft documents the first Ctrl+C/Ctrl+Break as sent to the remote shell and
a second Ctrl+C as forcing local `winrs.exe` termination. The remote process or
child may continue or clean up differently. Design idempotency, remote timeout/
cancellation, process correlation, and post-cancel verification.

### Relying on the deprecated `/timeout` or client exit alone

Microsoft marks `/timeout` deprecated. WinRM/shell/plugin/application timeouts
and quotas are distinct. A connection can fail before start, disconnect while a
process continues, or return output despite application failure. Record every
layer and verify remote state rather than interpreting one exit value as proof.

### Running an untrusted command string

Concatenating user input into a remote shell is command injection with remote
privileges. Allowlist executable, target, working directory, and typed arguments;
avoid `Invoke-Expression`, compound `cmd /c` strings, wildcards, and redirects.
Use a purpose-built constrained endpoint/API for repeatable automation.

## PowerShell boundaries

Use `winrs.exe` explicitly and pass options/arguments as scalar strings. Capture
stdout/stderr and `$LASTEXITCODE` immediately, preserving raw output with source/
target/build/locale. Native output is text, not deserialized PowerShell objects.

Invoking `powershell.exe` or `pwsh.exe` through WinRS still creates a native
child process and additional quoting/encoding layers; it is not equivalent to
`Invoke-Command`. Prefer PowerShell Remoting or SSH remoting for PowerShell code
when the intended endpoint/transport supports it.

## Version and platform differences

`winrs.exe` is Windows-only. Option availability, authentication/message
protection, profile rules, compression, shell quotas, encoding, remote program
architecture, and exit/cancellation behavior vary by Windows/WMF build, endpoint
configuration, domain/workgroup, policy, and caller/target program.

## Related documents

- [winrm.exe](winrm.exe.md)
- [cmd.exe](cmd.exe.md)
- [whoami.exe](whoami.exe.md)

See the separately installed `pwsh7` and `pwsh51` sources for their shell
manuals and edition-specific remoting boundaries.

## Sources and license

This original guide was adapted from Microsoft's official
[winrs reference](https://learn.microsoft.com/windows-server/administration/windows-commands/winrs),
[WinRM installation/configuration](https://learn.microsoft.com/windows/win32/winrm/installation-and-configuration-for-windows-remote-management),
and [PowerShell remoting security](https://learn.microsoft.com/powershell/scripting/security/remoting/winrm-security)
references. Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
