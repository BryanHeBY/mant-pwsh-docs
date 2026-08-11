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

## Related documents

- [git](git.md)
- [wsl](wsl.md)
- [where](where.md)

## Sources and license

This original ManT-oriented guide was adapted from the official
[OpenSSH ssh manual](https://man.openbsd.org/ssh). It emphasizes host identity,
configuration inspection, local/remote parsing boundaries, and least
privilege. Exact upstream revision and path are recorded in `upstream/cli.json`.

The cited OpenSSH source has a composite BSD-style license. This adaptation is
licensed under CC BY 4.0.
