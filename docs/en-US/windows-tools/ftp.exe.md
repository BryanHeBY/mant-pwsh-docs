<!-- mant:tldr:start -->
# ftp.exe

> Inspect the legacy Windows FTP client without sending credentials or data;
> FTP is plaintext, and `quote PASV` does not add client-side passive transfers.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ftp.

- Resolve the exact Windows client and record its file version:

`Get-Command ftp.exe -All -ErrorAction SilentlyContinue | Format-List Source, Version`

- Display launcher options without opening a network connection:

`ftp.exe -?`

- Test only TCP reachability to an approved endpoint; this does not prove FTP login or data-channel operation:

`Test-NetConnection -ComputerName "{{ftp.example.com}}" -Port {{21}} -InformationLevel Detailed`

- Discover encrypted, policy-approved transfer clients before designing new automation:

`Get-Command sftp.exe, scp.exe, curl.exe -All -ErrorAction SilentlyContinue | Format-Table Name, Source, Version`

<!-- mant:tldr:end -->

# ftp.exe

## Overview

`ftp.exe` is Windows' interactive and script-file FTP client. Launcher switches
control response/debug output, prompting, auto-login, globbing, binding, script
input and buffers. Once started, its own `ftp>` interpreter handles connection,
authentication, navigation, listing, transfer type, file transfer and session
state.

FTP normally exposes credentials, commands, filenames and content without
cryptographic protection. It is not SFTP (SSH File Transfer Protocol) or FTPS
(FTP over TLS). Prefer an approved encrypted client and pinned host/certificate
identity for new work. Retain `ftp.exe` only for a documented legacy endpoint on
an isolated trusted network with compensating controls.

## Command-family map

<!-- mant:entries role=command case=insensitive -->
- `ftp.exe`: Start the Windows FTP client or run one FTP command script.
- `open`: Connect the interpreter to an FTP server.
- `user`: Send a username and optional password/account during FTP login.
- `binary`: Select byte-preserving image transfer mode.
- `ascii`: Select text transfer mode with line-ending conversion.
- `get`: Download one remote file.
- `put`: Upload one local file.
- `mget`: Download multiple selected remote files.
- `mput`: Upload multiple selected local files.
- `delete`: Delete one remote file.
- `mdelete`: Delete multiple selected remote files.
- `dir`: Request a detailed remote directory listing.
- `ls`: Request an abbreviated remote listing.
- `lcd`: Change the local working directory.
- `cd`: Change the remote working directory.
- `quote`: Send one raw FTP command to the server.
- `status`: Display current interpreter settings.
- `help`: Display help for an FTP interpreter command.
- `quit`: Close the connection and exit the interpreter.

Launcher options are case-sensitive; in particular, `-a` and `-A` are distinct.

<!-- mant:entries role=option case=sensitive -->
- `-v`: Suppress display of remote-server responses.
- `-d`: Enable client/server protocol debugging, which can disclose sensitive data.
- `-i`: Disable interactive prompting during multi-file operations.
- `-n`: Suppress automatic login after the initial connection.
- `-g`: Disable local filename globbing.
- `-s`: Read FTP interpreter commands from a UTF-8 script file.
- `-a`: Bind the data connection using any local interface.
- `-A`: Request anonymous login instead of the ordinary automatic-login behavior.
- `-x`: Set the send buffer size on builds that support it.
- `-r`: Set the receive buffer size on builds that support it.
- `-b`: Set the asynchronous buffer count on builds that support it.
- `-w`: Set the transfer window size.
- `-?`: Display installed launcher syntax.

The interactive interpreter additionally groups its commands as follows:

- Session/authentication: `open`, `user`, `account`, `close`/`disconnect`,
  `bye`/`quit`.
- Local/remote navigation: `lcd`, `cd`, `pwd`, `dir`, `ls`.
- Transfers: `get`/`recv`, `mget`, `put`/`send`, `mput`, `append`, `delete`,
  `mdelete`, and rename operations.
- Representation and behavior: `ascii`, `binary`, `type`, `prompt`, `glob`,
  `hash`, `bell`, `verbose`, `debug`, `trace`, `status`, `sendport`.
- Raw/server and secondary-session controls: `quote`, `literal`, `proxy`.

Read `help <command>` inside the FTP interpreter on the exact Windows build.
Do not infer a subcommand's grammar from a Unix client with the same name.

