<!-- mant:tldr:start -->
# winget-mcp

> Print configuration for WinGet's local package-management MCP server.
> More information: https://learn.microsoft.com/windows/package-manager/winget/mcp-server-overview.

- Print the stdio server configuration to review and copy into an MCP client:

`winget mcp`

- Enable the WinGet MCP feature when the installed client exposes it:

`winget mcp --enable`

- Disable the feature:

`winget mcp --disable`
<!-- mant:tldr:end -->

# winget mcp

## Synopsis

```text
winget mcp [--enable | --disable]
```

With no option, `winget mcp` prints a JSON fragment containing the absolute
path of the bundled `winget-mcp` stdio server. It does not start a network
service or modify an MCP client configuration. The server exposes package
discovery and package installation/upgrade tools to compatible AI clients.

This is not the Microsoft Learn MCP Server. WinGet MCP can search and mutate
local package state; Microsoft Learn MCP is an optional documentation search
channel described in [Microsoft Learn MCP queries](microsoft-learn-mcp.md).

## Options

<!-- mant:entries role=option case=insensitive -->
- `--enable`: Enable WinGet's MCP feature for the installed client.
- `--disable`: Disable WinGet's MCP feature for the installed client.
- `-?`, `--help`: Display command help without printing a client configuration.
- `--wait`: Wait for a key press before exit; avoid in unattended execution.
- `--logs`, `--open-logs`: Open WinGet's log directory in the interactive desktop.
- `--verbose`, `--verbose-logs`: Enable verbose WinGet logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings without changing tool permissions.
- `--disable-interactivity`: Refuse interactive prompts.

`--enable` and `--disable` are mutually exclusive and cannot be combined with
another command-specific argument.

## Exposed MCP tools

<!-- mant:entries role=command case=sensitive -->
- `find-winget-packages`: Search installed or available packages; with `upgradeable=true`, list installed packages that have updates.
- `install-winget-package`: Install a package, or upgrade it when already installed; `upgradeOnly=true` refuses a new installation.

The implementation marks `find-winget-packages` read-only. It marks
`install-winget-package` destructive and non-idempotent. An MCP host should
therefore request explicit user approval for every installation or upgrade,
show the exact identifier and source, and preserve the returned result.

## Configure a client

First inspect the JSON emitted by the installed full-package WinGet client:

```powershell
$configuration = winget mcp
if ($LASTEXITCODE -ne 0) { throw "winget mcp failed: $LASTEXITCODE" }
$configuration
```

Copy the emitted `type` and `command` values into the chosen client's MCP
configuration using that client's documentation. Preserve the absolute path;
do not replace it with an unverified executable found through `PATH`.

Enabling the feature does not install or configure every possible MCP host.
Removing a client entry does not disable the WinGet feature. These are
separate state changes.

## Approval and automation boundaries

Before allowing an agent to call `install-winget-package`, require it to:

- search first and present the exact package ID, source, installed version,
  proposed version, and whether the operation is an install or upgrade;
- request explicit approval immediately before mutation;
- avoid inventing installer flags that the MCP tool does not expose;
- report cancellation, installer return state, and a post-install identity
  check instead of treating a tool call as proof of success.

MCP tool results are structured protocol data, but package metadata and
installer behavior still come from configured WinGet sources and publishers.

## PowerShell considerations

`winget mcp` emits JSON-shaped configuration as native stdout, not a PowerShell
object. Capture it only after checking `$LASTEXITCODE`; preserve backslashes and
the absolute command string when moving it into an MCP client's JSON file.

## Common mistakes

### Confusing package MCP with documentation MCP

Use WinGet MCP for package search and installation. Use Microsoft Learn MCP to
find current documentation pages. Installing either one does not provide the
other.

### Running the printed server command manually

The bundled server uses stdio framing and is meant to be started by an MCP
host. A quiet terminal or protocol output is not a conventional interactive
CLI failure.

### Granting blanket approval to installation

The install tool can run publisher installers and change machine state. Keep
approval per operation and enforce package/source identity rather than relying
on the natural-language request alone.

## Version and availability

The command and bundled server are new in WinGet 1.29. The no-option command
requires the full packaged App Installer layout so it can resolve the bundled
server. Availability can also be controlled by WinGet policy. Use the exact
configuration printed by the installed target client.

## Verification boundary

The command implementation, option exclusivity, emitted configuration shape,
stdio transport, and two exposed MCP tools were inspected in the official
WinGet source baseline. The server was not enabled, registered with a client,
or permitted to search, install, or upgrade packages on a Windows fixture.

## Related documents

- [Windows Package Manager](winget.exe.md)
- [winget install](winget-install.md)
- [winget search](winget-search.md)
- [Microsoft Learn MCP queries](microsoft-learn-mcp.md)

## Sources and license

This original guide was adapted from the official
[WinGet MCP Server overview](https://learn.microsoft.com/windows/package-manager/winget/mcp-server-overview)
and the WinGet `McpCommand` and `WinGetMCPServer` implementations. Exact
upstream revision and paths are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation and source code are licensed under MIT. This
adaptation is licensed under CC BY 4.0.
