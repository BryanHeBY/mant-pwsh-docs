<!-- mant:tldr:start -->
# ssh

> Connect securely to a remote host with OpenSSH from PowerShell.
> More information: https://man.openbsd.org/ssh.

- Test an explicit host connection:

`ssh {{user}}@{{host}}`

- Run one quoted remote command:

`ssh {{user}}@{{host}} '{{command}}'`

- Inspect the effective configuration for a host:

`ssh -G {{host}}`
<!-- mant:tldr:end -->

# ssh

## Synopsis

```text
ssh [options] destination [command [argument ...]]
```

OpenSSH `ssh` establishes an authenticated encrypted connection to a remote
server and can run one remote command. PowerShell parses the local invocation;
the remote shell or program then parses the command sent after connection.

## Important options

<!-- mant:entries role=option case=sensitive -->
- `-G`: Print the effective client configuration after evaluating `Host` and `Match` blocks, then exit without connecting.
- `-F FILE`: Use an explicit per-user configuration file instead of the default user configuration path.
- `-o OPTION`: Set one `ssh_config` option on the command line; repeat for multiple options.
- `-l USER`: Select the remote login name, equivalent to the user part of `USER@HOST`.
- `-p PORT`: Select the remote server port; unlike `scp`, lowercase `-p` means port.
- `-i FILE`: Select an identity file; repeatable, and agent identities can still participate unless restricted by configuration.
- `-J DESTINATION`: Reach the target through one or more comma-separated jump hosts; destination options do not automatically configure each jump host.
- `-L SPEC`: Create a local listening socket or port that forwards to a destination through the SSH connection.
- `-R SPEC`: Create a remote listening socket or port that forwards through the SSH connection.
- `-D [ADDRESS:]PORT`: Create a local dynamic SOCKS listener.
- `-N`: Do not run a remote command; useful for forwarding-only sessions.
- `-T`: Disable pseudo-terminal allocation for predictable noninteractive commands.
- `-t`: Force pseudo-terminal allocation; repeat when allocation is required despite no local terminal.
- `-n`: Prevent SSH from reading standard input, which avoids consuming PowerShell pipeline or background-job input.
- `-v`: Increase diagnostic verbosity; repeat up to three times for connection and authentication troubleshooting.
- `-E FILE`: Write debug logs to a file instead of standard error.
- `-4`, `-6`: Restrict address resolution and connections to IPv4 or IPv6.
- `-A`: Forward the authentication agent; use only across a host you trust with access to the forwarded agent.
- `-a`: Disable authentication-agent forwarding.
- `-X`, `-Y`: Enable untrusted or trusted X11 forwarding; trusted forwarding grants broader local display access.
- `-V`: Print the client version and exit.

## Verify identity before automation

Use a literal, reviewed destination and verify the host key on first contact.
Do not automatically accept a changed host key in production: it can indicate a
legitimate rebuild, a wrong destination, or an interception risk.

```powershell
ssh -G build.example.test
ssh deploy@build.example.test
```

`ssh -G` prints effective configuration and helps identify selected user, port,
identity files, proxy configuration, and host-key policy. User and system SSH
configuration can change those defaults, so record the relevant configuration
for deployment automation.

## Keys, agents, and secrets

Use dedicated keys with least privilege and suitable file permissions. Prefer
an approved agent or secure key store over embedding a password, private-key
passphrase, or token in PowerShell text or command lines. Restrict remote
authorized keys with server-side policy where applicable.

When PowerShell launches the Windows OpenSSH client, ensure that the intended
`ssh.exe` wins command resolution. Use `Get-Command ssh -All` when debugging
and an explicit path or `.exe` suffix when a script requires the Windows
executable.

## Remote commands and quoting

`ssh host command` crosses at least two parsing layers. Prefer a reviewed
script or a small argument set over interpolated nested shell code. Quote data
for the remote shell, validate inputs, and never use `Invoke-Expression` to
assemble an SSH command.

Check `$LASTEXITCODE` after SSH. A successful local process start does not
prove the remote command succeeded; its result normally becomes SSH's exit
status, subject to connection and remote-shell behavior.

## PowerShell boundaries

PowerShell parses local arguments, SSH selects configuration and transports a
command, and a remote shell may parse that command again. Avoid interpolated
command strings, prevent unwanted stdin consumption with `-n` when needed,
and distinguish local `$LASTEXITCODE` from text written by the remote command.

## Version and platform differences

This page follows current OpenSSH and was runtime-checked with OpenSSH 10.4p1
on Linux. Windows OpenSSH packaging, service configuration, key-file ACLs,
agent integration, and default config paths differ from Unix-like systems;
older clients can lack newer algorithms and options.

## Common mistakes

### Automatically accepting or suppressing host-key changes

Investigate the expected destination and update trusted host keys through a
reviewed process. Disabling verification removes server identity protection.

### Exposing a forward beyond the intended interface

An empty or wildcard bind address can make a forwarded port reachable by
other hosts. Bind to loopback unless broader access is explicitly required and
authorized.

### Assuming local quoting survives the remote shell unchanged

Prefer a deployed remote script or a small, validated argument set. Nested
PowerShell-to-SSH-to-shell parsing is not safely solved with
`Invoke-Expression`.

## Related documents

- [git](git.md)
- [Cross-platform tools for PowerShell](cross-platform-tools.md)
- On Windows, query `mant wsl --source windows-tools` and
  `mant where --source windows-tools`.

## Sources and license

This original ManT-oriented guide was adapted from the official
[OpenSSH ssh manual](https://man.openbsd.org/ssh). It emphasizes host identity,
configuration inspection, local/remote parsing boundaries, and least
privilege. Exact upstream revision and path are recorded in `upstream/cross-platform-tools.json`.

The cited OpenSSH source has a composite BSD-style license. This adaptation is
licensed under CC BY 4.0.
