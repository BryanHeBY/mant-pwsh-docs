<!-- mant:tldr:start -->
# netsh

> Discover and inspect installed Windows network-shell contexts.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/netsh.

- List the contexts available on this computer:

`netsh.exe help`

- Ask for context-specific help without entering the interactive shell:

`netsh.exe {{context}} help`

- Show IPv4 interfaces through one complete non-interactive command:

`netsh.exe interface ipv4 show interfaces`

- Prefer typed PowerShell network objects when an equivalent cmdlet exists:

`Get-NetIPConfiguration | Select-Object InterfaceAlias, InterfaceIndex, IPv4Address, IPv4DefaultGateway, DNSServer`
<!-- mant:tldr:end -->

# netsh

## Overview

`netsh.exe` is a context-based Windows network administration shell. Installed
helper DLLs and optional roles determine its contexts and subcommands. It can
run one complete command, execute a script with `-f`, enter an interactive
context, or target some remote operations. Microsoft recommends PowerShell
networking cmdlets instead when an equivalent supported interface exists.

## Shell options

<!-- mant:entries role=option case=insensitive -->
- `-a FILE`: Run commands from an alias file and return to the Netsh shell afterward.
- `-c CONTEXT`: Enter one installed helper context before executing the remaining command.
- `-r COMPUTER`: Target a remote computer for contexts that implement remote operation.
- `-u DOMAIN\USER`: Select credentials for a supported remote operation.
- `-p PASSWORD`: Supply a remote password; use `*` for an interactive prompt instead of an inline secret.
- `-f FILE`: Execute a reviewed Netsh script file.

## Resolvable contexts

<!-- mant:entries role=command case=insensitive -->
- `interface`: Inspect or manage IPv4/IPv6 interfaces, addresses, DNS, TCP/UDP, tunnels, and port proxy.
- `wlan`: Inspect or manage Wi-Fi interfaces, networks, profiles, filters, reports, and tracing.
- `winsock`: Inspect or reset provider catalogs and related Winsock settings.
- `advfirewall`: Inspect or manage Windows Defender Firewall policy where this context is installed.
- `winhttp`: Inspect or manage WinHTTP proxy state, distinct from browser/user proxy state.
- `http`: Inspect or manage HTTP Service configuration according to installed context help.
- `trace`, `wfp`: Capture network tracing or inspect Windows Filtering Platform diagnostics with protected output handling.
- `dump`: Emit script-like configuration for contexts that implement it; read-only output can still contain sensitive topology.
- `help`: Display top-level or context-specific installed help.

## PowerShell boundaries

Call `netsh.exe` explicitly and place the full context path in one invocation.
Interactive prompt text is not executable syntax. Prefer typed NetTCPIP,
NetAdapter, NetSecurity, or DnsClient cmdlets when they cover the operation.

## Common mistakes

### Copying an interactive prompt line into PowerShell

Text after a prompt such as `netsh interface ipv4>` is a subcommand, not a
standalone executable. In automation, spell the full path in one invocation:
`netsh.exe interface ipv4 show interfaces`.

### Assuming every context exists everywhere

Client/server edition, installed features, roles, and helper DLLs change the
available surface. Discover with `netsh help` and context help on the target;
do not infer availability from another machine.

### Treating `dump` or `show` as universally read-only

Subcommand verbs are defined by their context. Read the exact context help and
official page; do not extrapolate parameters or safety from another context.

### Putting a password in arguments

For remote syntax, use `-p *` for a protected prompt rather than an inline
password. Even then, `-r` support is context-dependent and can require Remote
Registry, firewall rules, permissions, and services. Prefer approved remoting
with explicit target and authentication boundaries.

### Applying a generic “network reset” recipe

Reset, delete, set, add, and import operations can remove providers, routes,
firewall rules, profiles, or remote connectivity and may require restart.
Inventory the exact context, export supported configuration, identify rollback,
and work from a recoverable console before a change.

## Important context families

- `interface`: IPv4/IPv6 interfaces, addresses, DNS, TCP/UDP, tunnels, and
  port proxy; see [netsh-interface](netsh-interface.md).
- `wlan`: Wi-Fi interfaces, networks, profiles, filters, reports, and tracing;
  see [netsh-wlan](netsh-wlan.md).
- `winsock`: provider catalog and send autotuning; see
  [netsh-winsock](netsh-winsock.md).
- Other installed contexts can include `advfirewall`, `http`, `winhttp`,
  `trace`, `wfp`, `lan`, `ras`, `rpc`, `branchcache`, and server-role contexts.

## Version and platform differences

This executable is Windows-only. Contexts, commands, remote support, elevation,
and preferred PowerShell replacements vary by Windows release and installed
features.

## Related documents

- [ipconfig](ipconfig.md)
- [route](route.md)
- [microsoft-learn-mcp](microsoft-learn-mcp.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Network shell reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netsh).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