## Common mistakes

### Putting credentials in `-s:` files, commands, logs, or process arguments

The script is ordinary text and commonly contains user/password lines. It can
leak through source control, backups, task definitions, EDR, error bundles and
ACL mistakes. Debug/trace and server responses can leak more. Do not generate a
temporary plaintext secret file as a workaround; migrate to an approved secret-
aware encrypted client.

### Assuming `quote PASV` enables passive mode

`quote` sends a raw command to the server. It does not teach Windows `ftp.exe`
to parse the passive response and open the returned client data connection.
Control-channel login may succeed while `dir`, `get`, or `put` hangs/fails at
the data channel. Do not disable firewalls or add broad inbound rules; select a
client/protocol that supports the approved network design.

### Confusing FTP, FTPS, and SFTP

Port 22 usually indicates SSH/SFTP, not FTP. TLS negotiation and certificate
validation are not added by using a different port. Record protocol, server
identity, authentication, encryption, host/certificate verification, proxy and
data-channel requirements explicitly.

### Forgetting `binary` for non-text content

ASCII mode can transform line endings and corrupt archives, executables, images
and signed artifacts. Set representation deliberately and verify size plus a
trusted digest/signature after transfer. A successful FTP reply is not content
authenticity.

### Combining `-i`, wildcards, and destructive multi-file commands

`-i` disables confirmation during multiple transfers; globbing expands local
names, while remote wildcard behavior is server-dependent. First list exact
remote and local selections, use a new isolated destination, set collision and
partial-file policy, and never automate broad `mdelete` from mutable listings.

### Parsing localized or multiline replies as a stable API

FTP has preliminary/intermediate/final numeric replies and separate data-channel
failures. Capture the complete transcript without secrets, require the expected
final reply and artifact, bound runtime, and clean partial files. Do not equate
process exit alone with every requested transfer succeeding.

### Misencoding an `-s:` script

Microsoft requires UTF-8 script files on Windows 8/Server 2012 and later and
forbids spaces in the `-s:<filename>` parameter form. BOM, line endings,
interpreter encoding and literal variable text can still break scripts. Prefer a
client with structured arguments/configuration rather than echo-built scripts.

## PowerShell boundaries

Invoke `ftp.exe` explicitly. PowerShell expands and quotes launcher arguments,
but the FTP interpreter later parses script lines independently; PowerShell
variables inside an existing FTP script are not expanded. `$LASTEXITCODE` must
be captured immediately, but artifact/transcript validation remains necessary.

## Version and platform differences

This page covers Windows `ftp.exe`, not similarly named Unix clients. Microsoft
documents case-sensitive launcher switches, UTF-8 script requirements on modern
Windows, IPv6 support and build-dependent buffer options. Server behavior,
firewalls/NAT, active data ports, locale and policy affect operation.
On exact System32 file version `10.0.26100.8115`, local `-?` help returned 2
with 22 nonempty normalized lines. Native error-stream output became 26
PowerShell 5.1 `ErrorRecord` objects after `2>&1`; preserve message text and
`$LASTEXITCODE` separately. No host, port, username, password, script, input,
data channel, file, transfer, rename, or deletion was supplied.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 FTP file version 10.0.26100.8115 -?
returned 2 with 22 normalized nonempty lines; native stderr became 26 Windows
PowerShell 5.1 ErrorRecord objects after 2>&1. No host, credential, script,
connection, or file operation ran; approved TCP reachability and isolated
protocol fixtures remain pending.

## Related documents
- OpenSSH and native curl: query `mant ssh --source cross-platform-tools` and
  `mant curl --source cross-platform-tools`.
- [netstat.exe](netstat.exe.md)
- [ping.exe](ping.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[FTP reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ftp)
and its linked interpreter-command reference. Passive-mode and scheduled-script
failures were cross-checked against high-demand practitioner discussions of
[Windows FTP passive mode](https://stackoverflow.com/questions/18643542/how-to-use-passive-ftp-mode-in-windows-command-prompt)
and [active data-channel hangs](https://stackoverflow.com/questions/30591387/my-ftp-batch-script-is-stuck-on-200-port-command-successful-and-doesnt-upload).
Microsoft sources govern syntax. Exact sources/licenses are in
`upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
